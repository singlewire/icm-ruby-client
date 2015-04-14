require 'icm_client'
require 'rspec'
require 'webmock/rspec'
require 'json'

USER = {:createdAt => '2015-01-12T16:52:47.614+0000',
        :email => 'a@aol.com',
        :id => '6fd989e0-9a7b-11e4-a6d1-c22f013130a9',
        :locations => [],
        :lock => nil,
        :name => 'a',
        :permissions => %w(delete put get),
        :securityGroups => [],
        :subscriptions => []}.freeze

describe ICMClient::Client, '#new' do
  before(:each) do
    @client = ICMClient::Client.new('my_access_token')
  end

  it 'Access token must be provided or an exception will be thrown' do
    expect { ICMClient::Client.new(nil) }.to raise_error ArgumentError
  end

  it 'Should have the proper set of readers and methods assigned' do
    expect(@client).to be_an_instance_of ICMClient::Client
    expect(@client.access_token).to eq 'my_access_token'
    expect(@client.base_url).to eq 'https://api.icmobile.singlewire.com/api/v1-DEV'
    expect(@client.path).to be_nil
  end
end

describe ICMClient::Client, '#method_missing' do
  before(:each) do
    @client = ICMClient::Client.new('my_access_token')
  end

  it 'Should generate the proper url for first missing method' do
    expect(@client.users.path).to eq '/users'
    expect(@client.message_templates.path).to eq '/message-templates'
    expect(@client.distribution_lists.path).to eq '/distribution-lists'
  end

  it 'Should generate the proper url for nested missing methods' do
    expect { @client.users('first_arg', 'second_arg') }.to raise_error ArgumentError
    expect(@client.users('user_id').subscriptions.path).to eq '/users/user_id/subscriptions'
    expect(@client.message_templates('message_template_id').audio.path).to eq '/message-templates/message_template_id/audio'
    expect(@client.distribution_lists('distribution_list_id').user_subscriptions.path).to eq '/distribution-lists/distribution_list_id/user-subscriptions'
  end
end

describe ICMClient::Client, '#get' do
  before(:each) do
    @client = ICMClient::Client.new('my_access_token')
  end

  it "Raises an exception when the user can't be found" do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users/user-id').
        to_return(:status => 404, :body => '{"status": 404,"message": "Not Found"}')
    expect { @client.users('user-id').get }.to raise_error RestClient::ResourceNotFound
  end

  it 'Raises an exception when we receive an unauthorized response' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users/user-id').
        to_return(:status => 401, :body => '{"type": "unauthorized","status": 401,"message": "Unauthorized"}')
    expect { @client.users('user-id').get }.to raise_error RestClient::Unauthorized
  end

  it 'Can get data for an individual user' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users/user-id').
        to_return(:body => JSON.dump(USER), :status => 200)
    user = JSON.parse(@client.users('user-id').get, :symbolize_names => true)
    expect(user).to eq USER
  end
end

describe ICMClient::Client, '#list' do
  before(:each) do
    @client = ICMClient::Client.new('my_access_token')
  end

  it 'Raises an exception when we receive an unauthorized response' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=100').
        to_return(:status => 401, :body => '{"type": "unauthorized","status": 401,"message": "Unauthorized"}')
    expect { @client.users.list.first }.to raise_error RestClient::Unauthorized
  end

  it 'Can get an empty page of data' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=100').
        to_return(:status => 200, :body => JSON.dump({:total => 0, :next => nil, :previous => nil, :data => []}))
    users = @client.users.list.to_a
    expect(users).to be_empty
  end

  it 'Can get a full page of data' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=100').
        to_return(:status => 200, :body => JSON.dump({:total => 1, :next => nil, :previous => nil, :data => [USER]}))
    users = @client.users.list.to_a
    expect(users.count).to eq 1
    expect(users[0]).to eq USER
  end

  it 'Can get multiple pages of data' do
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=1').
        to_return(:status => 200, :body => JSON.dump({:total => 3, :next => 'first', :previous => nil, :data => [USER]}))
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=1&start=first').
        to_return(:status => 200, :body => JSON.dump({:total => 3, :next => 'second', :previous => 'first', :data => [USER]}))
    stub_request(:get, 'https://api.icmobile.singlewire.com/api/v1-DEV/users?limit=1&start=second').
        to_return(:status => 200, :body => JSON.dump({:total => 3, :next => nil, :previous => 'second', :data => [USER]}))
    users = @client.users.list(:params => {:limit => 1}).to_a
    expect(users.count).to eq 3
    users.each do |user|
      expect(user).to eq USER
    end
  end

  describe ICMClient::Client, '#post' do
    before(:each) do
      @client = ICMClient::Client.new('my_access_token')
    end

    it 'Raises an exception when we receive an unauthorized response' do
      stub_request(:post, 'https://api.icmobile.singlewire.com/api/v1-DEV/users').
          with(:body => {:name => 'Craig Smith', :email => 'craig.smith@acme.com'}).
          to_return(:status => 401, :body => '{"type": "unauthorized","status": 401,"message": "Unauthorized"}')
      expect { @client.users.post(:name => 'Craig Smith', :email => 'craig.smith@acme.com') }.to raise_error RestClient::Unauthorized
    end

    it 'Creates a new user with the correct data' do
      stub_request(:post, 'https://api.icmobile.singlewire.com/api/v1-DEV/users').
          with(:body => {:email => 'a@aol.com', :name => 'a'}).
          to_return(:status => 200, :body => JSON.dump(USER))
      created_user = JSON.parse(@client.users.post(:name => 'a', :email => 'a@aol.com'), :symbolize_names => true)
      expect(created_user).to eq USER
    end
  end

  describe ICMClient::Client, '#put' do
    before(:each) do
      @client = ICMClient::Client.new('my_access_token')
    end

    it 'Raises an exception when we receive an unauthorized response' do
      stub_request(:put, 'https://api.icmobile.singlewire.com/api/v1-DEV/users/user-id').
          with(:body => {:email => 'craig.smith@acme.com'}).
          to_return(:status => 401, :body => '{"type": "unauthorized","status": 401,"message": "Unauthorized"}')
      expect { @client.users('user-id').put(:email => 'craig.smith@acme.com') }.to raise_error RestClient::Unauthorized
    end

    it 'Creates a new user with the correct data' do
      temp_user = USER.dup
      temp_user[:name] = 'a2'
      stub_request(:put, 'https://api.icmobile.singlewire.com/api/v1-DEV/users/user-id').
          with(:body => {:name => 'a2'}).
          to_return(:status => 200, :body => JSON.dump(temp_user))
      created_user = JSON.parse(@client.users('user-id').put(:name => 'a2'), :symbolize_names => true)
      expect(created_user).to eq temp_user
    end
  end
end

