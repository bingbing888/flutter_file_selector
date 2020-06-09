import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  FileSystemEntity v;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.push( context, MaterialPageRoute( builder: (context) => FlutterFileSelector(
                      isScreen: true,
                      fileTypeEnd: [".pdf", ".doc", ".docx","xls","xlsx"],
                    ), ), ).then( (value) => setState( () => v = value),
                );
              },
              child: Text("打开文件选择器"),
            ),
            FlatButton(
              onPressed: () {
                OpenFile.open(v.path);
              },
              child: Text(
                  "打开文件：  ${v != null ? v.absolute.resolveSymbolicLinksSync() : ''}"),
            ),
          ],
        ),
      ),
    );
  }
}
