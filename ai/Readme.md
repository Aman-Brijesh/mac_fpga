# FPGA-Based Energy Consumption Prediction using Quantized Neural Networks

## Overview

This project implements a lightweight Artificial Neural Network (ANN) for predicting energy consumption using a minimal feature set. The model is specifically designed for deployment on FPGA hardware, where constraints such as limited precision, absence of bias terms, and integer-only arithmetic must be respected.

The workflow includes data preprocessing, neural network training, quantization of weights to int8 format, and exporting the model in a hardware-compatible format for FPGA inference.

---

## Problem Statement

The objective is to predict energy consumption based on two input features:

* Voltage
* Global Intensity

The model outputs a continuous value representing energy usage scaled between 0 and 100.

---

## Dataset

Source: UCI Machine Learning Repository
Dataset: Individual Household Electric Power Consumption

Selected features:

* Input 1: Voltage
* Input 2: Global Intensity
* Target: Global Active Power (scaled)

The dataset is originally provided in `.txt` format and is converted to `.csv` during preprocessing.

---

## Model Architecture

The neural network is intentionally kept small to ensure efficient FPGA implementation.

Input Layer: 2 neurons
Hidden Layer: 8 neurons (ReLU activation)
Output Layer: 1 neuron (linear output)

Key constraints:

* No bias terms
* Integer-only computation
* Activation function: ReLU (f(x) = max(0, x))

---

## Data Preprocessing

Steps performed:

1. Convert dataset from `.txt` to `.csv`
2. Handle missing values (`?`)
3. Convert relevant columns to numeric types
4. Normalize inputs to range [-1, 1]
5. Scale output to range [0, 1]

---

## Training

The model is trained using a regression approach:

* Loss function: Mean Squared Error (MSE)
* Activation: ReLU
* Training split: 80% train, 20% test

---

## Quantization

To ensure compatibility with FPGA hardware, all weights are quantized to int8 format.

Quantization method:

```
scale = 127 / max(abs(weights))
quantized_weights = (weights * scale).astype(int8)
```

This ensures all values lie within:

```
-128 to 127
```

---

## Weight Export

All weights are flattened into a single array for FPGA consumption.

Structure:

* First 16 values: Input → Hidden layer weights (2 × 8)
* Next 8 values: Hidden → Output layer weights (8 × 1)

Example:

```
[12, -5, 23, 44, ..., -8]
```

These weights are saved in:

```
weights.txt
```

---

## FPGA Inference Pipeline

The FPGA performs inference using integer arithmetic:

1. Multiply inputs with first layer weights
2. Apply ReLU activation
3. Multiply with second layer weights
4. Clamp output between 0 and 100

Mathematical flow:

```
hidden = ReLU(W1 × input)
output = W2 × hidden
```

---

## Stability Considerations

To ensure reliable FPGA inference:

* Inputs are clipped to int8 range
* Weights are scaled before quantization
* Hidden activations are clipped to prevent overflow
* Output is clamped to valid range

---

## Results

Model performance is evaluated using:

* Mean Squared Error (MSE)
* Training loss curve
* Predicted vs actual energy plots

---

## Project Structure

```
fpga-ai/
├── main.py
├── weights.txt
├── energy_dataset.csv
└── README.md
```

---

## How to Run

1. Place dataset file:

```
household_power_consumption.txt
```

2. Run:

```
python main.py
```

3. Outputs:

* Converted dataset (`.csv`)
* Trained model
* Quantized weights (`weights.txt`)
* Performance plots

---

## Future Improvements

* Implement quantization-aware training
* Reduce model size further for faster inference
* Add fixed-point simulation matching FPGA exactly
* Explore alternative lightweight models

---

## Conclusion

This project demonstrates how machine learning models can be adapted for FPGA deployment by simplifying architecture, removing bias terms, and using integer-only arithmetic. The result is a compact and efficient system suitable for real-time embedded energy prediction.

---
