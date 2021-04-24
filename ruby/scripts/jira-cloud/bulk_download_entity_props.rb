# Use case: Bulk download entity props from multiple Jira issues
# API docs: https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/

require 'typhoeus'
require 'json'
require 'oj'
require 'yaml'
require 'byebug'
require 'logger'
require 'securerandom'
logger = Logger.new(STDOUT)
config = YAML::load_file(File.join(__dir__, '../../config-cloud.yml'))

API_V2 = "/rest/api/2"
RESOURCE_ISSUE = "/issue"
PROJECT_KEY = "YEL"
PLUGIN_KEY = "some.plugin.key.nz"

#  Make parallel requests via hydra
totalRequests = 20 # Customize accordingly
hydra = Typhoeus::Hydra.new
requests = totalRequests.times.map {
    startIssuedId = 1 # Customize accordingly
    endIssuedId = 20 # Customize accordingly
    issueId = "#{PROJECT_KEY}-#{(startIssuedId..endIssuedId).to_a.sample}"

    # Declare a single request
    request = Typhoeus::Request.new(
      config["BASEURL"] + API_V2  + RESOURCE_ISSUE + "/#{issueId}/properties/#{PLUGIN_KEY}",
      method: :get,
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
extractedEntityProps = []
requests.map { |request|
    response = request.response
    if response.code == 200
        extractedEntityProps << Oj.load(response.body)
    end
    logger.info("request status: #{response.code}")
}

# Extract data
File.write("extracted_random_entity_props_data.json", extractedEntityProps)
print("Completed! Successfully downloaded random entity properties from #{requests.count} #{requests.count > 1 ? 'issues' : 'issue'}")