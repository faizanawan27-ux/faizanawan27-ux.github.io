/*
 * ============================================================================
 * Project:     Smart Security Alarm System (Bare-metal AVR C)
 * Institution: UET Peshawar - Computer Systems Engineering
 * Author:      Faizan (22PWCSE2134)
 * Hardware:    ATmega328P Microcontroller (16 MHz)
 * Description: Pure register-level implementation using DDR, PORT, PIN,
 *              Timer1 CTC siren sweep, and pin-change interrupt ISRs.
 * ============================================================================
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define F_CPU 16000000UL

// Pin Definitions
#define PIR_PIN       PD2
#define REED_PIN      PD3
#define FLAME_PIN     PD4
#define BUZZER_PIN    PD5
#define LED_GREEN     PD6
#define LED_AMBER     PD7
#define LED_RED       PB0

// System States
typedef enum {
    SYS_DISARMED,
    SYS_ARMED,
    SYS_ALARM
} sys_state_t;

volatile sys_state_t g_state = SYS_DISARMED;

// Setup hardware register configurations
void init_hardware(void) {
    // Inputs: PIR (PD2), Reed Switch (PD3 with pullup), Flame (PD4)
    DDRD &= ~((1 << PIR_PIN) | (1 << REED_PIN) | (1 << FLAME_PIN));
    PORTD |= (1 << REED_PIN); // Enable pullup on magnetic switch

    // Outputs: Buzzer (PD5), Green LED (PD6), Amber LED (PD7), Red LED (PB0)
    DDRD |= (1 << BUZZER_PIN) | (1 << LED_GREEN) | (1 << LED_AMBER);
    DDRB |= (1 << LED_RED);

    // Initial LED State: Disarmed (Green ON)
    PORTD |= (1 << LED_GREEN);
    PORTD &= ~((1 << LED_AMBER) | (1 << BUZZER_PIN));
    PORTB &= ~(1 << LED_RED);

    // External Interrupt 0 (INT0) on rising edge (PIR motion)
    EICRA |= (1 << ISC01) | (1 << ISC00);
    EIMSK |= (1 << INT0);

    sei(); // Enable global interrupts
}

// Timer1 CTC Mode Siren Sound Frequency Generator
void play_siren_sweep(void) {
    for (uint16_t freq = 800; freq < 2200; freq += 40) {
        uint16_t ocr_val = (F_CPU / (2 * 8 * freq)) - 1;
        TCCR1A = 0;
        TCCR1B = (1 << WGM12) | (1 << CS11); // CTC Mode, Prescaler 8
        OCR1A = ocr_val;
        
        PORTD |= (1 << BUZZER_PIN);
        _delay_ms(2);
        PORTD &= ~(1 << BUZZER_PIN);
        _delay_ms(2);
    }
}

// ISR for INT0 (PIR Motion Detection)
ISR(INT0_vect) {
    if (g_state == SYS_ARMED) {
        g_state = SYS_ALARM;
    }
}

int main(void) {
    init_hardware();

    while (1) {
        // Flame sensor emergency check (overrides state)
        if (PIND & (1 << FLAME_PIN)) {
            g_state = SYS_ALARM;
        }

        switch (g_state) {
            case SYS_DISARMED:
                PORTD |= (1 << LED_GREEN);
                PORTD &= ~((1 << LED_AMBER) | (1 << BUZZER_PIN));
                PORTB &= ~(1 << LED_RED);
                break;

            case SYS_ARMED:
                PORTD &= ~((1 << LED_GREEN) | (1 << LED_AMBER) | (1 << BUZZER_PIN));
                PORTB |= (1 << LED_RED);
                
                // Door Breach Check
                if (PIND & (1 << REED_PIN)) {
                    g_state = SYS_ALARM;
                }
                break;

            case SYS_ALARM:
                PORTD &= ~(1 << LED_GREEN);
                PORTB |= (1 << LED_RED);
                play_siren_sweep();
                break;
        }

        _delay_ms(50);
    }

    return 0;
}
