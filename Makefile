install:
	# Upgrade pip, setuptools, and wheel
	pip install --upgrade pip setuptools wheel
	# Install required Python packages
	pip install -r app/requirements.txt
	# Install CML for evaluation comments
	pip install cml

# Train the model
train:
	python train.py

#  the model
eval:
	# Ensure the result directory exists
	mkdir -p result
	# Create metrics report
	echo "## Model Metrics" > result/report.md
	cat result/metrics.txt >> result/report.md
	echo '\n## Confusion Matrix Plot' >> result/report.md  
	echo '![Confusion Matrix](./result/model_results.png)' >> result/report.md
	# Create GitHub PR/commit comment using CML
	cml comment create result/report.md

#  branch with model and results
update-branch:
	git config --global user.name scholargj17
	git config --global user.email scholargj17@gmail.com
	git add model result
	git commit -m "Update model and results"
	git push --force origin HEAD:update

# Hugging Face login
hf-login:
	# Pull and switch branch if it exists
	git pull origin update || true
	git switch update || true
	# Install HF CLI
	pip install -U "huggingface_hub[cli]"
	# Login using token stored in environment variable HF
	huggingface-cli login --token $(HF) --add-to-git-credential

# Push to Hugging Face Space
push-hub:
	# Upload app files
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./app --repo-type=space --commit-message="Sync App files"
	# Upload model files
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./model --repo-type=space --commit-message="Sync Model"
	# Upload result files
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./result --repo-type=space --commit-message="Sync Results"

# Deploy: login + push to HF
deploy: hf-login push-hub
