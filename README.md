# flutter_file_selector

#### 介绍
flutter版本的一个文件选择器 ，顺序按最近访问的时间排序

布局使用flutter，安卓使用原生实现，ios使用 file_picker插件得到返回的

<a href='https://gitee.com/jrnet/flutter_file_selector/releases/1.0.0'>apk下载体验,ios暂无</a>

<img src='/93647B559FE5554940720C3E55B43DDE.jpg' width='30%'/>
<img src='/F1D97A4DECD54AFBE1C31D77BD15BC2B.jpg' width='30%'/>
<img src='/images/微信图片_20200610154935.png' width='30%'/>


使用到的插件
|  插件依赖   | pub仓库地址  |
|  ----  | ----  |
| permission_handler  | <a href='https://pub.flutter-io.cn/packages/permission_handler'>pub</a>  |
|---|---|
| file_picker  | <a href='https://pub.flutter-io.cn/packages/file_picker'>pub</a>  |

使用：
```java
   # 在pubspec.yaml 中引入依赖 方式1
  flutterfileselector:
    git:
      url: https://gitee.com/jrnet/flutter_file_selector

 # 在pubspec.yaml 中引入依赖 方式2
 flutterfileselector: ^0.0.1

```

```java
FlutterSelect(
    btn: Text("这个按钮可以自定义"),
    isScreen: true,
    fileTypeEnd: [".pdf", ".doc", ".docx",".xls",".xlsx"],
    valueChanged: (v){
        // v 是 List<FileModelUtil>
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

未来须实现日志
|  参数名   | 说名  |
|  ----  | ----  |
| 自定义图标  | - |

<h3>注意：</h3>
<h5>安卓需配置目录访问权限 配置AndroidManifest.xml 文件，application里加入如下 file_select_flutter.xml不用创建 已集成：</h5>

```java
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




