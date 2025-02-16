// Copyright (c) 2023-2025 GerrysApps.com  
// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, prefer_initializing_formals

import 'dart:core';
import 'package:intl/intl.dart';

class FileSpec {
  static DateFormat df = DateFormat('yyyy-MM-dd'); // HH:mm');

  String filename = '';
  String path = 'poop';
  String size = 'doop';
  String datetime = 'goop';
  int sz = 0;

  static String date2date(DateTime dt) { 
    return df.format(dt);
  }

  FileSpec.s({String? filename, required String path, required String date, required String size}) {
    this.filename = filename as String;
    this.path = path;
    datetime = date;
    this.size = size;
  }

  FileSpec({String? filename, required String path, required String date, required int size}) {
    this.filename = filename as String;
    // this.date = date;
    this.path = path;
    // this.datetime = df.format(date);
    datetime = date;
    sz = size;

    if (size < 1 || filename.isEmpty) {
      this.size = ' ';
      datetime = ' ';
    }
    else if (size > 1024 * 1024 * 1024)
      this.size = '${(size / 1024 / 1024 / 1024).round()} Gb';
    else if (size > 1024 * 1024)
      this.size = '${(size / 1024 / 1024).round()} Mb';
    else if (size > 1024 * 50)
      this.size = size.toString();
    else
      this.size = '${(size / 1024).round()}K';
  }

  FileSpec.fromJson(Map<String, dynamic> json)
      : filename = json['filename'],
        path = json['path'],
        size = json['size'],
        datetime = json['datetime'];

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'path': path,
      'size': size,
      'datetime': datetime,
    };
  }
}
