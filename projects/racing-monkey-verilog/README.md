# Racing Monkey — Verilog Hardware Arcade Game Engine

Digital Logic Design Lab Project — **UET Peshawar (Computer Systems Engineering)**

---

## 📌 Project Overview
An endless-runner arcade game fully designed and synthesized in **Verilog HDL** for an **FPGA board**. The game generates a live **640x480 @ 60Hz VGA video signal**, handles player physics (jump, duck, gravity), obstacle movement, AABB bounding-box collision detection, a multi-state game FSM (`START`, `PLAYING`, `GAMEOVER`), score tracking, and custom bitwise sprite rendering.

---

## 🚀 Module Architecture & Source Files

- **`racing_monkey_top.v`**: Top-level FPGA module linking the 50 MHz to 25 MHz pixel clock divider, 640x480 VGA controller, game FSM engine, sprite ROM, and 12-bit RGB video output.
- **`vga_controller.v`**: Standard 640x480 @ 60Hz VGA timing generator outputting `hsync`, `vsync`, `video_on`, and `(pixel_x, pixel_y)` coordinates.
- **`monkey_game_logic.v`**: Physics simulation, collision detection engine, obstacle spawner, jump/duck buttons, and dynamic color rendering.
- **`monkey_sprite_rom.v`**: Bitwise 16x16 pixel pattern ROM module storing custom character graphics for the monkey and obstacles.
- **`tb_racing_monkey.v`**: Complete Verilog testbench verifying VGA horizontal/vertical sync timing and player jump physics.
- **`racing_monkey_pins.ucf`**: Xilinx UCF pin constraints mapping VGA DAC outputs, clock, reset, and push buttons to Spartan-6 FPGA board pins.

---

## 🕹️ Game Controls & State Machine

| Control Input | Button Pin | Action |
|---|---|---|
| `btn_start` | Push Button 0 | Start game / Restart after Game Over |
| `btn_jump` | Push Button 1 | Make monkey jump over low obstacles |
| `btn_duck` | Push Button 2 | Crouch monkey to avoid high branch obstacles |
| `reset` | Push Button 3 | Master System Reset |

---

## 💻 Simulation & FPGA Synthesis

### 1. Simulation with ModelSim / Icarus Verilog
```bash
iverilog -o monkey_sim.out racing_monkey_top.v vga_controller.v monkey_game_logic.v monkey_sprite_rom.v tb_racing_monkey.v
vvp monkey_sim.out
```

### 2. FPGA Target
Targeted for **Spartan-6 / Artix-7 FPGA** with 12-bit VGA resistor DAC network (4-bit Red, 4-bit Green, 4-bit Blue).
