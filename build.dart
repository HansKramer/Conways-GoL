import 'package:polymer/builder.dart';
        
main(args) {
  build(entryPoints: ['web/gameoflife.html'],
        options: parseOptions(args));
}
