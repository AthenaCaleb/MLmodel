# ----------------------
# Makefile for MLmodel CI
# ----------------------

install:
	# Upgrade pip, setuptools, and wheel
	pip install --upgrade pip setuptools wheel

	# Install Python dependencies
	pip install -r app/requirements.txt

train:
	# Train the model
	python train.py
eval:
	echo "## Model Metrics" > result/report.md
	cat result/metrics.txt >> result/report.md
	echo '\n## Confusion Matrix Plot' >> result/report.md  
	echo '![Confusion Matrix](./result/model_results.png)' >> result/report.md
	



update-branch:
	# Update branch with new model/results
	git config --global user.name "AthenaCaleb"
	git config --global user.email "athena.caleb17@gmail.com"
	git add model result
	git commit -m "Update model and results"
	git push --force origin HEAD:update

hf-login:
	# Login to Hugging Face using secret token
	git pull origin update || true
	git switch update || true
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	# Push app, model, results to Hugging Face Space
	huggingface-cli upload athenacaleb/MLmodel ./app --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload athenacaleb/MLmodel ./model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload athenacaleb/MLmodel ./result --repo-type=space --commit-message="Sync Results"

deploy: hf-login push-hub
