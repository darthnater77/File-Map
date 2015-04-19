// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.


class FileItem extends SimpleMapItem {
  FolderItem parent;    
  File file;
  String name;
  String fileType;
  int level;
  
  PImage img;
  String text;
  String [] hold;
  
  color c;
  float hue;
  float brightness;
    
  float textPadding = 8;
    
  float boxLeft, boxTop;
  float boxRight, boxBottom;
  float centerX, centerY;
  float lengthX, lengthY;


  FileItem(FolderItem parent, File file, int level, int order) {
    this.parent = parent;
    this.file = file;
    this.order = order;
    this.level = level;
      
    name = file.getName();
    size = file.length();
    
    fileType = name.substring(name.length()-4);
    
    if (fileType.equals(".pgn") || fileType.equals(".jpg"))
      img = loadImage(file.getAbsolutePath());
      
    if (fileType.equals(".txt") || fileType.equals(".tsv") || fileType.equals(".dat") || fileType.equals(".doc")){
      hold = loadStrings(file);
      text = hold[0] + "\n" + hold[1] + "\n" + hold[2];
      hold = new String[0];
    }

    modTimes.add(file.lastModified());
  }

  
  void updateColors() {
    if (parent != null) {
      hue = map(order, 0, parent.getItemCount(), 0, 360);
    }
    brightness = modTimes.percentile(file.lastModified()) * 100;

    colorMode(HSB, 360, 100, 100);
    if (parent == zoomItem) {
      c = color(hue, 80, 80);
    } else if (parent != null) {
      c = color(parent.hue, 80, brightness);
    }
    colorMode(RGB, 255);
  }
  
  
  void calcBox() {
    boxLeft = zoomBounds.spanX(x, 0, width);
    boxRight = zoomBounds.spanX(x+w, 0, width);
    boxTop = zoomBounds.spanY(y, 0, height);
    boxBottom = zoomBounds.spanY(y+h, 0, height);
    centerX = (boxRight+boxLeft)/2;
    centerY = (boxBottom+boxTop)/2;
    lengthX = boxRight-boxLeft;
    lengthY = boxTop-boxBottom;
  }


  void draw() {
    imageMode(CENTER);
    calcBox();

    fill(c);
    rect(boxLeft, boxTop, boxRight, boxBottom);
    
    if (textFits(name)) {
      drawTitle();
    } else if (mouseInside()) {
      rolloverItem = this;
    }
    
    if (fileType.equals(".pgn") || fileType.equals(".jpg")){
      if (img.width < lengthX && img.height < lengthY)
        image(img, centerX, centerY, lengthX);
      else if (lengthX > lengthY)
        image(img, centerX, centerY, lengthX, lengthX/img.width * img.height);
      else
        image(img, centerX, centerY, lengthY/img.height * img.width, lengthY);
    }
    
    if (fileType.equals(".txt") || fileType.equals(".tsv") || fileType.equals(".dat") || fileType.equals(".doc")){
      textAlign(CENTER, CENTER);
      if (textFits(text))
        text(text, boxLeft, boxTop, boxRight, boxBottom);
      else if (mouseInside())
        text(text, centerX, centerY);
    }
 }
     
  void drawTitle() {
    fill(255, 200);
    
    float middleX = (boxLeft + boxRight) / 2;
    float middleY = (boxTop + boxBottom) / 2;
    if (middleX > 0 && middleX < width && middleY > 0 && middleY < height) {
      if (boxLeft + textWidth(name) + textPadding*2 > width) {
        textAlign(RIGHT);
        text(name, width - textPadding, boxBottom - textPadding);
      } else {
        textAlign(LEFT);
        text(name, boxLeft + textPadding, boxBottom - textPadding);
      }
    }
  }


  boolean textFits(String word) {
    float wide = textWidth(word) + textPadding*2;
    float high = textAscent() + textDescent() + textPadding*2;
    return (boxRight - boxLeft > wide) && (boxBottom - boxTop > high); 
  }
    
 
  boolean mouseInside() {
    return (mouseX > boxLeft && mouseX < boxRight && 
            mouseY > boxTop && mouseY < boxBottom);    
  }


  boolean mousePressed() {
    if (mouseInside()) {
      if (mouseButton == LEFT) {
        parent.zoomIn();
        return true;

      } else if (mouseButton == RIGHT) {
        if (parent == zoomItem) {
          parent.zoomOut();
        } else {
          parent.hideContents();
        }
        return true;
      }
    }
    return false;
  }
}
