// ignore_for_file: curly_braces_in_flow_control_structures

// Copyright (c) 2023-2025 GerrysApps.com  
import 'dart:core';
import 'dart:io';
import 'package:ffinder/settings.dart';
import 'package:ffinder/tabdefinition.dart';
import 'filespec.dart';

// TODO don't match text on just the suffix, unless just 3 letters are entered

class FileManager {
  static List<String> ignore = [];

  late TabDefinition tb;

  Future<List<FileSpec>> readHardDrives(TabDefinition tabdef) async {
    tb = tabdef;
    List<FileSpec> files = List.of([]);

    for (var location in tabdef.locations) {
      try {
        await _find(files, location, tabdef.suffixes);
      } 
      catch (e) {
        // ignore: avoid_print
        print("location $location is unavailable $e");
      }
    }

    // remove two empty folders in a row
    /*
    for(int i = files.length - 2; i >= 0 && files.length > 1; i--) { 
      if (files[i].filename.isEmpty && files[i + 1].filename.isEmpty) { 
        files.removeAt(i);
      }
    }
    */

    // remove empty folders 
    for(int i = files.length - 1; i >= 0 && files.length > 1; i--) { 
      if (files[i].filename.isEmpty) {
        if (!rootfolder(files[i]))
          files.removeAt(i);
      }
    }
    return files;
  }

  // this handles one folder
  Future<void> _find(List<FileSpec> files, String folder, List<String> suffixes) async {
    var directory = Directory(folder); // this is the root folder
    if (!directory.existsSync()) {
      return;
    }
    if (SettingsYaml.get().ignorePath(folder.replaceAll("\\", "/"), tb)) {
      return;
    }
    // if (_matchSearch(searches, folder)) { }
print('finding in folder $folder');
    var stats = directory.statSync();
    String dt = FileSpec.date2date(stats.modified);
    files.add(FileSpec(filename: '', path: folder, size: stats.size, date: dt));

    await for (FileSystemEntity entity in directory.list(recursive: true, followLinks: false)) {
      if (!tb.children || SettingsYaml.get().ignorePath(entity.path.replaceAll('\\', '/'), tb)) {
      }
      else if ((await FileSystemEntity.isDirectory(entity.path))) {
        var path = entity.path.replaceAll("\\", "/");
        // if (_matchSearch(searches, path)) 
        {
          // print('subfolder match, add $path');
          var stats = entity.statSync();
          String dt = FileSpec.date2date(stats.modified);
          files.add(FileSpec(filename: '', path: path, size: stats.size, date: dt)); // this is a child folder
        }
      } 
      else {
        var filename = _filename(entity.path);
        var path = entity.parent.path.replaceAll("\\", "/");
        int dot = filename.lastIndexOf(".");
        if (dot > -1) {
          var dotsuffix = filename.substring(dot);
          if (_suffixMatch(suffixes, dotsuffix)) {
            // if (_matchSearch(searches, filename)) 
            {
              // print('its a file match! $filename');
              var stats = entity.statSync();
              String dt = FileSpec.date2date(stats.modified);
              files.add(FileSpec(filename: filename, path: path, size: stats.size, date: dt)); // this is a child folder
            } 
            /*
            else if (_matchSearch(searches, path)) 
            {
              // print('its a folder match! $filename');
              var stats = entity.statSync();
              files.add(FileSpec(filename: filename, path: path, size: stats.size, date: stats.modified)); // this is a child folder
            } 
            */
            // else { // print('not a match $filename'); }
          } 
          else {
            // print('no suffix match $filename $path');
          }
        } 
        else {
          // print('no dot found $filename');
        }
      }
    }
  }

  bool _suffixMatch(List<String> suffixes, String dotsuffix) {
    if (suffixes.isEmpty)
      return true;
    for (String suf in suffixes) {
      if (dotsuffix.toLowerCase().endsWith(suf.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  String _filename(String path) {
    int backslash = path.lastIndexOf('\\');
    if (backslash < 0) {
      backslash = path.lastIndexOf('/');
    }
    if (backslash < 0) {
      backslash = path.indexOf(':');
    }
    return path.substring(backslash + 1);
  }
  
  //______________________________________________________________________________
  bool rootfolder(FileSpec fil) {
    for (var loc in tb.locations) {
      if (fil.path.compareTo(loc) == 0)
        return true;
    }
    return false;
  }

  /*
  List<String> tokenize(String input) {
    List<String> words = [];
    if (input.isEmpty) {
      return words;
    }

    int dq = input.indexOf('"');
    int edq = -1;
    dq == -1 ? edq = -1 : edq = input.indexOf('"', dq + 1);
    while (dq > -1 && edq > -1) {
      String a = input.substring(0, dq);
      String q = input
          .substring(dq, edq)
          .replaceAll(' ', '/'); // filename can't have slashes! nice!
      String z = input.substring(edq);
      input = '$a$q$z';
      dq = input.indexOf('"', edq + 1);
      dq == -1 ? edq = -1 : edq = input.indexOf('"', dq + 1);
    }

    input = input.replaceAll('"', '');
    words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      words[i] = words[i].replaceAll('/', ' ');
    }

    return words;
  }

  bool _matchSearch(List<String> searches, String filename) {
    int start = 0;
    for (int i = 0; i < searches.length; i++) {
      int index =
          filename.toLowerCase().indexOf(searches[i].toLowerCase(), start);
      if (index < 0) {
        return false;
      }
      start = index + 1;
    }
    return true;
  }
  */
}