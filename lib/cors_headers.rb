#encoding: utf-8
module CorsHelpers
  private
  def cors_headers
    response.headers['Access-Control-Allow-Origin'] = "*"
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = %w{accept timestamp origin x-csrf-token server-client-id mobile-client-id client-sig Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(","),
    response.headers['Access-Control-Max-Age'] = (60 * 60 * 6).to_s
    response.headers['Access-Control-Allow-Credentials'] = 'false'
  end
end