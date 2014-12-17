import processing.serial.*;

Serial serial;
PFont font;
float radius;			// radius of the scope
int servoPosition;
int distance;
int scopeCenterX, scopeCenterY;
int scanLineTailX, scanLineTailY;
int[] distances; 

void setup()
{
  size(displayWidth, displayHeight);
  frame.setResizable(true);
  background(0);
  frameRate(60);
  font = loadFont("DroidSansMono-14.vlw");
  textFont(font, 14);
  stroke(0, 255, 0);
  textAlign(CENTER);
  radius = (displayWidth / 2) - 50;
  scopeCenterX = displayWidth / 2;
  scopeCenterY = displayHeight - 50;
  distances = new int[180];
  clearDistancesArray();
  
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 9600);
  serial.bufferUntil('@');
}

void draw()
{
  drawScope();
  drawScanLine(servoPosition);
  drawEchoes();
}

void serialEvent(Serial serial) 
{ 
  try 
  {      
    String inBuffer = serial.readStringUntil('@');
    
    if (inBuffer != null) {
      String[] splitBuffer = split(inBuffer, '/');
      if(splitBuffer.length == 2)
      {
        servoPosition = Integer.parseInt(splitBuffer[0]);
        String dist = splitBuffer[1];
        dist = dist.replaceAll("@", "");
        distances[servoPosition] = Integer.parseInt(dist);
      }
    }
  }
  catch(RuntimeException ex) 
  {
    println(ex);
  }
} 

/**
* This function draws the scope, the gridded arch/half circle in which
* the scan line will oscillate and the distances will be painted.
*/
void drawScope()
{
  background(0);
    
  // Draw the outwards arches
  // i = 0.25 so that 2 PI radius is reached in 8 steps
  for(float i = 0.25; i <= 2; i += 0.25)
  {
    arc(scopeCenterX, scopeCenterY, i*radius, i*radius, PI, 2*PI);  
  }
  
  // Draw the text on the bottom indicating the distance
  int cm = 0;  
  for(float i = 0; i <= radius; i += 0.125) 
  {
    text(cm + "cm", scopeCenterX + (i*radius), scopeCenterY + 15);
    cm += 25;
  }
  
  // Draw the degree lines and accompanying text.
  // Half a circle is PI rad. To get 15 degree segments:
  // 180° / 15° = 12 segments
  int deg = 0;
  for(float i = PI; i <= 2*PI; i += PI/12)
  {
    int x = scopeCenterX + (int) (radius * cos(i));
    int y = scopeCenterY + (int) (radius * sin(i));  
    line(scopeCenterX, scopeCenterY, x, y);
    
	// Add some distance to the radius to create some space
	// between the lines and text
    x = scopeCenterX + (int) ((radius + 18) * cos(i));
    y = scopeCenterY + (int) ((radius + 18) * sin(i));
    text(deg + "º", x, y);   
    deg += 15;
  }
}

/**
* Converts degrees to radians
*/
float degreesToRad(float d)
{
  // +180 to account for the fact we only see the top half of a circle
  return (d + 180) * PI / 180;
}

/**
* Re-maps a number from one range to another. 
* val: the number to map
* in_min: the lower bound of the value's current range
* in_max: the upper bound of the value's current range
* out_min: the lower bound of the value's target range
* out_max: the upper bound of the value's target range 
*/
float fmap(float val, float in_min, float in_max, float out_min, float out_max)
{
  return (val - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void clearDistancesArray()
{
  for(int i = 0; i < distances.length; i++)
  {
    distances[i] = -1;
  } 
}

void drawDot(int x, int y)
{
  fill(0, 255, 0);
  ellipse(x, y, 10, 10);
  noFill();
}

void drawEchoes()
{
  for(int i = 0; i < distances.length; i++)
  {
    if(distances[i] >= 0)
    {
      // r is the distance and thus the radius for the echo to be marked.
	  // This distance has to be scaled to the scope's radius.
      float r = fmap(distances[i], 0, 200, 0, radius);
      int x = scopeCenterX + (int) (r * cos(degreesToRad(i)));
      int y = scopeCenterY + (int) (r * sin(degreesToRad(i)));
      drawDot(x, y); 
    }
  }
}

/**
* Draws the oscillating scan line.
* int angle : the current position of the servo in degrees
*/
void drawScanLine(int angle) 
{
  float angleRad = degreesToRad(angle);
  scanLineTailX = scopeCenterX + (int) (radius * cos(angleRad));
  scanLineTailY = scopeCenterY + (int) (radius * sin(angleRad));  
  line(scopeCenterX, scopeCenterY, scanLineTailX, scanLineTailY);
}

boolean sketchFullScreen() {
  return true;
}
