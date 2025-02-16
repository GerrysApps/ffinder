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

// ignore_for_file: curly_braces_in_flow_control_structures
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