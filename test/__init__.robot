*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Resource   common/oidc-agent.robot
Force tags   wlcg

Suite Setup   Default Suite Setup

*** Keywords ***
Default Suite Setup
     Set Environment Variable   ${bearer.env}   ${EMPTY}
