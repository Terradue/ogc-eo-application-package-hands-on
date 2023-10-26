FROM mambaorg/micromamba

USER root

ENV PATH=/opt/conda/envs/env_norm_diff/bin:$PATH

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl gcc build-essential && \
    apt-get clean

RUN mkdir -p /app && chown -R mambauser:mambauser /app

USER mambauser

RUN micromamba create -n env_norm_diff -c conda-forge gdal click loguru && \
    micromamba clean -a

ADD app.py /app/app.py
