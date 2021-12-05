*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot
Resource    common/http.robot

Variables   test/variables.yaml

Force Tags   audience   pedantic-tests

*** Test cases ***

Token with random audience is rejected
    ${uuid}   Generate UUID
    ${token}   Get token   scope=-s openid   opts=--aud=${uuid}
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   401

Token with invalid multiple audiences is rejected
    ${uuid}   Generate UUID
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud="https://fake.audience:8443 ${uuid}"
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   401