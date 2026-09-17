# Smart Security Alarm System

Embedded Systems Lab Project — **UET Peshawar (Computer Systems Engineering)**

---

## 📌 Project Overview
An automated multi-sensor intrusion detection and fire alert system for home and facility protection. The system features a 4x4 matrix keypad for PIN-based arming/disarming, a PIR motion sensor for perimeter defense, a magnetic reed switch for door breach detection, an analog/digital flame sensor for fire emergency, a 16x2 LiquidCrystal display, status LEDs, and a dual-frequency piezo siren.

---

## 🚀 System Features & Source Files

- **`smart_security_alarm.ino`**: Complete Arduino C++ implementation with keypad PIN authentication ("1234"), state machine (`STATE_DISARMED`, `STATE_ARMING_COUNTDOWN`, `STATE_ARMED`, `STATE_ALARM_TRIGGERED`), failed attempt lockout, and I2C LCD menu navigation.
- **`smart_security_alarm_baremetal.c`**: Pure register-level AVR C implementation (ATmega328P) using external pin-change interrupts, Timer1 CTC mode for siren frequency sweep, and raw PORT/PIN register operations without Arduino library overhead.
- **`circuit_schematic.md`**: Complete wiring matrix, component list, and pinout table.

---

## 🛠️ Pin Connection Table (Arduino / AVR ATMega328P)

| Hardware Component | Arduino Pin | AVR Port/Pin | Description |
|---|---|---|---|
| PIR Motion Sensor | `Pin 2` | `PD2 (INT0)` | Digital input HIGH on motion |
| Magnetic Reed Switch | `Pin 3` | `PD3 (INT1)` | Pullup input HIGH when door opens |
| Flame / Fire Sensor | `Pin 4` | `PD4` | Digital input HIGH on flame detection |
| Piezo Siren Output | `Pin 5` | `PD5 (OC0B)` | PWM / Tone siren output |
| Green Status LED | `Pin 6` | `PD6` | Disarmed Status Indicator |
| Amber Status LED | `Pin 7` | `PD7` | Arming Countdown Indicator |
| Red Status LED | `Pin 8` | `PB0` | Armed / Alarm Triggered Indicator |
| Keypad Rows (1..4) | `A0, A1, A2, A3` | `PC0..PC3` | Keypad matrix row outputs |
| Keypad Columns (1..4)| `12, 11, 10, 9` | `PB4..PB1` | Keypad matrix column inputs |
| LCD 16x2 (I2C) | `SDA (A4), SCL (A5)` | `PC4, PC5` | TWI / I2C Bus Display |

---

## 💻 Compilation & Upload

### Arduino IDE / CLI
```bash
arduino-cli compile --fqbn arduino:avr:uno smart_security_alarm.ino
arduino-cli upload -p COM3 --fqbn arduino:avr:uno smart_security_alarm.ino
```

### AVR-GCC Bare-Metal Compilation
```bash
avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL -O2 -o alarm.elf smart_security_alarm_baremetal.c
avr-objcopy -O ihex -R .eeprom alarm.elf alarm.hex
avrdude -F -V -c arduino -p ATMEGA328P -P COM3 -b 115200 -U flash:w:alarm.hex
```
