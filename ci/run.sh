#!/bin/bash
set -e

now=$(date +%Y%m%d_%H%M%S)
eval $(oidc-agent --no-autoload)
oidc-add wlcg --pw-cmd='echo $OIDC_AGENT_SECRET'

endpoints=$(cat test/variables.yaml | shyaml keys endpoints | grep -v storm-example)

reports_dir=reports/${now}

mkdir -p reports/${now}

set +e

for e in ${endpoints}; do
  REPORTS_DIR=${reports_dir}/${e} ./run-testsuite.sh ${e}
done
