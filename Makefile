
install:
	pip install --upgrade pip
	pip install -r app/requirements.txt

train:
	python train.py

eval:
	echo "## Model Metrics" > result/report.md
	cat result/metrics.txt >> result/report.md
	echo '\n## Confusion Matrix Plot' >> result/report.md  
	echo '![Confusion Matrix](./result/model_results.png)' >> result/report.md
	cml comment create result/report.md

update-branch:
	git config --global user.name scholargj17
	git config --global user.email scholargj17@gmail.com
	git add model result
	git commit -m "Update model and results"
	git push --force origin HEAD:update

hf-login:
	git pull origin update || true
	git switch update || true
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./app --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload DRGJ2025/DRUG_CLASSIFY ./result --repo-type=space --commit-message="Sync Results"

deploy: hf-login push-hub
