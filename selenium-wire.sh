
#!/bin/bash

SELENIUM_SERVER="http://127.0.0.1:4444/wd/hub"

getParam () {
  if [ "$#" -ne 2 ]; then
    echo "Function Usage: getParam JSON_STRING PARAM_NAME " >&2
    exit 1
  fi
  ret_val=$(echo $1 | tr ',{}' '\n' | grep $2 | awk -F: '{printf $2}')
  echo $ret_val
}

checkStatus () {
  if [ "$#" -ne 2 ]; then
    echo "Function Usage: checkStatus JSON_STRING ACTION" >&2
    exit 1
  fi
  status=$(getParam $1 "status")
  if [ $status -ne "0" ]; then
    echo "Status is non-zero, error-code: $status" >&2
    echo "$2 failed" >&2
    exit 1
  fi
}

# Create a session
response=`curl -X POST -d @browser-caps.json $SELENIUM_SERVER/session`
checkStatus $response "Session creation"
session_id=$(getParam $response "sessionId" | sed "s/\"//g") 

echo "SessionId is $session_id"

# Open url
response=`curl -X POST -d @url.json $SELENIUM_SERVER/session/$session_id/url`
echo "Response: $response"
checkStatus $response "Opening URL"

# Find search element
response=`curl -X POST -d @element.json $SELENIUM_SERVER/session/$session_id/element`
checkStatus $response "Finding element"
element_id=$(getParam $response "ELEMENT" | sed "s/\"//g")

# Send keystrokes
response=`curl -X POST -d "{"value":["Browserstack"]}" $SELENIUM_SERVER/session/$session_id/element/$element_id/value`
checkStatus $response "Sending keystrokes"
sleep 3

# Get the title
response=`curl $SELENIUM_SERVER/session/$session_id/title`
checkStatus $response "Getting title"
title=$(getParam $response "value")
echo "Title of the window: $title"

# Delete the session
response=`curl -X DELETE $SELENIUM_SERVER/session/$session_id`
checkStatus $response "Closing the session"

