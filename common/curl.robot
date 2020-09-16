*** Settings ***

Resource   common/utils.robot
Resource   common/oidc-agent.robot

*** Variables ***

${x509.trustdir}  /etc/grid-security/certificates
${curl.opts.default}  -s -L -i -f --show-error --capath ${x509.trustdir}

*** Keywords ***

Curl   [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}   ${out}    Run and Return RC And Output   curl ${opts} ${url} 
    [Return]  ${rc}  ${out}

Curl Success  [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}  ${out}   Execute and Check Success  curl ${url} ${opts}
    [Return]  ${rc}  ${out}

Curl Error   [Arguments]  ${url}  ${opts}=${curl.opts.default}
    ${rc}  ${out}   Execute and Check Failure  curl ${opts} -H "Authorization: Bearer %{${bearer.env}}" ${url}
    [Return]  ${rc}  ${out}

Curl pull COPY Success  [Arguments]  ${dest}  ${source}  ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X COPY -H "Source: ${source}" -H "Authorization: Bearer %{${bearer.env}}" -H "TransferHeaderAuthorization: Bearer %{${bearer.env}}" ${opts}
    ${rc}  ${out}  Curl Success  ${dest}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl push COPY Success  [Arguments]  ${dest}  ${source}  ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X COPY -H "Destination: ${dest}" ${opts}
    ${rc}  ${out}  Curl Success  ${source}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl PUT   
    [Arguments]   ${file}   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   ${opts} -H "Authorization: Bearer %{${bearer.env}}" --upload-file "${file}"
    ${rc}  ${out}  Curl   ${url}  ${all_opts}
    [Return]   ${rc}  ${out}

Curl PUT Error
    [Arguments]   ${file}   ${url}   ${opts}=${curl.opts.default}
    ${rc}  ${out}  Curl PUT   ${url}   ${opts}
    Should Not Be Equal As Integers   ${rc}   0   curl exited with 0 : ${out}   False
    [Return]   ${rc}  ${out}

Curl DELETE Success   
    [Arguments]   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X DELETE ${opts} -H "Authorization: Bearer %{${bearer.env}}"
    ${rc}  ${out}  Curl Success  ${url}  ${all_opts}
    [Return]  ${rc}  ${out}

Curl MKCOL Success   
    [Arguments]   ${url}   ${opts}=${curl.opts.default}
    ${all_opts}   Set variable   -X MKCOL ${opts} -H "Authorization: Bearer %{${bearer.env}}"
    ${rc}  ${out}  Curl Success  ${url}  ${all_opts}
    [Return]  ${rc}  ${out}