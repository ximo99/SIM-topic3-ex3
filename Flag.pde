// Simulation of flags
// Author: Ximo Casanova

// Camera 3D
import peasy.*;
PeasyCam cam;

// We generate 3 flags with different structures
Mesh m1, m2, m3;

// Structure Types
final int STRUCTURED = 1;
final int BEND = 2;
final int SHEAR = 3;

// Mesh size
int pointsX;
int pointsY;

// Simulation values
float SIM_STEP = 0.1;

// Problem parameters
PVector g = new PVector (0,0,0); //gravedad
PVector wind = new PVector (0,0,0); //wind

// Boolean variables
boolean activeW = false;
boolean activeG = false;

public void settings()
{
  System.setProperty("jogl.disable.openglcore", "true");
  size (1200, 900, P3D);
}

void setup()
{
  smooth();
  
  // Camera
  cam = new PeasyCam(this, 500, 0, 0, 600);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(1000);
  
  // Rectangular meshes
  pointsX = 70;
  pointsY = 40;
  
  // Creation of the 3 flags
  m1 = new Mesh (STRUCTURED, pointsX, pointsY);
  m2 = new Mesh (BEND, pointsX, pointsY);
  m3 = new Mesh (SHEAR, pointsX, pointsY);
}

void draw()
{
  background(200);
  translate(100, 0, 0);
  
  // Wind
  if (activeW)
  {
    wind.x = 0.5 - random(10, 40) * 0.1;
    wind.y = 0.1 - random(0, 0.2);
    wind.z = 0.5 + random(10, 60) * 0.1;

  }
  else
  {
    wind.x = 0; 
    wind.y = 0;
    wind.z = 0;
  }
  
  // Gravity
  if (activeG)
    g.y = 4.9;
  else
    g.y = 0;
  
  // Flag Structured
  line(0, 0, 0, 255);
  color c = color(255, 0, 0);
  
  m1.update();
  m1.display(c);
  
  // Flag Bend
  color c2 = color(0, 255, 0);
  
  m2.update();
  pushMatrix();
  translate(300, 0, 0);
  line(0, 0, 0, 255);
  
  m2.display(c2);
  popMatrix();
  
  // Flag Shear
  color c3 = color(0, 206, 255);
  
  m3.update();
  pushMatrix();
  translate(600, 0, 0);
  line(0, 0, 0, 255);
  
  m3.display(c3);
  popMatrix();
  
  drawStaticEnvironment();
}

void drawStaticEnvironment()
{
  //Draw data
  fill (0);
  textSize(20);
  
  text("Press the 'W' key to activate/deactivate the wind", 0, -300, 0);
  text("Press the 'G' key to activate/deactivate the gravity", 0, -275, 0);
  
  text("Wind: " + activeW, 600, -300, 0);
  text("Gravity: " + activeG, 600, -275, 0);
    
  text("Type STRUCTURED", 0, -200, 0);
  text("Elastic constant (k): " + m1.k, 0, -175, 0);
  text("Damping constant:" + m1.m_Damping, 0, -150, 0);
  
  text("Type BEND", 300, -200, 0);
  text("Elastic constant (k): " + m2.k, 300, -175, 0);
  text("Damping constant: " + + m2.m_Damping, 300, -150, 0);
  
  text("Type SHEAR", 600, -200, 0);
  text("Elastic constant (k): " + m3.k, 600, -175, 0);
  text ("Damping constant:" + m3.m_Damping, 600, -150, 0);
  
  line(-100, 255, width, 255);
}

void keyPressed()
{
  if (key == 'w' || key == 'W')
  {
    activeW = !activeW;
  }
  
  if (key == 'g' || key == 'G')
  {
    activeG = !activeG;
  }
}
