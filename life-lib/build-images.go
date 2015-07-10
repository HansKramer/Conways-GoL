/*
    \Author : Hans Kramer

    \Date : July 2015
 */

package main


import (
    "io/ioutil"
    "image"
    "image/png"
    "image/color"
    "path/filepath"
    "strings"
    "os"
)


func setPixel(i *image.NRGBA, x, y int) {
    for zx:=1; zx<9; zx++ {
        for zy:=1; zy<9; zy++ {
            i.Set(x*10+zx, y*10+zy, color.RGBA{0, 0, 0, 255})
        }
    }
}


func getDimension(data []byte) (int, int) {
    var comments int = 0
    var lines    int = 0
    var width    int = 0
    var x        int = 0

    for i:=0; i<len(data); i++ {
        switch (data[i]) {
        case '!': 
            comments++
            for data[i+1] != '\n' {
                i++
            }
        case '\n':
            lines++ 
            x = 0
        case '.', 'O':
            x++
            if x > width {
                width = x 
            }
        }
    }

    return width, lines-comments
}


func getPixel(data []byte) chan image.Point {
    c := make(chan image.Point)

    go func() {
        var y int = 0        
        var x int

        for i:=0; i<len(data); i++ {
            switch (data[i]) {
            case '!': 
                for data[i+1] != '\n' {
                    i++
                }
                i++
            case '\n':
                y++ 
                x = 0
            case '.', 'O':
                if data[i] == 'O' {
                    c <- image.Point{x, y}
                } 
                x++
            }
        }

        close(c)
    }()

    return c
}


func create_image(filename string) {
    data, _       := ioutil.ReadFile(filename)

    width, height := getDimension(data)

    m := image.NewNRGBA(image.Rect(0, 0, width*10, height*10))

    for p := range getPixel(data) {
        setPixel(m, p.X, p.Y)
    }

    filename = strings.TrimSuffix(filename, filepath.Ext(filename)) + ".png" 
    fp, _ := os.OpenFile(filename, os.O_CREATE | os.O_WRONLY, 0666)
    defer fp.Close()
    png.Encode(fp, m)
}


func main() {
    for _, filename := range os.Args[1:] {
        create_image(filename)
    }
}
