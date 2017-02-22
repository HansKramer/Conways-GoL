import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'package:crypto/crypto.dart';


abstract class GoLBase {
    int world_width;
    int world_height;
    
    List< List<int> > world = [new List(), new List()];
    Map<String, int> period = new Map();
            
    int current;
    int generation;
    
    GoLBase(int width, int height) {
        this.world_width  = width;
        this.world_height = height;
        this.current      = 0;
        this.reset();
    }
    
    void reset_world(int width, int height);
    
    void set(int i, int j) {
        this.world[this.current][this.get_index(i, j)] = 1;   
    }
    
    int get(int i, int j) {
        return this.world[this.current][this.get_index(i, j)];
    }
    
    void reset() {
        this.reset_world(this.world_width, this.world_height);
        this.generation = 0;
    }
    
    void toggle(int i, int j) {
        int index = this.get_index(i, j);
        this.world[this.current][index] += 1;
        this.world[this.current][index] %= 2;
    }
    
    int get_index(int i, int j);
    
    List<int> get_coordinates(index);
    
    List next_iteration();

    bool detect_period() {
        var sha256 = new SHA256();
        sha256.add(this.world[this.current]);
        var digest = sha256.close();
        var hexString = CryptoUtils.bytesToHex(digest);
        //print(hexString);

        if (this.period.containsKey(hexString))
            return true;
            //this.generation = this.period[hexString];
        this.period[hexString] = this.generation;

        return false;
    }
}


class GoLT extends GoLBase {
        
    GoLT(int width, int height) : super(width, height) {
    }
    
    void reset_world(int width, int height) {
        int no_cells  = width*height;
        this.world[0] = new List<int>.filled(no_cells, 0);  
        this.world[1] = new List<int>.filled(no_cells, 0);     
    }
    
    int get_index(int i, int j) {
        return i + j*this.world_width;
    }
    
    List<int> get_coordinates(int index) {
        int i = index % this.world_width;
        return [i, (index-i)~/this.world_width];
    }
   
    int update_cell(int i, int j, int cell, int live, int count, int shadow) {
        if (count == 3) {        // life 
            this.world[shadow][cell] = 1;
            return (live == 0) ? 1 : null;
        } else if (count == 4) { //do nothing
            this.world[shadow][cell] = this.world[this.current][cell]; 
            return null;
        } else {                //dead
            this.world[shadow][cell] = 0;   
            return (live == 1) ? 0 : null;
        }      
    }
    
