// ignore_for_file: prefer_const_constructors, avoid_print, must_be_immutable, no_logic_in_create_state, curly_braces_in_flow_control_structures

// https://blog.codemagic.io/flutter-widget-cheat-sheet/
// layout only: https://medium.com/flutter-community/flutter-layout-cheat-sheet-5363348d037e

// Copyright (c) 2023-2025 GerrysApps.com  
import 'package:ffinder/alert.dart';
import 'package:ffinder/tabdefinition.dart';
import 'package:flutter/material.dart';
import 'package:ffinder/settings.dart';
import 'package:file_picker/file_picker.dart';

//______________________________________________________________________________
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

//______________________________________________________________________________
class SettingsScreenState extends State<SettingsScreen> {
  String _selectedTabName = ""; // SettingsYaml.get().firstTabname;               TODO don't need?
  final List<String> _tabNames = []; 
  late TabSettings _tabSettings;

  @override
  void initState() {
    super.initState();

    for (var tab in SettingsYaml.get().tablist()) { 
      _tabNames.add(tab.name);
    }

    _selectedTabName = _tabNames.first; // required: set the initial value for the dropdown
    _tabSettings = TabSettings(); // this is the RIGHT place to create TabSettings
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          TabSelector(
            dropdownValues: _tabNames,
            selectedTabname: _selectedTabName,
            onTabSelChanged: (value) {
              setState(() {
                _selectedTabName = value;
                _tabSettings.selectionHasChanged(value);
              });
            },
            onNewTab: (tabname) { 
              _newTab(tabname);
            },
            onDeleteTab: (dontuse) { 
              _maybeDelete();
            },
          ),
          Expanded(
            child: _tabSettings, // this is the WRONG place to be create TabSettings because build gets called a lot
          ),
        ],
      ),
    );
  }

  _newTab(String name) { 
    if (name.isEmpty)
      return;
    SettingsYaml.get().newTab(name);
    SettingsYaml.get().restartRequired = true;
    setState(() {
      _selectedTabName = name;
      _tabSettings.selectionHasChanged(name);
    });
  }

  _maybeDelete() { 
    int count = SettingsYaml.get().count();
    if (count < 2) {
      AlertMan().showMessage(context, 'No no...', 'Cannot delete all tabs, first create another tab').whenComplete(() => { });
      return;
    }

    var alert = AlertMan();
    alert.showQuestion(context, 'Confirm delete', 'Are you sure you wish to delete the current tab?').whenComplete(() {
    if (alert.result)
      _delete();
    });
  }

  _delete() { 
    _tabNames.remove(_selectedTabName);
    SettingsYaml.get().deleteTab(_selectedTabName);
    SettingsYaml.get().restartRequired = true;
    setState(() {
      _selectedTabName = _tabNames.first; // required: set the initial value for the dropdown
      _tabSettings.selectionHasChanged(_selectedTabName);
    });
  }
}

//______________________________________________________________________________
class TabSelector extends StatelessWidget {
  final List<String> dropdownValues;
  final String? selectedTabname;

  final ValueChanged<String>? onTabSelChanged;
  final ValueChanged<String>? onNewTab;
  final ValueChanged<String>? onDeleteTab;

  TabSelector({
    Key? key,
    required this.dropdownValues,
    required this.selectedTabname,
    required this.onTabSelChanged,
    required this.onNewTab,
    required this.onDeleteTab,
  }) : super(key: key);

  final _tabnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var selectTabDropdown = DropdownButton<String>(
      value: selectedTabname,
      onChanged: (value) {
        onTabSelChanged!(value!);
      },
      items: dropdownValues
        .map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        ).toList(),
    );

    var createTabButton = ElevatedButton(onPressed: () {
      dropdownValues.add(_tabnameController.text);
      onNewTab!(_tabnameController.text);
        _tabnameController.text = '';
      },
      child: Text('Create New Tab:'),
    );

    var createTabName = TextField(
      controller: _tabnameController,
      decoration: InputDecoration(
        labelText: 'New Tab Name',
        border: OutlineInputBorder(),
      ),
      // onChanged: (value) => { print(value) },
    );

    var deleteTab = ElevatedButton(
      child: Text('Delete Current Tab'),
      onPressed: () {
        onDeleteTab!(''); // must have parameter...
      },
    );

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Text('Select Tab: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 6),
          selectTabDropdown,

          SizedBox(width: 176),
          createTabButton,

          SizedBox(width: 6),
          SizedBox(width: 206,
            child: createTabName,
          ),

          SizedBox(width: 16), // add some space between widgets
          Expanded(child: Align(alignment: Alignment.centerRight,
            child: deleteTab,
          )),
        ],
      ),
    );
  }
}

