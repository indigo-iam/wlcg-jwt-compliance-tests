*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Resource   common/oidc-agent.robot
Resource   common/utils.robot

Suite Setup   Default Suite Setup

*** Keywords ***
Default Suite Setup
     ${suite_uuid}   Generate UUID 
     Set Suite Variable   \${SUITE_UUID}   ${suite_uuid}
     Set Environment Variable   ${bearer.env}   ${EMPTY}
