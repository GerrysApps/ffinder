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

// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, non_constant_identifier_names, prefer_final_fields
import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import 'package:ffinder/tabdefinition.dart';

abstract class SettingsChangedInterface {
  void settingsChanged();
}

//______________________________________________________________________________
class SettingsYaml { 
  List<TabDefinition> _tabDefinitions = [];
  List<String> _ignores = [];
  bool restartRequired = false;
  bool date = true;
  bool size = false;

  static SettingsChangedInterface? _updateCallback;
  static SettingsYaml? _instance;

  //______________________________________________________________________________
  static SettingsYaml get() { 
    if (_instance != null)
      return _instance as SettingsYaml;
    _instance = SettingsYaml._();
    return _instance as SettingsYaml ;
  }

  //______________________________________________________________________________
  void setUpdateCallback(SettingsChangedInterface callback) {
    _updateCallback = callback;
  }
  
  //______________________________________________________________________________
  SettingsYaml._() { 
     _readYaml();
  }
  
  //______________________________________________________________________________
  bool _readYaml() { 
    try {
      _read();
 //     firstTabname = _tabDefinitions[0].name;
      return true;
    }
    catch(e) { 
      TabDefinition error = TabDefinition();
      error.name = e.toString();
      _tabDefinitions.add(error);
      return false;
    }
  }

  //______________________________________________________________________________
  _tab2Map(TabDefinition tab) {
    Map<String, dynamic> map = {};
    map.putIfAbsent('suffixes', () => tab.suffixes);
    map.putIfAbsent('locations', () => tab.locations);
    return map;
  }
  Map<String, dynamic> _tabs2Map() {
    Map<String, dynamic> map = {};
    for (var tab in _tabDefinitions) {
      map.putIfAbsent(tab.name, () => _tab2Map(tab));
    }
    return map;
  }
  Map<String, dynamic> _2Map() {
    return {
      'author': 'Gerry H',
      'date': date,
      'size': size,
      'tabs': _tabs2Map(),
      'ignore': _ignores,
    };
  }

  //______________________________________________________________________________
  List<String> ignore() { 
    return _ignores;
  }

  //______________________________________________________________________________
  List<TabDefinition> tabs() { 
    return _tabDefinitions;
  }

  //______________________________________________________________________________
  List<TabDefinition> tablist() { 
    return _tabDefinitions;
  }

  //______________________________________________________________________________
  TabDefinition? find(String name) { 
    if (name.isEmpty)
      return _tabDefinitions[0];
    for(var tab in _tabDefinitions) { 
      if (tab.name == name)
        return tab;
    }
    return _tabDefinitions[0];
  }

  //______________________________________________________________________________
  void _read() { 
    String path = join(Directory.current.path, "settings.yaml");
    File file = File(path);

    if (!file.existsSync()) {
      path = join(Directory.current.path, "sample-settings.yaml");
      file = File(path);
    }

    if (!file.existsSync()) {
      var td = TabDefinition();
      td.placeholder();
      _tabDefinitions.add(td);
      return;
    }

    String yamlString = file.readAsStringSync();
    YamlMap yaml = loadYaml(yamlString);

    YamlMap tabs = yaml['tabs'];

    // List<dynamic> tabs = yaml['tabs'];
    for (String key in tabs.keys) {
      YamlMap ym = tabs[key] as YamlMap;

      // for (var key in ym.keys) 
      {
        // YamlList suffixes = ym[key]['suffixes'] as YamlList;
        var suffixes = ym['suffixes'];
        var locations = ym['locations']; // as YamlList;
        var ignores = ym['ignore'];
        var children = ym['child folders'];

        _tabDefinitions.add(TabDefinition.build(key, suffixes, locations, ignores, children));
      }
    }

    var junk = yaml['ignore'];
    if (junk != null) {
      for(dynamic j in junk) { 
        _ignores.add(j.trim());
      }
    }

    var dat = yaml['date'];
    if (dat != null)
      date = dat;
    var siz = yaml['size'];
    if (siz != null)
      size = siz;
  }

  //______________________________________________________________________________
  void save(bool closingSettings) async {
    for (var tab in _tabDefinitions) {
      tab.save();
    }

    var json = _2Map();
    var yamlWriter = YAMLWriter();
    var yaml = yamlWriter.write(json); 

    String path = join(Directory.current.path, "settings.yaml");
    File file = File(path);

    await file.writeAsString(yaml);

    if (closingSettings)
      _updateCallback?.settingsChanged();
    else
      print("no need to restart the program");
  }

  //______________________________________________________________________________
  bool ignorePath(String path, TabDefinition tb) { 
    for(var s in _ignores) {
      if (path.contains(s)) {
        return true;
      }
    }
    for(var s in tb.ignores) {
      if (path.contains(s)) {
        return true;
      }
    }
    return false;
  }

  //______________________________________________________________________________
  void newTab(String name) {
    TabDefinition td = TabDefinition();
    td.name = name;
    _tabDefinitions.add(td);
  }

  //______________________________________________________________________________
  void updateSuffixes(String tabname, String value) {
    TabDefinition? tab = find(tabname);
    if (tab != null && tab.newsufs == null)
      tab.newsufs = "";
    tab?.newsufs = value;
  }

  //______________________________________________________________________________
  void updateFolders(String tabname, String value) {
    TabDefinition? tab = find(tabname);
    if (tab != null && tab.newfolds == null)
      tab.newfolds = "";
    tab?.newfolds = value;
  }

  //______________________________________________________________________________
  void deleteTab(String name) {
    for(var tab in _tabDefinitions) { 
      if (tab.name == name) { 
        _tabDefinitions.remove(tab);
        break;
      }
    }
  }

  //______________________________________________________________________________
  int count() {
    return _tabDefinitions.length;
  }
}

/*
sample file:

{
  author: Gerry
  tabs: [
    {Video: {suffixes: [mp4, mkv], locations: [c:/movies]}}, 
    {Audio: {suffixes: [mp3], locations: [c:/music]}}
  ]
}
*/

/*
    // Directory getCurrentDirectory() => Directory.current;
    // String cunt = getCurrentDirectory.path;
    // String path = 'C:/Users/Everybody/Documents/gpsowl/ffinder/se ttings.yaml';

    String path = join(Directory.current.path, "se ttings.yaml");
    File file = File(path);
    String yamlString = file.readAsStringSync();

    YamlMap yaml = loadYaml(yamlString);

    // print(yaml['author']); 
    // print(yaml['tabs']); // [{Video: {suffixes: [mp4, mkv], locations: [c:/movies]}}, {Audio: {suffixes: [mp3], locations: [c:/music]}}] 

    List<dynamic> tabs = yaml['tabs'];

    for (dynamic tab in tabs) {
      YamlMap ym = tab as YamlMap; // {Video: {suffixes: [mp4, mkv], locations: [c:/movies]}}
      // print('ym: $ym'); // ym: {Video: {suffixes: [mp4, mkv], locations: [c:/movies]}}

      for (var key in ym.keys) {
        // print('key: $key with value ${ym[key]}'); // Video with value {suffixes: [mp4, mkv], locations: [c:/movies]}
        YamlList suffixes = ym[key]['suffixes'] as YamlList;
        YamlList locations = ym[key]['locations'] as YamlList;
        settings.add(TabDefinition(key, suffixes, locations));
      }
    }
    return settings;
*/