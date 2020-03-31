PImage Wall; //<>//
PImage Door;


int SizeX=2;
int SizeY=2;

//**************************************************************************************************************

//Variables for 3d animation

//x position of camera
float x=200;
//z position of camera
float z=200;
//showing map or not
boolean map = false;
//rotation of camera
float rotation=0;
//Movement speed
int speed=20;
//Rotation speed
float rotationSpeed=0.5;

boolean Cheat = false;

boolean showKPath=Cheat && true;
color KPath = color(200, 0, 0);

boolean showKey=Cheat && true;

boolean showDPath=Cheat && true;
color DPath = color(0, 200, 0);

color Floor = color(255);

int [] [] connections = new int [SizeX+1] [2*SizeY+1];

int [] [] explore = new int [SizeX+1] [2*SizeY+1];

int [] [] pathEnd = new int [0] [0];

int [] [] pathKey = new int [0] [0];

int [] [] seeing = new int [SizeX] [SizeY];

//Variables and arrays for maze Seeding

//Specifies the fraction out of 1 of the points picked as a seed. ex 0.05 means for every 100 5 are picked
float seed = 1;

boolean hasKey = false;
int keyX = 0;
int keyY = 0;

void setup() {
  fullScreen(P3D);
  //1366 , 768
  Wall = loadImage("Wall.jpg"); 
  Door = loadImage("Door.jpg");
  //textureWrap(CLAMP);
  camera(0, height/2, 0, 0, height/2, -400, 0, 1, 0);
  newMaze();
}

int t = 0;

void draw () {
  background(0);
  //line(x, z, 400*pathEnd [t/1] [1]+200, 400*pathEnd [t/1] [0]+200);
  //x = 400*pathEnd [t] [1]+200;
  //z = 400*pathEnd [t] [0]+200;
  t++;
  see();
  if (map==true) {
    Map();
  } else {
    Maze();
  }
  if (keyPressed && map==false) {
    Move();
  }
  //println(keyX);
  //println(keyY);
}


void Map() {
  int extraLR=(width-min(height, width))/2;
  int extraUD=(height-min(height, width))/2;
  pushMatrix();
  translate(-width/2, 0, -(height/2) / tan(PI/6));    
  translate(extraLR, extraUD, 0);
  stroke(255);
  for (int xPos = 0; xPos<SizeX+1; xPos++) {
    for (int yPos = 0; yPos<2*SizeY+1; yPos++) {
      if (connections [xPos] [yPos] != 0) {
        int x1=xPos;
        int y1=floor(yPos/2);
        int x2=xPos+((yPos+1)%2);
        int y2=ceil(yPos/2.0);                                               
        if ((explore [xPos] [yPos]!=0 && !((xPos==0 && yPos==1) || (xPos==SizeX-1 && yPos==2*SizeY))) || Cheat) { 
          line((x1+1)*min(height, width)/(SizeX+2), height-(y1+1)*min(height, width)/(SizeY+2), (x2+1)*min(height, width)/(SizeX+2), height-(y2+1)*min(height, width)/(SizeY+2));
        }
      }
    }
  }
  fill(256, 00, 00);
  ellipse(-(-z/400-1)*min(height, width)/(SizeX+2), height+(-x/400-1)*min(height, width)/(SizeY+2), min(height, width)/(SizeX+2)/4, min(height, width)/(SizeY+2)/4);
  if(showKey){
    fill(0);
    ellipse(-(-(keyX+0.5)-1)*min(height, width)/(SizeX+2), height+(-(keyY+0.5)-1)*min(height, width)/(SizeY+2), min(height, width)/(SizeX+2), min(height, width)/(SizeY+2));
  }
  noFill();
  //line(min(height, width)/(SizeX+2), min(height, width)/(SizeY+2), (SizeX)*min(height, width)/(SizeX+2), min(height, width)/(SizeY+2));    
  //line(min(height, width)/(SizeX+2), min(height, width)/(SizeY+2), min(height, width)/(SizeX+2), (SizeY)*min(height, width)/(SizeY+2));
  //line((SizeX+1)*min(height, width)/(SizeX+2), min(height, width)/(SizeY+2), (SizeX+1)*min(height, width)/(SizeX+2), (SizeY+1)*min(height, width)/(SizeY+2));
  //line((SizeX+1)*min(height, width)/(SizeX+2), (SizeY+1)*min(height, width)/(SizeY+2), min(height, width)/(SizeX+2), (SizeY+1)*min(height, width)/(SizeY+2));
  popMatrix();
}

