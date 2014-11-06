// by Les Hall
// started Sun Oct 26 2014
// 
// model viewer with stereoscopic display
// 3D display utilizing colored shades
// 
// This software is Protectd by the Creative Commosn (CC0)
// license. - Les Hall, Mon Nov 3, 2014
// 


// general purpose global variables
PShape s = new PShape();
String shapeFile = "";
float zoom = 1;
boolean drawShape = false;
boolean drawText = true;
PVector eye = new PVector(0, 256, 0);
PVector lookAt = new PVector(0, 0, 0);
PVector rotate = new PVector(0, 0, 0);
PVector trans = new PVector(0, 0, 0);
int method = 0;

// color filter glasses viewing method
int COLOR_FILTER_GLASSES = 1;
float theta = 1 * PI/180;
color clrLeft = color(255, 0, 255, 255);
color clrRight = color(0, 255, 255, 255);
PShape sLeft = new PShape();
PShape sRight = new PShape();
PGraphics pg = new PGraphics();
PImage imgLeft = new PImage();
PImage imgRight = new PImage();
float distance = 100;

// lenticular lens viewing method
int LENTICULAR_LENS = 2;
PVector screenSize = new PVector(13, 8, 1);
PVector screenResolution = new PVector(1920, 1200, 1);
PVector dpi = new PVector(
  screenResolution.x / screenSize.x, 
  screenResolution.y / screenSize.y, 
  screenResolution.z / screenSize.z);
float stripeWidth = 1;


void setup()
{
  // specify size and 3D renderer
  size(1920, 1200, P3D);
  pg = createGraphics(width, height, P3D);
  
  shapeMode(CENTER);
  println(dpi);
  println(theta);
  
  // choose a file and read it in
  selectInput("Select a file to process:", "fileSelected");
}



void draw()
{
  // preparatory stuff
  background(0, 0, 255);
  
  // draw the bicolor image 
  if (drawShape)
  {
    // prepare the image
    drawImg();

    // draw the image  
    image(imgLeft, 0, 0);
  }
   
  // draw text instructions
  instructions();
}



void fileSelected(File selection)
{
  if (selection == null)
  {
    exit();
  }
  else
  {
    // get the path name for the file
    shapeFile = selection.getAbsolutePath();
    
    // determine what the suffix on the filename is
    String[] tokens = splitTokens(shapeFile, ".");
    String suffix = trim(tokens[tokens.length-1]);

    // load in the shape based on which file type it is
    if ( (suffix.equals("STL")) || (suffix.equals("stl")) )
      s = loadSTL(shapeFile);
    else if ( (suffix.equals("OBJ")) || (suffix.equals("obj")) )
      s = loadShape(shapeFile);
    else
      exit();
      
    // prepare shape for coloring and displaying
    s.disableStyle();    
    drawShape = true;
  }
}



PShape loadSTL(String filePath)
{
  BufferedReader reader = createReader(filePath);    
  String line = "";

  PShape theShape = new PShape();
  theShape = createShape();
  theShape.beginShape(TRIANGLES);
  int vertexCount = 0;
  boolean done = false;

  while(!done)
  {
    try
    {
      line = reader.readLine();
    }
    catch (IOException e)
    {
      e.printStackTrace();
      exit();
    }
    
    if (line == null)
    {
      done = true;
    }
    else
    {
      String[] tokens = splitTokens(line);
      if (tokens.length == 4)
      {
        if (tokens[0].equals("vertex"))
        {
          PVector vertex = new PVector();
          vertex.x = float(tokens[1]);
          vertex.y = float(tokens[2]);
          vertex.z = float(tokens[3]);
          theShape.vertex(vertex.x, vertex.y, vertex.z);
          ++vertexCount;
        }
      }
    }
  }
  theShape.endShape(CLOSE);
  return theShape;
}


void drawImg()
{
  if ( (frameCount % 2) == 0)
  {
    drawShape(clrLeft, theta);
  }
  else
  {
    drawShape(clrRight, -theta);
  }
}


void drawShape(color c, float phi)
{
  // draw the shape
  pushMatrix();
  lights();
  camera(eye.x, eye.y, eye.z, lookAt.x, lookAt.y, lookAt.z, 0, 0, 1);
  fill(c);
  stroke(c);
  rotateZ(phi);    
  translate(trans.x, trans.y + distance, trans.z);
  rotateX(rotate.x);
  rotateY(rotate.y);
  shape(s);
  popMatrix();
}



void instructions()
{
  if (drawText)
  {
    textSize(42);
    textAlign(CENTER, CENTER);
    fill(255);
    stroke(255);
    text("mouse wheel zooms\n" + 
      "left mouse rotates\n" + 
      "right mouse pans\n" + 
      "space toggles text\n" + 
      "enter loads new file", width/2, height/2);
  }
}


void mouseDragged()
{
  if (mouseButton == LEFT)
  {
    // rotate the object
    rotate.x += PI/128 * (pmouseY - mouseY);
    rotate.y += PI/128 * (pmouseX - mouseX);
  }
  else if (mouseButton == RIGHT)
  {
    // pan the camera
    trans.x += mouseX - pmouseX;
    trans.z += mouseY - pmouseY;
  }
}


void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  distance += e;
}



void keyTyped()
{
  if (key == ENTER)
  {
    // choose a file and read it in
    s = new PShape();
    selectInput("Select a file to process:", "fileSelected");
  }
  else if (key == ' ')
    drawText = !drawText;
}


