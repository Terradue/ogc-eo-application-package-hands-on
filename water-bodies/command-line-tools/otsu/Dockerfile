FROM mambaorg/micromamba

USER root

ENV PATH=/opt/conda/envs/env_otsu/bin:$PATH

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl gcc build-essential && \
    apt-get clean

RUN mkdir -p /app && chown -R mambauser:mambauser /app

USER mambauser

RUN micromamba create -n env_otsu -c conda-forge gdal scikit-image click loguru

ADD app.py /app/app.py
