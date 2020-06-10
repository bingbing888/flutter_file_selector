import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FileUtilModel.dart';

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
  String pdfImg;// pdf图标
  String wordImg;// word图标
  String exelImg;
  bool isScreen;// 默认关闭筛选
  int maxCount;// 可选最大总数 默认9个
  ValueChanged<List<FileModelUtil>> valueChanged;
  FlutterSelect({this.btn,this.fileTypeEnd,this.maxCount,this.exelImg,this.isScreen,this.pdfImg,this.title,this.wordImg,this.valueChanged});
  @override
  _FlutterSelectState createState() => _FlutterSelectState();
}

class _FlutterSelectState extends State<FlutterSelect> {

  ///  IOS平台 直接使用FilePicker插件
  void getFilesIos () async{

    try{
      List<FileModelUtil> list = [];
      List<String> type = [];

      widget.fileTypeEnd.forEach((t){
        type.add("."+t);
      });

      log("当前的类型："+type.toString());

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
            fileTypeEnd: widget.fileTypeEnd ?? [".pdf", ".doc", ".docx",".xls",".xlsx"],
          ), ), ).then( (value) {
            widget.valueChanged(value);
          } );
        }else  if(Platform.isIOS) {
          getFilesIos();
          return;
        }
      },
      child: widget.btn ?? Text("选择文件"),
    );
  }
}

/// 安卓端ui
class FlutterFileSelector extends StatefulWidget {
  String title;// 标题
  List<String> fileTypeEnd;// 展示的文件后缀   默认：".pdf , .docx , .doc"
  String pdfImg;// pdf图标
  String wordImg;// word图标
  String exelImg;
  bool isScreen;// 默认关闭筛选
  int maxCount;// 可选最大总数 默认个
  FlutterFileSelector(
      {
        this.title,
        this.fileTypeEnd,
        this.pdfImg,
        this.wordImg,
        this.isScreen:false,
        this.exelImg,
        this.maxCount:9
    }
      );
  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {

  /// 选择的文件
  List<FileModelUtil> fileSelect = [];

  /// 原生交互通道
  static const MethodChannel _channel = const MethodChannel('flutterfileselector');

  /// 解析到的原生返回的数据
  static List<FileModelUtil> list = [];

  /// error
  static String errorMsg = "";

  @override
  void initState() {
//    _checkPhone();
  getFilesAndroid();
    WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement initState
    super.initState();

  }

//  _checkPhone(){
//    /// 判断平台
//    if (Platform.isAndroid) {
//      getFilesAndroid();
//    }else  if(Platform.isIOS) {
//      getFilesIos();
//      return;
//    }
//  }


  /// 调用原生 得到文件+文件信息
  void getFilesAndroid () async {

    try{
      if (await Permission.storage.request().isGranted) {
        errorMsg = "";
        log("当前的类型："+widget.fileTypeEnd.toString());
        Map<String, Object> map = {"type": widget.fileTypeEnd ?? [ ".pdf", ".docx", ".doc" ]};

        final List<dynamic>  listFileStr = await _channel.invokeMethod('getFile',map);

        /// 如果原生返回空 return掉
        if(listFileStr==null || listFileStr.length==0){
          return;
        }

        list.clear();
        listFileStr.forEach((f){
          list.add(FileModelUtil(
            fileDate: f["fileDate"],
            fileName: f["fileName"],
            filePath: f["filePath"],
            fileSize: f["fileSize"],
            file:File(f["filePath"]),
          ));
        });
        ///降序
//        list.sort((a,b)=>b.file.statSync().changed.compareTo(a.file.statSync().changed));
      }else{
        errorMsg = "当前设备未允许读写权限，无法检索目录!";
      }

      setState(() {

      });

    }catch (e){
      print("FlutterFileSelect Error:"+e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Builder(builder: (BuildContext context) {
        if(errorMsg!=null && errorMsg!=""){
          Scaffold.of(context).showSnackBar(SnackBar(content: new Text(errorMsg)));
        }
        return Column(
          children: <Widget>[
            /// appbar
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10,right: 10),
                width: MediaQuery.of(context).size.width,
                height: 40,
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.chevron_left,color: Colors.grey[700],),
                    ),
                    Text("  ${widget.title ?? '文件选择器 '} ${fileSelect.length}/${widget.maxCount}",style: TextStyle(height: 1.1,fontSize: 16,color: Colors.grey[700]),),
                    InkWell(
                      onTap: (){
                        log("返回的类型："+fileSelect.runtimeType.toString());
                        Navigator.pop(context,fileSelect);
                      },
                      child: Text("选择"),
                    ),
                  ],
                ),
                color: Colors.grey[100]
            ),
            /// 筛选
            !widget.isScreen?SizedBox():Container(
              color: Colors.grey[100],
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10,right: 10),
              child: Wrap(
                alignment: WrapAlignment.start,
                children: <Widget>[
                  OutlineButton(onPressed: (){
                    widget.fileTypeEnd = [".pdf",".xls",".xlsx",".doc",".docx"];
                    getFilesAndroid();
                  },child: Text("全部"),),
                  SizedBox(width: 5,),
                  OutlineButton(onPressed: (){
                    widget.fileTypeEnd = [".pdf"];
                    getFilesAndroid();
                  },child: Text("PDF"),),
                  SizedBox(width: 5,),
                  OutlineButton(onPressed: (){
                    widget.fileTypeEnd = [".doc",".docx"];
                    getFilesAndroid();
                  },child: Text("Word"),),
                  SizedBox(width: 5,),
                  OutlineButton(onPressed: (){
                    widget.fileTypeEnd = [".xls",".xlsx"];
                    getFilesAndroid();
                  },child: Text("Excel"),),
                ],
              ),
            ),
            /// 列表
            Expanded(child: list.length==0?Center(child: Text("当前目录为空"),):ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  value: fileSelect.contains(list[index]),
                  onChanged: (bool value){
                    setState(() {
                      /// 等于最大可选 拦截点击 并提示
                      if(widget.maxCount==fileSelect.length){
                        Scaffold.of(context).showSnackBar(SnackBar(content: new Text('最多可选${widget.maxCount}个文件')));
                        return;
                      }
                      if(!fileSelect.contains(list[index])){
                        fileSelect.add(list[index]);
                      }else{
                        fileSelect.removeAt(fileSelect.indexOf(list[index]));
                      }
                    });
                  },
                  secondary: ClipRRect(
                    child: Container(
                      color:_type(list[index].filePath)["color"],
                      width: 55,
                      height: 55,
                      alignment: Alignment.center,
                      child: Text(_type(list[index].filePath)["str"],style: TextStyle(color: Colors.white),),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  title: new Text("${list[index].fileName}",overflow: TextOverflow.ellipsis,),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(" ${File(list[index].filePath).statSync().changed}",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                      Text(" ${(File(list[index].filePath).statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                    ],
                  ),
                  dense: false,
                  activeColor: Colors.blue[400],// 指定选中时勾选框的颜色
                  checkColor: Colors.white,
                  isThreeLine: false,
                  selected: fileSelect.contains(list[index]),
                );
              },
            ),)
          ],
        );
      }),

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
      m["str"] = "Docx";
      m["color"] = Colors.blue[400];
      return m;
    }
    if(str.endsWith(".xlsx") || str.endsWith(".xls")){
      Map m = Map();
      m["str"] = "Excel";
      m["color"] = Colors.green[400];
      return m;
    }
    Map m = Map();
    m["str"] = str.substring(str.lastIndexOf(".")+1,str.length);
    m["color"] = Colors.grey[500];
    return m;
  }
}

