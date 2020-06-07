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
  String title;// 标题
  List<String> fileTypeEnd;// 展示的文件后缀   默认：".pdf , .docx , .doc"
  String pdfImg;// pdf图标
  String wordImg;// word图标
  String directory;// 检索的目录 默认 /storage/emulated/0/ 安卓根目录
  bool isScreen;// 默认关闭筛选
  FlutterFileSelector(
      {
        this.title,
        this.fileTypeEnd,
        this.pdfImg,
        this.wordImg,
        this.directory:"/storage/emulated/0/",
        this.isScreen:false,
    }
      );
  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {
  /// 检索到的文件
  List<FileSystemEntity> files1 = [];
  /// 展示的文件后缀
  List<String> fileTypeEnd = [
    ".pdf",
    ".docx",
    ".doc"
  ];
  bool _loading = false;

  /// 选择的文件
  FileSystemEntity selectFs;
  @override
  void initState() {
    _loading = true;
    if(widget.fileTypeEnd!=null || widget.fileTypeEnd.length!=0){
      fileTypeEnd = widget.fileTypeEnd;
    }
    WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement initState
    super.initState();
    /// 先进来页面使用延迟加载
    Timer.periodic(Duration(milliseconds: 350), (v){
      v.cancel();
      try {
        filesDirs(Directory(widget.directory));
      } finally {
        _loading = false;
        /// 按时间倒叙
        files1.sort((a,b)=>(b.statSync().changed).compareTo(a.statSync().changed));
        setState(() { });
        print("加载结束了");
        log(files1.join(","));
      }
    });
  }

  filesDirs(Directory directory) {
    List<FileSystemEntity>  fs = directory.listSync();
    for(int i =0 ; i<fs.length ;i++){
      //若是目录，则递归目录下的文件
      if(FileSystemEntity.isDirectorySync(fs[i].path)){
//        print("目录"+i.toString());
        filesDirs(fs[i]);
      }
      //若是文件
      if(FileSystemEntity.isFileSync(fs[i].path)){
//        print("文件"+i.toString());
        /// 后缀匹配
        fileTypeEnd.forEach((element) {
          if( fs[i].path.endsWith(element)){
            files1.add(fs[i]);
          }
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
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
                Text("  ${widget.title ?? '文件选择器'}",style: TextStyle(height: 1.1,fontSize: 16,color: Colors.grey[700]),),
                InkWell(
                  onTap: (){
                    Navigator.pop(context,selectFs);
                  },
                  child: Text("选择"),
                ),
              ],
            ),
              color: Colors.grey[100]
          ),
          /// 提示
          !widget.isScreen?SizedBox():Container(padding: EdgeInsets.only(left: 10,right: 10),width: MediaQuery.of(context).size.width,height: 25,alignment: Alignment.centerLeft,color: Colors.grey[100],child: Text("(检索全部时，系统文件较多会比较慢)",style: TextStyle(color: Colors.grey[400],fontSize: 12),),),
         /// 筛选
          !widget.isScreen?SizedBox():Container(
            color: Colors.grey[100],
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10,right: 10),
            child: Wrap(
              alignment: WrapAlignment.start,
              children: <Widget>[
                OutlineButton(onPressed: (){
                },child: Text("全部"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("Word"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("PDF"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("微信"),),
                SizedBox(width: 5,),
                OutlineButton(onPressed: (){
                },child: Text("QQ"),),
              ],
            ),
          ),
          /// 列表
          Expanded(child: files1.length==0?Center(child: Text(_loading ? "正在检索文件,请稍等...":"当前目录为空"),):ListView.builder(
            itemCount: files1.length,
            padding: EdgeInsets.all(0),
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () async{
                  Navigator.pop(context,files1[index]);
                },
                child: CheckboxListTile(
                  value: selectFs==files1[index],
                  onChanged: (bool value){
                    setState(() {
                      selectFs = files1[index];
                    });
                  },
                  secondary: ClipRRect(
                    child: Container(
                      color:_type(files1[index].resolveSymbolicLinksSync())["color"],
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(_type(files1[index].resolveSymbolicLinksSync())["str"],style: TextStyle(color: Colors.white),),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  title: new Text("${files1[index].resolveSymbolicLinksSync().substring(files1[index].resolveSymbolicLinksSync().lastIndexOf("/")+1,files1[index].resolveSymbolicLinksSync().length)}",overflow: TextOverflow.ellipsis,),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(" ${files1[index].statSync().changed}",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                      Text(" ${(files1[index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
                    ],
                  ),
                  dense: false,
                  activeColor: Colors.blue[400],// 指定选中时勾选框的颜色
                  checkColor: Colors.white,
                  isThreeLine: false,
                  selected: selectFs==files1[index],
                ),

//                Container(
//                    padding: EdgeInsets.all(5),
//                    alignment: Alignment.centerLeft,
//                    decoration: BoxDecoration(
//                        border: Border(bottom: BorderSide(color: Colors.grey[200],width: 1))
//                    ),
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          children: <Widget>[
//                            ClipRRect(
//                              child: Container(
//                                color:_type(files1[index].resolveSymbolicLinksSync())["color"],
//                                width: 40,
//                                height: 40,
//                                alignment: Alignment.center,
//                                child: Text(_type(files1[index].resolveSymbolicLinksSync())["str"],style: TextStyle(color: Colors.white),),
//                              ),
//                              borderRadius: BorderRadius.circular(3),
//                            ),
////                            Image.asset("${files1[index].resolveSymbolicLinksSync().contains(".pdf")? 'images/Pdf.png' : 'images/word.png'}",fit: BoxFit.fill,width: 35,height: 35,),
//                            SizedBox(width: 15,),
//                            Expanded(child: Text("${files1[index].resolveSymbolicLinksSync().substring(files1[index].resolveSymbolicLinksSync().lastIndexOf("/")+1,files1[index].resolveSymbolicLinksSync().length)}",overflow: TextOverflow.ellipsis,maxLines: 2,),),
//                          ],
//                        ),
//                        SizedBox(height: 3,),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            Text(" ${files1[index].statSync().changed}",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
//                            Text(" ${(files1[index].statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",style: TextStyle(fontSize: 12,color: Colors.grey[400]),),
//                          ],
//                        ),
//                      ],
//                    )
//                ),
              );
            },
          ),)
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
    m["str"] = str.substring(str.lastIndexOf(".")+1,str.length);
    m["color"] = Colors.grey[500];
    return m;
  }
}

