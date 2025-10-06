import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OrdinalEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt
import joblib

# Ensure directories exist
os.makedirs("model", exist_ok=True)
os.makedirs("result", exist_ok=True)

# Load dataset
drug_df = pd.read_csv("data/drug200.csv")  # correct path
drug_df = drug_df.sample(frac=1)  # shuffle rows

# Features and labels
X = drug_df.drop("Drug", axis=1).values
y = drug_df["Drug"].values

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=125)

# Define categorical & numerical columns (based on dataset order)
cat_col = [1, 2, 3]   # Sex, BP, Cholesterol
num_col = [0, 4]      # Age, Na_to_K

# Preprocessing + model pipeline
transform = ColumnTransformer([
    ("encoder", OrdinalEncoder(), cat_col),
    ("num_imputer", SimpleImputer(strategy="median"), num_col),
    ("num_scaler", StandardScaler(), num_col),
])

pipe = Pipeline(steps=[
    ("preprocessing", transform),
    ("model", RandomForestClassifier(n_estimators=100, random_state=125))
])

# Train model
pipe.fit(X_train, y_train)

# Evaluate
predictions = pipe.predict(X_test)
accuracy = accuracy_score(y_test, predictions)
f1 = f1_score(y_test, predictions, average="macro")

print(f"✅ Accuracy: {accuracy:.2f}, F1 Score: {f1:.2f}")

# Save metrics
with open("result/metrics.txt", "w") as f:
    f.write(f"Accuracy: {accuracy:.2f}, F1 Score: {f1:.2f}")

# Save confusion matrix
cm = confusion_matrix(y_test, predictions, labels=pipe.classes_)
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=pipe.classes_)
disp.plot()
plt.savefig("result/model_results.png", dpi=120)

# Save trained model
joblib.dump(pipe, "model/drug_pipeline.joblib")
print("Training complete — Model saved to model/drug_pipeline.joblib")