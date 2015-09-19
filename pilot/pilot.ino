#include <Servo.h>

Servo myservo;
int pos;

void setup() {
  // put your setup code here, to run once:
  pos = 0;
  myservo.attach(9);
}

void loop() {
  // put your main code here, to run repeatedly:
  pos = 30;
  myservo.write(pos);
  delay(250);
  pos = 0;
  myservo.write(0);
  delay(250);
}
