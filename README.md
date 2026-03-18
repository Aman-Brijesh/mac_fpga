# FPGA-Based Edge AI Accelerator for Energy Prediction

## Overview
This repository presents an end-to-end workflow for designing, training, and deploying a lightweight Artificial Neural Network (ANN) on FPGA hardware. The project is tailored for Edge AI applications, focusing on low power consumption, real-time deterministic inference, and hardware-efficient computation using integer-only arithmetic.

The overarching goal is to predict household energy consumption using a quantized neural network. To achieve this, the repository is split into two distinct parts: software-based model training/quantization, and the SystemVerilog hardware implementation of the compute nodes.

---

## Repository Structure

### 1. [AI Model & Quantization Pipeline (`/ai`)](./ai/Readme.md)
This directory handles the software and machine learning aspects of the project. 

* **Topic**: Training an MLP regression model for energy consumption prediction and quantizing it for hardware constraints.
* **What's Inside**:
  * Python scripts (`main.py`) to process the UCI Individual Household Electric Power Consumption dataset.
  * Training pipeline for a lightweight 2-8-1 neural network using ReLU activations and no bias terms.
  * A quantization script that scales and converts floating-point weights into `int8` format (-128 to +127).
  * The exported `weights.txt` file ready to be loaded into the hardware memory.
* **Read more in the [AI README](./ai/Readme.md)**.

### 2. [FPGA Hardware Accelerator (`/fpga_hardware`)](./fpga_hardware/README.md)
This directory contains the RTL design for the core neural network compute engine.

* **Topic**: SystemVerilog implementation of a custom Multiply-Accumulate (MAC) neuron with an FSM controller.
* **What's Inside**:
  * The custom hardware module (`mac_neuron_fsm.sv`) utilizing a controller-datapath architecture to execute weighted sums.
  * Hardware-level implementation of the ReLU activation function, appropriately handling signed arithmetic.
  * Simulation testbenches (`tb_mac_neuron_fsm.sv`) and waveform outputs for verification.
  * Vivado deployment metrics showing highly efficient resource utilization: ~313MHz estimated Fmax and an ultra-low total on-chip power of 0.072W.
* **Read more in the [Hardware README](./fpga_hardware/README.md)**.

---

## Overall System Workflow

1. **Train and Quantize (Software Phase)**: Run the Python environment in the `/ai` directory to train the model on household voltage and global intensity data. The network outputs `int8` weights formatted for FPGA consumption.
2. **Accelerate and Infer (Hardware Phase)**: The customized MAC neuron RTL in the `/fpga_hardware` directory reads the input parameters and the exported `int8` weights. It processes the MAC operations under FSM control, applying a hardware ReLU activation to deliver fast, localized, and deterministic predictions.
