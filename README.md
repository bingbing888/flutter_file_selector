# flutter_file_selector

#### 介绍
flutter版本的一个文件选择器 开发中...

<a href='https://gitee.com/jrnet/flutter_file_selector/raw/master/example/build/app/outputs/apk/debug/app-debug.apk'>apk体验</a>

<img src='/微信图片_20200607174036.jpg' width='20%'/>
<img src='/微信图片_20200607174043.jpg' width='20%'/>


使用到的插件
| path_provider  | <a href='https://pub.flutter-io.cn/packages/path_provider'>pub</a>  |
|---|---|
| file_picker  | <a href='https://pub.flutter-io.cn/packages/file_picker'>pub</a>  |

参数
|---|---|
| String title  | 标题  |
|---|---|
| List<String> fileTypeEnd  | 展示的文件类型   默认：".pdf , .docx , .doc"  |
|---|---|
| String pdfImg  | pdf图标  |
|---|---|
| String wordImg  | word图标  |
|---|---|
| String directory  | 检索的目录 默认 /storage/emulated/0/ 安卓根目录  这个几乎不用传 用默认即可|
|---|---|
| bool isScreen  | 默认关闭筛选|

未来须实现日志
|---|
| 文件类型筛选  |
|---|
| 自定义图标  |
|---|
| 本地存储上次检索的结果  |


使用：
```java
   # 引入依赖
  flutterfileselector:
    git:
      url: https://gitee.com/jrnet/flutter_file_selector

```

```java
安卓需配置目录访问权限 配置AndroidManifest.xml 文件，application里加入如下：
<provider
   android:name="androidx.core.content.FileProvider"
   android:authorities="${applicationId}.fileProvider"
   android:exported="false"
   android:grantUriPermissions="true"
   tools:replace="android:authorities">
   <meta-data
       android:name="android.support.FILE_PROVIDER_PATHS"
       android:resource="@xml/filepaths"
       tools:replace="android:resource" />
</provider>
```

```java
在 Android/app/src/main/res/xml 目录下 创建 filepaths.xml ,没有xml目录创建一个即可,内容如下：

<?xml version="1.0" encoding="utf-8"?>
<paths>
<external-path
name="external_storage_root"
path="." />
<files-path
name="files-path"
path="." />
<cache-path
name="cache-path"
path="." />
<!--/storage/emulated/0/Android/data/...-->
<external-files-path
name="external_file_path"
path="." />
<!--app 外部存储区域根目录下的文件 Context.getExternalCacheDir目录下的目录-->
<external-cache-path
name="external_cache_path"
path="." />
<!--配置root-path, 读取sd卡和一些应用分身的目录 -->
<root-path
name="root-path"
path="" />

</paths>
```

```java
/// 引用选择器
 FlatButton(
  onPressed: (){
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => FlutterFileSelector(
        fileTypeEnd: [".pdf",".doc",".docx",".mp4"],//默认：[".pdf",".doc",".docx",]
      )), ).then((value) => print(value));
  },
  child: Text("打开文件选择器"),
),
```

