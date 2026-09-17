/*
 * ============================================================================
 * Project:      Smart Security Alarm System
 * Institution:  UET Peshawar - Computer Systems Engineering
 * Author:       Faizan (22PWCSE2134)
 * Hardware:     Arduino Uno / AVR ATMega328P, 4x4 Keypad, 16x2 LCD (I2C),
 *               PIR Motion Sensor, Flame Sensor, Magnetic Reed Switch, Buzzer
 * ============================================================================
 */

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Keypad.h>
#include <EEPROM.h>

// ----------------------------------------------------------------------------
// Pin Configurations
// ----------------------------------------------------------------------------
const int PIR_PIN        = 2;   // PIR Motion Sensor (Interrupt 0)
const int DOOR_REED_PIN  = 3;   // Magnetic Reed Door Switch
const int FLAME_PIN      = 4;   // Flame / Fire Sensor
const int BUZZER_PIN     = 5;   // Piezo Siren Output
const int LED_GREEN_PIN  = 6;   // Disarmed Status LED
const int LED_AMBER_PIN  = 7;   // Arming Countdown LED
const int LED_RED_PIN    = 8;   // Armed / Alarm Status LED

// ----------------------------------------------------------------------------
// Keypad Configuration (4x4 Matrix)
// ----------------------------------------------------------------------------
const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte rowPins[ROWS] = {A0, A1, A2, A3};
byte colPins[COLS] = {12, 11, 10, 9};

Keypad customKeypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ----------------------------------------------------------------------------
// System States & Globals
// ----------------------------------------------------------------------------
enum SystemState {
  STATE_DISARMED,
  STATE_ARMING_COUNTDOWN,
  STATE_ARMED,
  STATE_ALARM_TRIGGERED
};

SystemState currentState = STATE_DISARMED;
String masterPasscode     = "1234";
String enteredPasscode    = "";
int failedAttempts        = 0;
unsigned long stateTimer  = 0;
String alarmReason        = "";

// ----------------------------------------------------------------------------
// Setup
// ----------------------------------------------------------------------------
void setup() {
  Serial.begin(9600);

  pinMode(PIR_PIN, INPUT);
  pinMode(DOOR_REED_PIN, INPUT_PULLUP);
  pinMode(FLAME_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_AMBER_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);

  lcd.init();
  lcd.backlight();
  
  lcd.setCursor(0, 0);
  lcd.print(" SMART SECURITY ");
  lcd.setCursor(0, 1);
  lcd.print(" SYSTEM READY ");
  delay(1500);

  setSystemState(STATE_DISARMED);
}

// ----------------------------------------------------------------------------
// Main Loop
// ----------------------------------------------------------------------------
void loop() {
  handleKeypad();
  checkSensors();
  updateStatusLEDs();

  if (currentState == STATE_ARMING_COUNTDOWN) {
    unsigned long elapsed = (millis() - stateTimer) / 1000;
    if (elapsed >= 10) {
      setSystemState(STATE_ARMED);
    } else {
      lcd.setCursor(12, 1);
      lcd.print(10 - elapsed);
      lcd.print("s ");
    }
  }

  if (currentState == STATE_ALARM_TRIGGERED) {
    triggerSirenSound();
  }
}

// ----------------------------------------------------------------------------
// State Management
// ----------------------------------------------------------------------------
void setSystemState(SystemState newState) {
  currentState = newState;
  enteredPasscode = "";
  lcd.clear();

  switch (currentState) {
    case STATE_DISARMED:
      noTone(BUZZER_PIN);
      lcd.setCursor(0, 0);
      lcd.print("Status: DISARMED");
      lcd.setCursor(0, 1);
      lcd.print("Press A to Arm  ");
      break;

    case STATE_ARMING_COUNTDOWN:
      stateTimer = millis();
      lcd.setCursor(0, 0);
      lcd.print("Arming System...");
      lcd.setCursor(0, 1);
      lcd.print("Countdown: ");
      break;

    case STATE_ARMED:
      lcd.setCursor(0, 0);
      lcd.print("Status: ARMED   ");
      lcd.setCursor(0, 1);
      lcd.print("Enter PIN:      ");
      break;

    case STATE_ALARM_TRIGGERED:
      lcd.setCursor(0, 0);
      lcd.print("!! ALARM ALERT !");
      lcd.setCursor(0, 1);
      lcd.print(alarmReason);
      break;
  }
}

