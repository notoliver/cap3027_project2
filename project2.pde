import controlP5.*;

ControlP5 cp5;
boolean constrain=false;
boolean terrain=false;
boolean stroke=false;
boolean randomSeed=false;
int maxSteps;
int stepRate;
int stepSize;
boolean run=false;

void setup() {
  size(1200, 800, P2D);
  smooth();
  background(141,170,210);
  gui();
}

void gui() {
  cp5 = new ControlP5(this);
  Group g1 = cp5.addGroup("myGroup1")
      .setBackgroundColor(color(100))
      .setBackgroundHeight(805)
      .setWidth(200)
  ;    
  cp5.addButton("walk")
     .setPosition(10,10)
     .setSize(120,40)
     .setColorBackground(color(0,150,0))
     .setCaptionLabel("START")
  ;
  cp5.addScrollableList("sup")
     .setPosition(10, 60)
     .setWidth(160)
     .setBarHeight(50)
     .setItemHeight(50)
     .addItem("SQUARES",null)
     .addItem("HEXAGONS",null)
     .setValue(0)
     .setType(ScrollableList.DROPDOWN)
     .setOpen(true)
  ;
  cp5.addTextlabel("Maximum Steps")
     .setPosition(12,240)
     .setValue("Maximum Steps")
  ;
  cp5.addSlider("maxSteps")
     .setPosition(10,250)
     .setSize(180,20)
     .setRange(100,50000)
     .setValue(100)
     .setCaptionLabel("")
  ;
  cp5.addTextlabel("Step Rate")
     .setPosition(12,280)
     .setValue("Step Rate")
  ;
  cp5.addSlider("stepRate")
     .setPosition(10,290)
     .setSize(180,20)
     .setRange(1,1000)
     .setValue(1)
     .setCaptionLabel("")
  ;
  cp5.addTextlabel("Step Size")
     .setPosition(12,360)
     .setValue("Step Size")
  ;
  cp5.addSlider("stepSize")
     .setPosition(10,370)
     .setSize(80,20)
     .setRange(10,30)
     .setValue(10)
     .setCaptionLabel("")
  ;
  cp5.addTextlabel("Step Scale")
     .setPosition(12,400)
     .setValue("Step Scale")
  ;
  cp5.addSlider("stepScale")
     .setPosition(10,410)
     .setSize(80,20)
     .setRange(1.00,1.50)
     .setValue(1.00)
     .setCaptionLabel("")
  ;
  cp5.addToggle("constrain")
     .setPosition(10,450)
     .setSize(20,20)
     .setCaptionLabel("Constrain Steps")
     .setValue(0)
  ;
  cp5.addToggle("terrain")
     .setPosition(10,490)
     .setSize(20,20)
     .setCaptionLabel("Simulate Terrain")
  ;
  cp5.addToggle("stroke")
     .setPosition(10,530)
     .setSize(20,20)
     .setCaptionLabel("Use Stroke")
  ;
  cp5.addToggle("randomSeed")
     .setPosition(10,570)
     .setSize(20,20)
     .setCaptionLabel("Use Random Seed")
  ;
  cp5.addTextfield("seed")
     .setCaptionLabel("Seed Value")
     .setPosition(100,570)
     .setSize(60,20)
     .setInputFilter(ControlP5.INTEGER)
     .setValue("0")
  ;
}
public void maxSteps(int theValue) {maxSteps = theValue;}
public void stepRate(int theValue) {stepRate = theValue;}
public void stepSize(int theValue) {stepSize = theValue;}

int y=height/2;

