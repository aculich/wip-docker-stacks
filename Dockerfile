FROM jupyter/datascience-notebook

RUN (cd ~ ; git clone https://github.com/BVLC/caffe.git )
RUN conda install protobuf libprotobuf -y
RUN conda install caffe -y
RUN conda install --quiet --yes 'tensorflow=0.12.1'
RUN conda install dipy tqdm nilearn -y
RUN pip install mne

RUN conda install --yes 'scikit-image=0.11*'
RUN conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy

USER root

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER

# Due to the way the jupyter/docker-stacks are designed, all data must be placed
# in the ~/work directory, not in the top-level of the home directory.
RUN ln -sf ~/work/data_ucsf ~/data_ucsf
RUN ln -sf ~/data_ucsf/dipy ~/.dipy
