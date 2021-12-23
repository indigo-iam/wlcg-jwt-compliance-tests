*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot
Resource    common/http.robot

Variables   test/variables.yaml


*** Test cases ***

Token with random audience is rejected (permissive)
    [Tags]   audience   permissive
    ${out}   Get token with random audience
    ${ret}   Should Match Regexp   ${out}   40[134]

Token with random audience is rejected (strict)
    [Tags]   audience   strict
    ${out}   Get token with random audience
    ${ret}   Should Match Regexp   ${out}   401

Token with correct audience is accepted
    [Tags]   audience
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud=${se_config.endpoint}
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Token with correct audience in multiple option is accepted
    [Tags]   audience
    ${uuid}   Generate UUID
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud="${se_config.endpoint} ${uuid}"
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Token with invalid multiple audiences is rejected (permissive)
    [Tags]   audience   permissive
    Get token with invalid multiple audience
    ${ret}   Should Match Regexp   ${out}   40[134]

Token with invalid multiple audiences is rejected (strict)
    [Tags]   audience   strict
    ${out}   Get token with invalid multiple audience
    ${ret}   Should Match Regexp   ${out}   401


*** Keywords ***

Get token with random audience
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${token}   Get token   scope=-s openid   opts=--aud=${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    [Return]   ${out}

Get token with invalid multiple audience
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud="https://fake.audience:8443 ${uuid}"
    ${rc}   ${out}   Curl Error   ${url}
    [Return]   ${out}
