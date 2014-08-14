require "json"
require "base64"

selenium_server = "http://127.0.0.1:4444/wd/hub"

def parseRespAndCheckStatus(resp, operation)
  parsed_resp = JSON.parse(resp)
  status = parsed_resp["status"]
  raise StandardError "#{operation} failed with error-code #{status}" unless status==0
  return parsed_resp
end

# Create a session
url = selenium_server + "/session"
resp = `curl -X POST -d @browser-caps.json #{url}`
parsed_resp = parseRespAndCheckStatus(resp, "Creating session")
session_id = parsed_resp["sessionId"]
puts "Session id is #{parsed_resp["sessionId"]}"

# Open a url in the browser
url = selenium_server + "/session/#{session_id}/url"
resp = `curl -X POST -d @url.json #{url}`
parseRespAndCheckStatus(resp, "Opening url")

# Find the search box element
url = selenium_server + "/session/#{session_id}/element"
resp = `curl -X POST -d @element.json #{url}`
parsed_resp = parseRespAndCheckStatus(resp, "Searching element")
webelement = parsed_resp["value"]["ELEMENT"]
puts "webelement json is #{webelement}"

# Send keystrokes to the element
url = selenium_server + "/session/#{session_id}/element/#{webelement}/value"
resp = `curl -X POST -d "{"value":["Browserstack"]}" #{url}`
parseRespAndCheckStatus(resp, "Sending keystrokes")

# wait for loading
sleep 3

# Get the title of current page
url = selenium_server + "/session/#{session_id}/title"
resp = `curl #{url}`
parsed_resp = parseRespAndCheckStatus(resp, "Getting title")
puts "The title of the window is #{parsed_resp["value"]}"

# Take a screenshot
url = selenium_server + "/session/#{session_id}/screenshot"
resp = `curl #{url}`
parsed_resp = parseRespAndCheckStatus(resp, "Taking screenshot")
image = Base64.decode64(parsed_resp["value"])
File.open('screenshot.png', 'wb') { |f| f.write(image) }

# Delete the session
url = selenium_server + "/session/#{session_id}"
resp = `curl -X DELETE #{url}`
parseRespAndCheckStatus(resp, "Closing the session")
