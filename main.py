import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt
from sklearn.neural_network import MLPRegressor
#convert
txt_file = "household_power_consumption.txt"
df = pd.read_csv(
    txt_file,
    sep=';',
    low_memory=False
)
df.to_csv("energy_dataset.csv", index=False)
print("TXT converted to CSV")
#load
data = pd.read_csv("energy_dataset.csv")
#missing values
data.replace("?", np.nan, inplace=True)
data.dropna(inplace=True)
#columns to numeric
cols = [
    "Voltage",
    "Global_intensity",
    "Global_active_power"
]
for c in cols:
    data[c] = pd.to_numeric(data[c])
X = data[["Voltage","Global_intensity"]].values
y = data["Global_active_power"].values
X = X.astype(np.float32)
#scale 
X = X / np.max(np.abs(X))
y = y / 100.0
#test train split
X_train,X_test,y_train,y_test = train_test_split(
    X,y,
    test_size=0.2,
    random_state=42
)
#build model
model = MLPRegressor(
    hidden_layer_sizes=(8,),
    activation="relu",
    solver="adam",
    max_iter=200
)
#train
model.fit(
    X_train,
    y_train
)
#eval
pred = model.predict(X_test)
mse = mean_squared_error(y_test,pred)
print("Test MSE:",mse)
#performance
pred_energy = pred * 100
actual_energy = y_test * 100
plt.figure()
plt.scatter(actual_energy, pred_energy)
plt.xlabel("Actual Energy")
plt.ylabel("Predicted Energy")
plt.title("Actual vs Predicted Energy Consumption")
plt.show()
#predictioncurve type shi
plt.figure()
plt.plot(actual_energy[:200], label="Actual")
plt.plot(pred_energy[:200], label="Predicted")
plt.xlabel("Sample")
plt.ylabel("Energy")
plt.title("Energy Prediction")
plt.legend()
plt.show()
#weights
weights = []
for w in model.coefs_:
    weights.append(w)
#quantize that shi
quantized_weights = []
for w in weights:
    scale = 127 / np.max(np.abs(w))
    w_q = (w * scale).astype(np.int8)
    quantized_weights.extend(w_q.flatten())
quantized_weights = np.array(quantized_weights)
print("Quantized Weights:", quantized_weights)
#save
np.savetxt(
    "weights.txt",
    quantized_weights,
    fmt="%d",
    delimiter=","
)
print("Weights exported to weights.txt")

#Example inference
def relu(x):
    return np.maximum(x,0)

def inference(x,c,weights):
    W1 = weights[:16].reshape(2,8)
    W2 = weights[16:].reshape(8,1)
    inp = np.array([x,c])
    hidden = np.dot(inp,W1)
    hidden = relu(hidden)
    out = np.dot(hidden,W2)
    out = np.clip(out,0,100)
    return out
print("Example inference:", inference(10,20,quantized_weights))