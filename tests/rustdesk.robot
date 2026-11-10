*** Settings ***
Library    SSHLibrary

*** Variables ***
${ADMIN_USER}    admin
${ADMIN_PASSWORD}    Nethesis,1234
${module_id}    ${EMPTY}

*** Keywords ***
Login to cluster-admin
    New Page    https://${NODE_ADDR}/cluster-admin/
    Fill Text    text="Username"    ${ADMIN_USER}
    Click    button >> text="Continue"
    Fill Text    text="Password"    ${ADMIN_PASSWORD}
    Click    button >> text="Log in"
    Wait For Elements State    css=#main-content    visible    timeout=10s

Port is listening
    [Arguments]    ${port}
    ${rc} =    Execute Command    ss -ltn 'sport = :${port}' | grep -q LISTEN
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Test Cases ***
Check if rustdesk is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Global Variable    ${module_id}    ${output.module_id}

Check if rustdesk can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"host": "rustdesk.test.local", "lets_encrypt": false, "http2https": false, "ban_threshold": 5, "log_retention_days": 180, "admin_allowlist": ["127.0.0.1"], "web_client": true}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if the RustDesk ports are listening
    Wait Until Keyword Succeeds    30s    3s    Port is listening    21116
    Wait Until Keyword Succeeds    30s    3s    Port is listening    21117

Check if the public key is returned
    ${output}  ${rc} =    Execute Command    api-cli run module/${module_id}/get-configuration
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{config} =    Evaluate    json.loads('''${output}''')    json
    Should Not Be Empty    ${config.public_key}

Check if the relay enforces the key
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} podman inspect hbbr --format '{{.Config.Cmd}}'
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Contain    ${output}    -k

Check if the log retention timer is active
    ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user is-active purge-logs.timer
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if the web console answers
    ${rc} =    Execute Command    curl -fsk -H 'Host: rustdesk.test.local' https://127.0.0.1/_admin/
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if the browser client is served
    ${rc} =    Execute Command    curl -fsk -H 'Host: rustdesk.test.local' https://127.0.0.1/webclient/
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if the websocket routes reach hbbs and hbbr
    FOR    ${path}    IN    /ws/id    /ws/relay
        ${output} =    Execute Command    curl -sk --http1.1 -o /dev/null -w '\%{http_code}' -H 'Host: rustdesk.test.local' -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' --max-time 3 https://127.0.0.1${path}
        Should Be Equal    ${output}    101
    END

Take screenshots
    [Tags]    ui
    Import Library    Browser
    New Browser    chromium    headless=True
    New Context    ignoreHTTPSErrors=True
    Login to cluster-admin
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}?page=settings
    Wait For Elements State    iframe >>> h2 >> text="Settings"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/Settings.png
    Close Browser

Check if rustdesk is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

