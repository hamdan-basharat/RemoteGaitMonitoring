/* **************************************************************************************
* Spinal Stenosis Post-Op Monitoring 
* Authors: Konrad Grala, Hamdan Basharat, Sharda Kotru, and Fatima Ahmad
* Version 4.5
************************************************************************************** */
import processing.serial.*;          //for bluetooth communication
import org.gicentre.utils.stat.*;    //for chart classes.

Serial mySerial;
PImage pic;
Table table;
String filename;

XYChart graph1;
XYChart graph2;
XYChart graph3;

float buttX, buttY, butt2X, butt2Y;
int buttSize = 100;
color rectColor;
color rectHighlight;
boolean rect1Over = false;
boolean rect2Over = false;
boolean startFlag = false;

float[] xhipVals = new float[30];
float[] xVals = new float[30];
float[] temphipx = new float[30];
float[] tempx = new float[30];
float[] yhipVals = new float[30];
float[] yVals = new float[30];
float[] temphipy = new float[30];
float[] tempy = new float[30];
float[] zhipVals = new float[30];
float[] zVals = new float[30];
float[] temphipz = new float[30];
float[] tempz = new float[30];
float ox, oy, oz, accx, accy, accz;
String[] temp;

float xPoint;
float yPoint;
float zPoint;
String foundPort;
boolean portFound = false;
String currentString = "";

void setup() {
  frameRate(240);
  
  //setup background form (the window) and dimension
  //search through all ports to find the right connection
  size(1200,600);
  background(8,151,157); //set background colour
  rectColor = color(132,116,161);
  rectHighlight = color(204,171,216);
  
  //pic = loadImage("pelvis.png");
  table = new Table();
  table.addColumn("X");
  table.addColumn("Y");
  table.addColumn("Z");
  /*
  table.addColumn("acc X");
  table.addColumn("acc Y");
  table.addColumn("acc Z");
  */
    
  //=========== FIND AND SETUP BLUETOOTH ===================================================================== 
  while (portFound == false){
    String[] portList = mySerial.list();
    for(String strPort : portList){
      println(strPort);
      try{
        mySerial = new Serial(this, strPort, 115200);
        //waits until you have the whole line because of BufferUntil. "10" is referring to ASCII linefeed
        mySerial.bufferUntil(10);
        delay(1000);
      } catch (RuntimeException e){
          println("error");
        }
      if (currentString.length() > 0){
        portFound = true;
        foundPort = strPort;
        print("PORT FOUNDDDD!");
        break;
      } 
    }
    delay(100);
  }
  println();
  print("found ");
  println(foundPort);
  
  buttX = width/1.9-buttSize-10;
  buttY = height/1-buttSize/2;
  butt2X = buttX;
  butt2Y = height/1.15-buttSize/2;
  
  //=========== SETUP GRAPHS ===================================================================== 
  // create graph objects  
  graph1 = new XYChart(this);
  graph2 = new XYChart(this);
  graph3 = new XYChart(this);
  
  setupGraph(graph1);
  setupGraph(graph2);
  setupGraph(graph3);
}

void draw(){
  update(mouseX, mouseY);
  background(110,198,202); //set background colour (this will also erase all previous shapes that were drawn
  
  if(rect1Over){fill(rectHighlight);} 
  else{fill(rectColor);}
  stroke(255);
  rect(buttX, buttY, buttSize, buttSize/2,7);
  
  if(rect2Over){fill(rectHighlight);} 
  else{fill(rectColor);}
  stroke(255);
  rect(butt2X, butt2Y, buttSize, buttSize/2,7);
  
  fill(255,255,255);
  textSize(buttSize*0.15);
  text("Close & Log", width/2.03-buttSize-10, height/0.99-buttSize/2);
  
  fill(255,255,255);
  textSize(buttSize*0.15);
  text("Start", width/1.95-buttSize-10, height/1.14-buttSize/2);
  
  fill(255,255,255);
  textSize(buttSize*0.15);
  text("Team 2: Konrad, Sharda, Fatima & Hamdan", 5, height-5);
  
  //==##==##==  draw hip rectangles
  hipRect(0, 0, width/2, height/2, zPoint ,"Coronal Plane");
  hipRect(0, height/2, width/2, height/2, yPoint, "Sagittal Plane");

  drawGraph(graph1,width/2,0,width/2,height/3,xVals,xhipVals, "Transverse");
  drawGraph(graph2,width/2,height/3,width/2,height/3,yVals,yhipVals, "Sagittal");
  drawGraph(graph3,width/2,height*2/3,width/2,height/3,zVals,zhipVals, "Coronal");
}

//=========== READ AND UPDATE DATA =====================================================================
void update(int x, int y){
    if(overRect(buttX, buttY, buttSize, buttSize/2)){
      rect1Over = true;
    }
    if(overRect(butt2X, butt2Y, buttSize, buttSize/2)){
      rect2Over = true;
    }
}

void mousePressed(){
  if(rect2Over){
    startFlag = true;
  }
  if(rect1Over){
    filename = "gaittest_log.csv";
    saveTable(table, filename);
    exit();
  }
}

boolean overRect(float x, float y, float width, float height){
  if(mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height){
    return true;
  } 
  else{
    return false;
  }
}

