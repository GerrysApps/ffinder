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
// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, unused_import

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ffinder/filemanager.dart';
import 'package:ffinder/filespec.dart';
import 'package:ffinder/tabdefinition.dart';
import 'package:synchronized/synchronized.dart';

class Cache {
  final FileManager _filemanager = FileManager();

  final HashMap<String, List<FileSpec>> _cache = HashMap<String, List<FileSpec>>(); // tabname -> List of FileSpec

  static Cache? _instance;

  //______________________________________________________________________________
  static Cache get() { 
    _instance ??= Cache._private();
    return _instance as Cache;
  }

  //______________________________________________________________________________
  Cache._private() { 
    _instance = this;
  }

  //______________________________________________________________________________
  Future<List<FileSpec>> getAllHash(TabDefinition td) async {
    String key = td.name; // '${td.name}.$index'; this would be needed for tabs with the same name, not supported

    if (_cache.containsKey(key)) {
      print('found cache in memory, return data for ${td.name}');
      return Future.value(_cache[key]);
    }

    if (!_cache.containsKey(td.name)) {
      print('not found in memory ${td.name}');

      if (_readJson(key)) {
        print('found json file of data to use for ${td.name}, loading and return');
        return Future.value(_cache[key]);
      }
    }

    // cache from disk
    print('found nothing for ${td.name} need to read hard-drives');
    List<FileSpec> fileSpecs = await _filemanager.readHardDrives(td);

    try {
      print('put dat shit into ${td.name} ${fileSpecs.length}');
      _cache[key] = fileSpecs;
      _save2disk(td.name, fileSpecs);
    } 
    catch (e) {
      print('getAll(${td.name}) exception $e');
    }

    return _cache[key] as List<FileSpec>;
  }

  //______________________________________________________________________________
  void clear(TabDefinition tab) {
      var file = File('${tab.name}.json');
      if (!file.existsSync())
        return;
      File('${tab.name}.json').deleteSync();
      String key = tab.name; // .$index';
      _cache.remove(key);
  }

  //______________________________________________________________________________
  void _save2disk(String tabname, List<FileSpec> files) {
    try {
      var jsonString = json.encode(files);
      String key = tabname; 
      File('$key.json').writeAsStringSync(jsonString);
    } 
    catch (e) {
      print(e);
    }
  }

  //______________________________________________________________________________
  bool cached(String name, int index) { 
    print('find cache? $name');
    String key = name;// '$name.$index';
    return _cache.containsKey(key);
  }

  //______________________________________________________________________________
  bool _readJson(String key) {
    try {
      String path = join(Directory.current.path, '$key.json');
      File file = File(path);
      if (!file.existsSync())
        return false;

      List<dynamic> filedata  = json.decode(file.readAsStringSync());

      List<FileSpec> specs = [];
      for (var map in filedata) {
        try {
          var f = map['filename'];
          var p = map['path'];
          var d = map['datetime'];
          var s = map['size'];
        
          var fs = FileSpec.s(filename: f, path: p, date: d, size: s);
          specs.add(fs);
        } 
        catch(e) { 
          print('read $key json failed for $map $e');
        }
      }

      _cache[key] = specs;
      return true;
    } 
    catch (e) {
      print(e);
      return false;
    }
  }
}