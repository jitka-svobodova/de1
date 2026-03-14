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
**Task:** Implement PWM with an adjustable duty cycle controlled by a counter (triangle waveform for "inhale" and "exhale"). [vhdlwhiz.com/pwm-controller/](https://vhdlwhiz.com/pwm-controller/)
*   **Student A (PWM Module):** Creates the PWM module.
*   **Student B (Logic + TB):** Handles brightness control logic and the testbench.

### 3.2. Waveform Generator (2–4 students)
This project is ideal for 4 students because it is perfectly modular. Each student is responsible for one waveform type, and one "lead" oversees integration.
*   **Student A:** PWM and Rectangle (adjustable duty cycle). [vhdlwhiz.com/pwm-controller/](https://vhdlwhiz.com/pwm-controller/)
*   **Student B:** Sawtooth and Triangle (linear counter increment).
*   **Student C:** Sine wave (using Look-Up Table – ROM memory). [vhdlwhiz.com/breathing-led-using-sine-wave-stored-in-block-ram/](https://vhdlwhiz.com/breathing-led-using-sine-wave-stored-in-block-ram/)
*   **Student D (Integrator):** Top module, multiplexer, button debouncing, and synchronization.

### 3.3. Digital Stopwatch with "Lap" function (2–3 students)
Time measurement to hundredths of a second, output to a 7-segment display.
*   **Student A:** Frequency divider.
*   **Student B:** BCD counters.
*   **Student C:** Display decoder.

### 3.4. Audio "Breathing" Visualizer (2–3 students)
An LED strip or row of LEDs reacts to input intensity (simple comparator with a sawtooth waveform).

### 3.5. Multi-Mode Counter (2–3 students)
8-digit counter with various modes: Decimal, Hexadecimal, and "Scrolling text" (e.g., HELLO). 8 segment displays, switches for mode selection (Hex/Dec), buttons for Reset/Stop.
*   **Student A:** Display multiplexing module (fast anode switching at approx. 100 Hz).
*   **Student B:** Counter with selectable base (Dec/Hex).
*   **Student C:** Character decoder (0-F, H, E, L, O).

### 3.6. RGB Mood Lamp (1-2 students)
Smooth color transitions (Rainbow effect). A five-way button controls speed or brightness. RGB LED (requires 3 independent PWMs for one LED), 16 switches for "mixing" custom colors in manual mode.
*   **Student A:** Triple PWM and color control via R, G, B components.
*   **Student B:** FSM (Finite State Machine) cycling through rainbow colors.

### 3.7. Digital Safe / Combination Lock (2–3 students)
User must enter a 4-digit code using switches and the center button. Switches (code entry), 7-segment (displays "----" or "OPEN"/"ERR"), LEDs (attempt indication).
*   **Student A:** Button debouncer.
*   **Student B:** Main FSM (states: IDLE, ENTER_1, ENTER_2, ..., UNLOCKED, ALARM).
*   **Student C:** Display management and indication.

### 3.8. "Ping-Pong" on 16 LEDs (3-4 students)
The "ball" (lit LED) oscillates from left to right. The player must press the left/right button in time to bounce it back. If they miss, the LEDs flash (loss).
*   **Student A:** Shift register / LED movement logic.
*   **Student B:** Button press detection in the "hit zone."
*   **Student C:** Score counter and display.
*   **Student D:** Acceleration generator (clock tick density increases with each bounce).

### 3.9. Digital Thermometer (I2C + 7-segment) (3-4 students)
Read temperature from the sensor and display it on the 7-segment display in degrees Celsius. Switches set the "target temperature" and LEDs indicate heating/cooling. ADT7420 (via I2C), 8x 7-segment, LED (status), 16x Switch (limit).
*   **Student A:** I2C Integrator: Sensor register configuration and data reading.
*   **Student B:** Data processor: Converting raw sensor data to degrees (binary to BCD).
*   **Student C:** Score counter and display.

### 3.10. Spirit Level (SPI + RGB LED) (2-3 students)
Using the ADXL362 accelerometer (typically on SPI, but the principle is the same for I2C). Detect board tilt. Depending on the tilt direction, the corresponding LED lights up or light "flows" across the 16-LED row. Accelerometer, 16x LED, RGB LED.
*   **Student A:** I2C Driver: Reading X and Y axes from sensor registers.
*   **Student B:** Mapping: Converting tilt value to active LED position (data scaling).
*   **Student C:** Visuals: Driver for LED and RGB effects.

### 3.11. Configurable Waveform Generator (3-4 students)
Generator (as in assignment #2), but parameters (amplitude, frequency, waveform type) are set via a five-way button and displayed on the display as a "menu." Buttons (menu), 7-segment (status), 16x LED (amplitude/PWM visualization).
*   **Student A:** Menu Controller: FSM switching between modes (Set Freq, Set Type).
*   **Student B:** Signal Engine: Generators (Sine, Tri, Saw).
*   **Student C:** Output Logic: PWM output and amplitude scaling.
*   **Student D:** Current values display on 7-segment.

### 3.12. 7-segment Snake (3–4 students)
The snake crawls around the outer segments (a, b, c, d, e, f). A five-way button (center or directional) is used to control direction (clockwise/counter-clockwise) or to jump to the inner segment (segment g). "Food" appears on a random segment (flashing segment). The player must "eat" it, which extends the snake (more consecutive segments lit) or increases the score. 8x 7-segment displays, five-way button, 16x LED (displaying snake length or binary score).
*   **Student A (Mapper):** Index mapping: Must create logic that maps the snake's linear position (0–47, based on 8 displays × 6 peripheral segments) to specific anodes and segments.
*   **Student B (Logic):** Game logic and FSM: Handles movement direction, collisions, and random "food" generation (using a simple LFSR register).
*   **Student C (Generator):** Implements the random food position generator (LFSR) and score counter. (If in a group of 4, this student takes over these tasks from Student B).
*   **Student D (Mux):** Modifies the multiplexer to allow displaying multiple segments (the snake's body) simultaneously.

### 3.13. Alarm Clock (2-3 students)
Implementation of a 24-hour clock (HH:MM:SS) with the ability to set the current time and an alarm time.
*   **Student A (Timekeeper):** Implementation of the main time counter (seconds, minutes, hours) using a frequency divider from the board's 100MHz clock. Must handle overflow (e.g., jumping from 23:59:59 to 00:00:00).
*   **Student B (Control & Alarm):** Logic for setting time via buttons (switching modes: run/set time/set alarm). Compares current time with stored alarm time and triggers a buzzer (PWM signal for sound).
*   **Student C (Display Driver):** Multiplexed display of time on the 8-digit 7-segment display (e.g., HH-MM-SS), including blinking separator segments.

### 3.14 UART Controller with FIFO (3–4 students)
A complete controller for PC communication via RS232.
*   **Student A (Baudrate/Sampling):** Sampling clock generator and start bit detection.
*   **Student B (Rx/Tx FSM):** State machines for receiving and transmitting data frames.
*   **Student C (FIFO):** Implementation of a buffer memory for smooth data flow.
*   **Student D (UI/App):** Logic for echo-back or controlling LEDs via a terminal.

### 3.15 Multi-channel PWM / Servo Controller (2–3 students)
Design of a multi-channel PWM generator for independent control of LED brightness and servo motor positions (angles 0° to 180°).
*   **Student A (PWM Core):** Implementation of a generic PWM module with adjustable resolution. Must ensure a fixed 20 ms period (50 Hz) required by servos and a precisely defined pulse width ranging from 1 ms (0°) to 2 ms (180°).
*   **Student B (Control & Mapping):** Parameter control logic. Switches select which servo/LED is being controlled, and buttons (Up/Down) smoothly change the duty cycle. Must implement a "saturating counter" to prevent the servo from hitting mechanical stops.
*   **Student C (Multi-channel Interface):** Integration of multiple PWM module instances into a single unit. Routing outputs to Pmod connectors (for servos) and RGB LEDs (for visualization). Displaying the current duty cycle or angle in percent on the 7-segment display.

### 3.17 ADC & Signal Filtering (3–4 students)
Digitization of analog voltage (e.g., from a Pmod potentiometer or internal sensor) followed by digital processing to stabilize the measured values. The XADC on the Nexys A7 typically measures in the range of 0V to 1V.
*   **Student A (XADC Interface):** Configuring and instantiating the XADC IP core in "Sequencer" or "Single Channel" mode. Ensuring correct reading of 12-bit data via DRP (Dynamic Reconfiguration Port) or AXI4-Lite.
*   **Student B (Digital Filter):** Implementation of a digital filter to remove noise. Ideally a Moving Average or a simple one-pole IIR filter (exponential smoothing). Must work with fixed-point arithmetic.
*   **Student C (Data Scaler & BCD):** Converting raw ADC data (0–4095) to real voltage (0.0V – 1.0V) or percentages. Converting results to BCD format for display.
*   **Student D (Visualizer & Alarm):** Displaying the value on the 7-segment display and visualizing signal levels on the 16-LED bar graph. Implementing an alarm (flashing LEDs when a set limit is exceeded).

---

## 4. Documentation Requirements (README.md)

Each project repository must include:
*   **Block Diagram:** Graphical representation of module hierarchy and signal flows.
*   **Git Flow:** Commit history demonstrating the activity of all team members.
*   **Simulations:** Screenshots from the Vivado simulator (Waveforms) proving module functionality.
*   **Resource Report:** A table of resource utilization (LUTs, FFs) after synthesis.
