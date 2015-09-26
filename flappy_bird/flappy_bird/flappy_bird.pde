import java.util.LinkedList;
import cc.arduino.*;
import processing.serial.*;

boolean started;
LinkedList<Pipe> pipes = new LinkedList<Pipe>();
Bird aBird = new Bird();
boolean recentlyJumped = false;
boolean userControlled = false;
int controlState = 2;
int flightState;
boolean hovering = true;
int lastHoverCall = 0;

Arduino arduino;
int servoPin = 9;


class Bird{
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector jumpAccel;
  int topSpeed;
  
  
  Bird(){
    this.location = new PVector(150, height/2);
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0.15);
    this.jumpAccel = new PVector(0, -0.5);
    this.topSpeed = 10;
  }
  
  void jump(){
    if( !recentlyJumped ){
      this.velocity.y = -3;
    }
    recentlyJumped = true;
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
    rect(xLoc, this.gap + 150, 100, height);
  }
}

void hover(int timeCalled){
  if( hovering == false ){
    hovering = true;
    lastHoverCall = timeCalled;
  }
  int delay = (millis() - lastHoverCall) % 338 ;
  if( delay < 25 ){
    arduino.analogWrite(servoPin, 6);
  }else{
    arduino.analogWrite(servoPin, 0);
  }
}

void setup(){
  frameRate(120);
  size(1000, 700);
  background(255);
  flightState = 2;
  
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  arduino.pinMode(servoPin, Arduino.OUTPUT);
  arduino.analogWrite(servoPin, 0);
}



void draw(){
  background(255);
  
  if( frameCount % 10 == 0 ){
    recentlyJumped = false;
  }
  
  if( !started ){
    aBird.drawBird();
    
    flightState = 2;
    
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
      if( pipes.getFirst().xLoc < aBird.location.x + 13 && pipes.getFirst().xLoc + 100 > aBird.location.x - 13
        && (pipes.getFirst().gap > aBird.location.y - 13 || pipes.getFirst().gap + 150 < aBird.location.y + 13 ) ){
        started = false;
        flightState = 2;
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
      if( pipes.get(i).xLoc + 100 <= 0){
        pipes.remove(i);
      }
      pipes.get(i).updatePipe();
      pipes.get(i).drawPipe();
    }
    
    if( controlState == 1 ){
      // FLIGHT CODE STARTS HERE
      if( pipes.size() > 1 ){
        if( aBird.location.y > pipes.get(0).gap + 75 && pipes.get(0).xLoc + 100 > aBird.location.x){
          aBird.jump();
        }
        else if( aBird.location.y > pipes.get(1).gap + 75 && pipes.get(0).xLoc + 100 < aBird.location.x ){
          aBird.jump();
        }
      }
      else{
         if( aBird.location.y > 500 ){
          aBird.jump();
         }
      }
    }

    else if( controlState == 2 ){
      
      // CODE HERE TO SET THE FLIGHT STATE
      
      if( flightState == 0 ){
        hovering = false;
        arduino.analogWrite(servoPin, 6);
      }
      else if( flightState == 1 ){
        hover(millis());
      }
      else if( flightState == 2 ){
        hovering = true;
        arduino.analogWrite(servoPin, 0);
      }
      
      /**
      if( pipes.size() > 1 ){
        if( aBird.location.y > pipes.get(0).gap + 100 && pipes.get(0).xLoc + 100 > aBird.location.x){
          flightState = 0; // bird flies up
        }
        else if( aBird.location.y > pipes.get(0).gap && aBird.location.y < pipes.get(0).gap + 200 && pipes.get(0).xLoc < aBird.location.x && pipes.get(1).xLoc + 100 > aBird.location.x ){
          flightState = 1; // bird hovers
        }
        else if( aBird.location.y > pipes.get(1).gap && aBird.location.y < pipes.get(1).gap + 200 && pipes.get(0).xLoc + 100 < aBird.location.x && pipes.get(1).xLoc > aBird.location.x){
          flightState = 1; // bird hovers
        }
        else if( aBird.location.y > pipes.get(1).gap + 100 && pipes.get(0).xLoc + 100 < aBird.location.x ){
          flightState = 0; // 
        }
        else{
          flightState = 2;
        }
      }
      else{
        if( aBird.location.y > 200 ){
          flightState = 1;
        }
      }
      **/
      if(pipes.size() < 3){
        flightState = 1;
      }
      else{
        for( int i = 0; i < pipes.size(); i++ ){
          if( pipes.get(i).xLoc <= 325 && pipes.get(i).xLoc > 75 ){
            int targetHeight = pipes.get(i).gap + 75;
            
            if( aBird.location.y < targetHeight - 47    ){
              flightState = 2;
            }
            else if( aBird.location.y > targetHeight + 40 ){
              flightState = 0;
            }
            else{
              flightState = 1;
            }
          }
        }
      }
      
      aBird.updateBird();
      aBird.drawBird();
    }
  }
}