import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:mirrors';
import 'pwidget.dart';


@CustomTag('p-button-box')
class PButtonBox extends PWidget {

    @observable List<int>           buttons; 
    @observable Map<String, String> registered;
    @observable Map<String, String> command;
    
    PButtonBox.created() : super.created() {
        print("PButtonBox.created $buttons $registered");
    }
    
    void callback(MouseEvent event) {
        if (this.command.containsKey(event.target.text)) 
            this.exec(this.command[event.target.text]);
        
            //print(this.command[event.target.text]);
        if (registered.containsKey(event.target.text)) {
            List<String> callback = registered[event.target.text].split('.');
            if (callback.length != 2) {
                print("PButtonBox: Invalid callback; ${registered[event.target.text]}");
                return;
            }
            Element e = document.querySelector("#" + callback[0]);
            if (e == null) {
                print("PButtonBox: Invalid callback, cannot find instance ${callback[0]}; ${registered[event.target.text]}");
                return;
            }
            InstanceMirror klass = reflect(e);
            Symbol method = new Symbol(callback[1]);
            if (! klass.type.instanceMembers.keys.contains(method)) {
                print("PButtonBox: Invalid callback, method not defined ${callback[1]}; ${registered[event.target.text]}");
                return;
            }
            klass.invoke(method, []);
        }
    }
}