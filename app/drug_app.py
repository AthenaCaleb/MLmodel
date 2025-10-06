import gradio as gr
import joblib

# Load trained model
pipe = joblib.load(r"D:\MLmodel\model\drug_pipeline.joblib")
def predict_drug(age, gender, blood_pressure, cholesterol, na_to_k_ratio):
    features = [age, gender, blood_pressure, cholesterol, na_to_k_ratio]
    predicted_drug = pipe.predict([features])[0]
    return f"Predicted Drug: {predicted_drug}"

inputs = [
    gr.Slider(15, 74, step=1, label="Age"),
    gr.Radio(["M", "F"], label="Gender"),
    gr.Radio(["HIGH", "LOW", "NORMAL"], label="Blood Pressure"),
    gr.Radio(["HIGH", "NORMAL"], label="Cholesterol"),
    gr.Slider(6.2, 38.2, step=0.1, label="Na_to_K"),
]

outputs = gr.Label()

examples = [
    [30, "M", "HIGH", "NORMAL", 15.4],
    [35, "F", "LOW", "NORMAL", 8],
    [50, "M", "HIGH", "HIGH", 34],
]

gr.Interface(
    fn=predict_drug,
    inputs=inputs,
    outputs=outputs,
    examples=examples,
    title="Drug Classification",
    description="Enter the details to identify the drug type",
    theme=gr.themes.Soft(),
).launch()