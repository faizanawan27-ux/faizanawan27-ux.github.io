# Smart Security Alarm System — Circuit Schematic & Wiring Guide

---

## 🔌 Hardware Circuit Connections

```
                     +---------------------------------+
                     |       Arduino Uno / ATmega328P  |
                     +---------------------------------+
                                    |
   +-------------------+            |           +-------------------+
   | 4x4 Keypad Matrix |            |           |  16x2 I2C LCD     |
   | Rows: A0,A1,A2,A3 |------------+-----------|  SDA -> A4 (PC4)  |
   | Cols: 12,11,10,9  |            |           |  SCL -> A5 (PC5)  |
   +-------------------+            |           +-------------------+
                                    |
   +-------------------+            |           +-------------------+
   | PIR Motion Sensor |------------+           | Piezo Siren       |
   | Signal -> Pin 2   |            |-----------| Signal -> Pin 5   |
   +-------------------+            |           +-------------------+
                                    |
   +-------------------+            |           +-------------------+
   | Door Reed Switch  |------------+           | Status LEDs       |
   | Signal -> Pin 3   |            |-----------| Green  -> Pin 6   |
   +-------------------+            |           | Amber  -> Pin 7   |
                                    |           | Red    -> Pin 8   |
   +-------------------+            |           +-------------------+
   | Flame Sensor      |------------+
   | Signal -> Pin 4   |
   +-------------------+
```

---

## 📑 Complete Component List & Pin Table

1. **Microcontroller**: Arduino Uno R3 / Microchip ATmega328P (16 MHz Crystal).
2. **PIR Sensor (HC-SR501)**: VCC -> 5V, GND -> GND, OUT -> Pin 2 (`PD2`).
3. **Magnetic Door Reed Switch**: Terminal 1 -> Pin 3 (`PD3`), Terminal 2 -> GND (Internal Pull-Up enabled).
4. **IR Flame Sensor Module**: VCC -> 5V, GND -> GND, DO -> Pin 4 (`PD4`).
5. **Piezo Buzzer Siren**: Positive -> Pin 5 (`PD5`), Negative -> GND.
6. **16x2 I2C LCD Display**: VCC -> 5V, GND -> GND, SDA -> Pin A4 (`PC4`), SCL -> Pin A5 (`PC5`).
7. **Keypad 4x4 Matrix**:
   - R1..R4 -> A0, A1, A2, A3
   - C1..C4 -> Pin 12, 11, 10, 9
8. **LED Indicators**:
   - Green (Disarmed): Pin 6 + 220Ω resistor -> GND
   - Amber (Countdown): Pin 7 + 220Ω resistor -> GND
   - Red (Armed/Alarm): Pin 8 + 220Ω resistor -> GND
