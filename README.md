# DEPRECATION NOTICE

This library is now deprecated and no longer maintained. We recommend using a popular and active Ruby HTTP client such as [rest-client](https://github.com/rest-client/rest-client).

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
require 'icm_ruby_client'
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

The MIT License (MIT)

Copyright (c) 2015 Singlewire LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
