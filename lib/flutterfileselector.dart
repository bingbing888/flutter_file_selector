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
//  static const MethodChannel _channel =
//      const MethodChannel('flutterfileselector');
//
//  static Future<String> get platformVersion async {
//    final String version = await _channel.invokeMethod('getPlatformVersion');
//    return version;
//  }
}

class FlutterFileSelector extends StatefulWidget {
  String title;/// 标题
  List<String> fileTypeEnd;/// 展示的文件后缀
  ValueChanged<FileSystemEntity> valueChanged;/// 点击文件时的回调
  FlutterFileSelector(
      {
        this.valueChanged,
        this.title,
        this.fileTypeEnd
    }
      );
  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {
  List<FileSystemEntity> files = [];
  List<FileSystemEntity> files1 = [];
  List<String> fileTypeEnd;/// 展示的文件后缀
  @override
  void initState() {
    if(widget.fileTypeEnd==null || widget.title==0){
      fileTypeEnd = [
        ".pdf",
        ".docx",
        ".doc"
      ];
    }else{
      fileTypeEnd = widget.fileTypeEnd;
    }
    WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement initState
    super.initState();
    /// 先进来页面使用延迟加载
    Timer.periodic(Duration(milliseconds: 200), (v){
      v.cancel();
      try {
        filesDirs(Directory("/storage/emulated/0/"));
      } finally {
        /// 倒叙
        files1.sort((a,b)=>(b.statSync().changed).compareTo(a.statSync().changed));
        setState(() { });
        print("加载结束了");
      }
    });
  }
  filesDirs(Directory directory) {
    List<FileSystemEntity>  fs = directory.listSync();
    for(int i =0 ; i<fs.length ;i++){
      //若是目录，则递归目录下的文件
      if(FileSystemEntity.isDirectorySync(fs[i].path)){
        print("目录"+i.toString());
        filesDirs(fs[i]);
      }
      //若是文件
      if(FileSystemEntity.isFileSync(fs[i].path)){
        print("文件"+i.toString());
        if( fs[i].path.endsWith(".pdf") ||  fs[i].path.endsWith(".doc")   || fs[i].path.endsWith(".docx") ){
          files1.add(fs[i]);
        }
      }
    }
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
                Text("  文件选择器",style: TextStyle(height: 1.1,fontSize: 16,color: Colors.grey[700]),),
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
                },child: Text("全部"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("Word"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("PDF"),),
              ],
            ),
          ),
          Divider(height: 1,color: Colors.grey[400],),
          Expanded(child: files1.length==0?Center(child: Text("当前目录为空"),):Padding(padding: EdgeInsets.only(left: 10,right: 10),child: ListView.builder(
            itemCount: files1.length,
            padding: EdgeInsets.all(0),
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
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200],width: 1))
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ClipRRect(
                              child: Container(
                                color:_type(files1[index].resolveSymbolicLinksSync())["color"],
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: Text(_type(files1[index].resolveSymbolicLinksSync())["str"],style: TextStyle(color: Colors.white),),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
//                            Image.asset("${files1[index].resolveSymbolicLinksSync().contains(".pdf")? 'images/Pdf.png' : 'images/word.png'}",fit: BoxFit.fill,width: 35,height: 35,),
                            SizedBox(width: 15,),
                            Expanded(child: Text("${files1[index].resolveSymbolicLinksSync().substring(files1[index].resolveSymbolicLinksSync().lastIndexOf("/")+1,files1[index].resolveSymbolicLinksSync().length)}",overflow: TextOverflow.ellipsis,maxLines: 2,),),
                          ],
                        ),
                        SizedBox(height: 3,),
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

  _type(String str){
    if(str.endsWith(".pdf")){
      Map m = Map();
      m["str"] = "PDF";
      m["color"] = Colors.red[400];
      return m;
    }
    if(str.endsWith(".doc") || str.endsWith(".docx")){
      Map m = Map();
      m["str"] = "Doc";
      m["color"] = Colors.blue[400];
      return m;
    }
    Map m = Map();
    m["str"] = "Oth";
    m["color"] = Colors.grey[500];
    return m;
  }
}

