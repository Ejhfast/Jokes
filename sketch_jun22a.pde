int numBalls = 100;
float spring = 0.005;
float gravity = 0.000;
float friction = -0.9;
color new_color = color(255, 204);
Ball[] balls = new Ball[numBalls];
float time = 0;
String[] joketimes;
PFont myfont = createFont("FFScala",16);
int joke_num = 0;
//String txtfile = "with_scew.txt";
//String joking3 = "joking3.txt";
String txtfile = "jokes_long.csv";
int activejokes = 0;


void setup() 
{
  frameRate(5);
  size(750, 750);
  textFont(myfont);
  noStroke();
  smooth();
  joketimes = loadStrings(txtfile);
  for (int i = 0; i < numBalls; i++) {
    balls[i] = new Ball(random(width), random(height), 75, i, balls);
  }
  
}

void draw() 
{
  background(0);

  //background((205-joke_num)/6, (92+joke_num)/6, 0);
  for (int i = 0; i < numBalls; i++) {
    balls[i].collide();
    balls[i].move();
    if (time % 1 == 0){
      //new_color = color(255, 204);
      balls[i].joke();
    }
    balls[i].display();  
  }
  time = time + 1;
}

class Ball {
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  boolean activ = false;
  color mycolor;
  Ball[] others;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    mycolor = color(255, 204);
  } 
  
  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
      }
    }   
  }
  
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      vx *= friction; 
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > height) {
      y = height - diameter/2;
      vy *= friction; 
    } 
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }
  
  void joke() {
    
    //new_color = color(255, 204);
    
    //read from line t in file:
    //if time = t and joked with at time t, set activ = true
      //really: if i in line, set i
    String[] heard = new String[100];
   // if(time%10 == 0){
      if(time < float(joketimes.length)) {
        heard = split(joketimes[parseInt(time)], ' ');       
      }
    
      for(int j = 0; j < heard.length; j = j+1){
        if((parseInt(heard[j]) == 1) && (id == j)) {
          activ = true;
          joke_num = j;
          activejokes = activejokes + 1;
        }
      }
    //}
           // if (i in heard) {
           //   activ = true; 
           // }
    if (activ == true) {
      diameter = diameter * 1.1;
      //new_color = color(205-joke_num,92+joke_num,92);
      mycolor = color(205-joke_num,92+joke_num,92);
    }
    else{
      mycolor = color(255, 204);
    }
    activ = false;
  }
  
  void display() {
    color black = color(0,100);
    diameter = diameter * 0.99;
    fill(mycolor);
    ellipse(x, y, diameter, diameter);
    fill(black);
    text(id,x-7,y+5);
    //textFont(myfont,50);
    //text(Integer.toString(activejokes),500,500);
    //textFont(myfont);
    fill(mycolor);
  }
}
