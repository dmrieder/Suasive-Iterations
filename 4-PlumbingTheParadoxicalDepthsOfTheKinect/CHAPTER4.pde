
//Use this sketch!
//http://www.openprocessing.org/sketch/16256#
//Or this one
//http://www.openprocessing.org/sketch/21866
//Or this?
//http://www.openprocessing.org/sketch/34978
//http://www.openprocessing.org/sketch/17043
import dLibs.freenect.toolbox.*;
import dLibs.freenect.constants.*;
import dLibs.freenect.interfaces.*;
import dLibs.freenect.*;

import processing.opengl.*;

Kinect kinect_;  
KinectFrameDepth kinect_depth_;      

//KinectTilt kinect_tilt;

Kinect3D k3d_;                       
KinectCalibration calibration_data_; 

PFont font, font2;

int colReverse, dd, qq, clockwisey, clockwisex, clockpushx;

float cz;

int[] depths, qquad;

PImage arrow;

//indices move clockwise, 0 - 3
int[][] quadrants = {     
                           //[0][x] is top-left quadrant
                           {0, 0, 0, 0},
                           //[1][x] is top-right quadrant
                           {0, 0, 0, 0},
                           //[2][x] is bottom-right quadrant
                           {0, 0, 0, 0},
                           //[3][x] is bottom-left quadrant
                           {0, 0, 0, 0}    };


int scl = 4, dirs = 9, rdrop = 8, lim = 128;
int res = 2, palette = 0, pattern = 2, soft = 2;
int dx, dy, w, h, s;
boolean border, invert;
float[] pat;
PImage img;

float angle=0;

void setup() {
  
  size(1024, 768, OPENGL);
  
  background(0);
  
  kinect_ = new Kinect(0);  

//  kinect_tilt = new KinectTilt();   
//  kinect_tilt.connect(kinect_);   
  
  kinect_depth_ = new KinectFrameDepth(DEPTH_FORMAT._11BIT_);
  
  k3d_ = new Kinect3D(); 
  k3d_.setFrameRate(30); 
  
  kinect_depth_.connect(kinect_);
  k3d_.connect(kinect_);

  calibration_data_ = new KinectCalibration();
  calibration_data_.fromFile("kinect_calibration_red.yml", null); 
  k3d_.setCalibration(calibration_data_);

  depths = new int[4];
  qquad = new int[4];
    qquad[0] = 0;
    qquad[1] = 0;
    qquad[2] = 0;
    qquad[3] = 0;
    
  
  font = loadFont("SegoeUI-14.vlw");
  font2 = loadFont("CourierNewPSMT-12.vlw");
  
  clockwisey = 26;
  clockwisex = 1;
  clockpushx = 102;
  
  arrow = loadImage("arrow.jpg");
}

void reset() {
  w = width/res;
  h = height/res;
  s = w*h;
  img = createImage(w, h, RGB);
  pat = new float[s];
  // random init
  for(int i=0; i<s; i++) 
    pat[i] = floor(random(256));
}

void draw() {
  
  background(0);
    
  KinectPoint3D kinect_3d[] = k3d_.get3D();
  
  drawRect();
    
  for(int row = 0; row < 480; row += 4) { // 64
    for(int col = 0; col < 640; col += 4) { // 48
    
      colReverse = int(map(col,0,640,640,0));
      
      float cz = kinect_3d[row * 640 + colReverse].z;
  
 if((cz < -0.300) && (cz > -1.500)) 
 {
   drawPoints(col, row, cz);
  
   depthLevels(cz, col, row);
   
   
 }
    }
  } 
  
 for(int i = 0; i < depths.length; i++) {
     if(depths[dd] < depths[i]) {
     dd = i; 
    }
 }

//println(dd + ": " + quadrants[dd][0] + ", " + quadrants[dd][1] + ", " + quadrants[dd][2] + ", " + quadrants[dd][3] + " ---- " + qq);

 for(int e = 0; e < quadrants.length; e++) {
     if(quadrants[dd][qq] < quadrants[dd][e]) {
     qq = e; 
    }
  }



pushMatrix();
translate(920, 125, 0);
for(int h = 0; h < 4; h++) {
  for(int u = 0; u < 4; u++) {
    if(u <= 1) {
      clockwisey = 32;
    }
    else {
      clockwisey = 64;
    }
    
    if((u == 0) || (u == 2)) {
      clockwisex = 32;
    }
    else {
      clockwisex = 64;      
    }
    
    noStroke();
    fill(map(quadrants[h][u], 0, 2000, 50,255));
    rect(clockwisex, clockwisey + (clockpushx * h), 30,30);
    
  }
}
popMatrix();

image(arrow, width-251,0);

//poem();

//graph();



  depthThermometer();

//  println("Total: " + depths[0]);
//    println(quadrants[0][0]);
//    println(quadrants[0][1]);    
//    println(quadrants[0][2]);
//    println(quadrants[0][3]);
//  println("---------------");
  
  
  resetDepths();  
  resetQuadrants();
  
  //saveFrame("c3-####.jpg");

}
// END DRAW



