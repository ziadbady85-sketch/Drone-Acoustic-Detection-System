Drone Acoustic Detection System

Overview

This project implements a real-time drone detection system based on acoustic signal processing using Digital IC Design.

The system takes digital audio samples as input, processes them through a filtering and energy detection pipeline, and determines the presence of a drone using an FSM-based decision module.

System Flow

Audio Samples (MATLAB)

        ↓

IN_Buffer

        ↓

FIR_Filter

        ↓

Energy_Detector

        ↓

Decision (FSM)

        ↓

There_is_a_Drone

MATLAB Part

Purpose

Generate or record audio signal

Convert it to 8-bit signed digital samples

Export samples in binary format for simulation

Output File

samples_bin.txt

Example

11110011

00010110

11111101

Verilog Design

IN_Buffer

Function

Stores incoming samples using an 8-sample shift register

Outputs samples sequentially

Generates a valid signal every 8 samples

FIR_Filter

Function

Applies an 8-tap FIR filter to the input signal

Equation

y[n] = Σ h[k] * x[n-k]

Coefficients

8, 16, 24, 32, 40, 48, 56, 64

Notes

Uses shift register + multiply-accumulate

Output is scaled to avoid overflow

Energy_Detector

Function

Computes signal energy over a window of 8 samples

Equation

Energy = Σ (x^2)

Operation

Squares each sample

Accumulates energy

Outputs result every 8 samples

Decision (FSM)

Function

Determines drone presence based on energy level

Condition

50 < Energy < 200

States

IDLE → COUNTING → DETECTED

Behavior

Moves to COUNTING when energy is within range

Confirms detection after consecutive valid samples

Returns to IDLE when signal disappears

Top Module

Drone_Detect

Connects all modules together

Outputs final detection signal

Testbench

Features

Clock generation

Reset control

Reads samples from file

Stimulates the design

File Read

$readmemb("samples_bin.txt", DUT.M1.B_REG);

Design Specifications

Bit Widths

Input: 8-bit signed

FIR internal sum: 19-bit

Energy accumulator: 20-bit

Energy output: 10-bit

Window Size

Buffer: 8 samples

Energy: 8 samples

Features

Fully implemented in Verilog (RTL)

Real-time processing

Modular design

No AI or external processing

Conclusion

This project demonstrates a complete digital pipeline for detecting drone presence using acoustic signals, including buffering, filtering, energy computation, and FSM-based decision making.

This project demonstrates a complete digital pipeline for detecting drone presence using acoustic signals, including buffering, filtering, energy computation, and FSM-based decision making.