void Maze() {
  stroke(0);
  pushMatrix();
  rotateY(rotation/10);
  translate(x-200, height/2+200, z+200); 
  fill(Floor);
  pushMatrix();
  rotateX(-PI/2); 
  rect(200,200,-400*SizeX,400*SizeY);
  popMatrix();
  if (showKPath) {
    DrawPath(KPath,pathKey);
  }
  if (showDPath) {
    DrawPath(DPath,pathEnd);
  }
  popMatrix();
  
  
  noFill();
  //background(0);
  noStroke();
  pushMatrix();
  rotateY(rotation/10);
  translate(x, 0, z);
  for (int xpos=0; xpos<SizeX+1; xpos++) {
    for (int ypos=0; ypos<2*SizeY+1; ypos++) {
      if (connections [xpos] [ypos] !=0 ) {
        pushMatrix();
        translate(-400*ypos/2, height/2, -400*(xpos+((ypos+1)%2)/2.0));
        if (ypos%2==0) {
          rotateY(PI/2);
        }
        beginShape();
        if ((xpos==0 && ypos==1) || (xpos==SizeX-1 && ypos==2*SizeY)) {
          texture(Door);
        } else {
          texture(Wall);
        }
        vertex(-200, 200, 0, 0, 0);
        vertex(200, 200, 0, 400, 0);
        vertex(200, -200, 0, 400, 400);
        vertex(-200, -200, 0, 0, 400);          
        endShape();
        popMatrix();
      }
    }
  }  
  if (!hasKey) {
    fill(0);
    translate(-keyY*400-200, height/2+200-30, -keyX*400-200);
    sphere(30); 
    noFill();
  }
  popMatrix();
}

void DrawPath(color path, int Path [] [] ) {
  fill(path);
  for (int t =0; t<Path.length; t++) {      
    pushMatrix();
    translate(-400*Path [t] [1], -1, -400*Path [t] [0]);
    rotateX(-PI/2);  
    rect(-200, 200, 400, 400);
    popMatrix();
  }
}

void Move() {
  switch(keyCode) {
    case(UP):
    z+=speed*cos(-rotation/10);
    x+=speed*sin(-rotation/10);
    break;
    case(DOWN):
    z-=speed*cos(-rotation/10);
    x-=speed*sin(-rotation/10);
    break;
    case(LEFT):
    rotation-=rotationSpeed;
    break;
    case(RIGHT):
    rotation+=rotationSpeed;    
    break;   
  default:           
    break;
  }

  //collision

  // ypos/3D xpos   -400*ypos/2    xpos/3D zpos  -400*(xpos+((ypos+1)%2)/2.0)
  int ySquare = floor(x/400);
  int aboutYSquare = round(x) % 400;
  int xSquare = floor(z/400);
  int aboutXSquare = round(z) % 400;

  //UP
  if (connections [xSquare] [2*ySquare+2] != 0 && aboutYSquare>300) {
    x=400*ySquare+300;
  }  
  //Left
  if (connections [xSquare] [2*ySquare+1] != 0&&aboutXSquare<100) {
    z=400*xSquare+100;
  }
  //Down
  if (connections [xSquare] [2*ySquare] != 0&&aboutYSquare<100) {
    x=400*ySquare+100;
  }
  //right
  if (connections [xSquare+1] [2*ySquare+1] != 0&&aboutXSquare>300) {
    z=400*xSquare+300;
  }
  //explore [floor(z/400)] [floor(x/400)] = 1;
}

void keyTyped() {
  switch(key) {
    case('m'):
    map=!map;
    break;
    case('g'):
    if (floor(x/400)==keyY && floor(z/400)==keyX) {
      hasKey=true;
    }
    break;
    case(' '):
    if (floor(z/400)==SizeX-1 && floor(x/400)==SizeY-1 && hasKey) {
      SizeX++;
      SizeY++;
      background(0);
      newMaze();
    }
    break;
  }
}

void see() {
  int X=floor(z/400);
  int y=floor(x/400);
  explore [X] [2*y]=1;
  explore [X] [2*y+2]=1;
  explore [X] [2*y+1]=1;
  explore [X+1] [2*y+1]=1;
  //up
  while (connections [X] [2*y]==0) {
    y--;
    explore [X] [2*y]=1;
    explore [X] [2*y+2]=1;
    explore [X] [2*y+1]=1;
    explore [X+1] [2*y+1]=1;
  }
  X=floor(z/400);
  y=floor(x/400);
  while (connections [X] [2*y+2]==0) {
    y++;
    explore [X] [2*y]=1;
    explore [X] [2*y+2]=1;
    explore [X] [2*y+1]=1;
    explore [X+1] [2*y+1]=1;
  }
  X=floor(z/400);
  y=floor(x/400);
  while (connections [X] [2*y+1]==0) {
    X--;
    explore [X] [2*y]=1;
    explore [X] [2*y+2]=1;
    explore [X] [2*y+1]=1;
    explore [X+1] [2*y+1]=1;
  }
  X=floor(z/400);
  y=floor(x/400);
  while (connections [X+1] [2*y+1]==0) {
    X++;
    explore [X] [2*y]=1;
    explore [X] [2*y+2]=1;
    explore [X] [2*y+1]=1;
    explore [X+1] [2*y+1]=1;
  }
}

void newMaze() {
  hasKey = false;
  while (keyX==0 && keyY==0) {
    keyX=int(random(0, SizeX));
    keyY=int(random(0, SizeY));
  }
  int [] [] blankArray = new int [SizeX+1] [2*SizeY+1];
  explore = blankArray;   
    for(int t=0;t<SizeX;t++){
    explore [t] [0]=1;
    explore [0] [2*t+1]=1;
    explore [SizeX] [2*t+1]=1;
    explore [t] [2*SizeY]=1;
  }
  connections = GrowMaze();
  if (showDPath) {
    pathEnd = SolveMaze(SizeX-1, SizeY-1);
  }
  if (showKPath) {
    pathKey = SolveMaze(keyX, keyY);
  }
  x=200;
  z=200;
  //t=0;
}
