# Use case: Generate data based on the specified structure

require 'byebug'
require 'securerandom'
require 'json'

# Initialized data
seedEntityProperties = {}

# Generate seeded data
# 190 is an ideal num for data size that's below 32 KB. Context: https://developer.atlassian.com/server/jira/platform/entity-properties/
total_to_create = 10 # Customize accordingly
total_to_create.times do
  soid = SecureRandom.hex(10)
  seedEntityProperties.store(soid, {
      "syncEnabled": false,
      "highPriority": [true, false].sample
    }
  )
end

# Generate EP data
entityPropsData = {
  "app_data" => JSON.parse(seedEntityProperties.to_json),
  "sources" => "#{%w(mailing_list phone chat).sample(2).join(",")}"
}

# Manually cleanse "=>" to ":"
# To pretty print json, use cmd + opt + l. But! When sending REST request,
# it's best to use the minified version as prettying the json will increase the data size by 10 KB
File.write("random_entity_props_data.json", entityPropsData)
print("Completed! Generating random entity properties data")