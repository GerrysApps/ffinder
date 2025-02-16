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

// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print
import 'dart:core';
import 'package:ffinder/cache.dart';
import 'package:ffinder/tabdefinition.dart';

import 'filespec.dart';

// TODO be able to search for folders, doesn't work for root folder
class Search {
  static List<String> ignore = [];
  List<FileSpec> files = List.of([]);

  //_____________________________________________________________________________
  void clear(TabDefinition mytabdef) {
    Cache.get().clear(mytabdef);
  }

  //______________________________________________________________________________
  bool cached(String name, int index) {
    return Cache.get().cached(name, index);
  }

// TODO always add root folders?
  //_____________________________________________________________________________
  Future<List<FileSpec>> searchForFilesAndFolders(String search, TabDefinition tabdef) async {
    //_tabdef = tabdef;
    files.clear();

    List<FileSpec> allfiles = await Cache.get().getAllHash(tabdef);
    List<String> searches = _tokenize(search);

    for (var fspec in allfiles) 
    { 
      if (fspec.filename.isEmpty) {
        if (_matchSearch(searches, fspec.path)) {
            files.add(fspec);
            continue;
        }
      }

      if (fspec.filename.isEmpty)
          continue;

      int dot = fspec.filename.lastIndexOf(".");
      if (dot < 1)
          continue;
      var dotsuffix = fspec.filename.substring(dot);
      if (!_suffixMatch(tabdef.suffixes, dotsuffix))
          continue;

      if (_matchSearch(searches, fspec.filename) || _matchSearch(searches, fspec.path)) 
      {
          // TODO if this is the first file in a folder that is a match, also add the folder
          /* Not easy!
          if (lastfolderadded != fspec.path) {
            var fs = FileSpec(filename: fspec.filename, path: fspec.path, date: fspec.datetime, size: 0);
            lastfolderadded = fspec.path;
            files.add(fs);
          }
          */
        files.add(fspec);
      }
    }
    return files;
  }

