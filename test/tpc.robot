*** Settings ***

Variables   test/variables.yaml
Resource    common/endpoint.robot
Resource    common/curl.robot
Resource    common/oidc-agent.robot

*** Keywords ***

Generate UUID
    ${uuid}   Evaluate   uuid.uuid4()   uuid
    [Return]   ${uuid}

Default Setup
    Get token

Create remote file
    [Arguments]  ${file}  ${se_alias}   ${sa}=wlcg
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    ${url}   Set Variable   ${endpoint}/${file}
    ${local_file}   Create Temporary File   ${file}
    ${rc}   ${out}   Curl PUT Success   ${local_file}  ${url}
    [Return]   ${url}
    
Create remote dir   
    [Arguments]  ${dir}  ${se_alias}   ${sa}=wlcg
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    ${url}   Set Variable   ${endpoint}/${dir}
    ${rc}   ${out}   Curl MKCOL Success   ${url}
    [Return]   ${url}

HTTP URL
    [Arguments]  ${path}  ${se_alias}   ${sa}=wlcg
    ${endpoint}   GET SE endpoint   ${se_alias}   ${sa}
    ${url}   Set Variable   ${endpoint}/${path}
    [Return]   ${url}

Tpc pull copy
    [Arguments]   ${se1}   ${se2}   ${sa}=wlcg
    Set tags   ${se1}   ${se2}   ${sa}
    ${uuid}   Generate UUID
    ${test_dir}   Create Dictionary
    ${test_dir.se1}   Create remote dir  tpc-pull-${uuid}  ${se1}
    ${test_dir.se2}   Create remote dir  tpc-pull-${uuid}  ${se2}
    ${tdir}   Set Test Variable   ${test_dir}
    ${path}   Set Variable   tpc-pull-${uuid}/f-${uuid}
    ${destUrl}   HTTP URL   ${path}  ${se1}
    ${url}   Create remote file   ${path}   ${se2}
    Curl pull COPY Success   ${destUrl}   ${url}

*** Test cases ***

#Tpc pull works
#    [Template]   Tpc pull copy
#    [Setup]   Default Setup
    # se1=cnaf-amnesiac   se2=infn-t1-xfer
    # se1=cnaf-amnesiac   se2=prometheus