    List next_iteration() {
        List changes = new List();
            
        int u;
        int shadow = (this.current + 1) % 2;
        
        // top and bottom row
        int cell_upper  = this.get_index(1, 0);
        int cell_bottom = this.get_index(1, this.world_height-1);
        for (int i=1; i<this.world_width-1; i++, cell_upper++, cell_bottom++) {
            int live  = this.world[this.current][cell_upper];
            int dy    = this.world_width;
            int ddy   = (this.world_height-1)*this.world_width;   
            
            int count = this.world[this.current][cell_upper-1+ddy] + this.world[this.current][cell_upper+ddy] + this.world[this.current][cell_upper+ddy+1] +
                        this.world[this.current][cell_upper-1]     + live                                     + this.world[this.current][cell_upper+1]     +
                        this.world[this.current][cell_upper-1+dy]  + this.world[this.current][cell_upper+dy]  + this.world[this.current][cell_upper+dy+1];  
            if ((u = this.update_cell(i, 0, cell_upper, live, count, shadow)) != null)
                changes.add([i, 0, u]);
            
            live = this.world[this.current][cell_bottom];
            
            count = this.world[this.current][cell_bottom-1-dy]  + this.world[this.current][cell_bottom-dy]  + this.world[this.current][cell_bottom-dy+1]  +        
                    this.world[this.current][cell_bottom-1]     + live                                      + this.world[this.current][cell_bottom+1]     +
                    this.world[this.current][cell_bottom-1-ddy] + this.world[this.current][cell_bottom-ddy] + this.world[this.current][cell_bottom-ddy+1];
            if ((u = this.update_cell(i, this.world_height-1, cell_bottom, live, count, shadow)) != null)
                 changes.add([i, this.world_height-1, u]);
        }
        
        // left and right row
        int cell_left  = this.get_index(0, 1);
        int cell_right = this.get_index(this.world_width-1, 1);
        for (int j=1; j<this.world_height-1; j++, cell_left+=this.world_width, cell_right+=this.world_width) {
            int live = this.world[this.current][cell_left];
            int dx   = this.world_width;
            int ddx  = this.world_width*2;   
               
            int count = this.world[this.current][cell_left-1]     + this.world[this.current][cell_left-dx] + this.world[this.current][cell_left-dx+1] +
                        this.world[this.current][cell_left-1+dx]  + live                                   + this.world[this.current][cell_left+1]    +
                        this.world[this.current][cell_left-1+ddx] + this.world[this.current][cell_left+dx] + this.world[this.current][cell_left+dx+1];
            
            if ((u = this.update_cell(0, j, cell_left, live, count, shadow)) != null)
                changes.add([0, j, u]);
          
            live = this.world[this.current][cell_right];
                      
            count = this.world[this.current][cell_right-1-dx] + this.world[this.current][cell_right-dx] + this.world[this.current][cell_right-ddx+1] +        
                    this.world[this.current][cell_right-1]    + live                                    + this.world[this.current][cell_right-dx+1]  +
                    this.world[this.current][cell_right-1+dx] + this.world[this.current][cell_right+dx] + this.world[this.current][cell_right+1];
            
            if ((u = this.update_cell(this.world_width-1, j, cell_right, live, count, shadow)) != null)
                changes.add([this.world_width-1, j, u]);
        }
        
        // the corners
        int lt    = 0;
        int rt    = this.world_width-1;
        int lb    = (this.world_height-1)*this.world_width;
        int rb    = this.world_width*this.world_height-1;
        
        // Left Top
        int count = this.world[this.current][rb] + this.world[this.current][lb] + this.world[this.current][lb+1]   +
                    this.world[this.current][rt] + this.world[this.current][lt] + this.world[this.current][lt+1] +
                    this.world[this.current][rt+this.world_width] + this.world[this.current][lt+this.world_width] + this.world[this.current][lt+1+this.world_width];
        if ((u = this.update_cell(0, 0, lt, this.world[this.current][lt], count, shadow)) != null)
            changes.add([0, 0, u]);
        
        // Right Top
        count = this.world[this.current][rb-1] + this.world[this.current][rb] + this.world[this.current][lb] +
                this.world[this.current][rt-1] + this.world[this.current][rt] + this.world[this.current][lt] + 
                this.world[this.current][rt+this.world_width-1] + this.world[this.current][rt+this.world_width] + this.world[this.current][lt+this.world_width];
        if ((u = this.update_cell(this.world_width-1, 0, rt, this.world[this.current][rt], count, shadow)) != null)
            changes.add([this.world_width-1, 0, u]);
        
        // Left Bottom
        count = this.world[this.current][rb-this.world_width] + this.world[this.current][lb-this.world_width] + this.world[this.current][lb-this.world_width+1] +
                this.world[this.current][rb] + this.world[this.current][lb] + this.world[this.current][lb+1] +
                this.world[this.current][rt] + this.world[this.current][lt] + this.world[this.current][lt+1];
        if ((u = this.update_cell(0, this.world_height-1, lb, this.world[this.current][lb], count, shadow)) != null)
            changes.add([0, this.world_height-1, u]);
        
        // Right Bottom
        count = this.world[this.current][rb-this.world_width-1] + this.world[this.current][rb-this.world_width] + this.world[this.current][lb-this.world_width] +
                this.world[this.current][rb-1] + this.world[this.current][rb] + this.world[this.current][lb] +
                this.world[this.current][rt-1] + this.world[this.current][rt] + this.world[this.current][lt];
        if ((u = this.update_cell(this.world_width-1, this.world_height-1, rb, this.world[this.current][rb], count, shadow)) != null)
            changes.add([this.world_width-1, this.world_height-1, u]);
        
        // the rest
        int cell = this.get_index(1, 1);
        for (int j=1; j<this.world_height-1; j++, cell+=2) {
            for (int i=1; i<this.world_width-1; i++, cell++) {
                int live  = this.world[this.current][cell];
                int dy    = this.world_width;
                int count = this.world[this.current][cell-1-dy] + this.world[this.current][cell-dy] + this.world[this.current][cell-dy+1] +
                            this.world[this.current][cell-1]    + live                              + this.world[this.current][cell+1]    +
                            this.world[this.current][cell-1+dy] + this.world[this.current][cell+dy] + this.world[this.current][cell+dy+1];
                int u;
                if ((u = this.update_cell(i, j, cell, live, count, shadow)) != null)
                    changes.add([i, j, u]);
            }       
        }
            
        this.current = shadow;
            
        return changes;
    }
}


class GoL extends GoLBase {

    GoL(int width, int height) : super(width, height);
    
    void reset_world(int width, int height) {
        int no_cells = (width+2)*(height+2);
        this.world[0] = new List<int>.filled(no_cells, 0);  
        this.world[1] = new List<int>.filled(no_cells, 0);     
    }
    
    int get_index(int i, int j) {
        return i+1 + (j+1)*(this.world_width+2);
    }

    List<int> get_coordinates(int index) {
        int i1 = index % (this.world_width+2);
        return [i1-1,  (index-i1)~/(this.world_width+2) - 1];
    }
    
