# Use case: Bulk update entity properties to Jira issue
# API docs: https://developer.atlassian.com/server/jira/platform/entity-properties/

require 'typhoeus'
require 'json'
require 'yaml'
require 'byebug'
require 'logger'
require 'securerandom'
logger = Logger.new(STDOUT)
config = YAML::load_file(File.join(__dir__, '../../config-server.yml'))

API_V2 = "/rest/api/2"
PROJECT_KEY = "YEL"
PLUGIN_KEY = "some.plugin.key.nz"

#  Make parallel requests via hydra
totalRequests = 20 # Customize accordingly
hydra = Typhoeus::Hydra.new
requests = totalRequests.times.map {
    data = File.read("../random_entity_props_data.json")
    startIssuedId = 1 # Customize accordingly
    endIssuedId = 50 # Customize accordingly
    issueId = "MTIP-#{(startIssuedId..endIssuedId).to_a.sample}"

    # Declare a single request
    request = Typhoeus::Request.new(
      config["BASEURL"] + API_V2  + RESOURCE_ISSUE + "/#{issueId}/properties/#{PLUGIN_KEY}",
      method: :put,
      body: data,
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