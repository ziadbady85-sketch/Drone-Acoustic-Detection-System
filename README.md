# Acoustic Drone Detection System

## FPGA-Based Real-Time Acoustic Drone Detection Using Verilog RTL

A real-time FPGA-based acoustic drone detection system designed to identify drone-like acoustic signals from noisy environments using digital signal processing techniques implemented in Verilog RTL.

The system processes digitized microphone samples through a hardware DSP pipeline consisting of an input buffer, FIR filter, energy detection, Zero-Crossing Rate (ZCR), frequency-domain analysis using FFT/Goertzel, and a final decision unit.

The main objective is to demonstrate how real-time acoustic signal processing and hardware-based feature extraction can be implemented efficiently on an FPGA.

---

## Table of Contents

- [Project Overview](#project-overview)
- [System Objective](#system-objective)
- [System Architecture](#system-architecture)
- [Signal Processing Flow](#signal-processing-flow)
- [Hardware Architecture](#hardware-architecture)
- [Modules](#modules)
- [MATLAB Signal Generation](#matlab-signal-generation)
- [Verification and Simulation](#verification-and-simulation)
- [Waveform Results](#waveform-results)
- [RTL Design](#rtl-design)
- [Elaborated Design](#elaborated-design)
- [Synthesis](#synthesis)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Future Development](#future-development)
- [Limitations](#limitations)
- [Conclusion](#conclusion)
- [Author](#author)

---

# Project Overview

Acoustic drone detection is an important problem in modern surveillance systems because drones can operate at low altitude and may not always be easily detected using conventional visual monitoring.

This project investigates an FPGA-based approach for detecting drone-like acoustic signals using real-time digital signal processing.

Instead of sending the complete signal to a software processor, the main signal-processing operations are implemented directly in hardware using Verilog RTL.

The system extracts several characteristics from the acoustic signal:

- Signal Energy
- Zero-Crossing Rate (ZCR)
- Frequency-domain characteristics

These features are then provided to a decision unit that determines whether the observed signal satisfies the defined drone-detection conditions.

---

# System Objective

The main objectives of the project are:

- Process acoustic samples in real time.
- Implement DSP operations using Verilog RTL.
- Reduce unwanted frequency components using FIR filtering.
- Extract multiple signal features.
- Perform frequency analysis.
- Implement hardware-based decision logic.
- Verify the complete processing chain using simulation.
- Demonstrate a practical FPGA-oriented architecture for acoustic drone detection.

---

# System Architecture

The complete signal-processing architecture follows this flow:

```text
                    ┌─────────────────────┐
                    │      Microphone     │
                    │  Acoustic Signal    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │        ADC          │
                    │ Analog → Digital    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      IN_Buffer      │
                    │    Sample Storage   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     FIR_Filter      │
                    │   Signal Filtering  │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
       ┌────────────────┐ ┌───────────┐ ┌──────────────────┐
       │ Energy Detector│ │    ZCR    │ │ FFT / Goertzel   │
       │                │ │           │ │ Frequency        │
       │ Signal Energy  │ │ Sign      │ │ Analysis         │
       └───────┬────────┘ └─────┬─────┘ └────────┬─────────┘
               │                │                │
               └────────────────┼────────────────┘
                                │
                                ▼
                     ┌─────────────────────┐
                     │      Decision       │
                     │                     │
                     │ Feature Evaluation  │
                     └──────────┬──────────┘
                                │
                                ▼
                     ┌─────────────────────┐
                     │  Drone Detection    │
                     │                     │
                     │ 1 = Detected        │
                     │ 0 = Not Detected    │
                     └─────────────────────┘

The FIR-filtered signal is distributed to the feature-extraction blocks in parallel.

This allows multiple characteristics of the same signal to be evaluated before the final decision.

Hardware Architecture

The FPGA contains the main digital signal-processing blocks:

                   FPGA
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  ┌───────────┐      ┌────────────┐                        │
│  │ IN_Buffer │ ───► │ FIR_Filter │                        │
│  └───────────┘      └──────┬─────┘                        │
│                             │                              │
│              ┌──────────────┼───────────────┐              │
│              │              │               │              │
│              ▼              ▼               ▼              │
│        ┌───────────┐   ┌────────┐   ┌──────────────┐      │
│        │  Energy   │   │  ZCR   │   │ FFT/Goertzel │      │
│        │ Detector  │   │        │   │   Detector   │      │
│        └─────┬─────┘   └───┬────┘   └──────┬───────┘      │
│              │             │               │              │
│              └─────────────┼───────────────┘              │
│                            ▼                              │
│                    ┌──────────────┐                       │
│                    │   Decision   │                       │
│                    └──────┬───────┘                       │
│                           │                               │
│                           ▼                               │
│                  There_is_a_Drone                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
Modules
1. Input Buffer

The IN_Buffer receives the digital samples and stores them temporarily before passing them to the FIR filter.

Main Functions
Receive valid input samples.
Store recent samples.
Maintain sample ordering.
Generate a valid signal for the next processing stage.
Main Signals
Signal	Description
clk	System clock
rst	Reset
sample_valid	Indicates a valid input sample
new_sample	Signed 8-bit input sample
sample_out	Buffered sample
out_valid	Indicates a valid output sample
2. FIR Filter

The FIR filter performs digital filtering on the incoming acoustic samples.

The purpose of this stage is to reduce unwanted frequency components and prepare the signal for feature extraction.

The current architecture uses an 8-tap FIR structure.

Main Operations
Input Samples
      ↓
Delay / Shift Registers
      ↓
Coefficient Multiplication
      ↓
Accumulation
      ↓
Scaling
      ↓
Filtered 8-bit Output

The filter uses fixed-point arithmetic suitable for FPGA implementation.

3. Energy Detector

The Energy Detector estimates the signal energy over a predefined sample window.

For each valid filtered sample:

Sample
  ↓
Square
  ↓
Accumulator
  ↓
Energy Value

The accumulated energy is then scaled and provided to the decision system.

A high-energy signal may indicate the presence of a strong acoustic source, while energy outside the expected range can help reject unwanted signals.

4. Zero-Crossing Rate

The Zero-Crossing Rate (ZCR) measures how frequently the signal changes its sign.

The block compares consecutive samples:

Positive → Negative
Negative → Positive

Each valid sign transition contributes to the crossing counter.

After the defined observation window is completed, the ZCR value is generated together with a valid signal.

ZCR provides additional information about the frequency characteristics of the signal and helps distinguish between different acoustic sources.

5. Frequency Analysis

The system also uses frequency-domain information to identify frequency characteristics associated with the acoustic signal.

The frequency-analysis stage can be implemented using an FPGA-friendly approach such as:

FFT
Goertzel algorithm

The frequency detector processes the FIR-filtered samples and produces a frequency-related feature for the decision stage.

General Flow
Filtered Samples
       ↓
 Sample Window
       ↓
Frequency Analysis
       ↓
Target Frequency / Power
       ↓
Frequency Valid

The frequency information is combined with the energy and ZCR features.

6. Decision Unit

The Decision block is responsible for combining the extracted features and producing the final detection result.

The decision logic considers:

Energy condition
ZCR condition
Frequency condition
Valid signals
Temporal behavior

Conceptually:

              Energy
                 │
                 ▼
              ┌─────────┐
              │         │
ZCR ─────────►│ Decision│◄──────── Frequency
              │         │
              └────┬────┘
                   │
                   ▼
            Drone Detected

The final output is:

There_is_a_Drone = 1

when the defined detection conditions are satisfied.

Otherwise:

There_is_a_Drone = 0
MATLAB Signal Generation

MATLAB is used to generate the input signal used for RTL simulation.

The generated signal contains a drone-like component together with interfering signals and noise.

The signal is then:

Sampled at the selected sampling frequency.
Mixed with interference and noise.
Normalized.
Quantized into signed 8-bit samples.
Converted into binary representation.
Stored in:
samples_bin.txt

The Verilog testbench reads this file and feeds the samples to the RTL design.

This creates a connection between the signal-level MATLAB model and the hardware-level Verilog simulation.

Verification and Simulation

The RTL design is verified using a Verilog testbench.

The testbench performs the following operations:

Reset
  ↓
Load Samples
  ↓
Apply Samples to DUT
  ↓
Process Through DSP Pipeline
  ↓
Monitor Feature Outputs
  ↓
Monitor Decision

Important internal signals can be observed during simulation, including:

FIR output
FIR valid
Energy value
Energy valid
ZCR value
ZCR valid
Frequency value
Frequency valid
Final drone detection output
Waveform Results
Waveform 1 — Energy Detection

This waveform demonstrates the behavior of the energy detector and its relationship with the decision logic.

Waveform 2 — ZCR Detection

This waveform demonstrates the generated ZCR value and the corresponding valid signal over the processing window.

Waveform 3 — Final Drone Detection

This waveform demonstrates the final decision behavior of the system.

RTL Design

The design is developed using Verilog HDL with a modular RTL architecture.

The main RTL modules are:

IN_Buffer
FIR_Filter
Energy_Detector
ZCR
FFT / Goertzel Detector
Decision
Drone_Detect

The design follows a synchronous digital architecture based on a common clock and reset.

Elaborated Design

The elaborated design is used to verify the structural connectivity of the RTL modules before synthesis.

It confirms the module hierarchy and the connections between the different processing stages.

Synthesis

After RTL verification, the design can be synthesized for FPGA implementation.

Synthesis converts the Verilog RTL into FPGA hardware resources such as:

LUTs
Flip-Flops
Registers
DSP resources
Block RAM where applicable

The synthesis result is used to evaluate the hardware implementation and resource utilization.

Technologies Used
Hardware Description
Verilog HDL
RTL Design
Fixed-Point Arithmetic
FPGA-oriented DSP
Signal Processing
FIR Filtering
Energy Detection
Zero-Crossing Rate
Frequency Analysis
FFT / Goertzel
Software
MATLAB
Verilog Simulation Environment
FPGA Design Tools
Project Structure
Acoustic-Drone-Detection/
│
├── RTL/
│   ├── IN_Buffer.v
│   ├── FIR_Filter.v
│   ├── Energy_Detector.v
│   ├── ZCR.v
│   ├── Goertzel_Detector.v
│   ├── Decision.v
│   └── Drone_Detect.v
│
├── Testbench/
│   └── Drone_Detect_tb.v
│
├── MATLAB/
│   └── signal_generation.m
│
├── Simulation/
│   └── samples_bin.txt
│
├── Images/
│   ├── architecture.png
│   ├── wave_energy_detection.png
│   ├── wave_zcr.png
│   ├── wave_drone_detection.png
│   ├── elaborated_design.png
│   └── synthesis_design.png
│
└── README.md
Future Development

Future development can focus on improving the robustness and practical applicability of the system.

Possible improvements include:

Testing with real drone acoustic recordings.
Evaluation under different environmental noise conditions.
Optimization of FIR coefficients.
Optimization of fixed-point precision.
Improved frequency analysis.
Multi-frequency detection.
FPGA resource optimization.
Latency and throughput optimization.
Hardware implementation and real-time testing using a microphone and ADC.
Limitations

The current prototype is primarily focused on demonstrating the FPGA-based signal-processing architecture and RTL implementation.

The MATLAB stimulus and RTL simulation provide a controlled environment for validating the processing chain.

Real-world deployment would require additional validation using real drone acoustic recordings collected under different:

Distances
Background noise levels
Drone operating conditions
Environmental conditions
Microphone characteristics

Therefore, simulation results should not be interpreted as complete real-world validation of drone detection performance.

Conclusion

This project demonstrates a modular FPGA-based architecture for acoustic drone detection using real-time digital signal processing.

The system combines:

Input Buffer
     ↓
FIR Filtering
     ↓
Energy Detection
     +
ZCR
     +
Frequency Analysis
     ↓
Decision Logic
     ↓
Drone Detection

The project provides a hardware-oriented approach to acoustic signal processing and demonstrates how multiple DSP features can be extracted and combined using Verilog RTL for FPGA implementation.

Author

Ziad Mohamed

Electrical Engineering
Electronics and Communications Engineering

Digital IC Design | FPGA | Verilog RTL | DSP Hardware
