*** Settings ***

Library     DynamicTestCases

Variables   test/variables.yaml
Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot

*** Keywords ***

Read access granted to WLCG members
    [Documentation]     Read access is granted to the storage area to WLCG members
    [Arguments]   ${seAlias}
    ${token}   Get token   scope=-s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}   ${seAlias}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Write access denied to WLCG members
    [Documentation]     Write access is denied to the storage area to WLCG members
    [Arguments]   ${seAlias}
    ${token}   Get token   scope=-s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}   ${seAlias}
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403

Write access granted to storage.modify:/ scope
    [Documentation]     Write access is granted to bearer presenting the storage.modify:/ scope
    [Arguments]   ${seAlias}
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}   ${seAlias}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Contain   ${out}   200


*** Test cases ***

Authz Tests Generator
    [Tags]   generator
    @{aliases}   Load endpoints
    FOR   ${alias}   IN   @{aliases}
        Add test case   Read access granted to WLCG members (${alias})   ${alias}  Read access granted to WLCG members   ${alias}
        Add test case   Write access denied to WLCG members (${alias})   ${alias}   Write access denied to WLCG members   ${alias}
        Add test case   Write access granted to storage.modify:/ scope (${alias})   ${alias}   Write access granted to storage.modify:/ scope   ${alias}
    END