//______________________________________________________________________________
class TabSettings extends StatefulWidget {
  late TabSettingsState _tabSettingsState;

//TabSettings({Key? key, required this.tabname}) : super(key: key);
  TabSettings({Key? key}) : super(key: key);

  selectionHasChanged(String tabname) { 
    _tabSettingsState.tabChangedNoSetState(tabname);
  }

  // this syntax sucks becaues it is so fucking inflexible:
  // TabSettingsState createState() => TabSettingsState();

  // this syntax rocks, the other syntax can go fuck itself
  @override
  TabSettingsState createState() {
    _tabSettingsState = TabSettingsState();
    return _tabSettingsState;
  }
}

//______________________________________________________________________________
class TabSettingsState extends State<TabSettings> {
  String _tabname = '';

  final _suffixController = TextEditingController();
  final _foldersController = TextEditingController();

  // don't call setState(), already in there
  void tabChangedNoSetState(String tabname) { 

    _save(false);

    _tabname = tabname;
    TabDefinition? tab = SettingsYaml.get().find(_tabname);
    if (tab == null) { 
      _suffixController.text = '';
      _foldersController.text = '';
    }
    else { 
      _suffixController.text = _clean(tab.suffixes);
      _foldersController.text = _clean(tab.locations);
    }
  }

  String _clean(List<String> list) { 
    return list.toString().replaceFirst('[', '').replaceFirst(']', '');
  }

  @override
  void initState() {
    super.initState();
//    TabDefinition? tab = SettingsYaml.get().find(SettingsYaml.get().firstTabname);        don't need?
    TabDefinition tab = SettingsYaml.get().tablist()[0];
    //if (tab != null) 
    { 
      _suffixController.text = _clean(tab.suffixes);
      _foldersController.text = _clean(tab.locations);
    }
    _foldersController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _suffixController.dispose();
    _foldersController.removeListener(_onTextChanged);
    _foldersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _suffixController,
            decoration: InputDecoration(
              labelText: 'Suffixes',
              hintText: 'A comma separated list of program suffixes, e.g. txt, doc, docx',
            ),
            onChanged: (value) {
              SettingsYaml.get().updateSuffixes(_tabname, value);
              // setState(() { });
            },
            onSubmitted: (value) {
              _suffixController.text = value;
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _foldersController,
            decoration: InputDecoration(
              labelText: 'Folders',
              hintText: 'A comma separated list of folders, e.g. c:/Users/MyLogin/OneDrive, c:/Users/MyLogin/Documents',
            ),
            onChanged: (value) {
              SettingsYaml.get().updateFolders(_tabname, value);
              // setState(() { });
            },
            onSubmitted: (value) {
              _foldersController.text = value;
            },
          ),

          SizedBox(height: 16),
          Expanded(child: Align(alignment: Alignment.topLeft,
            child: Tooltip(message: 'Select a folder to add to the Folders list',
              child: ElevatedButton(onPressed: () {

                // force change: doesn't work...
                // String tmp = _foldersController.text;
                // _foldersController.text = '';
                // _foldersController.text = tmp;

                pickFolder();
                // works, but blows up later Navigator.pop(context);
              },
              child: Text('Add a Folder...'),
              ),
            ),
          )),

          // Text('Use comma separated lists for Suffixes and Folders'),
          // Text('Suffixes defines what types of files to include, for example: doc, docx, txt'),
          // Text('Folders defines the locations of the files to include'),

          //Text('Use the Back arrow to save changes', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Press the Back arrow to Save your changes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          // Text('Restart ffinder after adding or removing tabs (remember to Save)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),

          SizedBox(height: 36),
        ],
      ),
    );
  }

  //______________________________________________________________________________
  void _onTextChanged() {
    SettingsYaml.get().updateFolders(_tabname, _foldersController.text);
  }

  //______________________________________________________________________________
  Future<void> pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null)
      return;
    if (_foldersController.text.isEmpty)
      _foldersController.text = result.replaceAll("\\", "/");
    else
      _foldersController.text += ', ${result.replaceAll("\\", "/")}';

  }

  //______________________________________________________________________________
  @override
  void deactivate() {
// Navigator.of(context).pop(); // TODO???

    /* blows up, there is no navigator anymoer
   // if (SettingsScreenState.foobar) 
    { 
      AlertMan().showMessage(context, 'Restart required', 'Restart ffinder for changes to take affect').whenComplete(() => { });
      SettingsScreenState.foobar = false;
    }
    */

// blows up Navigator.pop(context);

    super.deactivate();
    _save(true);
  }

  //______________________________________________________________________________
  // called when leaving the Settings screen or changing tabs
  void _save(bool closingSettings) {
      SettingsYaml.get().save(closingSettings);
  }
}

/* Android only
  void printHello() {
    Fluttertoast.showToast(
        msg: "This is Center Short Toast",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
*/