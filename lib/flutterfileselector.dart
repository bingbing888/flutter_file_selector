  
library flutterfileselector;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

///
/// @DevTool: AndroidStudio
/// @Author: ZhongWb
/// @Date: 2020/6/7 17:04
/// @FileName: flutterfileselector
/// @FilePath: flutterfileselector.dart
/// @Description: 文件选择器
///
class Flutterfileselector {
  static const MethodChannel _channel =
      const MethodChannel('flutterfileselector');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class FlutterFileSelector extends StatefulWidget {
  String title;
  String pdfImg;// pdf图标
  String wordImg;// word图标
  ValueChanged<FileSystemEntity> valueChanged;
  FlutterFileSelector(
      {
        this.valueChanged,
        this.title,
        this.pdfImg,
        this.wordImg,
    }
      );
  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> files1 = [];
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement initState
    super.initState();
    getDv();
  }

  /// [i]==0 微信  [i]==1 QQ
  /// 默认展示微信目录
  getDv({int i:0})async{
    await getExternalStorageDirectories().then((value) {
      Directory directory  ;
      if(i==0){
        directory = Directory("/storage/emulated/0/tencent/MicroMsg/Download");
      }else if(i==1){
        directory = Directory("/storage/emulated/0/tencent/QQfile_recv");
      }
//      else{
//        directory = Directory("/storage/emulated/0/tencent/weixinWork/filecache");
//      }
      files = directory.listSync();
      log(files.toString());
      files1.clear();
      files.forEach((element) {
        if(FileSystemEntity.isFileSync(element.path)){
          if(element.path.contains(".pdf") || element.path.contains(".doc") || element.path.contains(".docx")){
            files1.add(element);
            print(element.resolveSymbolicLinksSync());
          }

        }
      });
      setState(() {

      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            height: 40,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.chevron_left,color: Colors.grey[700],),
                ),
                Text("  ${widget.title ?? '文件选择器'}",style: TextStyle(height: 1.1,fontSize: 16,color: Colors.grey[700]),),
              ],
            ),
              color: Colors.grey[100]
          ),
          Container(padding: EdgeInsets.only(left: 10,right: 10),width: MediaQuery.of(context).size.width,height: 25,alignment: Alignment.centerLeft,color: Colors.grey[100],child: Text("(暂只支持 微信、QQ、接收的PDF、word)",style: TextStyle(color: Colors.grey[400],fontSize: 12),),),
          Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            child: Row(
              children: <Widget>[
                OutlineButton(onPressed: (){
                  getDv(i: 0);
                },child: Text("全部"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                  getDv(i: 0);
                },child: Text("微信"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                  getDv(i: 1);
                },child: Text("QQ"),),
              ],
            ),
          ),
          Divider(height: 1,color: Colors.grey[400],),
          Expanded(child: files1.length==0?Center(child: Text("当前目录为空"),):Padding(padding: EdgeInsets.only(left: 10,right: 10),child: ListView.builder(
            itemCount: files1.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () async{
//                  String filePath = files1[index].resolveSymbolicLinksSync();
                  widget.valueChanged(files1[index]);
//                  if(filePath.contains(".pdf") || filePath.contains(".PDF")){
//                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfShowView(pdfPath: filePath,)));
//                  }else{
//                    Toast.center(msg: filePath);
//                    try{
//                      final result = await OpenFile.open(filePath);
//                    }catch (e){
//                      Toast.error(msg: "打开文件失败");
//                    }
//
//                  }
                },
                child: Container(
//              height: 40,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200],width: 1))
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset("${files1[index].resolveSymbolicLinksSync().contains(".pdf")? widget.pdfImg : widget.wordImg}",fit: BoxFit.fill,width: 35,height: 35,),
//                      Text("${files1[index].resolveSymbolicLinksSync().contains(".pdf")? 'PDF' : 'Doc'}",style: TextStyle(fontSize: 12,color: files1[index].resolveSymbolicLinksSync().contains(".pdf")? Colors.pink : Colors.blue),),
                            SizedBox(width: 15,),
                            Expanded(child: Text("${files1[index].resolveSymbolicLinksSync().substring(files1[index].resolveSymbolicLinksSync().lastIndexOf("/")+1,files1[index].resolveSymbolicLinksSync().length)}",overflow: TextOverflow.ellipsis,maxLines: 2,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(" ${files1[index].statSync().changed}",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                            Text(" ${(files1[index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                          ],
                        ),
                      ],
                    )
                ),
              );
            },
          ),),)
        ],
      ),
    );
  }
}