void drawPoints(int x, int y, float z) {

  pushMatrix();
    translate(width - (254/2 + 110), 580, map(z, -0.300, -1.500, 50, -50));
    stroke(map(z, -0.300, -1.500, 255, 0));
    point(map(x, 0, 640, 0, 640/3), map(y, 0, 480, 0, 480/3));
  popMatrix();
  
  
  
}

void drawRect() {

  stroke(150);
  strokeWeight(0.2);
  noFill();

  rect(770,-1, 254, height - 207);
  rect(770, 560, 254, 210);

  stroke(150);
  line(771, 125, 1024, 125);
  stroke(50);
  line(940,125,940,559);
  line(720, 0, 720, height);
//
// strokeWeight(0.2);
// stroke(150);
  
 fill(255);
 textFont(font); 
 text("1.5m", 730,555);
 text("1.25m", 723,550-104);
 text("1.0m", 730,550-204);
 text(".75m", 730,550-304);
 text(".30m", 728,550-410);
}

void depthLevels(float z, float c, float r) {
  
   if((z < -1.251) && (z > -1.500)) {
      depths[3]++;      
      quadrants(c, r, 3);
      }
      
    else if((z < -1.001) && (z > - 1.250)) {
      depths[2]++;
      quadrants(c, r, 2);
      }
     
    else if((z < -0.751) && (z > - 1.000)) {
      depths[1]++;
      quadrants(c, r, 1);
      }
  
    else if((z < -0.300) && (z > - 0.750)) {
      depths[0]++;
      quadrants(c, r, 0);
      }
}

void quadrants(float c, float r, int d) {
  
  if(r < 240) {
    
    if(c <= 320) {
      
    quadrants[d][0]++; 
    }
    else {
      
    quadrants[d][1]++;    
    
    }
    
  }
  
  else if(r >= 240) {
    
    if(c >= 320) {
      
     quadrants[d][3]++;   
         
    }
    
  else {
      
     quadrants[d][2]++;   
     
    }
    
  }
}

void resetQuadrants() {
  
  for(int qr = 0; qr < 4; qr++) {
    for(int qc = 0; qc < 4; qc++) {
      quadrants[qr][qc] = 0;
    }
  }
  
}

void depthThermometer() {
  
  stroke(0);
  rectMode(CENTER);
  for(int k = 0; k < depths.length; k++) {

    fill(map(depths[k], 0, 5000, 50, 255));
    rect(850, 190 + (102 * k), 15 + map(depths[k], 0, 13000, 5, 150), 100);
   textAlign(RIGHT);
   //textSize(12);
   fill(200);
   textFont(font2);
    text(depths[k], 765, 190 + (102 * k + 5));
    textAlign(LEFT);
  }
 rectMode(CORNER);
}

void resetDepths() {
    for(int j = 0; j < depths.length; j++) {
     depths[j] = 0;
   }
}

void graph() {
  stroke(255);
  fill(255);
  //x
  line(95,600,500,600);
     text("0",95,620);   
   line(95,200,105,200); 
     text("1",195,620); 
   line(95,300,105,300); 
     text("2",295,620); 
   line(95,400,105,400); 
     text("3",395,620); 
   line(95,500,105,500); 
     text("4",495,620);  
  //y
  
  line(100,200,100,605); 
     text("0",80,600 + 5);
   line(500,595,500,605); 
       text("4",80,200 + 5);
   line(400,595,400,605); 
    text("3",80,300 + 5);
   line(300,595,300,605); 
    text("2",80,400 + 5);
  line(200,595,200,605); 
    text("1",80,500 + 5);    
}

void keyPressed() {
  switch(key) {
    case 'r': reset(); break;
    case 'p': pattern = (pattern + 1) % 3; break;
    case 'c': palette = (palette + 1) % 4; break;
    case 'b': border = !border; dx=0; dy=0; break;
    case 'i': invert = !invert; break;
    case 's': soft = (soft + 1) % 3; break;
    case '+': lim = min(lim+8, 255); break;
    case '-': lim = max(lim-8, 0); break;
    case CODED:
      switch(keyCode) {
        case LEFT: scl = max(scl-1, 2); break;
        case RIGHT:scl = min(scl+1, 6); break;
        case UP:   res = min(res+1, 5); reset(); break;
        case DOWN: res = max(res-1, 1); reset(); break;
      }
      break;
  }
}
 
// moving the canvas
void mouseDragged() {
  if(mouseButton == CENTER && !border) {
    dx = mod(dx + mouseX - pmouseX, width);
    dy = mod(dy + mouseY - pmouseY, height);
  }
}
 
// floor modulo
final int mod(int a, int n) {
  return a>=0 ? a%n : (n-1)-(-a-1)%n;
}

void dispose(){
  Kinect.shutDown(); 
  super.dispose();
}























