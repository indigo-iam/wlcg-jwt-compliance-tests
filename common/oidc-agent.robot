*** Variables ***

${oidc-agent.scope.default}   -s storage.read:/ -s storage.modify:/ -s openid
${bearer.env}   BEARER_TOKEN

*** Keywords ***

Get token   [Arguments]   ${issuer}=wlcg  ${scope}=${oidc-agent.scope.default}  ${opts}=${EMPTY}
    ${rc}  ${out}   Execute and Check Success   oidc-token ${scope} ${opts} ${issuer} 
    Set Environment Variable   ${bearer.env}   ${out}
    [Return]   ${out}