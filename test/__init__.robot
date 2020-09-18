*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections

Resource   common/oidc-agent.robot
Resource   common/endpoint.robot
Resource   common/curl.robot
Resource   common/utils.robot

Variables   test/variables.yaml

Suite Setup   Default Suite Setup

*** Keywords ***
Default Suite Setup
     ${SUITE_UUID}   Generate UUID 
     Set Global Variable   ${SUITE_UUID}   ${suite_uuid}
     ${token}   Get token
     Create Suite Directory