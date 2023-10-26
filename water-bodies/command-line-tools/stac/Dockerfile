FROM mambaorg/micromamba

USER root

ENV PATH=/opt/conda/envs/env_stac/bin:$PATH

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl gcc build-essential && \
    apt-get clean

USER mambauser

RUN micromamba create -n env_stac -c conda-forge pystac python=3.9 pip loguru && \
    /opt/conda/envs/env_stac/bin/pip install rio_stac

ADD app.py /app/app.py

WORKDIR /home/mambauser
