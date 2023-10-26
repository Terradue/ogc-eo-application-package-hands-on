FROM docker.io/mambaorg/micromamba

USER root

ENV PATH=/opt/conda/envs/env_crop/bin:$PATH

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl gcc build-essential && \
    apt-get clean

RUN mkdir -p /app && chown -R mambauser:mambauser /app

USER mambauser

RUN micromamba create -n env_crop -c conda-forge gdal click pystac loguru && \
    micromamba clean -a

ADD app.py /app/app.py

