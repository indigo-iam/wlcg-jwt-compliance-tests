*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot

Variables   test/variables.yaml

Force Tags   path-enforced-authz-checks

*** Test cases ***

Path authorization enforced on storage.read
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${uuid}   Generate UUID
    ${url}   Set Variable   ${endpoint}/not-found-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   403
    ${url}   SE URL  not-found-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Path authorization enforced on storage.modify
    ${token}   Get token   scope=-s storage.modify:/wlcg-jwt-compliance
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${uuid}   Generate UUID
    ${url}   Set Variable   ${endpoint}/not-found-${uuid}
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403
    ${url}   SE URL  not-found-${uuid}
     ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01]

storage.read:/foo does not allow to read the /foobar file
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   ${uuid}/foobar
    ${rc}   ${out}   Curl PUT Success   /etc/services   ${url}
    Should Match Regexp   ${out}   20[01]
    ${token}   Get token   scope=-s storage.read:/foo
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   403
