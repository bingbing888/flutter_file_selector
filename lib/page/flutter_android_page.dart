import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfileselector/comm/style.dart';
import 'package:flutterfileselector/model/drop_down_model.dart';
import 'package:permission_handler/permission_handler.dart';
import '../comm/comm.dart';
import '../model/file_util_model.dart';

/// todo:  安卓端 UI
class FlutterFileSelector extends StatefulWidget {
  String title; // 标题
  List<String> fileTypeEnd; // 文件后缀
  bool isScreen; // 默认关闭筛选
  int maxCount; // 可选最大总数 默认个
  List<DropDownModel> dropdownMenuItem;

  FlutterFileSelector({
    this.title,
    this.fileTypeEnd,
    this.isScreen: true,
    this.maxCount: 9,
    List<DropDownModel> dropdownMenuItem,
  }) {
    this.dropdownMenuItem = dropdownMenuItem ?? [];
  }

  @override
  _FlutterFileSelectorState createState() => _FlutterFileSelectorState();
}

class _FlutterFileSelectorState extends State<FlutterFileSelector> {
  /// todo:  选择的文件
  List<FileModelUtil> fileSelect = [];

  /// todo:  解析到的原生返回的数据
  List<FileModelUtil> list = [];

  /// todo:  文件类型
  List<String> fileTypeEnd = [];

  // 常用音乐格式
  List<String> musicExpanName = [".mp3", ".wav", ".ape", ".ogg", ".flac",".flv"];

  // 常用视频格式
  List<String> videoExpanName = [
    ".avi",
    ".mp4",
    ".rmvb",
    ".mov",
    ".rm",
    ".flv"
  ];

  // 常用压缩包格式
  List<String> rarExpanName = [".zip", ".rar", ".iso", ".7z", ".gzip"];

  // 常用图片格式
  List<String> imgExpanName = [
    ".bmp",
    ".jpg",
    ".png",
    ".gif",
    ".svg",
    ".webp",
    ".jpeg"
  ];

  bool loading = true;

  BuildContext ctx;

  @override
  void initState() {
    super.initState();
    fileTypeEnd = widget.fileTypeEnd;
    if (widget.dropdownMenuItem.isEmpty) {
      widget.dropdownMenuItem = [];
      widget.dropdownMenuItem.add(DropDownModel(lable: "全部", value: ["全部"]));
      widget.dropdownMenuItem.add(DropDownModel(lable: "文档", value: [ ".pdf", ".txt", ".xlsx", ".xls", ".doc", ".docx", ".pptx", ".ppt"]));
      widget.dropdownMenuItem.add(DropDownModel(lable: "视频", value: videoExpanName));
      widget.dropdownMenuItem.add(DropDownModel(lable: "音频", value: musicExpanName));
      widget.dropdownMenuItem.add(DropDownModel(lable: "图片", value: imgExpanName));
    }
    Future.delayed(Duration(milliseconds: 300), () {
      _getFilesAndroid();
    });
  }

