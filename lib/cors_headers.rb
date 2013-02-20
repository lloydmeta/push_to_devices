#encoding: utf-8
module CorsHelpers
  private
  def cors_headers
    headers 'Access-Control-Allow-Origin' => request.env['HTTP_ORIGIN'],
              'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
              'Access-Control-Allow-Headers' => %w{accept timestamp origin x-csrf-token server-client-id mobile-client-id client-sig Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(","),
              'Access-Control-Max-Age' => (60 * 60 * 6).to_s,
              'Access-Control-Allow-Credentials' => "false"
  end
end