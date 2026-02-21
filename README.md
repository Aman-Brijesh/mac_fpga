# MAC Neuron – FPGA-Based Edge AI Accelerator

## Overview

This project implements a custom neural network hardware accelerator using Verilog.  
The accelerator performs weighted-sum (Multiply–Accumulate) operations under FSM control, enabling low-power, real-time inference suitable for Edge AI applications.

The core operation implemented is:
y = w1·x1 + w2·x2 + w3·x3

This weighted sum forms the foundation of neural network inference.

Instead of executing this computation in software, the design maps it directly to FPGA hardware for deterministic performance and energy efficiency.

---

## Inputs

- `clk` – System clock
- `rst` – Reset signal
- `start` – Starts inference
- `x` – Input data
- `w` – Weight value

---

## Outputs

- `acc` – Accumulator (weighted sum output)
- `done_out` – Indicates completion of inference

---

## Architecture

The accelerator follows a **controller–datapath architecture**.

### Datapath

- Multiplier (`x × w`)
- Accumulator register (`acc`)
- Counter (`count`)
- Done comparator (`done`)

### Controller

- Finite State Machine (FSM)

The datapath performs computation, while the FSM controls execution flow.

---

## Finite State Machine Operation

The FSM consists of four states:

### 1. IDLE

Waits for the `start` signal.

---

### 2. CLEAR

Initializes the datapath:
acc = 0
count = 0

This prepares the accelerator for a new inference.

---

### 3. MAC

Main computation state.

- Enable signal (`en`) is asserted.
- Each clock cycle performs:
  acc = acc + (x × w)
  count = count + 1

The FSM remains in MAC until the required number of inputs has been processed.

Completion is detected using:
done = (count == N-1)

---

### 4. DONE

Final state.

- Computation stops.
- Output remains stable.
- `done_out` is asserted.
- FSM transitions back to IDLE for the next inference.

---

## Control Logic

- The counter tracks how many MAC operations have occurred.
- The `done` signal is generated from the counter.
- The FSM uses `done` to exit MAC state.
- FSM produces `clear` and `en` signals to control the datapath.

---

## Key Features

- FSM-controlled MAC datapath
- Fixed-point arithmetic
- Deterministic latency
- Low hardware complexity
- Suitable for Edge AI deployment
- Fully verified in Vivado simulation

---

## Summary

This project demonstrates a custom FPGA-based neural compute unit implementing weighted-sum inference using a controller–datapath architecture. By mapping neural operations directly to hardware, the design achieves predictable real-time performance with minimal power and resource usage, making it suitable for Edge AI applications.

---

## Future Extensions

- ReLU activation
- Multiple neurons / layers
- FPGA deployment
- UART or GPIO interface
