*** Settings ***

Variables   test/variables.yaml
Resource    common/curl.robot
Resource    common/oidc-agent.robot

*** Keywords ***

Default Setup
    Get token

Create remote file
    [Arguments]  ${uuid}  ${seAlias}   ${sa}=wlcg
    ${file}   Set Variable   robot-file-${uuid}
    ${dest}   Get From Dictionary   ${endpoints}   ${seAlias}
    ${saPath}   Get From Dictionary   ${dest.paths}   ${sa}
    ${url}   Set Variable   ${dest.endpoint}${saPath}/robot-${uuid}/${file}
    ${localFile}   Create Temporary File   ${file}
    ${rc}   ${out}   Curl PUT Success   ${localFile}  ${url}
    [Return]   ${url}
    
Create remote dir   
    [Arguments]  ${uuid}  ${seAlias}   ${sa}=wlcg
    ${dir}   Set Variable   robot-${uuid}
    ${dest}   Get From Dictionary   ${endpoints}   ${seAlias}
    ${saPath}   Get From Dictionary   ${dest.paths}   ${sa}
    ${url}   Set Variable   ${dest.endpoint}${saPath}/${dir}
    ${rc}   ${out}   Curl MKCOL Success   ${url}
    [Return]   ${url}

HTTP URL
    [Arguments]  ${uuid}  ${seAlias}   ${sa}=wlcg
    ${dest}   Get From Dictionary   ${endpoints}   ${seAlias}
    ${saPath}   Get From Dictionary   ${dest.paths}   ${sa}
    ${url}   Set Variable   ${dest.endpoint}${saPath}/robot-${uuid}/robot-file-${uuid}
    [Return]   ${url}

Tpc pull copy   
    [Arguments]   ${se1}   ${se2}   ${sa}=wlcg
    ${rc}   ${uuid}   Execute and Check Success   uuidgen
    Create remote dir  ${uuid}  ${se1}
    Create remote dir  ${uuid}  ${se2}
    ${destUrl}   HTTP URL   ${uuid}  ${se1}
    ${url}   Create remote file   ${uuid}   ${se2}
    Curl pull COPY Success   ${destUrl}   ${url}

Tpc pull Teardown
    [Arguments]   ${se1}   ${se2}   ${sa}=wlcg
    Log   ${se1}
    Log   ${se2}

*** Test cases ***

Tpc pull works
    [Template]   Tpc pull copy
    [Setup]   Default Setup
    se1=cnaf-amnesiac   se2=infn-t1-xfer
    se1=cnaf-amnesiac   se2=prometheus