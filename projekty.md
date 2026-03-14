# VHDL Semester Projects (Nexys A7-50T)

This repository contains documentation and source codes for team projects developed in VHDL. The projects are designed for groups of **2–4 students** with a total time allocation of **10 hours** (5 lab sessions of 2 hours each).

## 1. Project Summary Table (2024/25)


| Project | Students | Concept | VHDL | Time | Peripherals (Nexys A7) | Required Module |
| :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **1. PWM Breathing LED** | 1–2 | 2 | 2 | 2 | 16x LED, 1x Switch | Counter |
| **2. Waveform Gen (Basic)** | 2–4 | 3 | 3 | 4 | 16x LED, Buttons | Counter, Debouncer |
| **3. Digital Stopwatch (Lap)** | 2–3 | 2 | 3 | 3 | 8x 7-seg, Buttons | Debouncer |
| **4. Audio Visualizer (PDM)** | 2–3 | 5 | 3 | 4 | MEMS Mic, 16x LED | Counter |
| **5. Multi-mode Counter** | 2–3 | 2 | 4 | 3 | 8x 7-seg, Switches | Counter |
| **6. RGB Mood Lamp** | 1–2 | 3 | 2 | 2 | RGB LED, Buttons | Debouncer |
| **7. Digital Safe** | 2–3 | 4 | 3 | 4 | Switches, 7-seg, Buttons | Debouncer |
| **8. LED Ping-Pong** | 3–4 | 3 | 4 | 5 | 16x LED, Buttons | Debouncer |
| **9. I2C Thermostat** | 3–4 | 4 | 4 | 4 | ADT7420 (I2C), 7-seg | I2C, Debouncer |
| **10. I2C Spirit Level** | 2–3 | 4 | 3 | 3 | ADXL362 (SPI/I2C), RGB LED | SPI/I2C Driver |
| **11. Config. Waveform Gen** | 3–4 | 3 | 5 | 5 | 7-seg (Menu), Buttons | Counter, Debouncer |
| **12. 7-segment Snake** | 3–4 | 4 | 4 | 5 | 8x 7-seg, Buttons | Debouncer, Counter |
| **13. Alarm Clock** | 2–3 | 2 | 3 | 4 | 7-seg, Buttons, Buzzer | Debouncer |
| **14. UART Tx/Rx with FIFO** | 3–4 | 4 | 4 | 5 | USB-UART Bridge | Counter |
| **15. Multi-channel PWM/Servo**| 2–3 | 3 | 3 | 3 | Servos (Pmod), LED | Counter |
| **16. Ultrasound HS-SR04** | 2–3 | 3 | 3 | 4 | HS-SR04 (Pmod), 7-seg | Debouncer |
| **17. ADC & Signal Filtering** | 3–4 | 5 | 4 | 5 | XADC, 7-seg/LED | Counter |
| **18. Custom I2C/SPI Design** | 3–4 | 5 | 5 | 5 | Pmod sensors | - |

*Difficulty Rating: 0 = lowest, 5 = highest.*

---

## 2. Implementation Schedule (5x 2 hours)

1.  **Lab 1: Architecture.** Block diagram design, role assignment, Git initialization, `.xdc` file preparation.
2.  **Lab 2: Unit Design.** Development of individual modules in separate Git branches, testbench simulation.
3.  **Lab 3: Integration.** Merging modules into the Top-level entity, synthesis, and initial HW testing.
4.  **Lab 4: Tuning.** Debugging, debouncing, code optimization, and documentation.
5.  **Lab 5: Defense.** Demonstration of the functional device and code review.

---

## 3. Detailed Project Descriptions

### 3.1. PWM Breathing LED (1-2 students)
Instead of simple blinking, students create a module that smoothly changes brightness.
**Task:** Implement PWM with an adjustable duty cycle controlled by a counter (triangle waveform for "inhale" and "exhale").
*   **Student A (PWM Module):** Creates the PWM module.
*   **Student B (Logic + TB):** Handles brightness control logic and the testbench.

### 3.2. Waveform Generator (2–4 students)
This project is modular and scales well. Each student is responsible for one waveform type.
*   **Student A:** PWM and Rectangle (adjustable duty cycle).
*   **Student B:** Sawtooth and Triangle (linear counter increment).
*   **Student C:** Sine wave (using Look-Up Table – ROM memory).
*   **Student D (Integrator):** Top module, multiplexer, button debouncing, and synchronization.

### 3.3. Digital Stopwatch with "Lap" function (2–3 students)
Time measurement to hundredths of a second, output to a 7-segment display.
*   **Student A:** Frequency divider and timing logic.
*   **Student B:** BCD counters and lap memory.
*   **Student C:** 7-segment display decoder and multiplexer.

### 3.4. Audio "Breathing" Visualizer (2–3 students)
An LED strip or row of LEDs reacts to input intensity from the onboard MEMS microphone using PDM.

### 3.5. Multi-Mode Counter (2–3 students)
8-digit counter with various modes: Decimal, Hexadecimal, and "Scrolling text" (e.g., HELLO).
*   **Student A:** Display multiplexing module (anode switching ~100 Hz).
*   **Student B:** Counter with selectable base (Dec/Hex).
*   **Student C:** Character decoder for special symbols (0-F, H, E, L, O).

### 3.6. RGB Mood Lamp (1-2 students)
Smooth color transitions (Rainbow effect) using three independent PWMs.
*   **Student A:** Triple PWM and color mixing logic.
*   **Student B:** FSM cycling through the color spectrum.

### 3.7. Digital Safe / Combination Lock (2–3 students)
Enter a 4-digit code using switches.
*   **Student A:** Button debouncer and input handling.
*   **Student B:** Main FSM (States: IDLE, ENTERING, UNLOCKED, ALARM).
*   **Student C:** Display driver for status messages ("OPEN", "ERR").

### 3.8. "Ping-Pong" on 16 LEDs (3-4 students)
A "ball" (lit LED) oscillates. Players must time their button presses to "hit" it back.
*   **Student A:** Shift register and LED movement logic.
*   **Student B:** Collision detection in the hit zone.
*   **Student C:** Score counter and display logic.
*   **Student D:** Speed generator (frequency increases after each hit).

### 3.9. Digital Thermometer (I2C + 7-segment) (3-4 students)
Read temperature from the ADT7420 sensor via I2C and display it in Celsius.
*   **Student A:** I2C Master controller (Read/Write).
*   **Student B:** Data processor (Raw data to BCD conversion).
*   **Student C:** Display and alert system (LEDs for overheating).

### 3.10. Spirit Level (SPI + RGB LED) (2-3 students)
Using the ADXL362 accelerometer to detect board tilt.
*   **Student A:** SPI/I2C Driver for sensor communication.
*   **Student B:** Data mapping (Tilt angle to LED position).
*   **Student C:** Visual effects and RGB feedback.

### 3.11. Configurable Waveform Generator (3-4 students)
Advanced generator with a menu system on the 7-segment display.
*   **Student A:** Menu Controller (FSM for parameter selection).
*   **Student B:** Signal Engine (Sine, Tri, Saw generators).
*   **Student C:** PWM Output and amplitude scaling.
*   **Student D:** UI rendering on 7-segment displays.

### 3.12. 7-segment Snake (3–4 students)
A snake moves around the outer segments of the 8-digit display.
*   **Student A (Mapper):** Maps linear snake position (0–47) to specific anodes/segments.
*   **Student B (Logic):** Game FSM, direction control, and collision logic.
*   **Student C (Generator):** Random "food" generation using LFSR.
*   **Student D (UI/Score):** Displaying score and managing speed levels.
