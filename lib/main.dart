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

// https://docs.flutter.dev/development/platform-integration/desktop
// https://docs.flutter.dev/deployment/windows    release a desktop app
// https://fonts.google.com/icons?icon.platform=ios

/*
MainStateApp: This class extends StatefulWidget, which means it represents a widget that has mutable state. 
This class is the main entry point of your app, and it likely contains the build method that returns the root widget of your app.

MainTabBar: This class extends State and implements SettingsChangedInterface. It is likely a child widget of MainApp, and it represents a tab bar 
that allows the user to switch between different views. It uses the TickerProviderStateMixin to provide an vsync object to its animation controller.
has callback

FilesStateTab: This class extends StatefulWidget, which means it represents a widget that has mutable state. It is likely a child widget of MainTabBar, 
and it represents a view that displays a list of files.

ListViewBuilderState: This class extends State and is the state object for FilesStateTab. It manages the mutable state for the FilesStateTab widget 
and provides the build method that returns the UI for the widget.
*/

import 'dart:async';
import 'dart:io';
// import 'dart:ffi';
// import 'package:ffinder/filemanager.dart';
import 'package:ffinder/search.dart';
import 'package:ffinder/settings.dart';
import 'package:ffinder/settingsscreen.dart';
import 'package:ffinder/tabdefinition.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//import 'ffinderapp.dart';
import 'filespec.dart';

void main() {
  //int a = 1;
  //if (a == 0)
  //  runApp(const FfinderApp()); // this is what was generated, where/how we want stuff to be eventually
  //else if (a == 1)
  runApp(MainStateApp());
}

/*
// Try running your application with "flutter run". You'll see the
// application has a blue toolbar. Then, without quitting the app, try
// changing the primarySwatch below to Colors.green and then invoke
// "hot reload" (press "r" in the console where you ran "flutter run",
// or simply save your changes to "hot reload" in a Flutter IDE).

 class FfinderApp extends StatelessWidget {
  const FfinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ffinder'),
    );
  }
}
*/

class MainStateApp extends StatefulWidget {
  MainStateApp({Key? key}) : super(key: key) {
    print('constructor main state app');
  }

  @override
  MainTabBar createState() => MainTabBar();
}

// https://flutterbyexample.com/lesson/stateful-widget-lifecycle
class MainTabBar extends State<MainStateApp>
    with TickerProviderStateMixin
    implements SettingsChangedInterface {
  int index = 0;
  List<Tab> maintabs = [];
  List<FilesStateTab> tabcontent = [];
  late TabController _tabController;

  MainTabBar() {
    print('constructor main tab bar');
  }

  //______________________________________________________________________________
  @override
  initState() {
    super.initState();

    rebuildMainTabs(0);
    SettingsYaml.get().setUpdateCallback(this);

    _tabController = TabController(length: maintabs.length, vsync: this, initialIndex: 0);
    _tabController.addListener(tabSelected);
  }

  //______________________________________________________________________________
  void rebuildMainTabs(int first) {
    print('rebuild tabs');
    maintabs.clear();
    tabcontent.clear();

    var settings = SettingsYaml.get();
    for (var tb in settings.tabs()) {
      maintabs.add(Tab(text: tb.name)); // , icon: Icon(Icons.queue_music)));
    }
    if (first > 0) _tabController.dispose();
      _tabController = TabController(length: maintabs.length, vsync: this, initialIndex: 0);
  }

  //______________________________________________________________________________
  void tabSelected() {
    print('index is now ${_tabController.index}');
    index = _tabController.index;
  }

  //______________________________________________________________________________
  @override
  Widget build(BuildContext context) {
    print(' ');
    print('building main tab bar');
    print(' why??? ');
    return MaterialApp(
      title: 'hello',
      theme: ThemeData(
          scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all<bool>(true),
      )),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('find your files'),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 13),
                child: IconButton(
                  tooltip: 'Show or hide the file size',
                  icon: const Icon(Icons.onetwothree,
                      color: Colors.greenAccent, size: 40.0),
                  onPressed: () {
                    tabcontent[_tabController.index]
                        .tabBodyListBuilder
                        ?._toggleSize(); // toggleSize();
                  },
                ),
              ),
              IconButton(
                tooltip: 'Show or hide the file date',
                icon: const Icon(Icons.calendar_month, color: Colors.orange),
                onPressed: () {
                  tabcontent[_tabController.index]
                      .tabBodyListBuilder
                      ?._toggleDate(); // toggleDate();
                },
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () {
                  tabcontent[_tabController.index]
                      .tabBodyListBuilder
                      ?._refresh();
                },
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings, color: Colors.brown),
                onPressed: () {
                  tabcontent[_tabController.index]
                      .tabBodyListBuilder
                      ?.openSettings();
                },
              ),
              IconButton(
                tooltip: 'Version 1.5.1 by ffinder@gerrysapps.com',
                icon: const Icon(Icons.mood, color: Colors.amber),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Open home page in your browser',
                icon: const Icon(Icons.help, color: Colors.white),
                onPressed: () {
                  launchWeb();
                },
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.amberAccent,
              indicatorWeight: 5,
              controller: _tabController,
              tabs: maintabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: buildTabContent(),
          ),
        ),
      ),
    );
  }

  //______________________________________________________________________________
  List<StatefulWidget> buildTabContent() {
    // we have access to 'widget' for state stuff
    print('build (all) tab content ');

    tabcontent.clear(); // adding clear (maybe this one?) fixed that widget length bug?
    for (int i = 0; i < SettingsYaml.get().tablist().length; i++) {
      tabcontent.add(FilesStateTab(td: SettingsYaml.get().tablist()[i]));
    }
    return tabcontent;
  }

  //______________________________________________________________________________
  Future<void> launchWeb() async {
    ProcessResult result = await Process.run('cmd', ['/c', 'start', '', 'https://orangesoftware.net/ffinder']);
    if (result.exitCode == 0) {
      // good
    } else {
      // bad
    }
  }

  //______________________________________________________________________________
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //______________________________________________________________________________
  @override
  void settingsChanged() {
    tabcontent[index].maybeRestart();

    // rebuildMainTabs(1); does not cause everything to be rebuilt, and nobody knows why
    // setState(() { });
  }
}

