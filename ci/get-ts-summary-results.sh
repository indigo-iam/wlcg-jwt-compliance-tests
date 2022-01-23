#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  exit 1
fi

report_file="$1"

json_out=$(cat "${report_file}" | grep '^window.output\["stats"\]' | sed -e 's/window.output\["stats"\] = //' -e 's/;$//')

passed_tests=$(echo "${json_out}" | jq .[0][0].pass)
failed_tests=$(echo "${json_out}" | jq .[0][0].fail)

echo
echo "Test summary results"
echo
echo "All Tests $(( ${passed_tests} + ${failed_tests} ))"
echo "Pass ${passed_tests}"
echo "Fail ${failed_tests}"
echo
echo "Detailed report at ${BUILD_URL}artifact/reports/reports/latest/joint-report.html"
echo
echo "Git repository at https://github.com/indigo-iam/wlcg-jwt-compliance-tests"
echo
