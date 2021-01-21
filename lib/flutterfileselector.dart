
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model/file_util_model.dart';
import 'page/flutter_android_page.dart';

///
/// @DevTool: AndroidStudio
/// @Author: ZhongWb
/// @Date: 2020/6/7 17:04
/// @FileName: flutterfileselector
/// @FilePath: flutterfileselector.dart
/// @Description: 文件选择器
/// 顺序按最近访问的时间排序
///
class FlutterSelect extends StatefulWidget {
  Widget btn;// 按钮
  String title;// 标题
  List<String> fileTypeEnd;// 展示的文件后缀   默认：".pdf , .docx , .doc"
  bool isScreen;// 默认关闭筛选
  int maxCount;// 可选最大总数 默认9个
  ValueChanged<List<FileModelUtil>> valueChanged;
  FlutterSelect({this.btn,this.fileTypeEnd,this.isScreen,this.title,this.maxCount,this.valueChanged});
  @override
  _FlutterSelectState createState() => _FlutterSelectState();
}

class _FlutterSelectState extends State<FlutterSelect> {

  ///  IOS平台 直接使用FilePicker插件
  void getFilesIos () async{

    try{

      List<FileModelUtil> list = [];
      List<String> type = [];
      /// 清除 .
      widget.fileTypeEnd.forEach((t){
        type.add(t.substring(t.lastIndexOf(".")+1,t.length));
      });

      log("当前能选的类型 ios："+type.toString());


      log("当前能选的类型："+type.toString());

      List<File> files = await FilePicker.getMultiFile(
        type: FileType.custom,
        allowedExtensions: type ?? [ "pdf", "docx", "doc" ],
      );

      if(files==null|| files.length==0){
        return;
      }
      files.forEach((f){
        list.add(
            FileModelUtil(
          fileDate: f.statSync().changed.millisecondsSinceEpoch,
          fileName: f.resolveSymbolicLinksSync().substring(f.resolveSymbolicLinksSync().lastIndexOf("/")+1,f.resolveSymbolicLinksSync().length),
          filePath: f.path,
          fileSize:f.statSync().size,
          file:f,
        ));
      });

      widget.valueChanged(list);
    }catch (e){
      print("FlutterFileSelect Error:"+e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: (){
        /// 判断平台
        if (Platform.isAndroid) {
          Navigator.push( context, MaterialPageRoute( builder: (context) => FlutterFileSelector(
            isScreen: widget.isScreen ?? true,
            maxCount:widget.maxCount,
            fileTypeEnd: widget.fileTypeEnd ?? [".pdf", ".doc", ".docx",".xls",".xlsx"],
          ), ), ).then( (value) {
            widget.valueChanged(value);
          } );
        }else  if(Platform.isIOS) {
          getFilesIos();
        }
      },
      child: widget.btn ?? Text("选择文件"),
    );
  }
}



