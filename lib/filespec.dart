/*
 * ffinder Copyright (c) 2023-2025 GerrysApps.com  
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * This program is also subject to the following additional terms under
 * GPLv3 Section 7:
 *
 *   If you distribute this or a modified version of this program, you must
 *   include a prominent notice stating that the original version of this
 *   software, ffinder, is available at GerrysApps.com. This notice 
 *   must be reasonably prominent, such as a notice displayed within the
 *   "About" section of the application or in accompanying documentation.
 */

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
