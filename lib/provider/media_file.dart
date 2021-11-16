import 'dart:io';

enum CompressionStatus { PROCESSING, PENDING, COMPLETED, CANCELED }

class MediaFile {
  String description = "initial";
  final String type;
  final String path;
  final File file;
  final int duration;
  CompressionStatus compressionStatus = CompressionStatus.PENDING;

  MediaFile({
    required this.type,
    required this.path,
    required this.file,
    required this.duration,
    this.compressionStatus = CompressionStatus.PENDING,
  });
}
