library polymer.init;

import 'package:polymer/polymer.dart';
import 'dart:html';
//import 'package:three/three.dart';

Element container;

void init() {
    container = new Element.tag('div');
    document.body.nodes.add(container);
}

animate(num time) {
    window.requestAnimationFrame(animate);
   // render();
}

main() {
    initPolymer();
   // init();
   // animate(0);
}
