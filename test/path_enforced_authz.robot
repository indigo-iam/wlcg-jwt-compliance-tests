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

storage.read:/foobar allows to read the /foobar file
    [Setup]   Create foobar directory and file
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance/${SUITE_UUID}/foobar
    ${rc}   ${out}   Curl Auth Success   ${URL}
    Should Contain   ${out}   ${file.content}
    [Teardown]   Delete foobar directory and file

storage.read:/foo does not allow to read the /foobar file
    [Setup]   Create foobar directory and file
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance/${SUITE_UUID}/foo
    ${rc}   ${out}   Curl Error   ${URL}
    Should Contain   ${out}   403
    [Teardown]   Delete foobar directory and file

Create directory allowed with storage.create scope
    ${token}   Get token
    ${uuid}   Generate UUID
    ${basename}   Set Variable   create-dir-${uuid}
    ${url}   SE URL   ${basename}
    ${rc}   ${out}   Curl MKCOL Success   ${url}
    Should Match Regexp   ${out}   20[01]
    ${token}   Get token   scope=-s storage.create:/wlcg-jwt-compliance/${SUITE_UUID}/${basename}
    ${rc}   ${out}   Curl MKCOL Success   ${url}/foobar
    Should Match Regexp   ${out}   20[01]

Create directory not allowed with storage.create scope and partial path
    ${token}   Get token
    ${uuid}   Generate UUID
    ${basename}   Set Variable   create-dir-${uuid}
    ${url}   SE URL   ${basename}
    ${rc}   ${out}   Curl MKCOL Success   ${url}
    Should Match Regexp   ${out}   20[01]
    ${partial.basename}   Get Substring   ${basename}   0   -1
    ${token}   Get token   scope=-s storage.create:/wlcg-jwt-compliance/${SUITE_UUID}/${partial.basename}
    ${rc}   ${out}   Curl MKCOL Error   ${url}/foobar
    Should Contain   ${out}   403

storage.read scope with path not compliant with RFC3986 is rejected
    [Setup]   Create foobar directory and file
    ${token}   Get token   scope=-s storage.read:/foobar
    ${rc}   ${out}   Curl Error   ${URL}
    Should Contain   ${out}   403
    ${token}   Get token   scope=-s storage.read:/foo
    ${rc}   ${out}   Curl Error   ${URL}
    Should Contain   ${out}   403
    [Teardown]   Delete foobar directory and file

Trailing slash allows to read into a directory
    [Tags]   TBD
    [Setup]   Create foobar directory and file
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance/${SUITE_UUID}/foobar/
    ${rc}   ${out}   Curl Auth Success   ${URL}
    Should Contain   ${out}   ${file.content}
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance/${SUITE_UUID}/foo/
    ${rc}   ${out}   Curl Error   ${URL}
    Should Contain   ${out}   403
    ${token}   Get token   scope=-s storage.read:/wlcg-jwt-compliance/${SUITE_UUID}/foobar
    ${rc}   ${out}   Curl Error   ${URL}
    Should Contain   ${out}   403
    [Teardown]   Delete foobar directory and file



*** Variables ***

${file.content}   wlcg-suite-content-file
${file.name}   file


*** Keywords ***

Create foobar directory and file
    ${token}   Get token
    ${url}   SE URL   foobar
    ${rc}   ${out}   Curl MKCOL Success   ${url}
    Should Match Regexp   ${out}   20[01]
    ${tmp.file}   Set Variable   /tmp/${file.name}
    Create File   ${tmp.file}   ${file.content}
    Set Test Variable   ${URL}      ${url}/${file.name}
    ${rc}   ${out}   Curl PUT Success   ${tmp.file}   ${URL}
    Should Match Regexp   ${out}   20[01]

Delete foobar directory and file
    ${token}   Get token
    ${url}   SE URL   foobar
    Curl DELETE Success   ${url}/${file.name}
    Curl DELETE Success   ${url}