    List next_iteration() {
        List changes = new List();
        
        int shadow = (this.current + 1) % 2;
        for (int j=0; j<this.world_height; j++) {
            for (int i=0; i<this.world_width; i++) {
                int cell  = this.get_index(i, j);
                int live  = this.world[this.current][cell];
                int dy    = this.world_width + 2;
                int count = this.world[this.current][cell-1-dy] + this.world[this.current][cell-dy] + this.world[this.current][cell-dy+1] +
                            this.world[this.current][cell-1]    + live                              + this.world[this.current][cell+1] +
                            this.world[this.current][cell-1+dy] + this.world[this.current][cell+dy] + this.world[this.current][cell+dy+1];
                if (count == 3) { // life  
                    if (live == 0)
                        changes.add([i, j, 1]);
                    this.world[shadow][cell] = 1;
                } else if (count == 4) { //do nothing
                    this.world[shadow][cell] = this.world[this.current][cell]; 
                } else { //dead
                    if (live == 1)
                        changes.add([i, j, 0]);
                    this.world[shadow][cell] = 0;
                }
            }       
        }
        
        this.current = shadow;
        
        return changes;
    }
}


@CustomTag('gol-canvas')
class GolCanvas extends PolymerElement {

    @observable int world_width;
    @observable int world_height;
    
    @published int generation = 0;
  
    static final int  cell_width   = 10;
    bool running      = false;

    String alive_color = "#000000";
    String dead_color  = "#FCFCFC";
    
    int periods = 10;
    
    Map<int, int>    trail  = new Map();
    
    GoLT gol;
    
    CanvasRenderingContext2D context;
    Element drag_element;
    
    GolCanvas.created() : super.created() {
        //print("GolCanvas.created() $world_width");
        
        this.gol = new GoLT(world_width, world_height);
        
        CanvasElement ce = $['canvas'];
        ce.width  = world_width*cell_width+1;
        ce.height = world_height*cell_width+1;
        this.context = ce.getContext("2d");
      
        for (int n=0; n<(world_width+1)*cell_width; n+=cell_width) 
            this.draw_line(n, 1, n, world_height*cell_width+1);
        for (int n=0; n<(world_height+1)*cell_width; n+=cell_width)
            this.draw_line(1, n, world_width*cell_width+1, n);

        //var clientRect = ce.getBoundingClientRect();
        //print($['canvas']);
        
        $['canvas'].onDrop.listen(on_drop);
        $['canvas'].onDragEnter.listen(on_drag_enter);
        $['canvas'].onDragOver.listen(on_drag_over);
        $['canvas'].onDragStart.listen(on_drag_start);
        //document.querySelector("#aap").onDragStart.listen(on_drag_start);
        //this.addEventListener("button-callback", this.button_callback_handler);
        
        //CanvasElement dnd = document.querySelector("#aapcanvas");
        //CanvasRenderingContext2D ctx = dnd.getContext("2d");
        //ctx.fillRect(  0,  0, 50, 50);
        //ctx.fillRect(100,  0, 50, 50);
        //ctx.fillRect(  0, 50, 50, 50);
        
        //var path = 'images/slider.png';
        //var httpRequest = new HttpRequest();
        //httpRequest..open('GET', path)
        //           ..onLoadEnd.listen((e) => print(httpRequest))
        //           ..send('');
        
        ce.onClick.listen(this.click_handler);
    }
  
    void on_drag_enter(MouseEvent event) {
        print("on drag enter");
     //   this.drag_element.classes.add('moving');
    }
    
    void on_drag_start(MouseEvent event) {
        print("on_drag_start");
      /*
        event.dataTransfer.setData('id', this.id);
        print("on drag start ${this.id} <${event.target.id}> <${event.target.innerHtml}>");
        if (event.target.id == "aap") {
            event.target.classes.add('over');
            this.drag_element = event.target.childNodes[0];
        }
         */
    }
    
    void on_drag_over(MouseEvent event) {
        event.stopPropagation();
        event.preventDefault();
    }
    
    void draw_cells_on_canvas(int i, int j, String data) {
        int y = 0;
        for (String line in data.split('\n')) {
            if (line.length>0 && line[0] == '!')
                continue;
            
            for (int x=0; x<line.length; x++) {
                if (line[x] == 'O') {
                    this.gol.toggle(x+i, y+j);
                    this.fill_cell(x+i, y+j, this.alive_color);
                }
            }
            
            y++;
        }
    }
    