//______________________________________________________________________________
class FilesStateTab extends StatefulWidget {
  String searchString = "";
  late TabDefinition mytabdef;
  final List<FileSpec> seafiles = [];

  FilesStateTab({super.key, required TabDefinition td}) {
    print('constructor files state tab');
    mytabdef = td;
  }

  @override
  ListViewBuilderState createState() => ListViewBuilderState();

  ListViewBuilderState? tabBodyListBuilder;

  // already called within setState
  void setFiles(List<FileSpec> infiles) {
    seafiles.clear();
    for (var file in infiles) seafiles.add(file);
  }

  void maybeRestart() {
    if (SettingsYaml.get().restartRequired)
      tabBodyListBuilder?.restartFfinder();
  }
}

//______________________________________________________________________________
class ListViewBuilderState extends State<FilesStateTab> {
  final FocusNode _focusNode = FocusNode();
  final _textEditingController = TextEditingController();
  final _searchObject = Search();

  bool firstLoad = true;
  bool showBusy = false;
  bool showPath = true;
  bool showDate = SettingsYaml.get().date;
  bool showSize = SettingsYaml.get().size;

  //______________________________________________________________________________
  void openSettings() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  //______________________________________________________________________________
  void restartFfinder() {
    Alert(
      context: context,
      title: 'Question for you...',
      desc: 'Some changes require a program restart. Restart now?',
      buttons: [
        DialogButton(
        onPressed: () => Navigator.pop(context, true),
          width: 120,
          child: const Text(
            'Restart',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context, false),
          width: 120,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show().then((result) {
      if (result != null && result) {
        Process.run('ffinder.exe', []);
        Timer(const Duration(milliseconds: 100), () {
          exit(0);
        });
      }
    });
  }

  //______________________________________________________________________________
  // this gets called a lot
  @override
  void initState() {
    super.initState();
    print(
        'listviewbiulderstate initstate is called and tab tbody list builder hsa value $firstLoad');

    _textEditingController.text = widget.searchString;
    if (firstLoad) {
      firstLoad = false;
      Timer(const Duration(milliseconds: 500), () {
        _findFiles('');
      });
    }

    widget.tabBodyListBuilder =
        this; // TODO if I try to handle settings changes, this doesn't get a value?
  }

  //______________________________________________________________________________
  // this gets called a lot
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            const Align(alignment: Alignment.center, child: Text('Search:')),
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Type your search here...',
            hintStyle: TextStyle(color: Colors.purple),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.lightBlue,
          ),
          onChanged: _searchUpdated,
          onSubmitted:
              _findFiles, // magically passes the value from the text controller or something
          // onSubmitted: buildFuture,
          controller: _textEditingController,
          showCursor: true,
          focusNode: _focusNode,
        ),
        // actions:
      ),
      body: ListView.builder(
          itemExtent: 36,
          itemCount: widget.seafiles.length,
          itemBuilder: (BuildContext context, int index) {
            return getTile(context, index);
          }),
      floatingActionButton: Visibility(
        visible: showBusy,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  //______________________________________________________________________________
  // a tile is a widget for a file or path: as in, one line in the view of files
  ListTile getTile(BuildContext contet, int index) {
    FileSpec myfile = widget.seafiles[index];
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(8, -5, -5, 8),

      title: Flex(
        // Row and Flex both work
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: // do not call _expanded here it fails!
                Text(
              myfile.filename,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.purple),
            ),
          ),
          Visibility(
            visible: showPath,
            child: _expanded(myfile.path, 4, 0, myfile.filename.isEmpty),
          ),
          Visibility(
            visible: showSize,
            child: _expanded(myfile.size, 1, 1, false),
          ),
          Visibility(
            visible: showDate,
            child: _expanded(myfile.datetime, 1, 2, false),
          ),
        ],
      ),
      // keep trailing: const Icon(Icons.play_arrow),
      onTap: () {
        launchFile(myfile.path, myfile.filename);
      },
    );
  }

  //______________________________________________________________________________
  Expanded _expanded(String text, int flex, int ci, bool empty) {
    switch (ci) {
      case -1: // filename
        return Expanded(
            flex: flex,
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.blue[600])));
      case 0: // path
        if (empty)
          return Expanded(
              flex: flex,
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.red)));
        return Expanded(
            flex: flex,
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.blueAccent)));
      case 1:
        return Expanded(
            flex: flex,
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.green)));
      case 2:
        return Expanded(
            flex: flex,
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.orange)));
    }

    return Expanded(
        flex: flex,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.brown)));
  }

  //______________________________________________________________________________
  _refresh() {
    _searchObject.clear(widget.mytabdef);
    _findFiles(widget.searchString);
  }

  //______________________________________________________________________________
  String _spec(FileSpec fs) {
    // return '${fs.path}.${fs.filename}.toLowerCase()'; // do not sort by path, path doesn't matter
    return '${fs.filename}.toLowerCase()}';
  }

  //______________________________________________________________________________
  void _properSort() {
    widget.seafiles.sort((a, b) => a.path.compareTo(b.path));     // path sort
    widget.seafiles.sort((a, b) => _spec(a).compareTo(_spec(b))); // filename sort
  }

  //______________________________________________________________________________
  void _dateSort() {
      widget.seafiles.sort((a, b) => b.datetime.compareTo(a.datetime));
  }

  //______________________________________________________________________________
  //void _sizeSort() {
  //  widget.seafiles.sort((a, b) => b.sz > a.sz ? 1 : 0);
  //}

  //______________________________________________________________________________
  // switching show/hide date column
  _toggleDate() {
    setState(() {
      showDate = !showDate;
      SettingsYaml.get().date = showDate;
      SettingsYaml.get().save(showDate);
      if (showDate)
        _dateSort();
      else
        _properSort(); // sort on name
    });
  }

  //______________________________________________________________________________
  _toggleSize() {
    setState(() {
      showSize = !showSize;
      SettingsYaml.get().size = showSize;
      SettingsYaml.get().save(showSize);
    });
  }

  //______________________________________________________________________________
  // "value" is a generic name used by flutter
  _findFiles(String value) async {
    widget.searchString = value;
    setState(() {
      widget.setFiles([]); // reset the list (necessary?)
      showBusy = true;
      FocusScope.of(context).requestFocus(_focusNode);
    });

    List<FileSpec> ffiles = await _searchObject.searchForFilesAndFolders(value, widget.mytabdef);

    widget.setFiles(ffiles);

    bool showDate = SettingsYaml.get().date;
    //bool showSize = SettingsYaml.get().size;

    _properSort();
    if (showDate)
      _dateSort();
    // if (showSize)
    //   _sizeSort();

    setState(() {
      showBusy = false;
    });
  }

  //______________________________________________________________________________
  _searchUpdated(String value) async {
    print('search for: $value');
    await _findFiles(value);
  }

  //______________________________________________________________________________
  Future<void> launchFile(String path, String file) async {
    if (file.isEmpty) {
      path = path.replaceAll('/', '\\'); // necessary for Windows
      await Process.start('explorer', [path]);
    } else {
      ProcessResult result =
          await Process.run('cmd', ['/c', 'start', '', '$path/$file']);
      if (result.exitCode == 0) {
        // good
      } else {
        // bad
      }
    }
  }
}
