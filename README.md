# InformaCast Mobile REST Ruby Client

A simple, easy to use REST client based on [rest-client](https://github.com/rest-client/rest-client)

## Installation

Installation should be straight forward:

```shell
gem install icm-ruby-client
```

## Usage

Require the client:

```ruby
require 'icm_client'
```

Create an instance of the client:

```ruby
icm_client = ICMClient::Client.new('<My Access Token>')
```

Have fun!

```ruby
# Get first page of users
icm_client.users.get

# Paginate through all users
icm_client.users.list.each do |user|
    puts user
end

# Search for a user named Jim
icm_client.users.get(:params => {:limit => 10, :q => 'Jim'})

# Get a specific user
icm_client.users('de7b51a0-5a1e-11e4-ab31-8a1d033dd637').get

# Get a specific user's devices
icm_client.users('de7b51a0-5a1e-11e4-ab31-8a1d033dd637').devices.get

# Create a user
user = JSON.parse(icm_client.users.post(:name => 'Jim Bob', :email => 'jim.bob@aol.com'))

# Update the created user
icm_client.users(user['id']).put(:name => 'Jim Bob The Second')

# Delete the updated user
icm_client.users(user['id']).delete
```

## License

TODO