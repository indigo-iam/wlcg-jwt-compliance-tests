#!/bin/bash
set -e

REPORTS_URL=${REPORTS_URL:-davs://amnesiac.cloud.cnaf.infn.it:8443/wlcg/jwt-compliance-reports}
REPORTS_DIR_BASE=${REPORTS_DIR_BASE:-$(pwd)/reports}

if [ -n "${RUN_DEBUG}" ]; then
  set -x
fi

now=$(date +%Y%m%d_%H%M%S)
eval $(oidc-agent --no-autoload)
oidc-add --pw-cmd='echo $OIDC_AGENT_SECRET' wlcg

endpoints=$(cat test/variables.yaml | shyaml keys endpoints | grep -v se-storm-example)

reports_dir=${REPORTS_DIR_BASE}/reports/latest

mkdir -p ${reports_dir}

set +e

for e in ${endpoints}; do
  REPORTS_DIR=${reports_dir}/${e} ./run-testsuite.sh ${e}
done

reports=$(find ${reports_dir} -name output.xml)

set -e

echo "Creating final report..."
rebot --nostatusrc \
  --report ${reports_dir}/joint-report.html \
  --log ${reports_dir}/joint-log.html \
  --ReportTitle "JWT compliance tests ${now}" \
  --name "JWT compliance tests" \
  --tagstatinclude 'se-*' \
  ${reports}

if [ -n "${SKIP_REPORT_UPLOAD}" ]; then
  echo "Skipping report upload as requested by configuration"
else 
  export BEARER_TOKEN=$(oidc-token wlcg)
  echo "Uploading report to ${REPORTS_URL}"

  gfal-mkdir -p ${REPORTS_URL}/${now}
  gfal-copy -r ${reports_dir} ${REPORTS_URL}/${now}
fi

echo "Done!"
