#include <Servo.h>

Servo leftServo;
Servo rightServo;

const int leftPin = 9;
const int rightPin = 10;

// Current servo positions
int currentLeft = 90;
int currentRight = 90;

// Home position calibration
const int homeLeft = 90;
const int homeRight = 90;
const float homePy = 80.0;

// Safe workspace limits
const float minPy = 80.0;
const float maxPy = 120.0;

const int minLeft = 90;
const int maxLeft = 102;

const int minRight = 78;
const int maxRight = 90;

// Smooth motion speed
const int stepDelay = 20;

// Experimental calibration table
const int numberOfPoints = 4;

float pyTable[numberOfPoints] = {
  80.0,
  105.0,
  115.0,
  120.0
};

int leftTable[numberOfPoints] = {
  90,
  95,
  100,
  102
};

int rightTable[numberOfPoints] = {
  90,
  85,
  80,
  78
};

void setup() {
  Serial.begin(9600);

  leftServo.attach(leftPin);
  rightServo.attach(rightPin);

  moveSmooth(homeLeft, homeRight);

  Serial.println("Arduino ready.");
  Serial.println("Commands:");
  Serial.println("HOME       -> move to Py = 80 mm");
  Serial.println("Y:100      -> move to target Py in mm");
  Serial.println("A:95,85    -> move to manual servo angles");
}

void loop() {
  if (Serial.available()) {
    String data = Serial.readStringUntil('\n');
    data.trim();

    if (data.length() == 0) {
      return;
    }

    data.toUpperCase();

    if (data == "HOME") {
      moveToHome();
      return;
    }

    if (data.startsWith("Y:")) {
      float targetPy = data.substring(2).toFloat();
      moveToPy(targetPy);
      return;
    }

    if (data.startsWith("A:")) {
      moveToManualAngles(data.substring(2));
      return;
    }

    Serial.println("Invalid command.");
    Serial.println("Use HOME, Y:100, or A:95,85");
  }
}

void moveToHome() {
  moveSmooth(homeLeft, homeRight);

  Serial.print("Moved to HOME. Py = ");
  Serial.print(homePy);
  Serial.println(" mm");
}

void moveToPy(float targetPy) {
  targetPy = constrain(targetPy, minPy, maxPy);

  int targetLeft = interpolateServo(targetPy, pyTable, leftTable);
  int targetRight = interpolateServo(targetPy, pyTable, rightTable);

  targetLeft = constrain(targetLeft, minLeft, maxLeft);
  targetRight = constrain(targetRight, minRight, maxRight);

  moveSmooth(targetLeft, targetRight);

  Serial.print("Target Py = ");
  Serial.print(targetPy);
  Serial.print(" mm, Left = ");
  Serial.print(targetLeft);
  Serial.print(", Right = ");
  Serial.println(targetRight);
}

void moveToManualAngles(String angleData) {
  int commaIndex = angleData.indexOf(',');

  if (commaIndex < 0) {
    Serial.println("Wrong manual angle format. Use A:left,right");
    return;
  }

  int targetLeft = angleData.substring(0, commaIndex).toInt();
  int targetRight = angleData.substring(commaIndex + 1).toInt();

  targetLeft = constrain(targetLeft, minLeft, maxLeft);
  targetRight = constrain(targetRight, minRight, maxRight);

  moveSmooth(targetLeft, targetRight);

  Serial.print("Manual move completed. Left = ");
  Serial.print(targetLeft);
  Serial.print(", Right = ");
  Serial.println(targetRight);
}

int interpolateServo(float targetPy, float pyValues[], int servoValues[]) {
  if (targetPy <= pyValues[0]) {
    return servoValues[0];
  }

  if (targetPy >= pyValues[numberOfPoints - 1]) {
    return servoValues[numberOfPoints - 1];
  }

  for (int i = 0; i < numberOfPoints - 1; i++) {
    if (targetPy >= pyValues[i] && targetPy <= pyValues[i + 1]) {
      float ratio = (targetPy - pyValues[i]) / (pyValues[i + 1] - pyValues[i]);
      float servoAngle = servoValues[i] + ratio * (servoValues[i + 1] - servoValues[i]);
      return round(servoAngle);
    }
  }

  return servoValues[0];
}

void moveSmooth(int targetLeft, int targetRight) {
  while (currentLeft != targetLeft || currentRight != targetRight) {
    if (currentLeft < targetLeft) {
      currentLeft++;
    } else if (currentLeft > targetLeft) {
      currentLeft--;
    }

    if (currentRight < targetRight) {
      currentRight++;
    } else if (currentRight > targetRight) {
      currentRight--;
    }

    leftServo.write(currentLeft);
    rightServo.write(currentRight);

    delay(stepDelay);
  }
}