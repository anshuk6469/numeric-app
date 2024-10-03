#!/bin/bash

dockerImageName=$(awk 'NR==17 {print $2}' Dockerfile)
echo $dockerImageName

docker run -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ ghcr.io/aquasecurity/trivy --severity HIGH --exit-code 0 image $dockerImageName
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ ghcr.io/aquasecurity/trivy --severity CRITICAL --exit-code 1 image $dockerImageName

exit_code=$?
echo "EXIT CODE : ${exit_code}"

if [[ "${exit_code} == 1" ]]; then
   echo "Image Scanning Completed. Vulnerabilities Found"
   exit 1;
   else
   echo "Image Scan Completed. No CRITICAL Vulnerabilities Found"
fi;