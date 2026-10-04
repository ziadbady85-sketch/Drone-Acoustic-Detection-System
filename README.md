# Acoustic Drone Detection System

## FPGA-Based Real-Time Acoustic Drone Detection Using Verilog RTL

A real-time FPGA-based acoustic drone detection system designed to identify drone-like acoustic signals from noisy environments using digital signal processing techniques implemented in Verilog RTL.

The system processes digitized microphone samples through a hardware DSP pipeline consisting of an input buffer, FIR filter, energy detection, Zero-Crossing Rate (ZCR), frequency-domain analysis using FFT/Goertzel, and a final decision unit.

The main objective is to demonstrate how real-time acoustic signal processing and hardware-based feature extraction can be implemented efficiently on an FPGA.

---

## Table of Contents

- Project Overview
- System Objective
- System Architecture
- Signal Processing Flow
- Hardware Architecture
- Modules
- MATLAB Signal Generation
- Verification and Simulation
- Simulation Evidence
- RTL Design
- Elaborated Design
- Synthesis
- Verification Flow
- Technologies Used
- Project Structure
- Future Development
- Limitations
- Conclusion
- Author

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
- Verify the RTL structure through elaboration.
- Evaluate the synthesized FPGA implementation.

---

# System Architecture

The complete signal-processing architecture follows this flow:

                    ┌─────────────────────┐
                    │      Microphone     │
                    │   Acoustic Signal   │
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

## Architecture Image

![System Architecture]
(<img width="1536" height="1024" alt="Acoustic Drone Detection System Architecture" src="https://github.com/user-attachments/assets/cbea67fe-4c67-4057-8433-bf6dc3cbafdb" />
)

---

# Signal Processing Flow

The system starts with an acoustic signal captured by a microphone.

The analog signal is converted into digital samples using an ADC.

The FPGA then processes the samples through the following stages:

Acoustic Signal
       ↓
      ADC
       ↓
 Input Buffer
       ↓
  FIR Filter
       ↓
Feature Extraction
       ↓
Energy + ZCR + Frequency Analysis
       ↓
    Decision
       ↓
 Drone / Not Drone

The FIR-filtered signal is distributed to the feature-extraction blocks in parallel.

This allows multiple characteristics of the same signal to be evaluated before the final decision.

---

# Hardware Architecture

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

---

# Modules

## 1. Input Buffer

The `IN_Buffer` receives the digital samples and stores them temporarily before passing them to the FIR filter.

### Main Functions

- Receive valid input samples.
- Store recent samples.
- Maintain sample ordering.
- Generate a valid signal for the next processing stage.

### Main Signals

| Signal         | Description                    |
|----------------|--------------------------------|
| `clk`          | System clock                   |
| `rst`          | Reset                          |
| `sample_valid` | Indicates a valid input sample |
| `new_sample`   | Signed 8-bit input sample      |
| `sample_out`   | Buffered sample                |
| `out_valid`    | Indicates a valid output sample |

---

## 2. FIR Filter

The FIR filter performs digital filtering on the incoming acoustic samples.

The purpose of this stage is to reduce unwanted frequency components and prepare the signal for feature extraction.

The current architecture uses an 8-tap FIR structure.

### Main Operations

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

---

## 3. Energy Detector

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

---

## 4. Zero-Crossing Rate

The Zero-Crossing Rate (ZCR) measures how frequently the signal changes its sign.

The block compares consecutive samples:

Positive → Negative
Negative → Positive

Each valid sign transition contributes to the crossing counter.

After the defined observation window is completed, the ZCR value is generated together with a valid signal.

ZCR provides additional information about the frequency characteristics of the signal and helps distinguish between different acoustic sources.

---

## 5. Frequency Analysis

The system also uses frequency-domain information to identify frequency characteristics associated with the acoustic signal.

The frequency-analysis stage can be implemented using an FPGA-friendly approach such as:

- FFT
- Goertzel algorithm

The frequency detector processes the FIR-filtered samples and produces a frequency-related feature for the decision stage.

### General Flow

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

---

## 6. Decision Unit

The Decision block is responsible for combining the extracted features and producing the final detection result.

The decision logic considers:

- Energy condition
- ZCR condition
- Frequency condition
- Valid signals
- Temporal behavior

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

---

# MATLAB Signal Generation

MATLAB is used to generate the input signal used for RTL simulation.

The generated signal contains a drone-like component together with interfering signals and noise.

The signal is then:

1. Sampled at the selected sampling frequency.
2. Mixed with interference and noise.
3. Normalized.
4. Quantized into signed 8-bit samples.
5. Converted into binary representation.
6. Stored in:

samples_bin.txt

The Verilog testbench reads this file and feeds the samples to the RTL design.

This creates a connection between the signal-level MATLAB model and the hardware-level Verilog simulation.

---

# Verification and Simulation

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

- FIR output
- FIR valid
- Energy value
- Energy valid
- ZCR value
- ZCR valid
- Frequency value
- Frequency valid
- Final drone detection output

The simulation provides functional evidence that the different processing stages operate correctly and that the extracted features are propagated toward the final decision unit.

---

# Simulation Evidence

