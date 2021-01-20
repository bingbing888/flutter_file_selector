import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterfileselector/FileUtilModel.dart';
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
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            FlutterSelect(
              /// 标题
              title: "选择文档",
              /// 按钮
              btn: Text("选择文档"),
              /// 最大可选
              maxCount: 3,
              /// 开启筛选
              isScreen: true,
              /// 选择器展示的文件格式
              /// 往数组里添加需要展示出来选择的格式
              fileTypeEnd: [".pdf", ".doc", ".docx",".xls",".xlsx",".txt",".pptx",".ppt",".mp4",".mp3"],
              valueChanged: (v){
                print(v[0].filePath);
                this.v = v;
                setState(() {

                });
              },
            ),
            FlatButton(
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
