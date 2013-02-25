Push to Device
------------

[![Build
Status](https://secure.travis-ci.org/lloydmeta/push_to_devices.png)](http://travis-ci.org/lloydmeta/push_to_devices)

[![Code Climate](https://codeclimate.com/github/lloydmeta/push_to_devices.png)](https://codeclimate.com/github/lloydmeta/push_to_devices)

A REST-ful Padrino-based server for you to send push notifications to iOS and Android devices. There is a Ruby client library/gem [as well](https://github.com/lloydmeta/push_to_devices_rb).

This server will allow you to create Services (i.e. your application with production Apple PEM file and production GCM API keys) that you register users to and then send notifications to that service's users.

Out of the box, you can send notifications to users in 1, 5, 10, 15, 30 and 60 minute intervals, but this can be customised. It will also take care of pulling Apple APN feedback on a daily basis for you as well to make sure that devices to which notifications can no longer be pushed stop receiving notifications from you.

Gems used include:
* PushMeUp to take care of sending iOS and Android notifications. iOS notifications are sent in batches.
* Resque
* Resque-scheduler
* Redis

__Note__: For now, only Ruby 1.9.3 is supported and all payloads must be in JSON. Hope that isn't a problem for you !

__Note__: the POST /users/ endpoint by default supports CORs ([Cross Origin Resource Sharing](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing)) but can be modified to do without.

Basic Overview
------------

You must decide on a way to uniquely identify your users in your system. This can be something as simple as a user's id or something more sophisiticated such as `Digest::SHA2.hexdigest("#{app_name}::#{user_id}::#{user_created_at.to_s}")`. Your mileage may vary. The idea is that within your service that you register users using this unique hash and their device token (iOS device token and/or Android GCM registration id), and then from your application, your send notifications by posting to the Push to Device service by using the unique hash you used to register the user.

This server uses a very basic API key and secret authentication scheme (described later), and only supports JSON payloads.

Example Workflow
----------------

From your mobile application, register a user with this server by POSTing to `/users` in JSON with something like the following as a body payload:

```javascript
{
  "unique_hash": "user_1",
  "apn_device_token": "asdfasf", //actual device token
  "gcm_registration_id": "asdfdafsfads" //actual registration id from GCM
}

You can actually post both the APN and GCM at the same time if you've got both on hand
```

From your web application, POST to `/users/:unique_hash/notifications` to send notifications to your iOS and Android users based on the unique hash. The server will then push the notifications at a preset interval (explained later) to all the devices the user currently has registered with the service. The JSON payload should look like this:

```javascript
{
  "ios_specific_fields":{
    "alert": "An alert for you",
    "badge": 1
  },
  "android_specific_fields":{
    "data" : {
      "title": "Your app name",
      "text": "Alert alert!"
    },
    "options" : {
      "time_to_live": 3600 //seconds; by default we set this to 1 week
    }
  }
}
```

Authentication
-------------
Once you create your Service (see below), make sure you sign your calls to the Push to Devices server by setting the following headers in your requests

1. "server-client-id" or "mobile-client-id" from your Service details page in Padrino admin
2. "client-sig" SHA1 hexdigest of the client secret (from service) and the current Unix timestamp in seconds as a string
3. "timestamp" the same string used to sign the signature

Examples
--------
As much as I can go on talking about how to do stuff, a few good examples are probably the best so here we go.

Example of registering a user to the Push to Device server:

```ruby
require "net/http"
require "net/https"
require "cgi"

# Using mobile client credentials for this example, but server client
# credentials are used the same way, except the header is different
client_id = "my_mobile_client_id"
client_secret = "my_mobile_client_secret"

# Set up the HTTP connection
http = Net::HTTP.new(
    "push.myapp.com",
    80
)

# Building the request
request = Net::HTTP::Post.new("/users", initheader = {'Content-Type' =>'application/json'})
request.body = {
  "unique_hash": "user_1_20100305",
  "apn_device_token": "ghkajdlshg34k48qf", //actual device token, trust me
  "gcm_registration_id": "asdfdafsfads"
}

# Set headers on the request for authentication
timestamp_s = Time.now.to_i.to_s
client_sig = OpenSSL::HMAC.hexdigest 'sha1', client_secret, timestamp_s
client_credentials = {
  client_id: client_id,
  client_sig: client_sig,
  timestamp: timestamp_s
}
request["mobile-client-id"] = client_credentials[:client_id]
request["client-sig"] = client_credentials[:client_sig]
request["timestamp"] = client_credentials[:timestamp]

# Fire the package !
response = http.start {|http|
  http.request request
}

puts response
```

Example of sending a notification to a user based on the user's unique_hash
```ruby
require "net/http"
require "net/https"
require "cgi"

# Using server client credentials for this example
client_id = "my_server_client_id"
client_secret = "my_server_client_secret"

# Who to send the notification to
user_unique_hash = User.find(3).unique_hash

# Set up the HTTP connection
http = Net::HTTP.new(
    "push.myapp.com",
    80
)

# Building the request
request = Net::HTTP::Post.new("/users/#{user_unique_hash}/notifications", initheader = {'Content-Type' =>'application/json'})
request.body = {
  "ios_specific_fields" => {
    "alert" => "Your post got a new comment!",
    "badge" => 3
  },
  "android_specific_fields" => {
    "data" => {
      "title"=> "Your app name",
      "text"=> "Alert alert!"
    },
    "options" => {
      "time_to_live"=> 3600
    }
  }
}

# Set headers on the request for authentication
timestamp_s = Time.now.to_i.to_s
client_sig = OpenSSL::HMAC.hexdigest 'sha1', client_secret, timestamp_s
client_credentials = {
  client_id: client_id,
  client_sig: client_sig,
  timestamp: timestamp_s
}
request["server-client-id"] = client_credentials[:client_id]
request["client-sig"] = client_credentials[:client_sig]
request["timestamp"] = client_credentials[:timestamp]

# Fire the package !
response = http.start {|http|
  http.request request
}

puts response
```

For more examples, check out `support/api_auth_helper.rb` or the [Ruby library](https://github.com/lloydmeta/push_to_devices_rb)

Running the server
----------------

1. Deploy the server
2. `padrino rake resque:scheduler`
3. `padrino rake resque:work`
4. Run `padrino rake seed` to create an admin user
5. Log into Padrino admin (/admin/services/new) to create and configure a new service (filling in GCM api key __and__ uploading your [PEM file](https://github.com/NicosKaralis/pushmeup/wiki/APNS-iOS-and-OS-X))

## License

Copyright (c) 2013 by Lloyd Chan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, and to permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.