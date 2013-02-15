Push to Device
------------

A RESTful Padrino-based server for you to send push notifications to iOS and Android devices.

It uses the PushMeUp gem to do the pushing of notifications to Apple's APN and Google's GCM. The database used is MongoDB.

Basic Overview
------------

You must decide on a way to uniquely identify your users in your system. This can be something as simple as a user's id.

This server uses a very basic API key and secret authentication scheme (described later), and only supports JSON payloads.

From your mobile application, register a user with this server by POSTing to `/users` in JSON with the following:

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
    "title": "Your app name",
    "text": "Alert alert!"
  }
}
```

Authentication
-------------
Once you create your Service (see below), go ahead make sure you sign your calls to the server by setting the following headers in your requests

1. "server-client-id" from your service details
2. "client-sig" SHA1 hexdigest of the client secret (from service) and the current Unix timestamp in seconds as a string
3. "timestamp" the same string used to sign the signature

For an example, check out `support/api_auth_helper.rb`

Running the server
----------------

1. Deploy the server
2. `padrino rake resque:scheduler`
3. `padrino rake resque:work`
4. Run `padrino rake seed` to create an admin user
5. Log into admin (/admin) to create and configure a new service (filling in GCM api key, uploading your [PEM file](https://github.com/NicosKaralis/pushmeup/wiki/APNS-iOS-and-OS-X))

## License

Copyright (c) 2013 by Lloyd Chan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, and topermit persons to whom the Software is furnished to do so, subject to
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