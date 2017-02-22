import 'package:polymer/polymer.dart';
import 'dart:mirrors';
import 'dart:js';


class PWidget extends PolymerElement {
    PWidget.created() : super.created() {
      
    }
    
    get_value(String value) {
        value = value.trim();
       
        // is it a string?
        if ( (value[0] == '"' && value[value.length-1] == '"') || 
             (value[0] == "'" && value[value.length-1] == "'") )
            return value.substring(1, value.length-1);
        
        // is it a int?
        int int_value = int.parse(value, onError: (error) => null);   
        if (int_value != null)
            return int_value;
        
        // is it a double?
        double double_value = double.parse(value, (error) => null);
        if (double_value != null)
            return double_value;
        
        // it is a instance value?
        var im = value.split('.');
        if (im.length == 2)
            if (im[0].trim() == "this")
                return reflect(this).getField(new Symbol(im[1])).reflectee;
            else
                return reflect(context[im[0]]).getField(new Symbol(im[1])).reflectee;
        
        // not supported
        print("not supported value : ${value}");
        return null;
    }
    
    bool exec(String call) {
        var s1 = call.trim().split('\(');
        if (s1.length != 2) {
            print("invalid command call $call");
            return false;
        }
        if (s1[1][s1[1].length-1] != ')') {
            print("invalid command call $call");
            return false;
        }
        var argument_list = s1[1].substring(0, s1[1].length-1).split(',');
        if (argument_list.length == 1 && argument_list[0] == '')
            argument_list = [];

        var s2 = s1[0].split('.');
        if (s2.length > 2) {
            print("complex indirections not supported");
            return false;
        }
        
        var instance;
        if (s2.length == 1 || s2[0].trim() == "this") {
            instance = reflect(this);
        } else {
            instance = reflect(context[s2[0]]);
        }
        Symbol method = new Symbol(s2[1]);
        
        var args  = [];
        for (var value in argument_list) 
             args.add(this.get_value(value));
        instance.invoke(method, args);
        // print(instance.type.declarations[method].parameters[index].type.simpleName);
     
        return true;
    }
}