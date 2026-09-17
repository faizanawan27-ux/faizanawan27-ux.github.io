/******************************************************************************
 * Project : Smart Night Lamp with Overheat Alarm
 * Platform: ATmega328P
 * Language: C (AVR-GCC)
 *
 * Description:
 * -------------
 * This project implements:
 * 1. Automatic night lamp using an LDR sensor.
 * 2. Temperature monitoring using LM35.
 * 3. PWM brightness control.
 * 4. SOS LED warning when temperature is HOT.
 * 5. SOS LED + Buzzer warning when temperature is VERY HOT.
 * 6. UART status monitoring every second.
 *
 * Why C?
 * ------
 * C provides direct access to hardware registers, produces efficient code,
 * has minimal overhead, and is the standard language for AVR bare-metal
 * embedded programming.
 ******************************************************************************/
#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdio.h>

/*----------------------------------------------------------
 Hardware Pin Definitions
-----------------------------------------------------------*/
#define LED2_PIN PB0 // SOS LED
#define BUZZ_PIN PB1 // Buzzer

/*----------------------------------------------------------
 LDR Hysteresis Thresholds
-----------------------------------------------------------*/
#define DARK_ON 300
#define DARK_OFF 500

/*----------------------------------------------------------
 Temperature Hysteresis Thresholds
-----------------------------------------------------------*/
#define HOT_ON 35
#define HOT_OFF 32
#define VERY_HOT_ON 40
#define VERY_HOT_OFF 37

/*----------------------------------------------------------
 System Operating States
-----------------------------------------------------------*/
typedef enum
{
    STATE_NORMAL = 0,
    STATE_HOT,
    STATE_VERY_HOT
} system_state_t;

/*----------------------------------------------------------
 Global Variables
-----------------------------------------------------------*/
system_state_t state = STATE_NORMAL;
volatile uint32_t ms_ticks = 0;
volatile uint8_t sos_enable = 0;
volatile uint8_t very_hot_enable = 0;
uint8_t lamp_active = 0;

