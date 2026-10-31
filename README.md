# CSCI461 Assignment 1: Dockerized Data, Text Analysis and Machine Learning

- **Course:** CSCI461 Introduction to Big Data, Nile University, Fall 2026
- **Student:** Ahmed Mohamed Zeidan - 231001097
- **Docker Hub image:** `amzeidan/bd-a1:v1`
- **GitHub repository (bonus):** [FILL IN: link, or delete this line]

## 1. Project summary

This project analyses customer reviews from the **Women's E-Commerce Clothing Reviews** dataset. Everything (cleaning, sampling, text analysis, classification and clustering) runs inside a Docker container with JupyterLab.

- **Dataset:** Women's E-Commerce Clothing Reviews (Kaggle): https://www.kaggle.com/datasets/nicapotato/womens-ecommerce-clothing-reviews
- **One row** is one customer review of a clothing item.
- **Text:** `Title`, `Review Text` | **Label:** `Recommended IND` (and `Rating`) | **Numerical:** `Age`, `Rating`, `Positive Feedback Count` | **Categories:** `Division Name`, `Department Name`, `Class Name`
- **Dataset license note:** CC0: Public Domain

## 2. Project structure

```
bd-a1/
├── Dockerfile
├── requirements.txt
├── README.md
├── data/
│   └── dataset.csv
├── notebook/
│   └── analysis.ipynb
├── output/
│   ├── cleaned_data.csv
│   ├── model_metrics.txt
│   ├── cluster_summary.txt
│   └── figures/
└── screenshots/
```

## 3. Requirements

- Docker Desktop (running). On Windows it uses the WSL2 backend.
- A web browser.
- A free Docker Hub account (only needed to push the image).

The commands below are for **Windows PowerShell**, run from inside the `bd-a1` folder. For macOS/Linux replace `${PWD}` with `$(pwd)` and `\` in paths with `/`. In Windows CMD use `%cd%`.

## 4. The Dockerfile in short

- Base image: `quay.io/jupyter/scipy-notebook:latest`
- Extra packages are installed from `requirements.txt` (`pip install`).
- A project folder `/home/jovyan/bd-a1` is created in the image, and the dataset and the empty notebook are copied into it.
- `WORKDIR` is set to `/home/jovyan/bd-a1`.
- The base image already starts JupyterLab on port 8888, so no `CMD` is needed.

## 5. Build the image

```
docker build -t bd-a1:latest .
```

`-t bd-a1:latest` names the image (`bd-a1`) and gives it a tag (`latest`). The `.` means the current folder is the build context.

## 6. Run the container and open JupyterLab

```
docker run -d --name bd-a1-lab -p 8888:8888 -v "${PWD}\output:/home/jovyan/bd-a1/output" -v "${PWD}\notebook:/home/jovyan/bd-a1/notebook" bd-a1:latest
docker logs bd-a1-lab
```

Open the link printed in the logs (it looks like `http://127.0.0.1:8888/lab?token=...`) in a browser, open `notebook/analysis.ipynb`, and use **Kernel > Restart Kernel and Run All Cells**.

### Image vs container

- An **image** is a read-only package (a snapshot) that contains Python, Jupyter, the libraries, the dataset and the empty notebook. It is built from the Dockerfile and does not run by itself. Its layers (one per Dockerfile instruction) are cached and reused.
- A **container** is a running instance of an image. You can start many containers from one image, and removing a container does not delete the image.

### Port mapping: `-p 8888:8888`

The format is `HOST_PORT:CONTAINER_PORT`. JupyterLab listens on port 8888 **inside** the container, and `-p 8888:8888` makes it reachable on port 8888 of my computer. If the host port were busy, `-p 9999:8888` would publish it at `http://localhost:9999` instead.

### Persistent output: bind mounts

The two `-v` options are **bind mounts** that link a host folder to a folder inside the container:

- `output` is mounted to `/home/jovyan/bd-a1/output`, so all final CSV files, metrics and figures are written straight to my computer and stay there even if the container is deleted.
- `notebook` is mounted so that my work in `analysis.ipynb` is saved on my computer.

A **bind mount** links a specific folder of the host (I can open and edit the files directly). A **volume** is storage managed by Docker in its own area, better for data that does not need to be opened by hand.

## 7. Container lifecycle commands

```
docker images                 # the custom image exists
docker ps                     # the container is running
docker ps -a                  # all containers, including stopped ones
docker logs bd-a1-lab         # JupyterLab output and login link
docker inspect bd-a1-lab      # full configuration (JSON)
docker inspect --format "{{json .Mounts}}" bd-a1-lab
docker inspect --format "{{json .NetworkSettings.Ports}}" bd-a1-lab
docker history bd-a1:latest   # image layers
```

