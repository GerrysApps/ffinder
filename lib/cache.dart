// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, unused_import

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ffinder/filemanager.dart';
import 'package:ffinder/filespec.dart';
import 'package:ffinder/tabdefinition.dart';
import 'package:synchronized/synchronized.dart';
//import 'package:ffinder/main.dart';
//import 'package:ffinder/search.dart';


class Cache {
  final FileManager _filemanager = FileManager();

  //List<FileSpec> movies = [];
  //List<FileSpec> tv = [];

  // List<List<FileSpec>> fucker = <List<FileSpec>>[];

  final HashMap<String, List<FileSpec>> _cache = HashMap<String, List<FileSpec>>(); // tabname -> List of FileSpec

//  Future<List<FileSpec>> find(String search, TabDefinition tabdef) async {
//    return _search.find(search, tabdef);
//  }

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