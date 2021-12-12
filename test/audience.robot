*** Settings ***

Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot
Resource    common/http.robot

Variables   test/variables.yaml

Force Tags   audience

*** Test cases ***

Token with random audience is rejected
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${token}   Get token   scope=-s openid   opts=--aud=${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    ${ret}   Should Match Regexp   ${out}   40[0-9].*

Token with correct audience is accepted
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud=${se_config.endpoint}
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Token with correct audience in multiple option is accepted
    ${uuid}   Generate UUID
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud="${se_config.endpoint} ${uuid}"
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Error   ${url}
    Should Contain   ${out}   404

Token with invalid multiple audiences is rejected
    ${token}   Get token
    ${uuid}   Generate UUID
    ${url}   SE URL   audience-test-${uuid}
    ${rc}   ${out}   Curl Put Success   /etc/services  ${url}
    Should Match Regexp   ${out}   20[01].*
    ${se_config}   Get SE config
    ${token}   Get token   scope=-s openid   opts=--aud="https://fake.audience:8443 ${uuid}"
    ${rc}   ${out}   Curl Error   ${url}
    ${ret}   Should Match Regexp   ${out}   40[0-9].*