//function that is automatically called every time there is data available
void serialEvent(Serial foundPort){
  //read new data string
  //and update 'currentPoint'
  currentString = foundPort.readString();
  println(currentString);
  
  temp = split(currentString,',');
  ox = float(temp[0]);
  oy = float(temp[1]);
  oz = float(temp[2]);
  accx = float(temp[3]);
  accy = float(temp[4]);
  accz = float(temp[5]);
  
  //println(ox,accx);
  //println();
  
  //update rectangle's current data point
  xPoint = ox;
  yPoint = oy;
  zPoint = oz;
  
  if(startFlag == true){
    TableRow newRow = table.addRow();
    newRow.setFloat("X", xPoint);
    newRow.setFloat("Y", yPoint);
    newRow.setFloat("Z", zPoint);
  }
  /*
  newRow.setFloat("acc X", accx);
  newRow.setFloat("acc y", accy);
  newRow.setFloat("acc Z", accz);
  */
  
  //update graph's x and y value arrays
  for (int i =0; i < temphipx.length - 1; i++){
     temphipx[i] = xhipVals[i+1];
     tempx[i] = xVals[i+1];
  }
  //append newest recorded data point
  temphipx[temphipx.length - 1] = xPoint;
  tempx[tempx.length - 1] = tempx[xVals.length - 2] + 1.0; //increase by 1
  xhipVals = temphipx;
  xVals = tempx; 
  
  for (int i =0; i < temphipy.length - 1; i++){
     temphipy[i] = yhipVals[i+1];
     tempy[i] = yVals[i+1];
  }
  //append newest recorded data point
  temphipy[temphipy.length - 1] = yPoint;
  tempy[tempy.length - 1] = tempy[yVals.length - 2] + 1.0; //increase by 1
  yhipVals = temphipy;
  yVals = tempy; 
  
  for (int i =0; i < temphipz.length - 1; i++){
     temphipz[i] = zhipVals[i+1];
     tempz[i] = zVals[i+1];
  }
  //append newest recorded data point
  temphipz[temphipz.length - 1] = zPoint;
  tempz[tempz.length - 1] = tempz[zVals.length - 2] + 1.0; //increase by 1
  zhipVals = temphipz;
  zVals = tempz; 
}

//=========== DRAW RECTANGLES =====================================================================
// draws the rectangle and circle that represents the hip's current angle relative to the floor
//top-left cornerpoint (cx,cy)
//width of window 
//height of window
//angle of rotation
void hipRect(float cx,float cy, float w, float h, float ang, String label){
  fill(5,91,92);
  //draw the current data value in the top right corner
  textSize(h*0.1); 
  text(label, cx+w*0.01, cy+h*0.1);
  if (portFound == false) {
    text("No values detected", cx+w*0.01, cy+h*0.2);
  } 
  else {
    text(ang + "°", cx+w*0.1, cy+h*0.2);
  }
  
  //center mode means can draw rectangle by referring to a center x and y coord instead of by coordinates of a corner
  rectMode(CENTER);
  float rl = h*0.9;   //rectangle length
  float rw = h*0.05;  //rectangle width
  //draw black circle at centerpoint
  fill(204,171,216);
  rect(cx+0.5*w, cy+0.5*h, rl, rw,5); //draw rectangle at default 0 angle position

  pushMatrix();
  translate(cx+0.5*w, cy+0.5*h); //shift everything by these coordinates (allows us to write 0,0 and have the shape in the 'middle' of the window)
  //draw another circle cause why not  
  fill(5,91,92);
  circle(0,0,rw*2);
  //draw rect at rotated position based on angle
  rotate(radians(ang));
  fill(132,116,161);
  //image(pic,-pic.height/4,-pic.width/4,pic.height/2,pic.width/2);
  rect(0, 0, rl,rw,5);
  popMatrix();
}

//=========== SETUP GRAPH =====================================================================
void setupGraph(XYChart graph){
  //setup for the graph
  textFont(createFont("Arial",10),10);
  // Axis formatting and labels.
  graph.showXAxis(true); 
  graph.showYAxis(true); 
  graph.setMinY(-90);
  
  graph.setYFormat("###,### deg.");  // degrees
  graph.setXFormat("0000");      // counter value
   
  // Symbol colours
  graph.setAxisColour(color(5,91,92));
  graph.setPointColour(color(5,91,92));
  graph.setLineColour(color(8,151,157));
  graph.setPointSize(5);
  graph.setLineWidth(2);
}

//=========== DRAW GRAPH =====================================================================
//graph object to be modified
//top-left cornerpoint (cx,cy)
//width of window 
//height of window
//x-values
//y-values
void drawGraph(XYChart graph, float cx, float cy, float w, float h, float[] xlist, float[] ylist, String label){
  //refresh/update graph data values
  graph.setMinX(xlist[1]);
  graph.setMaxX(xlist[xlist.length - 1]);
  graph.setData(xlist,ylist);
  
  //Draw the graph
  fill(5,91,92);
  textSize(h*0.05);
  
  try {
    graph.draw(cx, cy+h*0.2, w-w*0.01, h-h*0.2); 
  } catch (ArrayIndexOutOfBoundsException e){
      println("invalid");
    }
  
  // Draw title
  fill(5,91,92);
  textSize(h*0.125);
  text(label, cx+w*0.1, cy+h*0.2);
}
