#Drone Acoustic Detection System
##Overview

A real-time drone detection system based on acoustic signal processing using Digital IC Design.
The system processes audio samples and detects drone presence using FIR filtering, energy calculation, and FSM-based decision logic.

##System Flow
Microphone (MATLAB)
        ↓
Digital Samples (8-bit)
        ↓
IN_Buffer
        ↓
FIR_Filter
        ↓
Energy_Detector
        ↓
Decision (FSM)
        ↓
Drone Detection Output

##MATLAB Part
Purpose
Record audio signal
Convert to digital samples (8-bit signed)
Export binary file for Verilog simulation

##Steps
Record audio (Fs = 8 kHz)
Normalize signal
Convert to 8-bit signed
Convert to binary (8-bit)
Save to file
Output File
samples_bin.txt

##Example
11110011
00010110
11111101

##Verilog Modules
###1. IN_Buffer
Function
Stores last 8 samples (shift register)
Outputs valid signal every 8 samples
Key Idea
Sliding window of samples

###2. FIR_Filter
Function
Smooths signal using FIR filter
Equation
y[n] = Σ h[k] * x[n-k]
Coefficients
8, 16, 24, 32, 40, 48, 56, 64
Notes
Uses shift register + MAC
Scaling prevents overflow

###3. Energy_Detector
Function
Calculates signal energy over 8 samples
Equation
Energy = Σ (x^2)
Steps
Square each sample
Accumulate
Output every 8 samples

###4. Decision (FSM)
Function
Detect drone based on energy level
Threshold
50 < Energy < 200
States
IDLE → COUNTING → DETECTED
Logic
Requires consecutive valid detections
Reduces noise and false alarms
Top Module
Drone_Detect

##Connects all modules:

Buffer → FIR → Energy → Decision

##Testbench
Features
Generates clock
Applies reset
Reads samples from file
Feeds system with data
File Read
$readmemb("samples_bin.txt", DUT.M1.B_REG);
Design Specs
Bit Widths
Input: 8-bit
FIR sum: 19-bit
Energy: 20-bit
Output: 10-bit
Window Size
Buffer: 8 samples
Energy: 8 samples
Key Features
Fully RTL (Verilog)
Real-time processing
No AI used
Modular design
FPGA/ASIC ready
Future Improvements
Multi-band FIR (classification)
Adaptive threshold
Confidence level output
UART interface
External control integration

##Conclusion

A complete digital pipeline for drone detection using acoustic signals, demonstrating core Digital IC Design concepts including filtering, energy analysis, and FSM decision making.
