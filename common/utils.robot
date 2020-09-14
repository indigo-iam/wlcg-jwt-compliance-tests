*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections

*** Keywords ***

Execute and Check Success   [Arguments]   ${cmd}
    ${rc}   ${output}    Run and Return RC And Output   ${cmd}
    Should Be Equal As Integers   ${rc}   0   ${cmd} exited with status ${rc} != 0 : ${output}   False
    [Return]   ${rc}  ${output}

Execute and Check Failure   [Arguments]   ${cmd}
    ${rc}   ${output}    Run and Return RC And Output   ${cmd}
    Should Not Be Equal As Integers   ${rc}   0   ${cmd} exited with 0 : ${output}   False
    [Return]   ${rc}  ${output}

Create Temporary File  
    [Arguments]  ${file}  ${content}=${EMPTY}
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    File Should Not Exist   ${path}
    Create File   ${path}  ${content}
    [Return]   ${path}

Remove Temporary File  [Arguments]  ${file}
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    Remove File   ${path}

Create Random Temporary File
    [Arguments]   ${content}=${EMPTY}
    ${file}   Execute and Check Success   uuid-gen
    ${path}    Normalize Path   ${TEMPDIR}/${file}
    File Should Not Exist   ${path}
    Create File   ${path}  ${content}
    [Return]   ${path}