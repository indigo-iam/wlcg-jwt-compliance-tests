*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot

Variables   test/variables.yaml

Force Tags   basic-authz-checks   pedantic-tests

*** Test cases ***

Delete access granted to storage.modify:/ scope
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[0|1].*
    ${rc}   ${out}   Curl Delete Success   ${url}
    Should Contain   ${out}   204

Wlcg/test group grants full access to /protected area
    ${token}   Get token   scope=-s wlcg.groups:/wlcg/test
    ${uuid}   Generate UUID
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${url}   Set Variable   ${endpoint}/protected/protected-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[0|1].*
    ${rc}   ${out}   Curl Delete Success   ${url}
    Should Contain   ${out}   204