// ----------------------------------------------------------------------------
// Keypad Input Handler
// ----------------------------------------------------------------------------
void handleKeypad() {
  char key = customKeypad.getKey();
  if (!key) return;

  tone(BUZZER_PIN, 1500, 50); // Keypress beep

  if (key == 'A' && currentState == STATE_DISARMED) {
    setSystemState(STATE_ARMING_COUNTDOWN);
    return;
  }

  if (key == '*') { // Clear input
    enteredPasscode = "";
    if (currentState == STATE_ARMED || currentState == STATE_ALARM_TRIGGERED) {
      lcd.setCursor(11, 1);
      lcd.print("    ");
    }
    return;
  }

  if (key == '#') { // Submit PIN
    if (enteredPasscode == masterPasscode) {
      failedAttempts = 0;
      setSystemState(STATE_DISARMED);
    } else {
      failedAttempts++;
      lcd.setCursor(0, 1);
      lcd.print("WRONG PIN! (" + String(failedAttempts) + ")");
      delay(1200);
      if (failedAttempts >= 3 && currentState != STATE_ALARM_TRIGGERED) {
        alarmReason = "PIN LOCKOUT";
        setSystemState(STATE_ALARM_TRIGGERED);
      } else {
        enteredPasscode = "";
        lcd.setCursor(0, 1);
        lcd.print("Enter PIN:      ");
      }
    }
    return;
  }

  // Append digit
  if (enteredPasscode.length() < 4 && key >= '0' && key <= '9') {
    enteredPasscode += key;
    if (currentState == STATE_ARMED || currentState == STATE_ALARM_TRIGGERED) {
      lcd.setCursor(11 + (enteredPasscode.length() - 1), 1);
      lcd.print("*");
    }
  }
}

// ----------------------------------------------------------------------------
// Sensor Detection
// ----------------------------------------------------------------------------
void checkSensors() {
  // Always check flame sensor regardless of state
  if (digitalRead(FLAME_PIN) == HIGH && currentState != STATE_ALARM_TRIGGERED) {
    alarmReason = "FIRE DETECTED!";
    setSystemState(STATE_ALARM_TRIGGERED);
    return;
  }

  // Check intrusion sensors only when Armed
  if (currentState == STATE_ARMED) {
    if (digitalRead(PIR_PIN) == HIGH) {
      alarmReason = "MOTION DETECTED";
      setSystemState(STATE_ALARM_TRIGGERED);
    } else if (digitalRead(DOOR_REED_PIN) == HIGH) { // Open door
      alarmReason = "DOOR BREACH!";
      setSystemState(STATE_ALARM_TRIGGERED);
    }
  }
}

// ----------------------------------------------------------------------------
// LED & Siren Outputs
// ----------------------------------------------------------------------------
void updateStatusLEDs() {
  digitalWrite(LED_GREEN_PIN, currentState == STATE_DISARMED);
  digitalWrite(LED_AMBER_PIN, currentState == STATE_ARMING_COUNTDOWN);
  digitalWrite(LED_RED_PIN,   currentState == STATE_ARMED || currentState == STATE_ALARM_TRIGGERED);
}

void triggerSirenSound() {
  // Dual tone siren sweep
  for (int hz = 800; hz < 2200; hz += 50) {
    tone(BUZZER_PIN, hz);
    delay(2);
  }
  for (int hz = 2200; hz > 800; hz -= 50) {
    tone(BUZZER_PIN, hz);
    delay(2);
  }
}
