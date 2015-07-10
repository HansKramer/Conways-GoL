import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:mirrors';


class PWidget extends PolymerElement {
    PWidget.created() : super.created() {
      
    }
    
    Symbol get_method(String call) {
        List<String> callback = call.split('.');
        
        if (callback.length != 2) {
            print("Invalid method specification; ${call}");
            return null;
        }
        Element e = document.querySelector("#" + callback[0]);
        if (e == null) {
            print("Invalid method specification, cannot find instance ${callback[0]}; ${call}");
            return null;
        }
        InstanceMirror klass = reflect(e);
        Symbol method = new Symbol(callback[1]);
        if (! klass.type.instanceMembers.keys.contains(method)) {
            print("Invalid method specification, method not defined ${callback[1]}; ${call}");
            return null;
        }
        
        return method;
    }
}

@CustomTag('p-toggle-button')
class PButton extends PolymerElement {

    @observable String text; 
    @observable String command;
    @observable String state;
    
    //bool state = false;
    
    PButton.created() : super.created() {
        print("PButton.created $text $command");
        $['checkbox'].checked = true;
    }
    
    void callback(MouseEvent event) {
        //this.state = !this.state;
        InputElement e = $['checkbox'];
        
        print("hello ${e.checked} ${command}");
        if (e.checked) {
            print("checked");
        }
        
        //RegExp exp = new RegExp("([^,]+\(.+?\))|([^,]+)");
        //RegExp exp = new RegExp(r"([A-Za-z]\w*)(^,\s*([A-Za-z]\w*))");
        RegExp exp = new RegExp(r"([A-Za-z]\w*)(?:^,\s*([A-Za-z]\w*))*");
        //String str = "Parse my string";
        Iterable<Match> matches = exp.allMatches("state,fuckers,   kudt,hufters");
        print(matches);
        for (Match match in matches) {
            print(match.groupCount);
            String m = match.group(0);
            m = match.group(1);
            print(match.group(1));
            print(match.group(2));
        }
      /*
        List<String> callback = this.registered.split('.');
        if (callback.length != 2) {
            print("PButton: Invalid callback; ${registered}");
            return;
        }
        Element e = document.querySelector("#" + callback[0]);
        if (e == null) {
            print("PButton: Invalid callback, cannot find instance ${callback[0]}; ${registered}");
            return;
        }
        InstanceMirror klass = reflect(e);
        Symbol method = new Symbol(callback[1]);
        if (! klass.type.instanceMembers.keys.contains(method)) {
            print("PButton: Invalid callback, method not defined ${callback[1]}; ${registered}");
            return;
        }
        klass.invoke(method, []);
        * 
         */
    }
}