Proof that outputs persist:

```
docker stop bd-a1-lab
docker ps -a
docker rm bd-a1-lab
docker ps -a
```

After removing the container, the files in `output/` were still on the host, and a new container started from the same image showed the saved notebook again. Screenshots are in the `screenshots/` folder.

## 8. Docker Hub

- **Repository:** `https://hub.docker.com/r/amzeidan/bd-a1`
- **Tags:** `v1` (and `latest`, both pointing to the same image)

Publish:

```
docker login
docker tag bd-a1:latest amzeidan/bd-a1:v1
docker push amzeidan/bd-a1:v1
```

Pull and run (anyone with Docker installed):

```
mkdir output
docker pull amzeidan/bd-a1:v1
docker run -d --name bd-a1-test -p 8888:8888 -v "${PWD}\output:/home/jovyan/bd-a1/output" amzeidan/bd-a1:v1
docker logs bd-a1-test
```

The image contains the dataset and an empty notebook. To run the full analysis, upload `analysis.ipynb` from this project to JupyterLab (or mount the `notebook` folder).

**Verification:** Deleted all local copies of the image, then pulled from Docker Hub on a clean state.

## 9. Reproduce the project

From the project folder:

1. `docker build -t bd-a1:latest .`
2. Run the container with the command in section 6.
3. Open the login link from `docker logs bd-a1-lab`.
4. Run `notebook/analysis.ipynb` with Restart and Run All.
5. Check the generated files in the `output/` folder on the host.

Or skip the build and use the pull-and-run commands from section 8.

## 10. What the notebook does

**I. Data analysis and preprocessing**
- Dataset understanding (head, shape, dtypes, info, statistics).
- Missing values and duplicates: Title (3,810), Review Text (845) and Division/Department/Class (14 each) were missing, with 21 duplicate rows. Reviews without text and rows without categories were dropped, missing titles were filled with an empty string, and duplicates were removed. Shape: (23,486, 10) to (22,627, 10).
- `loc` / `iloc` (including `np.r_`) examples.
- Five transformations: type conversion, age binning, label and rating-level encoding, category consolidation, min-max scaling.
- Simple random, stratified and cluster sampling, compared with the original distributions.
- Five numerical text features and a correlation heatmap.

**II. Text analysis**
- `cleaned_text` column (original text kept unchanged), tokenization (1,366,598 tokens, 13,595 unique words, 60.4 words per review).
- Top 20 words before and after stopword removal, and a Recommended vs Not recommended comparison.
- Five written insights.

**III. Machine learning**
- Supervised: TF-IDF + Logistic Regression, stratified 80/20 split (18,101 train / 4,526 test).
- Bonus: comparison with Multinomial Naive Bayes.
- Unsupervised: TF-IDF + TruncatedSVD (100 components) + K-Means, with k chosen by an elbow and silhouette experiment.

## 11. Results

| Model | Accuracy | Precision (Rec.) | Recall (Rec.) | F1 (Rec.) | Recall (Not rec.) | F1 (Not rec.) |
|---|---|---|---|---|---|---|
| Logistic Regression | 0.8911 | 0.9052 | 0.9684 | 0.9357 | 0.5415 | 0.6430 |
| Multinomial Naive Bayes | 0.8343 | 0.8320 | 0.9995 | 0.9081 | 0.0878 | 0.1611 |

The baseline accuracy (always predicting "Recommended") is 0.819. Confusion matrix of Logistic Regression: [[444, 376], [117, 3589]].

**K-Means:** k = 9, silhouette score 0.0388 (5,000-review sample), Adjusted Rand Index 0.0094, NMI 0.0314. The clusters mostly follow garment type (dresses, pants, jeans, skirts, shirts, sweaters) plus a sizing cluster, a praise cluster and a fabric-and-fit doubts cluster, which has the most complaints (36.6% not recommended). The clusters do not match the labels, because K-Means never used them.

**Limitations:** class imbalance (82% / 18%), TF-IDF ignores word order, reviews are cut at about 500 characters, noisy labels, a single train/test split, and a low silhouette score (the clusters overlap).

## 12. Output files (in `output/`)

- `cleaned_data.csv`
- `model_metrics.txt`
- `cluster_summary.txt`
- `figures/`: `correlation_heatmap.png`, `word_frequency.png`, `group_comparison.png`, `confusion_matrix.png`, `kmeans_k_selection.png`, `cluster_vs_label.png`

## 13. Screenshots (in `screenshots/`)

Successful `docker build`, `docker images`, running container (`docker ps`), `docker ps -a`, `docker logs`, `docker inspect`, the stop/remove test, JupyterLab with the notebook, the Docker Hub repository page, and the pull-and-run verification.
