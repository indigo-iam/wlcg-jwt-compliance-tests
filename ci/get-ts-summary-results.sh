#!/bin/bash
set -ex

cat reports/latest/joint-report.html | grep '^window.output\["stats"\]' | sed -e 's/window.output\["stats"\] = //' -e 's/;$//' | jq '.[0][0] | {pass,fail} | join(" ")' | tr -d '"' | awk '{printf "| All Tests %d | Pass %d | Fail %d|\n", $1+$2, $1, $2}'
