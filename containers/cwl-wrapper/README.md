
docker run --rm -i cwl-wrapper:latest $PWD:/app-package eoepca/

docker run --rm -i -v $PWD:/app cwl-wrapper:latest --stagein /app/stage/stage-in.yaml --stageout /app/stage/stage-out.yaml app/app-water-bodies.1.3.1.cwl