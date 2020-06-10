import 'dart:io';

/// file信息实体
class FileModelUtil{
  File file;
  String fileName;
  int fileSize;
  String filePath;
  int fileDate;
  FileModelUtil(
      {
        this.fileDate,
        this.fileName,
        this.filePath,
        this.fileSize,
        this.file,
      });
}