// ignore_for_file: curly_braces_in_flow_control_structures

// Copyright (c) 2023-2025 GerrysApps.com  
import 'package:yaml/yaml.dart';

class TabDefinition { 
  String name = 'undefined';

  List<String> suffixes = [];
  List<String> locations = [];
  List<String> ignores = [];
  bool children = true;

  String? newsufs;
  String? newfolds;

  //______________________________________________________________________________
  void save() {
    var sufs = newsufs?.split(',');
    if (sufs != null && sufs.isNotEmpty) {
      suffixes.clear();
      for (var suf in sufs) 
        suffixes.add(suf.trim());
    }
    var folds = newfolds?.split(',');
    if (folds != null && folds.isNotEmpty) { 
      locations.clear();
      for (var fol in folds) 
        locations.add(fol.trim().replaceAll('\\', '/'));
    }
  }

  void placeholder() { 
    name = 'Place holder only';
    suffixes.add('doc');
    suffixes.add('txt');
    locations.add('c:/replace_this_with_a_real_folder');
  }

  //______________________________________________________________________________
  static TabDefinition build(String name, YamlList suffixes, YamlList locations, YamlList? ignores, String? child) {
    TabDefinition tb = TabDefinition();
    tb.name = name;
    for (var element in suffixes) {
      tb.suffixes.add(element.toString().toLowerCase());
    }
    for (var element in locations) {
      tb.locations.add(element.toString());
    }
    if (ignores != null) {
      for (var element in ignores) {
        tb.ignores.add(element.toString());
      }
    }
    if (child != null) { 
      if (child.toString().toLowerCase().contains("no")) { 
        tb.children = false;
      }
    }
    return tb;
  }

  unittest() {
    name = 'just testing';
    suffixes = ['a', 'b'];
    locations = ['F:/TV'];
  }
}