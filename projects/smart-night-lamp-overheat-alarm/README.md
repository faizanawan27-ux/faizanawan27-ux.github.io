# Smart Night Lamp + Overheat Alarm

Embedded Systems Lab project — UET Peshawar, Spring 2026.

A bare-metal ATmega328P (Arduino Uno) system that automatically dims a night
lamp based on ambient light, and raises a two-stage overheat alarm based on
temperature, using **register-level** peripheral configuration (no
`analogRead()` / `Arduino.h` abstractions).

## Features
- **Automatic night lamp**: LDR read via ADC, lamp brightness controlled with
  Timer0 hardware PWM, with hysteresis (`DARK_ON`/`DARK_OFF`) to avoid flicker.
- **Overheat alarm**: LM35 temperature sensor drives a 3-state machine
  (`NORMAL` → `HOT` → `VERY_HOT`) with hysteresis thresholds.
- **SOS alarm pattern**: Timer2 CTC interrupt (1 ms tick) blinks an LED in an
  SOS pattern during `HOT`, and adds a buzzer during `VERY_HOT`.
- **UART telemetry**: system status transmitted every second at 9600 baud
  (`L:<ldr> T:<tempC>C State:<state>`).

## Hardware
| Component | Pin | Purpose |
|---|---|---|
| LDR | A0 / ADC0 | Ambient light sensing |
| LM35 | A1 / ADC1 | Temperature sensing |
| LED1 (night lamp) | D6 / OC0A | PWM-dimmed lamp |
| LED2 (alarm) | D8 / PB0 | SOS overheat indicator |
| Buzzer | D9 / PB1 | Audible VERY_HOT alarm |
| UART TX | D1 | Serial status output |

## Peripherals used (bare-metal)
- ADC (`ADMUX`, `ADCSRA`) — averaged over 16 samples
- Timer0 Fast PWM (`TCCR0A`, `TCCR0B`, `OCR0A`) — lamp brightness
- Timer2 CTC interrupt (`TCCR2A/B`, `OCR2A`, `TIMSK2`) — 1 ms SOS timing
- UART (`UBRR0`, `UCSR0B/C`, `UDR0`) — 9600 baud, 8N1

## Build
```
avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL -Os -o lamp.elf smart_night_lamp.c
avr-objcopy -O ihex lamp.elf lamp.hex
avrdude -c arduino -p atmega328p -P <port> -U flash:w:lamp.hex
```

## Team
Zarmina Miftah Durrani, Faizan, Anees ur Rehman — Section B.

Full project report (design decisions, register walkthrough, test cases,
circuit diagram) is included as `report.pdf`.
