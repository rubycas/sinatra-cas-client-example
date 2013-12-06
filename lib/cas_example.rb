require 'sinatra/base'
require 'cas_helpers'

class CasExample < Sinatra::Base
  use Rack::Session::Cookie, :secret => 'changeme' #using session cookies in production with CAS is NOT recommended

  helpers CasHelpers

  before do
    process_cas_login(request, session)
  end

  get "/" do
    "root"
  end

  get "/protected" do
    require_authorization(request, session) unless logged_in?(request, session)

    "you are logged in as #{session}"
  end
end