/*==========================================================
 UART INITIALIZATION
==========================================================*/
void uart_init(void)
{
    /* Baud Rate = 9600
       UBRR = 103 for 16 MHz */
    UBRR0H = 0;
    UBRR0L = 103;

    /* Enable transmitter only */
    UCSR0B = (1 << TXEN0);

    /* 8-bit data
       No parity
       1 Stop bit */
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

/*==========================================================
 UART SEND CHARACTER
==========================================================*/
void uart_send_char(char c)
{
    /* Wait until transmit buffer becomes empty */
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = c;
}

/*==========================================================
 UART SEND STRING
==========================================================*/
void uart_send_string(const char *str)
{
    while (*str)
    {
        uart_send_char(*str++);
    }
}

/*==========================================================
 ADC INITIALIZATION
==========================================================*/
void adc_init(void)
{
    /* REFS0 = 1
       AVCC used as reference voltage */
    ADMUX = (1 << REFS0);

    /* ADEN = Enable ADC
       ADPS2:0 = 111
       Prescaler = 128
       ADC Clock = 125kHz */
    ADCSRA =
        (1 << ADEN) |
        (1 << ADPS2) |
        (1 << ADPS1) |
        (1 << ADPS0);
}

/*==========================================================
 ADC SINGLE READ
==========================================================*/
uint16_t adc_read(uint8_t channel)
{
    channel &= 0x07;
    /* Select ADC channel */
    ADMUX = (ADMUX & 0xF0) | channel;

    /* Start conversion */
    ADCSRA |= (1 << ADSC);

    /* Wait until conversion finishes */
    while (ADCSRA & (1 << ADSC));

    return ADC;
}

/*==========================================================
 ADC AVERAGE OF 16 SAMPLES
==========================================================*/
uint16_t adc_read_avg(uint8_t channel)
{
    uint32_t sum = 0;
    for(uint8_t i=0;i<16;i++)
    {
        sum += adc_read(channel);
        _delay_ms(2);
    }
    return (uint16_t)(sum/16);
}

/*==========================================================
 TIMER0 PWM INITIALIZATION
==========================================================*/
void timer0_pwm_init(void)
{
    /* PD6 = OC0A output */
    DDRD |= (1 << PD6);

    /* Fast PWM
       Non-inverting mode */
    TCCR0A =
        (1 << COM0A1) |
        (1 << WGM01) |
        (1 << WGM00);

    /* Clock Prescaler = 64 */
    TCCR0B =
        (1 << CS01) |
        (1 << CS00);

    OCR0A = 0;
}

/*==========================================================
 PWM DUTY UPDATE
==========================================================*/
void set_lamp_brightness(uint8_t duty)
{
    OCR0A = duty;
}

/*==========================================================
 TIMER2 CTC INITIALIZATION
==========================================================*/
void timer2_ctc_init(void)
{
    /* CTC Mode */
    TCCR2A = (1 << WGM21);

    /* Compare value
       Generates interrupt every 1ms */
    OCR2A = 249;

    /* Enable compare interrupt */
    TIMSK2 = (1 << OCIE2A);

    /* Prescaler = 64 */
    TCCR2B = (1 << CS22);
}

/*==========================================================
 TIMER2 INTERRUPT
==========================================================*/
ISR(TIMER2_COMPA_vect)
{
    ms_ticks++;

    static uint16_t sos_timer = 0;
    static uint8_t sos_step = 0;

    if(!sos_enable)
    {
        PORTB &= ~(1<<LED2_PIN);
        PORTB &= ~(1<<BUZZ_PIN);
        sos_timer = 0;
        sos_step = 0;
        return;
    }

    sos_timer++;

    const uint16_t durations[] =
    {
        200,200,200,200,200,600,
        600,200,600,200,600,600,
        200,200,200,200,200,1000
    };

    const uint8_t outputs[] =
    {
        1,0,1,0,1,0,
        1,0,1,0,1,0,
        1,0,1,0,1,0
    };

    if(sos_timer >= durations[sos_step])
    {
        sos_timer = 0;
        sos_step++;
        if(sos_step >= 18)
            sos_step = 0;
    }

    if(outputs[sos_step])
    {
        PORTB |= (1<<LED2_PIN);
        if(very_hot_enable) PORTB |= (1<<BUZZ_PIN);
        else
            PORTB &= ~(1<<BUZZ_PIN);
    }
    else
    {
        PORTB &= ~(1<<LED2_PIN);
        PORTB &= ~(1<<BUZZ_PIN);
    }
}

/*==========================================================
 AUTOMATIC LAMP CONTROL
==========================================================*/
void update_lamp(uint16_t ldr_value)
{
    static uint8_t current_brightness = 0;
    uint8_t target = 0;

    if(!lamp_active && ldr_value < DARK_ON)
        lamp_active = 1;
    else if(lamp_active && ldr_value > DARK_OFF)
        lamp_active = 0;

    if(lamp_active)
    {
        if(ldr_value >= DARK_ON)
            target = 0;
        else
            target =
                (uint8_t)(((DARK_ON-ldr_value)*255UL)/DARK_ON);
    }

    if(current_brightness < target)
        current_brightness++;
    else if(current_brightness > target)
        current_brightness--;

    set_lamp_brightness(current_brightness);
}

/*==========================================================
 TEMPERATURE STATE MACHINE
==========================================================*/
void update_temperature_state(uint16_t tempC)
{
    switch(state)
    {
        case STATE_NORMAL:
            if(tempC >= VERY_HOT_ON)
                state = STATE_VERY_HOT;
            else if(tempC >= HOT_ON)
                state = STATE_HOT;
            break;

        case STATE_HOT:
            if(tempC >= VERY_HOT_ON)
                state = STATE_VERY_HOT;
            else if(tempC <= HOT_OFF)
                state = STATE_NORMAL;
            break;

        case STATE_VERY_HOT:
            if(tempC <= HOT_OFF)
                state = STATE_NORMAL;
            else if(tempC <= VERY_HOT_OFF)
                state = STATE_HOT;
            break;
    }

    if(state == STATE_NORMAL)
    {
        sos_enable = 0;
        very_hot_enable = 0;
    }
    else if(state == STATE_HOT)
    {
        sos_enable = 1;
        very_hot_enable = 0;
    }
    else {
        sos_enable = 1;
        very_hot_enable = 1;
    }
}

/*==========================================================
 STATE TO STRING
==========================================================*/
const char* state_to_string(system_state_t s)
{
    switch(s)
    {
        case STATE_HOT:
            return "HOT";
        case STATE_VERY_HOT:
            return "VERY_HOT";
        default:
            return "NORMAL";
    }
}

/*==========================================================
 MAIN PROGRAM
==========================================================*/
int main(void)
{
    char buffer[64];

    /* Configure LED and buzzer as outputs */
    DDRB |= (1<<LED2_PIN) | (1<<BUZZ_PIN);

    adc_init();
    uart_init();
    timer0_pwm_init();
    timer2_ctc_init();

    /* Enable global interrupts */
    sei();

    uint32_t last_status_time = 0;
    uart_send_string("Smart Night Lamp + Overheat Alarm Started\r\n");

    while(1)
    {
        uint16_t ldr_value = adc_read_avg(0);
        uint16_t lm35_adc = adc_read_avg(1);
        uint16_t tempC =
            (uint16_t)((lm35_adc * 500UL)/1024UL);

        update_lamp(ldr_value);
        update_temperature_state(tempC);

        if((ms_ticks-last_status_time)>=1000)
        {
            last_status_time = ms_ticks;
            snprintf(buffer,
                     sizeof(buffer),
                     "L:%u T:%uC State:%s\r\n",
                     ldr_value,
                     tempC,
                     state_to_string(state));
            uart_send_string(buffer);
        }

        _delay_ms(20);
    }
}
