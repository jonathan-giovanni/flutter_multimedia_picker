import 'dart:io';

class Media{
  String description = "initial";
  final String type;
  final String path;
  final File file;
  final int duration;

  Media({required this.type, required this.path, required this.file, required this.duration});

}