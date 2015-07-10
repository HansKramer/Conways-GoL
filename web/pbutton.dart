import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:mirrors';


@CustomTag('p-button')
class PButton extends PolymerElement {

    @observable String button; 
    @observable String registered;
    
    PButton.created() : super.created() {
        print("PButton.created $button $registered");
    }
    
    void callback(MouseEvent event) {
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
    }
}