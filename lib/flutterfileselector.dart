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

          Navigator.push( context, MaterialPageRoute( builder: (context) => _FlutterFileSelector(
            isScreen: widget.isScreen ?? true,
            wordImg: widget.wordImg,
            exelImg: widget.exelImg,
            pdfImg: widget.pdfImg,
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

/// 安卓端ui
class _FlutterFileSelector extends StatefulWidget {
  String title;// 标题
  List<String> fileTypeEnd;// 展示的文件后缀   默认：".pdf , .docx , .doc"
  String pdfImg;// pdf图标
  String wordImg;// word图标
  String exelImg;
  bool isScreen;// 默认关闭筛选
  int maxCount;// 可选最大总数 默认个
  _FlutterFileSelector(
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

class _FlutterFileSelectorState extends State<_FlutterFileSelector> {

  /// 选择的文件
  List<FileModelUtil> fileSelect = [];

  /// 原生交互通道
  static const MethodChannel _channel = const MethodChannel('flutterfileselector');

  /// 解析到的原生返回的数据
  static List<FileModelUtil> list = [];

  /// error
  static String errorMsg = "";

  List<String> fileTypeEnd = [];

  int btnIndex = 0;
  @override
  void initState() {
  
    //WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement initState
    super.initState();
    fileTypeEnd = widget.fileTypeEnd;
    fileTypeEnd.insert(0, "全部");
    Future.delayed(Duration(milliseconds:300),(){
      getFilesAndroid();
    });
  }

  /// 调用原生 得到文件+文件信息
  void getFilesAndroid () async {

    try{
      if (await Permission.storage.request().isGranted) {

        errorMsg = "";

        log("当前能选的类型："+widget.fileTypeEnd.toString());

        Map<String, Object> map = {"type": widget.fileTypeEnd ?? [ ".pdf", ".docx", ".doc" ]};

        final List<dynamic>  listFileStr = await _channel.invokeMethod('getFile',map);

        /// 如果原生返回空 return掉
        // if(listFileStr==null || listFileStr.length==0){
        //   list.clear();
        //   return;
        // }

        list.clear();
        print("原生返回 不为空");
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
        return Column(
          children: <Widget>[
            Image.asset("images/word.png"),
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
                    fileSelect.length > 0 ? InkWell(
                      onTap: (){
                        log("返回的类型："+fileSelect.runtimeType.toString());
                        Navigator.pop(context,fileSelect);
                      },
                      child: Text("选择"),
                    ) : Text("选择",style: TextStyle(color: Colors.transparent),),
                  ],
                ),
                color: Colors.grey[100]
            ),
            /// 筛选
            !widget.isScreen?SizedBox():Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],

              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10,right: 10),
              height: 45,
              child:  Container(
                width: 80,
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      underline: Container(color: Colors.white),
                      style: Theme.of(context).textTheme.subtitle2,
                      elevation: 8,
                      hint: Text('选择类型'),
                      items: List.generate(fileTypeEnd.length, (index) {
                        return DropdownMenuItem(child: Text(fileTypeEnd[index]), value: index,);
                      }),
                      onChanged: (value) {
                        // 0是全部
                        if (value == 0){
                          widget.fileTypeEnd = fileTypeEnd;
                          getFilesAndroid();
                        }else{
                          widget.fileTypeEnd = [fileTypeEnd[value]];
                          getFilesAndroid();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            /// 列表
            Expanded(child: list.length==0?Center(child: Text("无文件~"),):ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  value: fileSelect.contains(list[index]),
                  onChanged: (bool value){
                    if(!fileSelect.contains(list[index])){
                      /// 等于最大可选 拦截点击 并提示
                      if(widget.maxCount==fileSelect.length){
                        Scaffold.of(context).showSnackBar(SnackBar(content: new Text('最多可选${widget.maxCount}个文件')));
                        return;
                      }
                      fileSelect.add(list[index]);
                    }else{
                      fileSelect.removeAt(fileSelect.indexOf(list[index]));
                    }
                    setState(() { });
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
            ),),
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
      m["str"] = "Word";
      m["color"] = Colors.blue[400];
      return m;
    }
    if(str.endsWith(".xlsx") || str.endsWith(".xls")){
      Map m = Map();
      m["str"] = "Excel";
      m["color"] = Colors.green[400];
      return m;
    }
    if(str.endsWith(".txt")){
      Map m = Map();
      m["str"] = "TxT";
      m["color"] = Colors.grey[400];
      return m;
    }
    Map m = Map();
    m["str"] = str.substring(str.lastIndexOf(".")+1,str.length);
    m["color"] = Colors.grey[500];
    return m;
  }
}