  bool _suffixMatch(List<String> suffixes, String dotsuffix) {
    if (suffixes.isEmpty) return true;
    for (String suf in suffixes) {
      if (dotsuffix.toLowerCase().endsWith(suf.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  // tokenize the search, with support for double quotes for searches that include the space character
  List<String> _tokenize(String search) {
    List<String> words = [];
    if (search.isEmpty) {
      return words;
    }

    // look for double quotes
    int sdq = search.indexOf('"');
    int edq;
    sdq == -1 ? edq = -1 : edq = search.indexOf('"', sdq + 1);
    while (sdq > -1 && edq > -1) {
      String a = search.substring(0, sdq);
      String m = search
          .substring(sdq, edq)
          .replaceAll(' ', '/'); // filename can't have slashes! nice!
      String z = search.substring(edq);
      search = '$a$m$z';

      sdq = search.indexOf('"', edq + 1);
      sdq == -1 ? edq = -1 : edq = search.indexOf('"', sdq + 1);
    }

    search = search.replaceAll('"', '');
    words = search.split(' ');
    for (int i = 0; i < words.length; i++) {
      words[i] = words[i].replaceAll('/', ' ');
    }

    return words;
  }

  bool _matchSearch(List<String> searches, String filename) {
    int start = 0;
    for (int i = 0; i < searches.length; i++) {
      String search = searches[i]; 
      int index = filename.toLowerCase().indexOf(search.toLowerCase(), start);
      if (index < 0) 
        return false;
      if (searches.length == 1 && search.length == 3) { 
          // if (!filename.endsWith(search))
          // if all that is entered is a suffix, require an exact match TODO: really? no it fails for some reason
          // return false; 
      }
      start = index + 1; // TODO care about order or not?
    }
    return true;
  }
}

/*
class MyFileSystem {
  Future<void> tester() async {
    Directory tempDir = await getTemporaryDirectory();
    print(tempDir.path);

    listfiles(tempDir.listSync());

    Directory appDocDir = await getApplicationDocumentsDirectory();
    print(appDocDir.path);

    listfiles(appDocDir.listSync());
  }

  void listfiles(List<FileSystemEntity> entities) {
    for (var entity in entities) {
      print(entity.path);
    }
  }
}
*/
  /*
  how to do it with a timer: hard way

  var completer = Completer();
  var timeoutDuration = const Duration(seconds: 10);

  void timeout() {
    completer.completeError("Timed out");
  }

  void cancelTimeout() {
    completer.complete();
  }

  Future<void> function() async {
    var timer = Timer(timeoutDuration, timeout);

    try {
      var directory = Directory("x:/");
      await for (FileSystemEntity entity in directory.list(recursive: true, followLinks: false)) {
        // code to process each entity
        cancelTimeout(); // cancel the timeout once we start processing entities
      }
    } 
    catch (e) {
      print("An error occurred: $e");
    } 
    finally {
      timer.cancel(); // cancel the timeout
    }
  }

class MyFile {
  static DateFormat df = DateFormat('yyyy-MM-dd'); // HH:mm');

  String filename = '';
  String path = 'poop';
  String size = 'doop';
  String datetime = 'goop';
  DateTime? date;

  MyFile({String? filename, required String path, required DateTime date, required int size}) {
    this.filename = filename as String;
    this.date = date;
    this.path = path;
    this.datetime = df.format(date);

    if (size < 1 || filename.isEmpty) {
      this.size = ' ';
      this.datetime = ' ';
    }
    else if (size > 1024 * 1024 * 1024)
      this.size = '${(size / 1024 / 1024 / 1024).round()} Gb';
    else if (size > 1024 * 1024)
      this.size = '${(size / 1024).round()} Mb';
    else if (size > 1024 * 50)
      this.size = size.toString();
    else
      this.size = '${(size / 1024).round()}K';
  }
}
*/

  //_____________________________________________________________________________
  // this handles one folder
  /*
  Future<void> _find(List<String> searches, String folder, List<String> suffixes) async {
    var directory = Directory(folder); // this is the root folder
    if (!directory.existsSync()) {
      return;
    }
    if (SettingsYaml.ignorePath(folder.replaceAll("\\", "/"), tb)) {
      return;
    }
    if (_matchSearch(searches, folder)) {
      // print('root folder match, add $folder');
      var stats = directory.statSync();
      String dt = FileSpec.fuckoff(stats.modified);
      files.add(
          FileSpec(filename: '', path: folder, size: stats.size, date: dt));
    }

    await for (FileSystemEntity entity
        in directory.list(recursive: true, followLinks: false)) {
      if (!tb.children ||
          SettingsYaml.ignorePath(entity.path.replaceAll('\\', '/'), tb)) {
      } else if ((await FileSystemEntity.isDirectory(entity.path))) {
        var path = entity.path.replaceAll("\\", "/");
        if (_matchSearch(searches, path)) {
          // print('subfolder match, add $path');
          var stats = entity.statSync();
          String dt = FileSpec.fuckoff(stats.modified);
          files.add(FileSpec(
              filename: '',
              path: path,
              size: stats.size,
              date: dt)); // this is a child folder
        }
      } 
      else {
        var filename = _filename(entity.path);
        var path = entity.parent.path.replaceAll("\\", "/");
        int dot = filename.lastIndexOf(".");
        if (dot > -1) {
          var dotsuffix = filename.substring(dot);
          if (_suffixMatch(suffixes, dotsuffix)) {
            if (_matchSearch(searches, filename)) {
              // print('its a file match! $filename');
              var stats = entity.statSync();
              String dt = FileSpec.fuckoff(stats.modified);
              files.add(FileSpec(
                  filename: filename,
                  path: path,
                  size: stats.size,
                  date: dt)); // this is a child folder
            } else if (_matchSearch(searches, path)) {
              // print('its a folder match! $filename');
              var stats = entity.statSync();
              String dt = FileSpec.fuckoff(stats.modified);
              files.add(FileSpec(
                  filename: filename,
                  path: path,
                  size: stats.size,
                  date: dt)); // this is a child folder
            } else {
              // print('not a match $filename');
            }
          } else {
            // print('no suffix match $filename $path');
          }
        } else {
          // print('no dot found $filename');
        }
      }
    }
  }
  */

/*
  bool testy() {
    RegExp regExp = RegExp(r'[A-Za-z0-9]');

    bool matches = regExp.hasMatch('hello123');

    return matches;
  }

    var folder = Directory('C:/Users/Everybody/Documents/CircleDock');

    //List<FileSystemEntity> files = folder.listSync();
    //for (var file in files) { }

    // this is better cause it recurses
    await for (FileSystemEntity entity in folder.list(recursive: true, followLinks: false)) {
    //var search = "a b Q X z".toLowerCase();
      var searches = search.toLowerCase().split(' ');

      if (!(await FileSystemEntity.isDirectory(entity.path))) {
        var filename = entity.path.substring(entity.parent.path.length + 1); // MUST use var!?
        var lowerfilename = filename.toLowerCase();
        var path = entity.parent.path.replaceAll("\\", "/");

        int dot = lowerfilename.lastIndexOf(".");
        if (dot > 0) { 
          var suffix = lowerfilename.substring(dot);

          if (suffix == '.dll' || suffix == '.png') { 
            for (var sear in searches) {
              if (lowerfilename.contains(sear)) {
                // ignore: avoid_print
                // print('$filename in folder $path'); // object requires ${ }
                files.add(MyFile(filename: filename, path: path));
                break;
              }
            }

          }
        }
      }
    }
    */

  /*
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
  */

  //_____________________________________________________________________________
  /*
  Future<List<FileSpec>> _find_old(String search, TabDefinition tabdef) async {
    tb = tabdef;
    files.clear();
    List<String> searches = tokenize(search);

    for (var location in tabdef.locations) {
      try {
        await _find(searches, location, tabdef.suffixes);
      } catch (e) {
        // ignore: avoid_print
        print("location $location is unavailable $e");
      }
    }
    // 0,1,2,3
    for (int i = files.length - 2; i >= 0 && files.length > 1; i--) {
      if (files[i].filename.isEmpty && files[i + 1].filename.isEmpty) {
        files.removeAt(i);
      }
    }

//    if (search.isEmpty)
//      _cache.save2disk(tabdef.name, files);
    return files;
  }
  */
/*
  bool _matchSuffixAndSearch(List<String> searches, String filename,
      String dotsuffix, List<String> suffixes) {
    bool foundsuffix = false;
    for (String suf in suffixes) {
      if (!foundsuffix && dotsuffix.toLowerCase().endsWith(suf.toLowerCase())) {
        foundsuffix = true;
      }
    }
    if (!foundsuffix) {
      return false;
    }
    return _matchSearch(searches, filename);
  }
  */
