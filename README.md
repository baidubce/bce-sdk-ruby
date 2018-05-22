# BOS Ruby SDK文档

# 概述

本文档主要介绍BOS Ruby SDK的安装和使用。在使用本文档前，您需要先了解BOS的一些基本知识，并已开通了BOS服务。若您还不了解BOS，可以参考[产品描述](ProductDescription.html)和[入门指南](GettingStarted-new.html)。

# 安装SDK工具包

## 运行环境

Ruby SDK包要求运行环境至少为Ruby 2.0 版本。

## 安装SDK

### 方式一：通过gem安装

```gem install baidubce-sdk```

### 方式二：通过bundler安装

1. 首先得确认安装了bundler，安装命令：```gem install bundler```
2. 在你的应用程序的Gemfile中添加：```gem 'baidubce-sdk', '~> 0.9.0'```，再运行```bundle install```

> **说明：** 用户在安装好gem之后，可以输入irb进入Ruby交互式命令行，输入```require 'baidubce/services/bos/bos_client'```，如果显示"true"则SDK已经顺利安装。[github源码链接](https://github.com/baidubce/bce-sdk-ruby)

**SDK目录结构**

```
│──baidubce-sdk.gemspec         //依赖的第三方gem 
├──lib
│   └── baidubce
│       ├── auth                //BCE签名相关
│       ├── http                //BCE的http通信相关
│       ├── services
│       │   └── bos                   //BOS主目录
│       │       ├── bos_client.rb     //BOS操作类，所有操作可以通过BosClient类可以完成
│       │       ├── bos_constants.rb  //BOS常量
│       │   └── sts                   //STS主目录
│       │       ├── sts_client.rb     //STS操作类
│       ├── exception.rb              //BCE客户端的异常
│       ├── retry_policy.rb           //BCE客户端重试机制
│       ├── bce_base_client.rb        //BCE公用客户端
│       └── utils                //BCE公用工具 
└──samples                      //使用示例
```

## 卸载SDK

卸载SDK时，执行```gem uninstall baidubce-sdk```，删除脚本中require和include语句即可。

# 初始化

## 确认Endpoint

- 在确认您使用SDK时配置的Endpoint时，可先阅读开发人员指南中关于[BOS访问域名](https://cloud.baidu.com/doc/BOS/DevRef.html#BOS.E8.AE.BF.E9.97.AE.E5.9F.9F.E5.90.8D)的部分，理解Endpoint相关的概念。

- 百度云目前开放了多区域支持，请参考[区域选择说明](../Reference/Regions.html)。

- 目前支持“华北-北京”、“华南-广州”和“华东-苏州”三个区域。北京区域：`http://bj.bcebos.com`，广州区域：`http://gz.bcebos.com`，苏州区域：`http://su.bcebos.com`。

  对应信息为：

  | 访问区域 | 对应Endpoint  |
  | -------- | ------------- |
  | BJ       | bj.bcebos.com |
  | GZ       | gz.bcebos.com |
  | SU       | su.bcebos.com |

## 获取密钥

要使用百度云BOS，您需要拥有一个有效的 AK（Access Key ID）和SK(Secret Access Key)用来进行签名认证。AK/SK是由系统分配给用户的，均为字符串，用于标识用户，为访问BOS做签名验证。

可以通过如下步骤获得并了解您的AK/SK信息：

1. [注册百度云账号](https://login.bce.baidu.com/reg.html?tpl=bceplat&from=portal)
2. [创建AK/SK](https://console.bce.baidu.com/iam/?_=1513940574695#/iam/accesslist)

## 新建BosClient

BosClient是BOS服务的客户端，为开发者与BOS服务进行交互提供了一系列的方法。

### 使用AK/SK新建BosClient

通过AK/SK方式访问BOS，用户可以参考如下代码新建一个BosClient：

```
#使用Ruby SDK，引入bos_client和Baidubce模块
require 'baidubce/services/bos/bos_client'
include Baidubce

#配置client参数
credentials = Auth::BceCredentials.new(
    "accessKeyId",
    "secretAccessKey"
)

conf = BceClientConfiguration.new(
    credentials,
    "ENDPOINT"
)
#新建BosClient
client = Services::BosClient.new(conf)
```

> **注意：**
>
> 1. 在上面代码中，`accessKeyId`对应控制台中的“Access Key ID”，`secretAccessKey`对应控制台中的“Access Key Secret”，获取方式请参考《操作指南 [管理ACCESSKEY](GettingStarted.html#管理ACCESSKEY)》。
> 2. 如果用户需要自己指定域名，可以通过传入ENDPOINT参数来指定，`ENDPOINT`参数需要用指定区域的域名来进行定义，如服务所在区域为北京，则为`http://bj.bcebos.com`。

### 使用STS创建BosClient

#### 申请STS token

BOS可以通过STS机制实现第三方的临时授权访问。STS（Security Token Service）是百度云提供的临时授权服务。通过STS，您可以为第三方用户颁发一个自定义时效和权限的访问凭证。第三方用户可以使用该访问凭证直接调用百度云的API或SDK访问百度云资源。

通过STS方式访问BOS，用户需要先通过STS的client申请一个认证字符串，申请方式可参见[百度云STS使用介绍](https://cloud.baidu.com/doc/BOS/API.html#STS.E7.AE.80.E4.BB.8B)。

#### 用STS token新建BOSClient

申请好STS后，可将STStoken配置到BosClient中，用户可以参考如下代码新建一个BosClient：

1. 首先进行STS的endpoint配置。STS的配置示例如下：

   ```
   require 'baidubce/services/sts/sts_client'
   require 'baidubce/services/bos/bos_client'
   
   credentials = Baidubce::Auth::BceCredentials.new(
       "your ak",
       "your sk"
   )
   
   sts_conf = Baidubce::BceClientConfiguration.new(
       credentials,
       "http://sts.bj.baidubce.com"
   )
   ```

2. StsClient的示例代码如下：

   ```
   # 新建StsClient
   sts_client = Baidubce::Services::StsClient.new(sts_conf)
   acl = {
               id: '8c47a952db4444c5a097b41be3f24c94',
               accessControlList: [
                   {
                       eid: 'shj',
                       service: 'bce:bos',
                       region: 'bj',
                       effect: 'Allow',
                       resource: ["bos-demo"],
                       permission: ["READ"]
                   }
               ]
   }
   
   # durationSeconds为失效时间，如果为非int值或者不设置该参数，会使用默认的12小时作为失效时间
   # sts_client.get_session_token(acl, "test")
   # sts_client.get_session_token(acl, 1024)
   sts_response = sts_client.get_session_token(acl)
   
   sts_ak = sts_response["accessKeyId"]
   sts_sk = sts_response['secretAccessKey']
   token = sts_response['sessionToken']
   ```

   **注意：**其中acl指用户定义的acl，语法请参照[访问控制](API.html#访问控制)。

3. 将获取到的accessKeyID/secretAccessKey/sessionToken用于新建BosClient。

   ```
    # 使用获取到的ak, sk, token新建BosClient访问BOS
   sts_credentials = Baidubce::Auth::BceCredentials.new(
       sts_ak,
       sts_sk,
       token
   )
   
   conf = Baidubce::BceClientConfiguration.new(
       sts_credentials,
       "http://bj.bcebos.com",
   )
   
   client = Baidubce::Services::BosClient.new(conf)
   ```

   **注意：**目前使用STS配置client时，无论对应BOS服务的endpoint在哪里，endpoint都需配置为`http://sts.bj.baidubce.com`。

## 配置HTTPS协议访问BOS

BOS支持HTTPS传输协议，您可以通过如下两种方式在BOS Ruby SDK中使用HTTPS访问BOS服务：

- 在`endpoint`中指定HTTPS:

  ```
  # 配置client参数
  credentials = Auth::BceCredentials.new(
      "accessKeyId",
      "secretAccessKey"
  )
  
  conf = BceClientConfiguration.new(
      credentials,
      "https://bj.bcebos.com"
  )
  # 新建BosClient
  client = Services::BosClient.new(conf)
  ```

- 通过在`protocol`中指定`https`来设置HTTPS协议:

  ```
  # 配置client参数
  credentials = Auth::BceCredentials.new(
      "accessKeyId",
      "secretAccessKey"
  )
  
  options = {
      'protocol' => 'https'
  }
  
  conf = BceClientConfiguration.new(
      credentials,
      "bj.bcebos.com",
      options
  )
  
  # 新建BosClient
  client = Services::BosClient.new(conf)
  ```

  > **注意：**如果您在指定了endpoint的scheme的同时指定了protocol参数，则以endpoint为准。

## 配置BosClient

### 设置自定义参数

Ruby SDK默认设置了一些基本参数，若用户想要对参数的值进行修改，可以创建自身的参数配置，并在构造BosClient的时候传入，传入代码参考如下：

```
#配置自定义参数
options = {
    'protocol' => 'https',
    'read_timeout_in_millis' => 1000 * 60,
    'region' => 'bj'
}

conf = BceClientConfiguration.new(
    credentials,
    "http://bj.bcebos.com",
    options
)

#新建BosClient
client = Services::BosClient.new(conf)
```

参数说明如下：

| 参数                   | 说明                                           | 默认值                                                       |
| ---------------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| protocol               | 协议                                           | http                                                         |
| region                 | 区域                                           | bj                                                           |
| open_timeout_in_millis | 请求超时时间（单位：毫秒）                     | 50 * 1000                                                    |
| read_timeout_in_millis | 通过打开的连接传输数据的超时时间（单位：毫秒） | 10 * 60 * 1000（设置时需要对文件大小和网速进行评估，否则上传大文件时会产生超时） |
| send_buf_size          | 发送缓冲区大小                                 | 1024 * 1024                                                  |
| recv_buf_size          | 接收缓冲区大小                                 | 10 \* 1024 \* 1024                                           |

### 设置可选参数

BosClient将可选的参数封装到`options`中，每一个方法具有的可选参数详见具体的接口使用方法介绍，现以`put_object_from_string`方法为例，参考如下代码实现设置可选参数：

```
# 利用options在上传Object的时候传入指定参数
user_metadata = { "key1" => "value1" }
options = { Http::CONTENT_TYPE => 'string',
            "key2" => "value2",
            'Content-Disposition' => 'inline',
            'user-metadata' => user_metadata
}

client.put_object_from_string(bucket_name, object_name, "obj_str", options)
```

## Bucket管理

Bucket既是BOS上的命名空间，也是计费、权限控制、日志记录等高级功能的管理实体。

- Bucket名称在所有区域中具有全局唯一性，且不能修改。

  > **说明：**
  >
  > - 百度云目前开放了多区域支持，请参考[区域选择说明](../Reference/Regions.html)。
  > - 目前支持“华北-北京”、“华南-广州”和“华东-苏州”三个区域。北京区域：`http://bj.bcebos.com`，广州区域：`http://gz.bcebos.com`，苏州区域：`http://su.bcebos.com`。

- 存储在BOS上的每个Object都必须包含在一个Bucket中。

- 一个用户最多可创建100个Bucket，但每个Bucket中存放的Object的数量和大小总和没有限制，用户不需要考虑数据的可扩展性。

## Bucket权限管理

### 设置Bucket的访问权限

如下代码将Bucket的权限设置为了private：

```
client.set_bucket_canned_acl(bucket_name, "private")
```

canned acl支持三种权限，分别为：`private`、`public-read`、`public-read-write`。关于权限的具体内容可以参考《BOS API文档 [使用CannedAcl方式的权限控制](API.html#使用CannedAcl方式的权限控制)》。

### 设置指定用户对Bucket的访问权限

BOS提供set_bucket_acl方法来实现指定用户对Bucket的访问权限设置，可以参考如下代码实现：

```
acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                      {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
        'permission' => ['FULL_CONTROL']
}]

client.set_bucket_acl(bucket_name, acl)
```

> **注意：**
>
> 1. permission中的权限设置包含三个值：`READ`、`WRITE`、`FULL_CONTROL`，它们分别对应相关权限。具体内容可以参考《BOS API文档 [上传ACL文件方式的权限控制](API.html# 上传ACL文件方式的权限控制)》。
> 2. 设置两个以上（含两个）被授权人时，请参考以上示例的格式，若将数组合并会返回报错。

### 设置更多Bucket访问权限

1. 通过设置referer白名单方式设置防盗链

   ```
   acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                         {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
           'permission' => ['FULL_CONTROL'],
           'condition' => {
               'referer' => {
                   'stringLike' => ['http://www.abc.com/*'],
                   'stringEquals' => ['http://www.abc.com']
                }
           }
   }]
   
   client.set_bucket_acl(bucket_name, acl)
   ```

2. 限制客户端IP访问，只允许部分客户端IP访问

   ```
   acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                         {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
           'permission' => ['FULL_CONTROL'],
           'condition' => {
               "ipAddress" => [
                     '192.168.0.0/16',
                     '192.169.0.*',
                     '192.170.0.5'
               ]
           }
   }]
   
   client.set_bucket_acl(bucket_name, acl)
   ```

### 设置STS临时token权限

对于通过STS方式创建的临时访问身份，管理员也可进行专门的权限设定。
STS的简介及设置临时权限的方式可参见[临时授权访问](https://cloud.baidu.com/doc/BOS/API.html#.E4.B8.B4.E6.97.B6.E6.8E.88.E6.9D.83.E8.AE.BF.E9.97.AE)。

使用BOS Ruby SDK设置STS临时token权限可参考[使用STS创建BosClient](#使用STS创建BosClient)

### 查看Bucket的权限

如下代码可以查看Bucket的权限：

```
client.get_bucket_acl(bucket_name)
```

`get_bucket_acl`方法返回的解析类中可供调用的参数有：

| 参数       | 说明                 |
| ---------- | -------------------- |
| owner      | Bucket owner信息     |
| id         | Bucket owner的用户ID |
| acl        | 标识Bucket的权限列表 |
| grantee    | 标识被授权人         |
| -id        | 被授权人ID           |
| permission | 标识被授权人的权限   |

## 查看Bucket所属的区域

Bucket Location即Bucket Region，百度云支持的各region详细信息可参见[区域选择说明](https://cloud.baidu.com/doc/Reference/Regions.html)。

如下代码可以获取该Bucket的Location信息：

```
client.get_bucket_location(bucket_name)
```

## 新建Bucket

如下代码可以新建一个Bucket：

```
bucketName = "your_bucket";

# Bucket是否存在，若不存在创建Bucket
client.create_bucket(bucket_name) unless client.does_bucket_exist(bucket_name)
```

> **注意：**
> 由于Bucket的名称在所有区域中是唯一的，所以需要保证bucketName不与其他所有区域上的Bucket名称相同。
>
> Bucket的命名有以下规范：
>
> - 只能包括小写字母，数字，短横线（-）。
> - 必须以小写字母或者数字开头。
> - 长度必须在3-63字节之间。

通过上述代码创建的bucket，权限是私有读写，存储类型是标准类型（Standard）。用户在控制台创建Bucket时可以指定Bucket权限和存储类型。

## 列举Bucket

如下代码可以列出用户所有的Bucket：

```
buckets = client.list_buckets()
```

## 删除Bucket

### 删除指定Bucket

如下代码可以删除一个Bucket：

```
bucketName = "your_bucket";
client.delete_bucket(bucketName)
```

> **注意：**
>
> - 在删除前需要保证此Bucket下的所有Object和未完成的三步上传Part已经被删除，否则会删除失败。
> - 在删除前确认该Bucket没有开通跨区域复制，不是跨区域复制规则中的源Bucket或目标Bucket，否则不能删除。

### 删除所有Bucket

将`delete_bucket`和`list_buckets`函数结合，可以删除全部Bucket，参考代码如下：

```
# 列出全部Bucket
buckets = client.list_buckets()['buckets']

# 遍历删除全部Bucket
buckets.each do |bucket|
    while true
        options = {}
        res = client.list_objects(bucket['name'], options)
        res['contents'].each do |object|
            client.delete_object(bucket['name'], object['key'])
        end
        if res['isTruncated']
            options[:marker] = res['nextMarker']
        else
            break
        end
    end
    client.delete_bucket(bucket['name'])
end
```

## 判断Bucket是否存在

若用户需要判断某个Bucket是否存在，则如下代码可以做到：

```
client.does_bucket_exist(bucketName)
```

# 文件管理

## 上传文件

在BOS中，用户操作的基本数据单元是Object。Object包含Key、Meta和Data。其中，Key是Object的名字；Meta是用户对该Object的描述，由一系列Name-Value对组成；Data是Object的数据。

BOS Ruby SDK提供了丰富的文件上传接口，可以通过以下方式上传文件：

- 简单上传
- 追加上传
- 分片上传
- 断点续传上传

### 简单上传

BOS在简单上传的场景中，支持以指定文件形式、以数据流方式、以二进制串方式、以字符串方式执行Object上传，请参考如下代码：

```
# 以数据流形式上传Object
client.put_object(bucket_name, object_name, data)

# 从字符串中上传Object
client.put_object_from_string(bucket_name, object_name, "string")

# 从文件中直接上传Object
client.put_object_from_file(bucket_name, object_name, file_path)
```

Object以文件的形式上传到BOS中，putObject相关接口支持不超过5GB的Object上传。在PutObject请求处理成功后，BOS会在Header中返回Object的ETag作为文件标识。

**设置文件元信息**

文件元信息(Object Meta)，是对用户在向BOS上传文件时，同时对文件进行的属性描述，主要分为分为两种：设置HTTP标准属性（HTTP Headers）和用户自定义的元信息。 

**设定Object的Http Header**

BOS Ruby SDK本质上是调用后台的HTTP接口，因此用户可以在上传文件时自定义Object的Http Header。常用的http header说明如下：

| 名称                | 描述                                                         | 默认值                   |
| ------------------- | ------------------------------------------------------------ | ------------------------ |
| Content-MD5         | 文件数据校验，设置后BOS会启用文件内容MD5校验，把您提供的MD5与文件的MD5比较，不一致会抛出错误 | 无                       |
| Content-Type        | 文件的MIME，定义文件的类型及网页编码，决定浏览器将以什么形式、什么编码读取文件。如没有指，BOS则根据文件的扩展名自动生成，如文件没有扩展名则填默认值 | application/octet-stream |
| Content-Disposition | 指示MINME用户代理如何显示附加的文件，打开或下载，及文件名称  | 无                       |
| Content-Length      | 上传的文件的长度，超过流/文件的长度会截断，不足为实际值      | 流/文件时间长度          |
| Expires             | 缓存过期时间                                                 | 无                       |
| Cache-Control       | 指定该Object被下载时的网页的缓存行为                         | 无                       |

参考代码如下：

```
options = { Http::CONTENT_TYPE => 'string',
            Http::CONTENT_MD5 => 'md5',
            Http::CONTENT_DISPOSITION => 'inline',
            'key1' => 'value1'
}

client.put_object_from_string(bucket_name, object_name, "string", options)
```

**用户自定义元信息**

BOS支持用户自定义元数据来对Object进行描述。如下代码所示：

```
options = { 
            'user-metadata' => { "key1" => "value1" }
}

client.put_object_from_string(bucket_name, object_name, "string", options)
```

> **提示：**
>
> - 在上面代码中，用户自定义了一个名字为”key1”，值为”value1”的元数据
> - 当用户下载此Object的时候，此元数据也可以一并得到
> - 一个Object可以有多个类似的参数，但所有的User Meta总大小不能超过2KB

**上传Object时设置存储类型**

BOS支持标准存储, 低频存储和冷存储，上传Object并存储为低频存储类型通过指定StorageClass实现，三种存储类型对应的参数如下：

| 存储类型 | 参数        |
| -------- | ----------- |
| 标准存储 | STANDRAD    |
| 低频存储 | STANDARD_IA |
| 冷存储   | COLD        |

以低频存储为例，代码如下：

```
# 上传一个低频object（默认为标准object）
client.put_object_from_file(bucket_name, object_name, file_path, Http::BOS_STORAGE_CLASS => 'STANDARD_IA')
```

putObject请求处理成功后，BOS会在Header中返回Object的Content-MD5，用户可以根据这个参数来对文件进行校验。

### 追加上传

上文介绍的简单上传方式，创建的Object都是Normal类型，用户不可再进行追加写，这在日志、视频监控、视频直播等数据复写较频繁的场景中使用不方便。

正因如此，百度云BOS特别支持了AppendObject，即以追加写的方式上传文件。通过AppendObject操作创建的Object类型为Appendable Object，可以对该Object追加数据。AppendObject大小限制为0~5G。

通过AppendObject方式上传示例代码如下：

```
# 从字符串上传一个appendable object
client.append_object_from_string(bucket_name, object_name, "string")

# 从offset处开始追加写
client.append_object_from_string(bucket_name, object_name, "append_str", 'offset' => 6)
```

### 分块上传

除了通过简单上传几追加上传方式将文上传件到BOS以外，BOS还提供了另外一种上传模式 —— Multipart Upload。用户可以在如下的应用场景内（但不仅限于此），使用Multipart Upload上传模式，如：

- 需要支持断点上传。
- 上传超过5GB大小的文件。
- 网络条件较差，和BOS的服务器之间的连接经常断开。
- 需要流式地上传文件。
- 上传文件之前，无法确定上传文件的大小。

下面将一步步介绍Multipart Upload的实现。假设有一个文件，本地路径为 `/path/to/file.zip` ，由于文件比较大，将其分块传输到BOS中。

#### 初始化Multipart Upload

使用`initiate_multipart_upload` 方法来初始化一个分块上传事件：

```
upload_id = client.initiate_multipart_upload(bucket_name, object_name)["uploadId"]
```

`initiate_multipart_upload`的返回结果中含有 `uploadId` ，它是区分分块上传事件的唯一标识，在后面的操作中，我们将用到它。

#### 上传低频存储类型Object的初始化

初始化低频存储的一个分块上传事件：

```
options = { 
            Http::BOS_STORAGE_CLASS => 'STANDARD_IA'
}
client.initiate_multipart_upload(bucket_name, object_name, options)
```

#### 上传冷存储类型Object的初始化

初始化冷存储的一个分块上传事件：

```
options = { 
            Http::BOS_STORAGE_CLASS => 'COLD'
}
client.initiate_multipart_upload(bucket_name, object_name, options)
```

#### 上传分块

接着，把文件分块上传。

```
# 设置分块的开始偏移位置
left_size = File.open(multi_file, "r").size()
offset = 0
part_number = 1
part_list = []

while left_size > 0 do
    part_size = 5 * 1024 * 1024
    if left_size < part_size
        part_size = left_size
    end

    response = client.upload_part_from_file(
        bucket_name, object_name, upload_id, part_number, part_size, multi_file, offset)
    left_size -= part_size
    offset += part_size
    # your should store every part number and etag to invoke complete multi-upload
    part_list << {
        "partNumber" => part_number,
        "eTag" => response['etag']
    }
    part_number += 1
end
```

上面代码的核心是调用 `UploadPart` 方法来上传每一个分块，但是要注意以下几点：

- UploadPart 方法要求除最后一个Part以外，其他的Part大小都要大于等于5MB。但是Upload Part接口并不会立即校验上传Part的大小；只有当Complete Multipart Upload的时候才会校验。
- 为了保证数据在网络传输过程中不出现错误，建议您在`UploadPart`后，使用每个分块BOS返回的Content-MD5值分别验证已上传分块数据的正确性。当所有分块数据合成一个Object后，不再含MD5值。
- Part号码的范围是1~10000。如果超出这个范围，BOS将返回InvalidArgument的错误码。
- 每次上传Part时都要把流定位到此次上传块开头所对应的位置。
- 每次上传Part之后，BOS的返回结果会包含`eTag`和`partNumber`，需要保存到`part_list`中。`part_list`类型是array，里面每个元素是个hash，每个hash包含两个关键字，一个是partNumber, 一个是eTag；在后续完成分块上传的步骤中会用到它。

#### 完成分块上传

如下代码所示，完成分块上传：

```
client.complete_multipart_upload(bucket_name, object_name, upload_id, part_list)
```

上面代码中的 `part_list` 是第二步中保存的part列表，BOS收到用户提交的Part列表后，会逐一验证每个数据Part的有效性。当所有的数据Part验证通过后，BOS将把这些数据part组合成一个完整的Object。

#### 取消分块上传

用户可以使用`abort_multipart_upload`方法取消分块上传。

```
client.abort_multipart_upload(bucket_name, object_name, upload_id)
```

#### 获取未完成的分块上传事件

用户可以使用`list_multipart_uploads`方法获取Bucket中未完成的分块上传事件。

```
response = client.list_multipart_uploads(bucket_name)
puts response['bucket']
puts response['uploads'][0]['key']
```

> **注意：**
>
> 1. 默认情况下，如果Bucket中的分块上传事件的数目大于1000，则只会返回1000个Object，并且返回结果中IsTruncated的值为True，同时返回NextKeyMarker作为下次读取的起点。
> 2. 若想返回更多分块上传事件的数目，可以使用KeyMarker参数分次读取。

**获取所有已上传的块信息**

用户可以使用`list_parts`方法获取某个上传事件中所有已上传的块：

```
response = client.list_parts(bucket_name, object_name, upload_id)
puts response['bucket']
puts response['uploads'][0]['key']
```

> **注意：**
>
> 1. 默认情况下，如果Bucket中的分块上传事件的数目大于1000，则只会返回1000个Object，并且返回结果中IsTruncated的值为True，同时返回NextPartNumberMarker作为下次读取的起点。
> 2. 若想返回更多分块上传事件的数目，可以使用PartNumberMarker参数分次读取。

### 断点续传上传

当用户向BOS上传大文件时，如果网络不稳定或者遇到程序崩等情况，则整个上传就失败了，失败前已经上传的部分也作废，用户不得不重头再来。这样做不仅浪费资源，在网络不稳定的情况下，往往重试多次还是无法完成上传。
基于上述场景，BOS提供了断点续传上传的能力:

- 当网络情况一般的情况下，建议使用三步上传方式，将object分为1Mb的块，参考[分块上传](#分块上传)。
- 当您的网络情况非常差，推荐使用appendObject的方式进行断点续传，每次append 较小数据256kb，参考[追加上传](# 追加上传)。

> **提示**
>
> - 断点续传是分片上传的封装和加强，是用分片上传实现的；
> - 文件较大或网络环境较差时，推荐使用分片上传；

## 下载文件

BOS Ruby SDK提供了丰富的文件下载接口，用户可以通过以下方式从BOS中下载文件：

- 简单流式下载
- 下载到本地文件
- 断点续传下载
- 范围下载

### 简单流式下载

用户可以通过如下代码将Object读取到一个流中：

```
client.get_object_as_string(bucket_name, object_name)
```

### 直接下载Object到文件

用户可以参考如下代码将Object下载到指定文件：

```
client.get_object_to_file(bucket_name, object_name, file_name)
```

### 范围下载

为了实现更多的功能，可以通过配置`RANGE`参数来指定下载范围，实现更精细化地获取Object。如果指定的下载范围是0 - 100，则返回第0到第100个字节的数据，包括第100个，共101字节的数据，即[0, 100]。`RANGE`参数的格式为`array(offset, endset)`其中两个变量为长整型，单位为字节。用户也可以用此功能实现文件的分段下载和断点续传。

```
range = [0,100]
client.get_object_as_string(bucket_name, object_name, range)
```

### 其他使用方法

#### 获取Object的存储类型

Object的storage class属性分为`STANDARD`(标准存储), `STANDARD_IA`(低频存储)和`COLD`(冷存储)，通过如下代码可以实现：

```
response = client.get_object_meta_data(bucket_name, object_name)
puts response[Http::BOS_STORAGE_CLASS];
```

#### 只获取ObjectMetadata

用户也可通过`get_object_meta_data`方法可以只获取ObjectMetadata而不获取Object的实体。如下代码所示：

```
response = client.get_object_meta_data(bucket_name, object_name)
puts response['etag'];
```

`get_object_meta_data`方法返回的解析类中可供调用的参数有：

| 参数                | 说明                                                    |
| ------------------- | ------------------------------------------------------- |
| content-type        | Object的类型                                            |
| content-length      | Object的大小                                            |
| content-md5         | Object的MD5                                             |
| etag                | Object的HTTP协议实体标签                                |
| x-bce-storage-class | Object的存储类型                                        |
| user-metadata       | 如果在PutObject指定了userMetadata自定义meta，则返回此项 |

## 变更文件存储等级

上文中已提到，BOS支持为文件赋予STANDARD(标准存储), STANDARD_IA(低频存储)和COLD(冷存储)三种存储类型。同时，BOS Ruby SDK也支持用户对特定文件执行存储类型变更的操作。

涉及到的参数如下：

| 参数                | 说明                                                         |
| ------------------- | ------------------------------------------------------------ |
| x-bce-storage-class | 指定Object的存储类型，STANDARD_IA代表低频存储，COLD代表冷存储，不指定时默认是标准存储类型。 |

示例如下：

```
options = { 
            Http::BOS_STORAGE_CLASS => 'STANDARD_IA'
}

# 标准存储转低频存储
client.copy_object(bucket_name, object_name, bucket_name, object_name, options)
puts client.get_object_meta_data(bucket_name, object_name)[Http::BOS_STORAGE_CLASS]

options = { 
            Http::BOS_STORAGE_CLASS => 'COLD'
}

# 低频存储转冷存储
client.copy_object(bucket_name, object_name, bucket_name, object_name, options)
puts client.get_object_meta_data(bucket_name, object_name)[Http::BOS_STORAGE_CLASS]
```

## 获取文件下载URL

用户可以参考如下代码获取Object的URL：

```
options = { 'expiration_in_seconds' => 360,
            'timestamp' => Time.now.to_i
}

puts client.generate_pre_signed_url(bucket_name, object_name, options)
```

> **说明：**
>
> - 用户在调用该函数前，需要手动设置endpoint为所属区域域名。百度云目前开放了多区域支持，请参考[区域选择说明](../Reference/Regions.html)。目前支持“华北-北京”、“华南-广州”和“华东-苏州”三个区域。北京区域：`http://bj.bcebos.com`，广州区域：`http://gz.bcebos.com`，苏州区域：`http://su.bcebos.com`。
> - `EXPIRATION_IN_SECONDS`为指定的URL有效时长，时间从当前时间算起，为可选参数，不配置时系统默认值为1800秒。如果要设置为永久不失效的时间，可以将`expiration_in_seconds`参数设置为 -1，不可设置为其他负数。
> - `TIMESTAMP`为可选参数，不配置时，系统默认TIMESTAMP为当前时间。
> - 如果预期获取的文件时公共可读的，则对应URL链接可通过简单规则快速拼接获取: http://bucketName.$region.bcebos.com/$bucket/$object

## 列举存储空间中的文件

BOS SDK支持用户通过以下两种方式列举出object：

- 简单列举
- 通过参数复杂列举

除此之外，用户还可在列出文件的同时模拟文件夹

### 简单列举

当用户希望简单快速列举出所需的文件时，可通过listObjects方法获取Bucket中的Object列表。

```
client.list_objects(bucket_name)
```

> **注意：**
>
> 1. 默认情况下，如果Bucket中的Object数量大于1000，则只会返回1000个Object。
> 2. 若想增大返回Object的数目，可以使用Marker参数分次读取。

### 通过参数复杂列举

除上述简单列举外，用户还可通过`options`配置可选参数来实现各种灵活的查询功能。可设置的参数如下：

| 参数      | 功能                                                         |
| --------- | ------------------------------------------------------------ |
| PREFIX    | 限定返回的object key必须以prefix作为前缀                     |
| DELIMITER | 是一个用于对Object名字进行分组的字符所有名字包含指定的前缀且第一次出现。Delimiter字符之间的Object作为一组元素: CommonPrefixes |
| MARKER    | 设定结果从marker之后按字母排序的第一个开始返回               |
| MAX_KEYS  | 限定此次返回object的最大数，如果不设定，默认为100，max-keys取值不能大于1000 |

> **注意：**
>
> 1. 如果有Object以Prefix命名，当仅使用Prefix查询时，返回的所有Key中仍会包含以Prefix命名的Object，详见[递归列出目录下所有文件](#递归列出目录下所有文件)。
> 2. 如果有Object以Prefix命名，当使用Prefix和Delimiter组合查询时，返回的所有Key中会有Null，Key的名字不包含Prefix前缀，详见[查看目录下的文件和子目录](# 查看目录下的文件和子目录)。

下面我们分别以几个案例说明通过参数列举的方法：

**指定最大返回条数**

```
# 指定最大返回条数为500
options = { 
            maxKeys: 500
}
puts client.list_objects(bucket_name, options)
```

**返回指定前缀的object**

```
# 指定返回前缀为usr的object
options = { 
            prefix: 'usr'
}
puts client.list_objects(bucket_name, options)
```

**从指定Object后返回**

```
# 用户可以定义不包括某object，从其之后开始返回
options = { 
            marker: 'object'
}
puts client.list_objects(bucket_name, options)
```

**分页获取所有Object**

用户可设置每页最多500条记录

```
options = { 
            maxKeys: 500
}

is_truncated = true
while is_truncated 
    res = client.list_objects(bucket_name, options)
    is_truncated = res['isTruncated']
    options[:marker] = res['nextMarker'] unless res['nextMarker'].nil?
end
```

**分页获取所有特定Object后的结果**

用户可设置每页最多500条记录，并从某特定object之后开始获取

```
options = { 
            maxKeys: 5,
            marker: 'object'
}

is_truncated = true
while is_truncated 
    res = client.list_objects(bucket_name, options)
    is_truncated = res['isTruncated']
    options[:marker] = res['nextMarker'] unless res['nextMarker'].nil?
end
```

`listObjects`方法返回的解析类中可供调用的参数有：

| 参数          | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| name          | Bucket名称                                                   |
| prefix        | 匹配以prefix开始到第一次出现Delimiter字符之间的object作为一组元素返回 |
| marker        | 本次查询的起点                                               |
| maxKeys       | 请求返回的最大数目                                           |
| isTruncated   | 指明是否所有查询都返回了；false-本次已经返回所有结果，true-本次还没有返回所有结果 |
| contents      | 返回的一个Object的容器                                       |
| +key          | Object名称                                                   |
| +lastModified | 此Object最后一次被修改的时间                                 |
| +eTag         | Object的HTTP协议实体标签                                     |
| +storageClass | Object的存储形态                                             |
| +size         | Object的内容的大小（字节数）                                 |
| +owner        | Object对应Bucket所属用户信息                                 |
| ++id          | Bucket Owner的用户ID                                         |
| ++displayName | Bucket Owner的名称                                           |

### 模拟文件夹功能

在BOS的存储结果中是没有文件夹这个概念的，所有元素都是以Object来存储，但BOS的用户在使用数据时往往需要以文件夹来管理文件。

因此，BOS提供了创建模拟文件夹的能力，其本质上来说是创建了一个size为0的Object。对于这个Object可以上传下载，只是控制台会对以”/“结尾的Object以文件夹的方式展示。

用户可以通过 Delimiter 和 Prefix 参数的配合模拟出文件夹功能。Delimiter 和 Prefix 的组合效果是这样的：

如果把 Prefix 设为某个文件夹名，就可以罗列以此 Prefix 开头的文件，即该文件夹下递归的所有的文件和子文件夹（目录）。文件名在Contents中显示。

如果再把 Delimiter 设置为 “/” 时，返回值就只罗列该文件夹下的文件和子文件夹（目录），该文件夹下的子文件名（目录）返回在 CommonPrefixes 部分，子文件夹下递归的文件和文件夹不被显示。

如下是几个应用方式：

#### 列出Bucket内所有文件

当用户需要获取Bucket下的所有文件时，可以参考[分页获取所有Object](#分页获取所有Object)

#### 递归列出目录下所有文件

可以通过设置 `Prefix` 参数来获取dir目录下所有的文件：

```
options = { 
            prefix: 'dir/'
}

is_truncated = true
while is_truncated 
    res = client.list_objects(bucket_name, options)
    is_truncated = res['isTruncated']
    options[:marker] = res['nextMarker'] unless res['nextMarker'].nil?
end
```

#### 查看目录下的文件和子目录

在 `Prefix` 和 `Delimiter` 结合的情况下，可以列出dir目录下的文件和子目录：

```
options = { 
            prefix: 'dir/',
            delimiter: '/'
}

is_truncated = true
while is_truncated 
    res = client.list_objects(bucket_name, options)
    is_truncated = res['isTruncated']
    options[:marker] = res['nextMarker'] unless res['nextMarker'].nil?
end
```

### 列举Bucket中object的存储属性

当用户完成上传后，如果需要查看指定Bucket中的全部Object的storage class属性，可以通过如下代码实现：

```
res = client.list_objects(bucket_name)

res['contents'].each { |obj| puts obj['storageClass'] } 
```

## Object权限控制

### 设置Object的访问权限

如下代码将Object的权限设置为了private：

```
client.set_object_canned_acl(bucket_name, object_name, Http::BCE_ACL  => 'private')
```

关于权限的具体内容可以参考《BOS API文档 [Object权限控制](API.html#Object权限控制)》。

### 设置指定用户对Object的访问权限

BOS提供`set_object_acl`方法和`set_object_canned_acl`方法来实现指定用户Object的访问权限设置，可以参考如下代码实现：

1. 通过`set_object_canned_acl`的`x-bce-grant-read`和`x-bce-grant-full-control`设置指定用户的访问权限

   ```
   id_permission = "id=\"8c47a952db4444c5a097b41be3f24c94\",id=\"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\""
   client.set_object_canned_acl(bucket_name, object_name, 'x-bce-grant-read' => id_permission)
   ```

   ```
   id_permission = "id=\"8c47a952db4444c5a097b41be3f24c94\",id=\"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\""
   client.set_object_canned_acl(bucket_name, object_name, 'x-bce-grant-full-control' => id_permission)
   ```

2. 通过`set_object_acl`设置object访问权限

   ```
   acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                         {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
           'permission' => ['FULL_CONTROL']
   }]
   client.set_object_acl(bucket_name, object_name, acl)
   ```

> **注意：**
>
> 1. permission中的权限设置包含两个值：`READ`、`FULL_CONTROL`，它们分别对应相关权限。
> 2. 设置两个以上（含两个）被授权人时，请参考以上示例的格式，若将数组合并会返回报错。

### 查看Object的权限

如下代码可以查Object的权限：

```
client.get_object_acl(bucket_name, object_name)
```

`get_object_acl`方法返回的解析类中可供调用的参数有：

| 参数              | 说明                 |
| ----------------- | -------------------- |
| accessControlList | 标识Object的权限列表 |
| grantee           | 标识被授权人         |
| -id               | 被授权人ID           |
| permission        | 标识被授权人的权限   |

### 删除Object的权限

如下代码可以删除Object的权限：

```
client.delete_object_acl(bucket_name, object_name)
```

## 删除文件

**删除单个文件**

可参考如下代码删除了一个Object:

```
client.delete_object(bucket_name, object_name)
```

## 查看文件是否存在

用户可通过如下操作查看某文件是否存在：

```
begin
    client.get_object_meta_data(bucket_name, object_name)
rescue BceServerException => e
    puts "#{object_name} not exist!" if e.status_code == 404    
end
```

## 获取及更新文件元信息

文件元信息(Object Metadata)，是对用户上传BOS的文件的属性描述，分为两种：HTTP标准属性（HTTP Headers）和User Meta（用户自定义元信息）。 

### 获取文件元信息

参考[只获取ObjectMetadata](#只获取ObjectMetadata)。

### 修改文件元信息

BOS修改Object的Metadata通过拷贝Object实现。即拷贝Object的时候，把目的Bucket设置为源Bucket，目的Object设置为源Object，并设置新的Metadata，通过拷贝自身实现修改Metadata的目的。如果不设置新的Metadata，则报错。

```
user_metadata = { "key1" => "value1" }
options = {
            'user-metadata' => user_metadata
}

client.copy_object(bucket_name, object_name, bucket_name, object_name, options)
puts client.get_object_meta_data(bucket_name, object_name)['user-metadata']['key1']
```

## 拷贝Object

### 拷贝一个文件

用户可以通过copyObject方法拷贝一个Object，如下代码所示：

```
client.copy_object(source_bucket_name, source_object_key, target_bucket_name, target_object_key)
```

`copy_object`方法可以通过`options`配置可选参数，参数列表参考如下:

| 参数          | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| user-metadata | 用户自定义Meta，包含Key-Value对                              |
| eTag          | Source Object的eTag，若选择上传，则会对Target Object和Source Object的eTag进行比对，若不相同，则返回错误。 |

#### 同步Copy

当前BOS的CopyObject接口是通过同步方式实现的。同步方式下，BOS端会等待Copy实际完成才返回成功。同步Copy能帮助用户更准确的判断Copy状态，但用户感知的复制时间会变长，且复制时间和文件大小成正比。

同步Copy方式更符合业界常规，提升了与其它平台的兼容性。同步Copy方式还简化了BOS服务端的业务逻辑，提高了服务效率。

### 分块拷贝

除了通过CopyObject接⼝拷贝文件以外，BOS还提供了另外一种拷贝模式——Multipart Upload Copy。用户可以在如下的应用场景内（但不仅限于此），使用Multipart Upload Copy，如：

- 需要支持断点拷贝。
- 拷贝超过5GB大小的文件。
- 网络条件较差，和BOS的服务器之间的连接经常断开。

下面将介绍分步实现三步拷贝。

三步拷贝包含init、“拷贝分块”和complete三步，其中init和complete的操作同分块上传一致，可直接参考[初始化Multipart Upload](#初始化Multipart Upload)和[完成分块上传](#完成分块上传)。

```
left_size = client.get_object_meta_data(source_bucket_name, source_object_key)['content-length']
offset = 0
part_number = 1
part_list = []

while left_size > 0 do
    part_size = 5 * 1024 * 1024
    if left_size < part_size
        part_size = left_size
    end

    response = client.upload_part_copy(
        source_bucket_name, source_object_key, target_bucket_name, target_object_key, upload_id, part_number, part_size, offset)
    left_size -= part_size
    offset += part_size
    # your should store every part number and etag to invoke complete multi-upload
    part_list << {
        "partNumber" => part_number,
        "eTag" => response["eTag"]
    }
    part_number += 1
end
```

> **注意:**
> size参数以字节为单位，定义每个分块的大小，除最后一个Part以外，其他的Part大小都要大于5MB。

# 异常处理

BOS异常提示有如下四种方式：

| 异常方法           | 说明              |
| ------------------ | ----------------- |
| BceHttpException   | 客户端异常        |
| BceServerException | 服务器异常        |
| BceHttpException   | net::http相关异常 |

用户可以使用rescue获取某个事件所产生的异常：

```
begin
    client.get_object_meta_data(bucket_name, object_name)
rescue Exception => e
    puts "Catch a http exception" if e.is_a?(BceHttpException)
    puts "Catch a client exception" if e.is_a?(BceClientException)
    puts "Catch a server exception" if e.is_a?(BceServerException)
end
```

## 客户端异常

客户端异常表示客户端尝试向BOS发送请求以及数据传输时遇到的异常。

## 服务端异常

当BOS服务端出现异常时，BOS服务端会返回给用户相应的错误信息，以便定位问题。常见服务端异常可参见[BOS错误信息格式](https://cloud.baidu.com/doc/BOS/API.html#.E9.94.99.E8.AF.AF.E4.BF.A1.E6.81.AF.E6.A0.BC.E5.BC.8F)

## SDK日志

BOS Ruby SDK支持四个级别的日志(默认为`Logger::INFO`级别)，支持设置输出日志文件的目录，详细可以参考`Log`模块。示例代码：

```
# 默认日志路径：DEFAULT_LOG_FILE = "./baidubce-sdk.log"
Log.set_log_file(file_path)

# 四个日志级别：Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
Log.set_log_level(Logger::DEBUG)
```



# 版本变更记录

- Ruby SDK开发包[2018-05-21] 版本号 0.1.0
  - 创建、查看、罗列、删除Bucket，获取位置和判断是否存在
  - 支持管理Bucket的生命周期、日志、ACL、存储类型
  - 上传、下载、删除、罗列Object，支持追加上传、分块上传、分块拷贝