    void on_drop(MouseEvent event) {
        event.stopPropagation();
        event.preventDefault();
         
        int i = (event.offset.x/cell_width).toInt();
        int j = (event.offset.y/cell_width).toInt(); 
        print("$i $j");
        print("${event.clientX}");
        
        var cells = event.dataTransfer.getData('id');
        if (cells != "") {
            var request = new HttpRequest();
            request
                ..open('GET', '/cells/${cells}.cells')
                ..onLoadEnd.listen((_) => this.draw_cells_on_canvas(i, j, request.responseText))
                ..send('');                
            return;
        }
      /*
        var x = event.dataTransfer.files;
                    */
        
        //print("type: ${event.type} ${event.dataTransfer.items.length} attr:${event.target.attributes}");
      //  for (var key in event.target.attributes.keys) {
      //      print("$key " + event.target.attributes.keys[key]);
      //  }
      //  event.target.attributes.forEach((k,v) => print(v));
/*
        print("id:" + event.dataTransfer.getData('id'));
        for (File file in event.dataTransfer.files) {
            print(file.type);
            FileReader fp = new FileReader();
            fp.onLoad.listen((e) {
                print(e);
                print(fp.result.toString().split('\n'));
                int y = 0;
                for (String line in fp.result.toString().split('\n')) {
                    if (line.length>0 && line[0] != '!') {
                        for (int x=0; x<line.length; x++) {
                            if (line[x] == 'O') {
                                this.gol.toggle(x+50, y+25);
                                this.fill_cell(x+50, y+25, this.alive_color);
                            }
                        }
                    }
                    y++;
                }
            });
            fp.readAsText(file);       
        }*/
    }
    
    void on_files_selected(List<File> files) {
        print(files);
    }
    
    void button_callback_handler(CustomEvent e) {
        switch (e.detail) {
        case 'start':
            this.loop();
            break;
        case 'stop':
            this.cancel();
            break;
        }
        print("Button callback We got an event $e ${e.detail}");
    }
    
    void callback() {
        print("callback called");
    }
    
    void click_handler(MouseEvent event) {
        int i = (event.offset.x/cell_width).toInt();
        int j = (event.offset.y/cell_width).toInt();     
       
        this.gol.toggle(i, j);
        this.fill_cell(i, j, this.gol.get(i,j) == 0 ? this.dead_color : this.alive_color);
    }
  
    bool next_iteration() {
        var changes = this.gol.next_iteration();
        if (changes.length == 0)
            return false;
        if (this.gol.detect_period()) {
            if (this.periods > 0)
                this.periods--;
            else
                return false;
        }
        
        this.trail.forEach((k, v) {
            this.trail[k] += 1;
        });
        for (var change in changes) {
            this.fill_cell(change[0], change[1], change[2] == 0 ? "#BBBBBB": this.alive_color);
            if (change[2] == 0) 
                this.trail[this.gol.get_index(change[0], change[1])] = 1;
            if (change[2] == 1) 
                this.trail.remove(this.gol.get_index(change[0], change[1]));
        }
        
        var nuke = new List();
        this.trail.forEach((index, v) {
            var coordinates = this.gol.get_coordinates(index);
            if (v == 2) 
                this.fill_cell(coordinates[0], coordinates[1], "#CCCCCC");
            if (v == 7)
                this.fill_cell(coordinates[0], coordinates[1], "#DDDDDD");
            if (v == 16)
                this.fill_cell(coordinates[0], coordinates[1], "#EEEEEE");
            if (v == 32) {
                this.fill_cell(coordinates[0], coordinates[1], this.dead_color); 
                nuke.add(index);
            }
        });
        for (var n in nuke)
            this.trail.remove(n);   
        
        return true;
    }
   
    void fill_cell(int x, int y, String color) {
        this.context.fillStyle = color;
        this.context.fillRect(x*10+1, y*10+1, 8, 8); 
    }
  
    void draw_line(int x0, int y0, int x1, int y1) {
        this.context.beginPath();
        this.context.moveTo(x0, y0);
        this.context.lineTo(x1, y1);
        this.context.closePath();

        this.context.strokeStyle="#c1c1c1";
        this.context.lineWidth = 0.5;
      
        this.context.stroke(); 
    }

    void loop() {
        this.generation = 0;
        this.running = true;
        const oneSec = const Duration(milliseconds:10);
        new Timer.periodic(oneSec, this.run_loop);
    }
    
    void run_loop(Timer t) {
        if (this.running && this.next_iteration()) {
            this.generation++;
            return;
        } else
            t.cancel();
    }

    void cancel() {
        this.running = false;
    }
    
    void reset() {
        this.gol.reset();
        this.trail = new Map();
        for (int j=0; j<world_height; j++)
            for (int i=0; i<world_width; i++) 
                this.fill_cell(i, j, this.dead_color);
    }
    
    void hide(bool state) {
        print("state:${state}");
    }
    
    void aaa(double x, int a, String b) {
          print("aaa: <$x>, <$a>, <$b>");
    }
      
}
