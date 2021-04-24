# Use case: Generate Jira issues with random issue type by targeting multiple projects

require 'typhoeus'
require 'json'
require 'yaml'
require 'logger'
require 'byebug'
require 'securerandom'
logger = Logger.new(STDOUT)
config = YAML::load_file(File.join(__dir__, '../../config-server.yml'))

API_V2 = "/rest/api/2"
RESOURCE_ISSUE = "/issue"
url = config["BASEURL"] + API_V2  + RESOURCE_ISSUE

#  Make parallel requests via hydra
totalRequests = 40 # Customize accordingly
hydra = Typhoeus::Hydra.new
requests = totalRequests.times.map {
    data = {
      "fields": {
        "project": {
          "id": "#{%w(10005).sample}" # To randomize targeted projects for issue creation, use: "#{%w(10005 10100 10006).sample}
        },
        "summary": SecureRandom.hex(10),
        "issuetype": {
          "id": "#{%w(10002).sample}" # To randomize issue type, use: "id": "#{%w(10000 10001 10002 10004 10100).sample}"
        }
      }
    }

    # Declare a single request
    request = Typhoeus::Request.new(
        url,
        method: :post,
        body: JSON.dump(data),
        userpwd: "#{config["USERNAME"]}:#{config["PASSWORD"]}",
        headers: { 'Accept-Encoding' => 'application/json', 'Content-Type' => 'application/json'},
        followlocation: true,
        verbose: true
    )

    # Add callback to each request
    request.on_complete do | response |
        if response.timed_out? || response.failure?
            logger.("request timed out. Retrying..")
            hydra.queue(request)
            logger.info('retried request being queued')
        else
            logger.info("HTTP request failed: " + response.code.to_s)
        end
      end

    # Q the request that now contains callback
    hydra.queue(request)
    logger.info('request being queued')
    request # specifically return this to get requests = [ request, request, request ... ] which will be used for troubleshooting
}
hydra.run

# Inspect the status of each request
requests.map { |request|
    logger.info("request status: #{request.response.code}")
}