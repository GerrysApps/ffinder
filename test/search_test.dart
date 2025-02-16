// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:ffinder/settings.dart';
import 'package:ffinder/tabdefinition.dart';

void main() {
  test('Test search function', () async {
    String input = '  Hello World "How are you today" poop "and this too" nada '.trim();
    input = 'a "good bye" "my fri" b';


    // omfg!
    int dq = input.indexOf('"');
    int edq = -1;
    dq == -1 ? edq = -1 : edq = input.indexOf('"', dq + 1); 
    while(dq > -1 && edq > -1) { 
      String a = input.substring(0, dq);
      String q = input.substring(dq, edq).replaceAll(' ', '/'); // filename can't have slashes! nice!
      String z = input.substring(edq);
      input = '$a$q$z';
      dq = input.indexOf('"', edq + 1);
      dq == -1 ? edq = -1 : edq = input.indexOf('"', dq + 1); 
    }

    input = input.replaceAll('"', '');
    List<String> searches = input.split(' ');
    for (int i = 0; i < searches.length; i++) {
      searches[i] = searches[i].replaceAll('/', ' ');
    }



    int start = -1;
    List<String> words = [];


    int sp = edq > -1 ? input.indexOf(' ', edq) : 0;
    int esp = input.indexOf(' ', sp + 1);

while ((sp > -1 && esp > -1) || (dq > -1 && edq > -1)) { 
    if (dq > -1 && edq > -1 && (dq <= sp || sp < 0)) { 
      words.add(input.substring(dq + 1, edq));

      //sp = input.indexOf(' ', edq);
      //sp == -1 ? esp = -1 : esp = input.indexOf(' ', sp + 1); 

      dq = input.indexOf('"', edq + 1);
      dq == -1 ? edq = -1 : edq = input.indexOf('"', dq + 1); 

      sp = edq > -1 ? input.indexOf(' ', edq) : -1;
      esp = sp > -1 ? input.indexOf(' ', sp + 1) : -1;
    }
    if (sp > -1 && esp < 0 && dq < 0) { 
      esp = input.length;
    }
    if (sp > -1 && esp > -1) { 
      words.add(input.substring(sp, esp).trim());
      sp = esp + 1;
      if (sp > input.length - 1) {
        break;
      }
      esp = input.indexOf(' ', sp + 1); 
    }
}


/*
for (int i = 0; i < 3; i++) { 
    if (dq > -1 && dq < sp) { 
      int edq = input.indexOf('"', dq + 1);
      if (edq > -1) { 
          words.add(input.substring(dq, edq).replaceAll('"', '').trim());
          startdq = edq + 1;
          startsp = startdq;
      }
    }

    if (sp > -1) {
      int esp = input.indexOf(' ', sp + 1);
      if (esp > -1) { 
          words.add(input.substring(sp, esp).trim());
          startsp = esp + 1;
          startdq = startsp;
      }
    }
}
*/

    for (int i = 0; i < input.length; i++) {
      if (i == 0) {
        start = 0;
      }
      if (input[i] == '"' && start < 0) {
        start = i;
        int end = input.indexOf('"', start + 1);
        if (end > -1) {
          words.add(input.substring(start, end));
          start = -1;
          i = end;
        }
      } 
      else if (input[i] == ' ' && start >= 0) {
        int end = input.indexOf(' ', start + 1);
        if (end < 0) {
          end = input.length;
        }
        words.add(input.substring(start, end));
        start = -1;
        i = end;
      }
    }

    SettingsYaml sc = SettingsYaml.get();
    List<TabDefinition> tabDefs = SettingsYaml.get().tablist();
    TabDefinition tb = tabDefs[0];

    /*
    List<FileSpec> files = await Search().find("hell go bye my ri", tb);
    if (files.length == 1) {
      print("found: ${files[0].filename}");
    }
    */

    // expect(files.length, 1);
  });
}
