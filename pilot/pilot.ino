#include <Servo.h>

Servo myservo;
int pos;
String a;

void setup() {
  // put your setup code here, to run once:
  pos = 100;
  myservo.attach(9);
  myservo.write(pos);
  Serial.begin(9600);
}

// 320 seems to be a fairly consistent hover
void setTapRate(int rate){
  pos = 100;
  myservo.write(pos);
  delay(rate);
  pos = 111;
  myservo.write(pos);
  delay(100);
}

void loop() {
  /**
  if( Serial.available() ){
    a = Serial.read();
    for( int i = 0; i < a.length; i++ ){
      setTapRate(a[i]);
      delay(2000);
    }
  }
  **/
  setTapRate(230);
}
