*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot

Variables   test/variables.yaml

Force Tags   basic-authz-checks   pedantic-tests

*** Test cases ***

Write access denied to WLCG members
    ${token}   Get token   scope=-s openid
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-write-access-denied-${uuid}
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403

Write access denied to storage.read:/ scope
    ${token}   Get token   scope=-s storage.read:/
    ${uuid}   Generate UUID
    ${url}   SE URL   robot-test-${uuid}
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403

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

Path authorization enforced on storage.write
    ${token}   Get token   scope=-s storage.modify:/wlcg-jwt-compliance
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${uuid}   Generate UUID
    ${url}   Set Variable   ${endpoint}/not-found-${uuid}
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403
    ${url}   SE URL  not-found-${uuid}
     ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*

storage.modify does not imply storage.read
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL  found-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${token}   Get token   scope=-s storage.modify:/
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   403

storage.create does not imply storage.read
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL  found-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${token}   Get token   scope=-s storage.create:/
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   403

storage.create does not allow overwriting files
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL  overwrite-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    ${token}   Get token   scope=-s storage.create:/
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403

storage.create does not allow deleting files
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL  overwrite-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${token}   Get token   scope=-s storage.create:/
    ${rc}   ${out}   Curl Delete Error   ${url}
    Should Contain   ${out}   403

Default groups do not grant write access to /protected area
    ${token}   Get token   scope=-s wlcg.groups
    ${uuid}   Generate UUID
    ${endpoint}   GET SE endpoint   ${se_alias}
    ${url}   Set Variable   ${endpoint}/protected/protected-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404
    ${rc}   ${out}   Curl Put Error   /etc/services  ${url}
    Should Contain   ${out}   403