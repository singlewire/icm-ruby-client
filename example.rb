require 'icm_client'
require 'json'

token = '3F24FYHHIUI6HPEMZAVBIT7LC64DAFJA45DRDY5VIHECUFCP5MLWVENH42IBA755VMXVBFOCHO7FZY5LQTLHVQ6ZGRZP4EAO3VLCEUQ='
icm_client = ICMClient::Client.new(token, 'https://james.qadev.singlewire.com:8443/api/v1-DEV')

#print icm_client.users.get

#puts JSON.pretty_generate(JSON.parse(icm_client.session.get))
#puts JSON.parse(icm_client.session.get)

# begin
#   puts icm_client.users.post(
#          :name => 'Craig Smith',
#          :email => 'craig.smith@acme.com')
# rescue => e
#   p e
#   p e.response
# end

def getting_started_example(icm_client)
  puts "Creating user"
  begin
    user = JSON.parse(
      icm_client.users.post(
      :name => 'Craig Smith',
      :email => 'craig.smith@acme.com'))
    puts JSON.pretty_generate(user)
    
    puts "Creating distribution list"
    list = JSON.parse(
      icm_client.distribution_lists.post(
      :name => 'To Just Craig Smith'))
    puts JSON.pretty_generate(list)
    
    puts "Subscribing user"
    sub = JSON.parse(
      icm_client.users(user['id']).subscriptions.
      post(:distributionListId => list['id']))
    puts JSON.pretty_generate(sub)
    
    puts "Registering user device"
    reg = JSON.parse(
      icm_client.users(user['id']).devices.post(
        :type => "Android",
        :name => "Android Nexus Fire 2",
        :deviceIdentifier => "APA91bFpOikKATC523g5Z_4-1puPNa_oE8t1sTzEwlfWKE0jFH-TvjAmFL_1ZkSCq7VGNA6dGn3jDQ5BsdZAf"))
    puts JSON.pretty_generate(reg)
    
    puts "Creating confirmation request"
    conf_req = JSON.parse(
      icm_client.confirmation_requests.post(
        :name => "Are you there?",
        :options => ["Yes", "No"]))
    puts JSON.pretty_generate(conf_req)

    puts "Creating message template"
    template = JSON.parse(
      icm_client.message_templates.post(
        :name => "For Craig Smith Only",
        :subject => "Hello Craig. Are you there?",
        :body => "Please confirm you are present.",
        :confirmationRequestId => conf_req['id'],
        :distributionListIds => [list['id']]))

    puts "Sending notification"
    sent = JSON.parse(
      icm_client.notifications.post(
        :messageTemplateId => template['id']))
    puts JSON.pretty_generate(sent)

    puts "Cleaning up..."
    
    puts icm_client.message_templates(template['id']).delete;
    puts icm_client.confirmation_requests(conf_req['id']).delete;
    puts icm_client.distribution_lists(list['id']).delete;
    puts icm_client.users(user['id']).delete;
  rescue => e
    p e
  end
end

getting_started_example icm_client

