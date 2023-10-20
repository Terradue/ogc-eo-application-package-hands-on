FROM docker.io/eoepca/cwl-wrapper@sha256:066566ab6dcee685bb95d4eeab20ef07eefc5aaaf320857a251a3a608c81e694

COPY containers/cwl-wrapper/templates /templates

COPY containers/cwl-wrapper/default.conf /home/jovyan/.cwlwrapper/default.conf

ENTRYPOINT [ "cwl-wrapper" ]