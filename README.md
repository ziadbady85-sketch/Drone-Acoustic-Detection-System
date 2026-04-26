Drone Acoustic Detection System (Digital IC Design Project)
Overview

This project implements a real-time drone detection system based on acoustic signal processing using Digital IC Design principles. The system captures audio signals, processes them through a digital pipeline, and detects the presence of a drone using energy-based decision logic.

The design is fully implemented in Verilog and supported by MATLAB for data generation and preprocessing.

System Architecture

The system consists of the following processing stages:

Audio Acquisition (MATLAB)
Input Buffer (IN_Buffer)
FIR Filter (FIR_Filter)
Energy Detection (Energy_Detector)
Decision Unit (FSM-based)

Data Flow:

Mic (MATLAB) → Digital Samples → IN_Buffer → FIR_Filter → Energy_Detector → Decision → Output

MATLAB Part
Purpose

MATLAB is used to:

Record or generate audio signals
Normalize and quantize signals to 8-bit signed format
Export samples as binary values compatible with Verilog testbench
Processing Steps
Audio Recording
Sampling Frequency: 8 kHz
Duration: controlled (e.g., ~650 samples)
Normalization
Signal scaled between -1 and +1
Quantization
Converted to 8-bit signed integers (range: -128 to 127)
Binary Conversion
Each sample converted to 8-bit binary (two's complement)
File Output
Output file: samples_bin.txt
Each line = one 8-bit sample
Output Format Example
11110011
00010110
11111101
Verilog Design
1. IN_Buffer
Function

Implements a sliding window buffer of 8 samples.

Inputs
clk: system clock
rst: reset
sample_valid: indicates valid input sample
new_sample [7:0]: incoming audio sample
Outputs
sample_out [7:0]: buffered output sample
out_valid: asserted every 8 samples
Operation
Stores last 8 samples in a shift register
Each new sample shifts older samples
Generates valid signal every 8 samples
2. FIR_Filter
Function

Applies an 8-tap FIR filter to smooth and shape the signal.

Inputs
clk, rst
valid_in: input valid signal
sample_in [7:0]
Outputs
FIR_out [7:0]
FIR_valid
Internal Components
Shift register (8 samples)
Multiply-Accumulate (MAC)
Scaling (right shift)
FIR Equation

y[n] = Σ (h[k] * x[n-k]), for k = 0 → 7

Coefficients
8, 16, 24, 32, 40, 48, 56, 64
Notes
Scaling is applied to prevent overflow
Output is normalized using right shift
3. Energy_Detector
Function

Calculates signal energy over a window of 8 samples.

Inputs
clk, rst
FIR_valid
FIR_Sample [7:0]
Outputs
Energy_Out [9:0]
Energy_Valid
Operation
Square each sample:
square = sample × sample
Accumulate energy:
energy = Σ square
After 8 samples:
Output energy
Reset accumulator
Formula

Energy = Σ (x[n]^2)

Scaling
Right shift applied to control magnitude
4. Decision Module (FSM)
Function

Detects drone presence based on energy thresholds and persistence.

Inputs
clk, rst
E_Valid
Energy_Value [9:0]
Output
There_is_a_Drone
Threshold Logic
Drone_Energy_min = 50
Drone_Energy_max = 200

Signal is considered valid if:

Energy_Value within range
FSM States
IDLE
COUNTING
DETECTED
Behavior

IDLE:

Wait for valid signal

COUNTING:

Count consecutive valid detections
Transition to DETECTED if stable

DETECTED:

Stay detected while signal persists
Return to IDLE if signal disappears
Purpose
Reduces false detection
Ensures stability before declaring detection
5. Top Module (Drone_Detect)
Function

Connects all modules together

Flow
IN_Buffer → FIR_Filter → Energy_Detector → Decision
Testbench (Drone_Detect_tb)
Purpose

Simulates full system behavior

Key Features
Clock generation
Reset handling
Sample feeding
File loading using:
$readmemb("samples_bin.txt", DUT.M1.B_REG);
Behavior
Feeds random samples initially
Then injects real audio samples
Observes detection output
Design Considerations
Bit Widths
Input: 8-bit signed
FIR internal sum: 19-bit
Energy accumulator: 20-bit
Output energy: 10-bit
Scaling
FIR scaling prevents overflow
Energy scaling normalizes output
Latency
Buffer: 8 cycles
FIR: 1 cycle per valid input
Energy: 8 cycles window
Decision: depends on FSM counter
Key Features
Fully digital implementation (RTL level)
Real-time processing capability
Modular and scalable architecture
No AI dependency
Suitable for FPGA/ASIC implementation
Possible Improvements
Multi-band FIR filters for classification
Adaptive thresholding
Confidence level output
UART interface for real-time monitoring
Integration with external countermeasure systems
Conclusion

This project demonstrates a complete digital signal processing chain implemented in Verilog for drone detection using acoustic signals. It highlights key Digital IC Design concepts including buffering, filtering, accumulation, and FSM-based decision making.

The system is efficient, scalable, and suitable for integration into larger defense or monitoring systems.
