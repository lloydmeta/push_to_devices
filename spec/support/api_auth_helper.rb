module ApiAuthHelper
  def server_api_auth_params(client_id, client_secret, format = :json)
    timestamp_s = Time.now.to_i.to_s
    {server_client_id: client_id, client_sig: api_client_sig(client_secret, timestamp_s), timestamp: timestamp_s}
  end

  def mobile_api_auth_params(client_id, client_secret, format = :json)
    timestamp_s = Time.now.to_i.to_s
    {mobile_client_id: client_id, client_sig: api_client_sig(client_secret, timestamp_s), timestamp: timestamp_s}
  end

  def credentials_to_headers(params)
    params.reduce({}) { |headerized_params, (k,v)|
      headerized_params.merge({k.to_s.dasherize => v})
    }.merge({accept: 'application/json'})
  end

  def api_client_sig(client_secret, timestamp_s)
    OpenSSL::HMAC.hexdigest 'sha1', client_secret, timestamp_s.to_s
  end
end