class RandomWalkBaseClass{
  float maxSteps;
  float stepsTaken;
  float stepSize;
  float stepScale;
  boolean drawTerrain;
  boolean useStroke;
  float boundaryLeft=200;
  float boundaryRight=width-1;
  float boundaryTop=0;
  float boundaryBottom=height-1;
  float x=(width+200)/2;
  float y=height/2;
  HashMap<PVector, Integer> terrain;
  RandomWalkBaseClass(){
    stepsTaken=0;
    maxSteps=cp5.getController("maxSteps").getValue();
    stepSize=cp5.getController("stepSize").getValue();
    stepScale=cp5.getController("stepScale").getValue();
    drawTerrain=cp5.getController("terrain").getValue()==1;
    terrain=new HashMap<PVector, Integer>();
    if(cp5.getController("constrain").getValue()==1){
      boundaryLeft=200;
      boundaryRight=width-1;
      boundaryTop=0;
      boundaryBottom=height-1;
    }else{
      boundaryLeft=Integer.MIN_VALUE;
      boundaryRight=Integer.MAX_VALUE;
      boundaryTop=Integer.MIN_VALUE;
      boundaryBottom=Integer.MAX_VALUE;
    }
  }
  void DoSomeWalkStuff(){}
}
class SquareClass extends RandomWalkBaseClass{
  void Update(){
    int direction = int(random(4));
    boolean moved = false;
    float factor=stepSize*stepScale;
    if(direction==0&&y-factor-stepSize/2>boundaryTop){//up
      y-=factor; moved = true;
    }if(direction==1&&y+factor+stepSize/2<boundaryBottom){//down
      y+=factor; moved = true;
    }if(direction==2&&x-factor-stepSize/2>boundaryLeft){//left
      x-=factor; moved = true;
    }else if(direction==3&&x+factor+stepSize/2<boundaryRight){//right
      x+=factor; moved = true;
    }
    if(moved){
      if(drawTerrain){
        PVector temp = new PVector(x,y);
        terrain.put(temp,terrain.getOrDefault(temp,0)+1);
      }
      stepsTaken++;
    }
  }
  void Draw(){
    rectMode(CENTER);
    if(drawTerrain){
      int terrainCount = terrain.getOrDefault(new PVector(x,y),0);
      if(terrainCount<4){
        fill(160,126,84);
      }else if(terrainCount<7){
        fill(143, 170, 64); 
      }else if(terrainCount<10){
        fill(135, 135, 135); 
      }else{
        fill(terrainCount*20);
      }
    }else{
      fill(167,100,200);
    }
    rect(x,y,stepSize,stepSize);
  }
  void DoSomeWalkStuff(){
     Draw();
     Update();
  }
}
class HexClass extends RandomWalkBaseClass{
  void Update(){
    int direction = int(random(6));
    boolean moved = false;
    float hypLength=sqrt(3)*stepSize;
    float longSide=hypLength*sqrt(3)/2;
    float shortSide=hypLength/2;
    float factor=hypLength*stepScale;
    
    if(direction==0  &&  (x+(longSide*stepScale)+stepSize)<boundaryRight  && (y+(shortSide*stepScale)+stepSize)<boundaryBottom){//30deg down and right
      x+=longSide*stepScale;
      y+=shortSide*stepScale;
      moved = true;
    }
    if(direction==1  &&  y+factor+stepSize<boundaryBottom){//90deg down
      y+=factor;
      moved = true;
    }
    if(direction==2  &&  (x-(longSide*stepScale)-stepSize)>boundaryLeft  && (y+(shortSide*stepScale)+stepSize)<boundaryBottom){//150deg down and left
      x-=longSide*stepScale;
      y+=shortSide*stepScale;
      moved = true;
    }
    if(direction==3  &&  (x-(longSide*stepScale)-stepSize)>boundaryLeft  && (y-(shortSide*stepScale)-stepSize)>boundaryTop){//210deg up and left
      x-=longSide*stepScale;
      y-=shortSide*stepScale;
      moved = true;
    }
    if(direction==4&&y-factor-stepSize>boundaryTop){//270deg up 
      y-=factor;
      moved = true;  
    }
    else if(direction==5  &&  (x+(longSide*stepScale)+stepSize)<boundaryRight  && (y-(shortSide*stepScale)-stepSize)>boundaryTop){//330deg up and right
      x+=longSide*stepScale;
      y-=shortSide*stepScale;
      moved = true;
    }
    //CARTESIAN TO HEX IS LIKE FOR THE HASHMAP
    PVector converted = CartesianToHex(x,y,stepSize,stepScale,(width+200)/2,height/2);
    
    if(moved){
      if(drawTerrain){
        PVector temp = new PVector(converted.x,converted.y);
        terrain.put(temp,terrain.getOrDefault(temp,0)+1);
      }
      stepsTaken++;
    }
  }
  void Draw(){
    if(drawTerrain){
      PVector converted = CartesianToHex(x,y,stepSize,stepScale,(width+200)/2,height/2);
      int terrainCount = terrain.getOrDefault(new PVector(converted.x,converted.y),0);
      if(terrainCount<4){
        fill(160,126,84);
      }else if(terrainCount<7){
        fill(143, 170, 64); 
      }else if(terrainCount<10){
        fill(135, 135, 135); 
      }else{
        fill(terrainCount*20);
      }
    }else{
      fill(167,100,200);
    }
    //print(converted.x+", "+converted.y);
    DrawHex(x,y,stepSize);
  }
  void DoSomeWalkStuff(){
     //print(converted.x+", "+converted.y);
     Draw();
     Update();
  }
}

//click start
RandomWalkBaseClass someObject = null;
void walk() {
  run=true;
  if(cp5.getController("randomSeed").getValue()==1){
    randomSeed(Integer.parseInt(cp5.get(Textfield.class,"seed").getText()));
  }
  if(cp5.getController("stroke").getValue()==1){
    stroke(1);
  }else{
    noStroke(); 
  }
  //square or hex
  if(cp5.getController("sup").getValue()==0){
    background(141,170,210);
    someObject = new SquareClass();
  }else{
    background(50,140,210);
    someObject = new HexClass();
  }
}

void draw() {
  if(run==true){
    if(someObject.stepsTaken<someObject.maxSteps){
      for(int steps=0;steps<cp5.getController("stepRate").getValue();steps++){
        someObject.DoSomeWalkStuff();
      }
    }
  }
}

//hex stuff
void DrawHex(float x, float y, float radius){
  //fill(255);
  beginShape();
  for (int i = 0; i <= 360; i+= 60)
  {
    float xPos = x + cos(radians(i)) * radius;
    float yPos = y + sin(radians(i)) * radius;

    vertex(xPos, yPos);
  }
  endShape();
}
PVector CartesianToHex(float xPos, float yPos, float hexRadius, float stepScale, float xOrigin, float yOrigin)
{
  float startX = xPos - xOrigin;
  float startY = yPos - yOrigin;

  float col = (2.0/3.0f * startX) / (hexRadius * stepScale);
  float row = (-1.0f/3.0f * startX + 1/sqrt(3.0f) * startY) / (hexRadius * stepScale);
  
  /*===== Convert to Cube Coordinates =====*/
  float x = col;
  float z = row;
  float y = -x - z; // x + y + z = 0 in this system
  
  float roundX = round(x);
  float roundY = round(y);
  float roundZ = round(z);
  
  float xDiff = abs(roundX - x);
  float yDiff = abs(roundY - y);
  float zDiff = abs(roundZ - z);
  
  if (xDiff > yDiff && xDiff > zDiff)
    roundX = -roundY - roundZ;
  else if (yDiff > zDiff)
    roundY = -roundX - roundZ;
  else
    roundZ = -roundX - roundY;
    
  /*===== Convert Cube to Axial Coordinates =====*/
  PVector result = new PVector(roundX, roundZ);
  
  return result;
}
