import 'package:polymer/polymer.dart';
import 'dart:html';


@CustomTag('p-fixed-scroll-pane')
class PFixedScrollPane extends PolymerElement {

    @observable String       ewidth;
    @observable List<String> images; 
    
    DivElement first_element;
    DivElement pane;
    int        position = 0;
    int        visible  = 3;
    Map<String, ImageElement> image_list;
    
    PFixedScrollPane.created() : super.created() {
        this.pane = $['pane'];
        
        this.image_list = new Map();
        
        print("PFixedScrollPane.created ${['left-arrow']}");
        
        CanvasElement left  = $['left-arrow'].firstChild;
        CanvasElement right = $['right-arrow'].firstChild;
        
        this.load_all_images();
        
        this.draw_arrows();
        
        for (var image in images) {
            CanvasElement ee = $[image];
            ee.onDragStart.listen( (event) {
                this.on_drag_start(event, image);
            });
        }      
    }
    
    void hide() {
        $['widget'].style.height = "0px";  
    }
    
    void on_drag_start(MouseEvent event, String image) {
        print("$event $image ${this.image_list[image]}");
        event.dataTransfer.setDragImage(this.image_list[image], 5, 5);
        event.dataTransfer.setData('id', image);
    }
    
    void draw_arrows() {
        CanvasElement left  = $['left-arrow'].firstChild;
        CanvasElement right = $['right-arrow'].firstChild;
        
        var path=new Path2D();
        path.moveTo(28, 5);
        path.lineTo(28, 95);
        path.lineTo( 2, 50);
                
        var context = left.getContext("2d");
        context.save();
        context.globalAlpha = 0.8;
        context.fill(path);
        context.restore();
                
        context = right.getContext("2d");
        context.scale(-1, 1);
        context.translate(-30, 0);
        context.fill(path); 
        context.restore();
    }
    
    void load_all_images() {
        for (var image in images)
            this.load_image(image); 
    }
    
    void load_image(String image) {
        ImageElement img = new ImageElement(src: "/images/${image}.png");
        img.onLoad.listen((e) {
            var ee = $[image];
            
            var context = ee.getContext("2d");
            context.imageSmoothingEnabled = false;
           
            if (img.width > img.height) {
                context.drawImageScaled(img, 0, (1-img.height/img.width)*50, 100, 100*img.height/img.width);
            } else {
                context.drawImageScaled(img, (1-img.width/img.height)*50, 0, 100*img.width/img.height, 100);
            }
            this.image_list[image] = img;
        });
    }
    
    void right_callback() {
        if (this.position > -this.images.length + 1) {
            this.position -= 1;
            this.pane.style.marginLeft = "${position*100}px";
        }
    }
    
    void left_callback() {
        if (this.position < this.visible - 1) {
            this.position += 1;
            this.pane.style.marginLeft = "${position*100}px";
        }
    }
}