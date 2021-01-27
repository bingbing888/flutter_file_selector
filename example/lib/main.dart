import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterfileselector/model/drop_down_model.dart';
import 'package:flutterfileselector/model/file_util_model.dart';
import 'package:flutterfileselector/flutterfileselector.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
//      platformVersion = await Flutterfileselector.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<FileModelUtil> v;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("演示"),actions: [],),
      body: Center(
        child: Column(
          children: <Widget>[
            FlutterSelect(
              /// todo:  标题
              /// todo:  按钮
              btn: Text("选择文档"),
              /// todo:  最大可选
              maxCount: 3,
              /// todo:  开启筛选
              isScreen: true,
              /// todo:  往数组里添加需要的格式
              fileTypeEnd: [".pdf", ".doc", ".docx",".xls",".xlsx",".pptx",".ppt",".mp4",".mp3",".flac"],
              /// todo:  自定义下拉选项，不传默认

              valueChanged: (v){
                print(v[0].filePath);
                this.v = v;
                setState(() {

                });
              },
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                OpenFile.open(v[0].filePath);
              },
              child: Text(
                  "打开文件：  ${v != null ? v[0].fileName : ''}"),
            ),
          ],
        ),
      ),
    );
  }
}
