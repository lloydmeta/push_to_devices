require 'openssl'

module ApiAuth

    API_TIMESTAMP_TOLERANCE = 10.minutes

    def api_credentials
      @api_credentials || extract_api_credentials
    end

    def extract_api_credentials
      @api_credentials = {}
      @api_credentials[:server_client_id] = request.env["HTTP_SERVER_CLIENT_ID"] || request.env["server-client-id"]
      @api_credentials[:mobile_client_id] = request.env["HTTP_MOBILE_CLIENT_ID"] || request.env["mobile-client-id"]
      @api_credentials[:client_sig] = request.env["HTTP_CLIENT_SIG"] || request.env["client-sig"]
      @api_credentials[:timestamp] = request.env["HTTP_TIMESTAMP"] || request.env["timestamp"]
      @api_credentials
    end

    def api_current_user?(user)
      user == api_current_user
    end

    def api_current_user=(user)
      @api_current_user = user
    end

    def api_current_user
      if api_signed_in?
       @api_current_user
     else
        api_authenticate
        @api_current_user
      end
    end

    def api_authenticate
      if api_credentials[:server_client_id]
        client_id = api_credentials[:server_client_id]
        mobile_client = false
      else
        client_id = api_credentials[:mobile_client_id]
        mobile_client = true
      end
      timestamp = api_credentials[:timestamp]
      client_sig = api_credentials[:client_sig]
      # sanity check
      if [client_id, timestamp, client_sig].any?{|p| p.nil?}
        api_deny_access("api-auth-err-ensure-client-id-timestamp-client-sig-all-sent")
      elsif ! timestamp_valid?(timestamp)
        api_deny_access("api-auth-err-timestamp-invalid")
      elsif service = api_credentials_valid?(client_id, timestamp, client_sig, mobile_client)
        self.api_current_user = service
        service
      else
        api_deny_access
      end
    end

    def api_deny_access(message="api-auth-err-authentication-failed")
      Padrino::logger.info "API Auth failed: #{message}"
      content_type :json
      halt 403,  {error: message}.to_json
    end

    def api_signed_in?
      !@api_current_user.nil?
    end

    # simple method to find a service based on client_id
    def retrieve_by_client_id(client_id, mobile_client)
      if mobile_client
        client_credentials = Service.where(mobile_client_id: client_id).first
      else
        client_credentials = Service.where(server_client_id: client_id).first
      end
    end

    private

    def securerandom_string(n = 23)
      SecureRandom.urlsafe_base64(n, true)
    end

    # Checks to see if the credentials given are valid
    # Returns false if not valid
    # Returns the service if everything checks out
    def api_credentials_valid?(client_id, timestamp, given_signature, mobile_client)
      # Fetch the service and calculate the HMAC signature and compare
      # With what the client sent along
      service = retrieve_by_client_id(client_id, mobile_client)
      if service.present?
        if mobile_client
          client_secret = service.mobile_client_secret
        else
          client_secret = service.server_client_secret
        end
        calculated_signature = OpenSSL::HMAC.hexdigest 'sha1', client_secret, timestamp
        if calculated_signature == given_signature
          service
        else
          false
        end
      else
        false
      end
    end

    def timestamp_valid?(timestamp)
      (API_TIMESTAMP_TOLERANCE.ago.to_i .. API_TIMESTAMP_TOLERANCE.from_now.to_i).cover?(timestamp.to_i)
    end

end