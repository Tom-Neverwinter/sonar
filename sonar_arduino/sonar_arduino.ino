#include <Servo.h>

#define servoPin  9
#define triggerPin 13
#define echoPin 12

Servo servo;
int const minRange = 0;
int const maxRange = 200;
int const servoMinRange = 0;
int const servoMaxRange = 179;

int servoPosition = 0;
int servoDirection = 1;

// returns the distance
long pulse()
{
  long duration, distance;
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  
  duration = pulseIn(echoPin, HIGH);
  distance = duration / 68.2;
  
  if(distance >= maxRange || distance <= minRange)
  {
    return -1;
  }
  else
  {
    return distance;
  }
}

void setup()
{
  Serial.begin(9600);
  servo.attach(servoPin);
  pinMode(triggerPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop()
{
  servo.write(servoPosition);
  Serial.print(servoPosition);
  Serial.print("/");
  Serial.print(pulse());
  Serial.print("@");
  
  servoPosition += servoDirection;  
  if(servoPosition >= servoMaxRange || servoPosition <= servoMinRange)
  {
    servoDirection *= -1;  // turn direction around
  }
  delay(50);
}
