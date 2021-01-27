
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model/drop_down_model.dart';
import 'model/file_util_model.dart';
import 'page/flutter_android_page.dart';

///
/// @DevTool: AndroidStudio
/// @Author: ZhongWb
/// @Date: 2020/6/7 17:04
/// @FileName: flutterfileselector
/// @FilePath: flutterfileselector.dart
/// @Description: 文件选择器
///
class FlutterSelect extends StatefulWidget {
  Widget btn;// 按钮
  String title;// 标题
  List<String> fileTypeEnd;// 文件后缀
  bool isScreen;// 默认开启筛选
  int maxCount;// 可选最大总数 默认9个
  List<DropDownModel> dropdownMenuItem;// 类型列表
  ValueChanged<List<FileModelUtil>> valueChanged;// 类型回调
  FlutterSelect({
    this.btn,
    List<String> fileTypeEnd,
    this.isScreen:true,
    this.title:"文件选择",
    this.maxCount,
    this.valueChanged,
    this.dropdownMenuItem,
  }){
    this.fileTypeEnd = fileTypeEnd ?? [".pdf", ".doc", ".docx",".xls",".xlsx"];
  }
  @override
  _FlutterSelectState createState() => _FlutterSelectState();
}

class _FlutterSelectState extends State<FlutterSelect> {

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: (){
        /// 判断平台
        if (Platform.isAndroid) {
          _getFilesAndroidPage(context);
        }else if(Platform.isIOS) {
          _getFilesIosPage();
        }
      },
      child: widget.btn ?? Text("选择文件"),
    );
  }


  /// Android平台 调用Flutter布局页
  _getFilesAndroidPage(context){
    Navigator.push( context, MaterialPageRoute( builder: (context) => FlutterFileSelector(
      title: widget.title,
      isScreen: widget.isScreen,
      maxCount:widget.maxCount,
      fileTypeEnd: widget.fileTypeEnd,
      dropdownMenuItem: widget.dropdownMenuItem,
    ), ), ).then( (value) {
      widget.valueChanged(value);
    } );
  }

  ///  IOS平台 直接使用FilePicker插件
  _getFilesIosPage() async{

    try{
      List<FileModelUtil> list = [];
      List<String> type = [];

      /// 去除点
      widget.fileTypeEnd.forEach((t){
        type.add(t.substring(t.lastIndexOf(".")+1,t.length));
      });

      log("当前能选的类型 ios："+type.toString());

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

}



