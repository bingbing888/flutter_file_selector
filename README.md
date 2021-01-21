# Flutter_file_selector

#### 介绍
flutter版本的一个文件选择器 ，顺序按最近访问的时间排序

布局使用Flutter布局，安卓使用原生的MediaStore.Files类实现

ios使用 file_picker插件得到返回的

支持多选，支持所有文件类型

<a href='https://gitee.com/jrnet/flutter_file_selector/releases/1.0.0'>apk下载体验 , ios暂无打包 自行拉取代码编译</a>

<img src='/001.jpg' width='40%'/>
<img src='/002.jpg' width='40%'/>
<img src='/003.jpg' width='40%'/>
<img src='/images/微信图片_20200610154935.png' width='40%'/>


使用到的插件
|  插件依赖   | pub仓库地址  |
|  ----  | ----  |
| permission_handler  | <a href='https://pub.flutter-io.cn/packages/permission_handler'>pub</a>  |
|---|---|
| file_picker  | <a href='https://pub.flutter-io.cn/packages/file_picker'>pub</a>  |

<h3>示例：</h3>

```java
   # 在pubspec.yaml 中引入依赖 方式1
  flutterfileselector:
    git:
      url: https://gitee.com/jrnet/flutter_file_selector

 # 在pubspec.yaml 中引入依赖 方式2
 flutterfileselector: ^0.0.1
```

```java
List fileTypeEnd = [".pdf", ".doc", ".docx",".xls",".xlsx"];
FlutterSelect(
    btn: Text("这个按钮可以自定义"),
    isScreen: true,
    // 文件类型后缀
    fileTypeEnd: fileTypeEnd,
    // 选择文件后的返回
    valueChanged: (v){
        // v = List<FileModelUtil>
        print(v);
    },
),
```

FlutterSelect可选参数
|  参数名   | 说名  |
|  ----  | ----  |
| String title  | 标题 |
| List<String> fileTypeEnd  | 展示的文件类型   默认：".pdf , .docx , .doc" |
| String pdfImg  | pdf图标 |
| String wordImg  | word图标 |
| String exelImg  | exelImg图标 |
| bool isScreen  | 默认关闭筛选 |
| int maxCount  | 可选最大总数 默认 9 |

FileModelUtil的参数：
|  参数名   | 说名  |
|  ----  | ----  |
| File file  | 文件 |
| String fileName  | 文件名称 |
| int fileSize | 文件大小 |
| String filePath  | 文件路径 |
| int fileDate  | 文件日期时间 |

<h3>注意：一定要有权限</h3>
<h5>安卓需配置目录访问权限 配置AndroidManifest.xml 文件，application里加入如下代码</h5>

```java
// tools:replace="android:resource"  需要导入tools 才能使用
// AndroidManifest.xml 的 manifest 中 引入 xmlns:tools="http://schemas.android.com/tools"
<provider
   android:name="androidx.core.content.FileProvider"
   android:authorities="${applicationId}.fileProvider"
   android:exported="false"
   android:grantUriPermissions="true"
   tools:replace="android:authorities">
   <meta-data
       android:name="android.support.FILE_PROVIDER_PATHS"
       android:resource="@xml/file_select_flutter"
       tools:replace="android:resource" />
</provider>
```




