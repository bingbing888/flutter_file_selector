import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../comm/comm.dart';
import '../model/file_util_model.dart';

/// todo:  安卓端 UI
class FlutterFileSelector extends StatefulWidget {
  String title;// 标题
  List<String> fileTypeEnd;// 展示的文件后缀   默认：".pdf , .docx , .doc"
  bool isScreen;// 默认关闭筛选
  int maxCount;// 可选最大总数 默认个
  FlutterFileSelector(
      {
        this.title,
        this.fileTypeEnd,
        this.isScreen:false,
        this.maxCount:9
      }
      );
  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {

  /// todo:  选择的文件
  List<FileModelUtil> fileSelect = [];

  /// todo:  原生交互通道
  static const MethodChannel _channel = const MethodChannel('flutterfileselector');

  /// todo:  解析到的原生返回的数据
  static List<FileModelUtil> list = [];

  /// todo:  error 信息
  static String errorMsg = "";

  List<String> fileTypeEnd = [];

  int btnIndex = 0;

  List musicExpanName = [".mp3",".wav",".ape",".ogg",".flac"];

  List videoExpanName = [".avi",".mp4",".rmvb",".mov",".rm",".flv"];

  List rarExpanName = [".zip",".rar",".iso",".7z",".gzip"];

  List imgExpanName = [".bmp",".jpg",".png",".gif",".svg",".webp",".jpeg"];

  bool loading = true;
  @override
  void initState() {
    super.initState();
    fileTypeEnd = widget.fileTypeEnd;
    Future.delayed(Duration(milliseconds:300),(){
      getFilesAndroid();
    });
  }

  /// todo:  调用原生 得到文件+文件信息
  void getFilesAndroid () async {

    try{
      if (await Permission.storage.request().isGranted) {

        errorMsg = "";

        log("当前能选的类型 安卓："+widget.fileTypeEnd.toString());

        Map<String, Object> map = {"type": widget.fileTypeEnd ?? [ ".pdf", ".docx", ".doc" ]};

        final List<dynamic>  listFileStr = await _channel.invokeMethod('getFile',map);
        loading = false;
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
        /// todo: 降序
//        list.sort((a,b)=>b.file.statSync().changed.compareTo(a.file.statSync().changed));
      }else{
        errorMsg = "当前设备未允许读写权限，无法检索目录!";
        print(errorMsg);
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
        /// todo:
        if (!fileTypeEnd.contains("全部")){
          fileTypeEnd.insert(0, "全部");
        }

        return Column(
          children: <Widget>[
            /// todo:  appbar
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
                      // child: Text("选择"),
                      child: Image.asset("images/select.png",width: 25,height: 25,package: Comm.PACKNAME,),
                    ) : Text("选择",style: TextStyle(color: Colors.transparent),),
                  ],
                ),
                color: Colors.grey[100]
            ),
            /// todo:  筛选
            !widget.isScreen?SizedBox():Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],

              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10,right: 10),
              height: 45,
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                  Text("总文件数 ${list.length}"),
                ],
              ),
            ),
            /// todo:  列表
            Expanded(child: list.length==0 && loading?Center(child: Text("加载中..."),):ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  value: fileSelect.contains(list[index]),
                  onChanged: (bool value){
                    if(!fileSelect.contains(list[index])){
                      /// todo:  等于最大可选 拦截点击 并提示
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
                    child: Image.asset(_type(list[index].filePath)["png"], package: Comm.PACKNAME,width: 50,height: 50,),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  title: new Text("${list[index].fileName}",overflow: TextOverflow.ellipsis,),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(" ${File(list[index].filePath).statSync().changed}",style: TextStyle(fontSize: 14,color: Colors.grey[400]),),
                      Text(" ${(File(list[index].filePath).statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",style: TextStyle(fontSize: 14,color: Colors.grey[400]),),
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

  /// todo: 待优化
  _type(String str){
    str = str.toLowerCase();
    Map m = Map();
    if(str.endsWith(".pdf")){
      m["png"] = "images/pdf.png";
      return m;
    }
    if(str.endsWith(".ppt") || str.endsWith(".pptx")){
      m["png"] = "images/ppt.png";
      return m;
    }
    if(str.endsWith(".doc") || str.endsWith(".docx")){
      m["png"] = "images/word.png";
      return m;
    }
    if(str.endsWith(".xlsx") || str.endsWith(".xls")){
      m["png"] = "images/excel.png";
      return m;
    }
    if(str.endsWith(".txt")){
      m["png"] = "images/txt.png";
      return m;
    }

    for(int i=0; i<musicExpanName.length ; i++){
      if(str.endsWith(musicExpanName[i])){
        m["png"] = "images/music.png";
        return m;
      }
    }

    for(int i=0; i<videoExpanName.length ; i++){
      if(str.endsWith(videoExpanName[i])){
        m["png"] = "images/video.png";
        return m;
      }
    }

    for(int i=0; i<rarExpanName.length ; i++){
      if(str.endsWith(rarExpanName[i])){
        m["png"] = "images/ys.png";
        return m;
      }
    }

    for(int i=0; i<imgExpanName.length ; i++){
      if(str.endsWith(imgExpanName[i])){
        m["png"] = "images/image.png";
        return m;
      }
    }
    m["png"] = "images/out.png";
    return m;
  }
}