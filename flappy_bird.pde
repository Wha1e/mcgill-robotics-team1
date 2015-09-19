import java.util.LinkedList;

boolean started;
LinkedList<Pipe> pipes = new LinkedList<Pipe>();
Bird aBird = new Bird();

class Bird{
  PVector location;
  PVector velocity;
  PVector acceleration;
  int topSpeed;
  
  
  Bird(){
    this.location = new PVector(150, height/2);
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0.15);
    this.topSpeed = 10;
  }
  
  void jump(){
    this.velocity.y = -3;
  }
  
  void updateBird(){
    velocity.add(acceleration);
    if( this.velocity.y >= this.topSpeed ){
      this.velocity.y = this.topSpeed;
    }
    location.add(velocity);
  }
  
  void drawBird(){
    stroke(126);
    fill(126);
    ellipse(this.location.x, this.location.y, 30, 30);
  }
}

class Pipe{
  int xLoc;
  int gap;
  
  Pipe(){
    this.xLoc = 1000;
    float n = (noise(frameCount));
    this.gap = (int)map(n, 0, 1, 150, 550);
  }
  
  void updatePipe(){
      this.xLoc--;
  }
  
  void drawPipe(){
    // upper half
    stroke(126);
    fill(0);
    rect(xLoc, 0, 100, this.gap);
    
    // lower half
    stroke(126);
    fill(0);
    rect(xLoc, this.gap + 100, 100, height);
  }
}

void setup(){
  frameRate(120);
  size(1000, 700);
  background(255);
}

void draw(){
  background(255);
  
  if( !started ){
    aBird.drawBird();
    
    if( keyPressed && key ==' ' ){
      started = true;
    }
    
  }
  else{
    Pipe aPipe;
    if( frameCount % 300 == 0 ){
      aPipe = new Pipe();
      pipes.addLast(aPipe);
    }
    
    if( aBird.location.y > height ){
      started = false;
      aBird = new Bird();
      pipes = new LinkedList<Pipe>();
    }
    if( pipes.size() > 0 ){
      if( pipes.getFirst().xLoc < aBird.location.x + 13 && pipes.getFirst().xLoc + 50 > aBird.location.x - 13
        && (pipes.getFirst().gap > aBird.location.y - 13 || pipes.getFirst().gap + 100 < aBird.location.y + 13 ) ){
        started = false;
        aBird = new Bird();
        pipes = new LinkedList<Pipe>();
      }
      else{
      }
    }
    
    if( keyPressed && key == ' '  && aBird.location.y > 0  ){
      aBird.jump();
    }
    
    for( int i = 0; i < pipes.size(); i++ ){
      if( pipes.get(i).xLoc + 100 <= 0 ){
        pipes.remove(i);
      }
      pipes.get(i).updatePipe();
      pipes.get(i).drawPipe();
    }
    aBird.updateBird();
    aBird.drawBird();
  }
}