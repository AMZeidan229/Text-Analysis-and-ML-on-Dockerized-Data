FROM quay.io/jupyter/scipy-notebook:latest

# Install extra packages from requirements.txt
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Create the project folder inside the image
RUN mkdir -p /home/jovyan/bd-a1/data /home/jovyan/bd-a1/notebook /home/jovyan/bd-a1/output/figures

# Copy the empty notebook and the dataset into the image
COPY --chown=${NB_UID}:${NB_GID} data/dataset.csv /home/jovyan/bd-a1/data/dataset.csv
COPY --chown=${NB_UID}:${NB_GID} notebook/analysis.ipynb /home/jovyan/bd-a1/notebook/analysis.ipynb

# Work from the project folder
WORKDIR /home/jovyan/bd-a1

EXPOSE 8888