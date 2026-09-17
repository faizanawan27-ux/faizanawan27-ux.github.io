# Real-Time Temperature Monitoring System Using FPGA

Digital System Design Lab Project — **UET Peshawar (Computer Systems Engineering)**

---

## 📌 Project Overview
A complete hardware-level **FPGA system** implemented in **Verilog HDL** on a **Spartan-6 FPGA**. The system continuously samples analog temperature from an **LM35** sensor via an **MCP3008** 10-bit SPI ADC, processes the digitized value in integer arithmetic, displays the real-time temperature (°C) on a multiplexed 4-digit 7-segment display, and triggers multi-level LED and audible PWM siren alerts.

---

## 🚀 Module Architecture & Source Files

- **`fpga_temp_monitor.v`**: Main top-level Verilog module containing:
  - 50 MHz to 1 MHz SPI clock divider (`spi_clk_tick`).
  - SPI Master State Machine (`IDLE`, `START`, `TRANSMIT`, `SAMPLE`, `LATCH`) interfacing with MCP3008 ADC Channel 0.
  - Temperature conversion pipeline ($Temp = \frac{ADC \times 322}{1000} \text{ °C}$).
  - Multiplexed 4-digit 7-segment display cathode & anode decoder.
  - Warning LED output ($\ge 45\text{°C}$) & Critical Alarm LED + 2 kHz PWM Siren ($\ge 75\text{°C}$).
- **`tb_fpga_temp_monitor.v`**: Verilog simulation testbench simulating MCP3008 MISO bit stream response for normal, warning, and critical alarm temperature levels.
- **`spartan6_pins.ucf`**: Xilinx ISE User Constraints File defining FPGA pin locations for clock, SPI bus, 7-segment anodes/cathodes, LEDs, and buzzer outputs.

---

## 🛠️ Pin Assignments (Spartan-6 FPGA)

| Signal Name | FPGA Pin | Description |
|---|---|---|
| `clk` | `P56` | 50 MHz On-board Crystal Oscillator |
| `reset` | `P38` | Active-High Reset Push Button |
| `cs_n` | `P120` | SPI Chip Select Output to MCP3008 (Active Low) |
| `sclk` | `P121` | SPI Serial Clock Output (1 MHz) |
| `mosi` | `P123` | SPI Master Output Slave Input |
| `miso` | `P124` | SPI Master Input Slave Output |
| `warn_led` | `P131` | Yellow Warning LED Output ($\ge 45\text{°C}$) |
| `alarm_led` | `P132` | Red Critical Alarm LED Output ($\ge 75\text{°C}$) |
| `buzzer` | `P133` | Piezo Siren PWM Output |
| `seg_anode[3:0]` | `P126..P127` | 7-Segment Multiplex Anode Enable |
| `seg_cathode[7:0]`| `P114..P119` | 7-Segment Segment Cathodes (a-g, dp) |

---

## 💻 How to Synthesize & Simulate

### 1. Simulation with ModelSim / Icarus Verilog
```bash
iverilog -o temp_sim.out fpga_temp_monitor.v tb_fpga_temp_monitor.v
vvp temp_sim.out
gtkwave dump.vcd
```

### 2. Synthesis in Xilinx ISE / Vivado
1. Create a new Xilinx ISE project targeting **Spartan-6 XC6SLX9-FTG256**.
2. Add `fpga_temp_monitor.v` and `spartan6_pins.ucf`.
3. Run **Synthesize - XST**, **Implement Design**, and **Generate Programming File**.
4. Program the FPGA via JTAG programmer.
