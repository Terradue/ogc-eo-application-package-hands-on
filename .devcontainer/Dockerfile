FROM mambaorg/micromamba

USER root

ENV USERNAME=mambauser 

ENV PATH=/srv/conda/envs/env_base/bin:$PATH

RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl sudo git gcc build-essential tree nodejs

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p /srv/conda && chown -R mambauser:1000 /srv/conda/

USER mambauser

#ADD .devcontainer/environment.yml /tmp/environment.yml

RUN micromamba create -r /srv/conda -n env_crop -c conda-forge gdal==3.1.4 click pystac python==3.9
RUN micromamba create -r /srv/conda -n env_norm_diff -c conda-forge click gdal python==3.9
RUN micromamba create -r /srv/conda -n env_otsu -c conda-forge scikit-image click gdal python==3.9
RUN micromamba create -r /srv/conda -n env_stac -c conda-forge click pystac python==3.9 pip && \
    /srv/conda/envs/env_stac/bin/pip install rio_stac

RUN micromamba create -r /srv/conda -n env_base -c conda-forge -c terradue Stars black awscli cwltool mkdocs-material pystac && \
    /srv/conda/envs/env_base/bin/pip install mkdocs-mermaid2-plugin

WORKDIR /home/mambauser
