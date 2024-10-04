#!/bin/bash

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

chmod 777 $(pwd)
echo $(id -u):$(id -g)

docker run -v $(pwd):/zap/wrk/:rw -t quay.io/anshuk6469/owaspzap-report zap-api-scan.py -t http://$applicationURL:$PORT/v3/api-docs -f openapi -r zapreport.html

exit_code=$?

mkdir -p owasp-zap-report
mv zapreport.html owasp-zap-report

if [[ "${exit_code}" -ne 0 ]]; then
   echo "OWASP ZAP FOUND RISK. Please check the HTML Report"
   exit 1;
   else
   echo "NO RISK YOU ARE GOOD"
fi;