The following waveform results provide visual evidence of the RTL behavior during simulation.

<img width="1897" height="616" alt="Screenshot 2026-07-24 184508" src="https://github.com/user-attachments/assets/9b0da6cd-1ee6-4adf-8970-36a1d8c21791" />



---

<img width="1896" height="614" alt="Screenshot 2026-07-24 184625" src="https://github.com/user-attachments/assets/2f1ee183-d029-4472-8b19-af92a17547d4" />

---

<img width="1897" height="610" alt="Screenshot 2026-07-24 184809" src="https://github.com/user-attachments/assets/964a4ba6-5b33-41dd-a333-5a782eb2a86c" />

---

# RTL Design

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

The modular structure allows each DSP function to be developed, simulated, verified, and integrated independently before being combined into the complete system.

---

# Elaborated Design

After functional simulation, the RTL is elaborated using the FPGA design environment.

Elaboration verifies the structural integrity of the RTL and confirms:

- Module hierarchy.
- Module instantiation.
- Signal connectivity.
- Parameter resolution.
- Port connections.
- Overall RTL structure.

This stage provides a structural representation of the actual RTL design before synthesis.

## Elaborated Design Evidence

![Elaborated Design]
<img width="1540" height="636" alt="elaborated" src="https://github.com/user-attachments/assets/e571197d-8d42-43c8-8b06-334002ae6c9c" />


The elaborated design confirms that the individual RTL modules are correctly connected to form the complete acoustic drone detection processing chain.

---

# Synthesis

After successful RTL verification and elaboration, the design is synthesized for FPGA implementation.

Synthesis converts the Verilog RTL into an implementation-oriented hardware representation using FPGA resources such as:

- LUTs
- Flip-Flops
- Registers
- DSP resources
- Block RAM where applicable

The synthesis stage provides an additional level of hardware validation and allows the design to be evaluated in terms of its FPGA resource utilization.

## Synthesis Evidence

![Synthesis Design]
<img width="1543" height="709" alt="Synthesis" src="https://github.com/user-attachments/assets/a4e52b0f-9d54-4ee7-b0fe-2c04f327e6ae" />


The synthesis result demonstrates that the RTL can be successfully mapped into FPGA-oriented hardware resources.

---

# Verification Flow

The complete verification and implementation flow can be summarized as:

                 MATLAB
                   │
                   ▼
          Signal Generation
                   │
                   ▼
             samples_bin.txt
                   │
                   ▼
              Verilog TB
                   │
                   ▼
              RTL Simulation
                   │
                   ▼
          ┌─────────────────┐
          │ Simulation      │
          │ Evidence        │
          │                 │
          │ Energy          │
          │ ZCR             │
          │ Detection       │
          └────────┬────────┘
                   │
                   ▼
             RTL Elaboration
                   │
                   ▼
          Elaborated Design
                   │
                   ▼
               Synthesis
                   │
                   ▼
          Synthesized Hardware

This flow demonstrates the complete path from signal generation and RTL verification to structural RTL validation and FPGA synthesis.

---

# Technologies Used

## Hardware Description

- Verilog HDL
- RTL Design
- Fixed-Point Arithmetic
- FPGA-oriented DSP

## Signal Processing

- FIR Filtering
- Energy Detection
- Zero-Crossing Rate
- Frequency Analysis
- FFT / Goertzel

## Software and Tools

- MATLAB
- Verilog Simulation Environment
- FPGA Design Tools
- RTL Elaboration
- FPGA Synthesis

---

# Project Structure

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

---

# Future Development

Future development can focus on improving the robustness and practical applicability of the system.

Possible improvements include:

- Testing with real drone acoustic recordings.
- Evaluation under different environmental noise conditions.
- Optimization of FIR coefficients.
- Optimization of fixed-point precision.
- Improved frequency analysis.
- Multi-frequency detection.
- FPGA resource optimization.
- Latency and throughput optimization.
- Hardware implementation and real-time testing using a microphone and ADC.
- Development of a more advanced classification algorithm for improved detection accuracy.

---

# Limitations

The current prototype is primarily focused on demonstrating the FPGA-based signal-processing architecture and RTL implementation.

The MATLAB stimulus and RTL simulation provide a controlled environment for validating the processing chain.

Real-world deployment would require additional validation using real drone acoustic recordings collected under different:

- Distances
- Background noise levels
- Drone operating conditions
- Environmental conditions
- Microphone characteristics

Therefore, simulation results should not be interpreted as complete real-world validation of drone detection performance.

---

# Conclusion

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

The project demonstrates the complete development flow of an FPGA-oriented DSP system:

Signal Generation
       ↓
RTL Design
       ↓
Functional Simulation
       ↓
Simulation Evidence
       ↓
RTL Elaboration
       ↓
Elaborated Design
       ↓
FPGA Synthesis
       ↓
Synthesized Hardware

By combining signal processing algorithms with a modular Verilog RTL architecture, the project demonstrates how acoustic features can be extracted and processed directly in hardware for real-time FPGA-based applications.

---

# Author

**Ziad Mohamed**

Electrical Engineering
Electronics and Communications Engineering

**Digital IC Design | FPGA | Verilog RTL | DSP Hardware**
