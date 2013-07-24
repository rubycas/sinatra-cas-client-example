require 'active_support/all' #bug in rubycas client requires this
require 'rubycas-client'

module CasHelpers

  CAS_CLIENT = CASClient::Client.new(:cas_base_url => ENV['CAS_BASE_URL'], :log => Logger.new(STDOUT), :ticket_store_config => {:storage_dir => ENV['TICKET_STORE_DIR']})

  def need_authentication(request, session)
    if session[:cas_ticket]
      if request[:ticket] && session[:cas_ticket] != request[:ticket]
        true
      else
        false
      end
    else
      true
    end
  end

  def process_cas_login(request, session)
    if request[:ticket] && request[:ticket] != session[:cas_ticket]

      service_url = read_service_url(request)
      st = read_ticket(request[:ticket], service_url)

      CAS_CLIENT.validate_service_ticket(st)

      if st.success
        session[:cas_ticket] = st.ticket
        session[:cas_user] = st.user
      else
        raise "Service Ticket validation failed! #{st.failure_code} - #{st.failure_message}"
      end
    end

  end

  def logged_in?(request, session)
    session[:cas_ticket] && !session[:cas_ticket].empty?
  end

  def require_authorization(request, session)
    if !logged_in?(request, session)
      service_url = read_service_url(request)
      url = CAS_CLIENT.add_service_to_login_url(service_url)
      redirect url
    end
  end

  private
  def read_ticket(ticket_str, service_url)
    return nil unless ticket_str and !ticket_str.empty?

    if ticket_str =~ /^PT-/
      CASClient::ProxyTicket.new(ticket_str, service_url)
    else
      CASClient::ServiceTicket.new(ticket_str, service_url)
    end
  end

  def read_service_url(request)
    service_url = url(request.path_info)
    if request.GET
      params = request.GET.dup
      params.delete(:ticket)
      if params
        [service_url, Rack::Utils.build_nested_query(params)].join('?')
      end
    end
    return service_url
  end
end