  /// todo:  调用原生 得到文件+文件信息
  void _getFilesAndroid() async {
    try {
      // 校验权限
      if (await Permission.storage.request().isGranted) {
        Map<String, Object> map = {Comm.TYPE: widget.fileTypeEnd};
        // 将后缀发给原生，原生返回文件集合
        final String dataStr =
            await Comm.CHANNEL.invokeMethod(Comm.GET_FILE, map);
        List<dynamic> listFileStr = jsonDecode(dataStr);
        loading = false;
        list.clear();
        listFileStr.forEach((f) {
          list.add(FileModelUtil(
            fileDate: f["fileDate"],
            fileName: f["fileName"],
            filePath: f["filePath"],
            fileSize: f["fileSize"],
            file: File(f["filePath"]),
          ));
        });
      } else {
        _snackBarMsg('当前设备未允许读写权限，无法检索文件!');
      }
      setState(() {});
    } catch (e) {
      print("FlutterFileSelect Error:" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            color: Colors.grey[700],
          ),
        ),
        elevation: 0.0,
        actions: [
          fileSelect.length > 0 ? Row(
            children: [
              // 保持水波纹效果
              // InkWell里的child组件 不能设置color ，否则会覆盖
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Material(
                  color: Colors.grey[200], // child组件的颜色
                  child: InkWell(
                    child: Container(
                      height: 35,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text( "选择 ${fileSelect.length}/${widget.maxCount}",style: TextStyle(color: Colors.green)),
                    ),
                    onTap: (){
                      log("返回的类型：" + fileSelect.runtimeType.toString());
                      Navigator.pop(context, fileSelect);
                    },
                  ),
                ),
              ),
            ],
          ) : SizedBox(),
        ],
        title: Text( "  ${widget.title}",
          style: TextStyle(height: 1.1, fontSize: 16, color: Colors.grey[700]),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: Builder(builder: (BuildContext context) {
        ctx = context;
        return Column(
          children: <Widget>[
            /// todo:  筛选
            !widget.isScreen ? SizedBox() : _screenWidget(),

            /// todo:  列表
            Expanded(
              child: list.length == 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loading
                            ? CircularProgressIndicator(
                                strokeWidth: 6.0,
                                backgroundColor: Colors.grey[400],
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.black45),
                              )
                            : SizedBox(),
                        Text(
                          loading ? "加载中" : "没有文件~",
                          style: TextStyle(height: 1.5),
                        )
                      ],
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      padding: EdgeInsets.all(0),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          value: fileSelect.contains(list[index]),
                          onChanged: (bool value) {
                            if (!fileSelect.contains(list[index])) {
                              /// todo:  等于最大可选 拦截点击 并提示
                              if (widget.maxCount == fileSelect.length) {
                                _snackBarMsg('最多可选${widget.maxCount}个文件');
                                return;
                              }
                              fileSelect.add(list[index]);
                            } else {
                              fileSelect
                                  .removeAt(fileSelect.indexOf(list[index]));
                            }
                            setState(() {});
                          },
                          secondary: ClipRRect(
                            child: Image.asset(
                              _type(list[index].filePath)["png"],
                              package: Comm.PACKNAME,
                              width: 40,
                              height: 40,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          title: new Text(
                            "${list[index].fileName}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                " ${File(list[index].filePath).statSync().changed}",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[400]),
                              ),
                              Text(
                                " ${(File(list[index].filePath).statSync().size / 1024 / 1024).toStringAsFixed(2)} MB",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          dense: false,
                          activeColor: Colors.blue[400],
                          // 指定选中时勾选框的颜色
                          checkColor: Colors.white,
                          isThreeLine: false,
                          selected: fileSelect.contains(list[index]),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  /// todo: 筛选组件
  Widget _screenWidget() {
    return Container(
      color: Colors.grey[100],
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.dropdownMenuItem.length == 0
              ? SizedBox()
              : ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    underline: Container(color: Colors.transparent),
                    elevation: 8,
                    hint: Text('选择类型'),
                    items:
                        List.generate(widget.dropdownMenuItem.length, (index) {
                      return DropdownMenuItem(
                        child: Text(widget.dropdownMenuItem[index].lable),
                        value: widget.dropdownMenuItem[index].value,
                      );
                    }),
                    onChanged: (value) {
                      fileSelect = [];
                      if (value[0] == "全部") {
                        widget.fileTypeEnd = fileTypeEnd;
                        _getFilesAndroid();
                      } else {
                        widget.fileTypeEnd = value;
                        _getFilesAndroid();
                      }
                    },
                  ),
                ),
          Text("总文件数 ${list.length}"),
        ],
      ),
    );
  }

  /// todo: 列表组件
  Widget _listWidget() {

  }

  /// todo: 左侧子组件
  Widget _letWidget() {}

  /// todo: 内容子组件
  Widget _cententWidget() {}

  /// todo: 底部通知
  _snackBarMsg(msg) {
    Scaffold.of(ctx).removeCurrentSnackBar();
    Scaffold.of(ctx).showSnackBar(
      SnackBar(content: new Text(msg)),
    );
  }

  /// todo: 待优化
  _type(String str) {
    str = str.toLowerCase();
    Map m = Map();
    if (str.endsWith(".pdf")) {
      m["png"] = Style.IMG_PDF;
      return m;
    }
    if (str.endsWith(".ppt") || str.endsWith(".pptx")) {
      m["png"] = Style.IMG_PPT;
      return m;
    }
    if (str.endsWith(".doc") || str.endsWith(".docx")) {
      m["png"] = Style.IMG_WORD;
      return m;
    }
    if (str.endsWith(".xlsx") || str.endsWith(".xls")) {
      m["png"] = Style.IMG_EXCEL;
      return m;
    }
    if (str.endsWith(".txt")) {
      m["png"] = Style.IMG_TXT;
      return m;
    }

    for (int i = 0; i < musicExpanName.length; i++) {
      if (str.endsWith(musicExpanName[i])) {
        m["png"] = Style.IMG_MUSIC;
        return m;
      }
    }

    for (int i = 0; i < videoExpanName.length; i++) {
      if (str.endsWith(videoExpanName[i])) {
        m["png"] = "images/video.png";
        return m;
      }
    }

    for (int i = 0; i < rarExpanName.length; i++) {
      if (str.endsWith(rarExpanName[i])) {
        m["png"] = "images/ys.png";
        return m;
      }
    }

    for (int i = 0; i < imgExpanName.length; i++) {
      if (str.endsWith(imgExpanName[i])) {
        m["png"] = "images/image.png";
        return m;
      }
    }
    m["png"] = "images/out.png";
    return m;
  }
}
