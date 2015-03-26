class RemoteSessionsController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, :except => ['remote_login']

  def authenticate

    if session[:user_token].blank?
      redirect_to "/remote_login" and return
    else
      auth_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["order_server_login_check"]}?token=" + session[:user_token] + "&username=" + session[:user]
   
      auth_status = JSON.parse(RestClient.get(auth_link))
      
      if auth_status[0].to_s == "true"
        return true
      else
        redirect_to "/remote_login" and return
      end
    end
  end
  
  def remote_login  	
  	if request.post?
  	  login_link = "#{CONFIG["order_transport_protocol"]}://#{params[:username]}:#{params[:password]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["order_server_login"]}"

      remote_status = JSON.parse(RestClient.get(login_link))

      if (remote_status.match(/error/i) rescue false)
        flash[:error] = remote_status.gsub("Error: ", "")
      else
        session[:user_token] = remote_status['token']
        session[:user] = remote_status['username']
        session[:user_person_names] = [remote_status['name']]  
                
        redirect_to "/lab_processing/index" and return
      end
  	end
  	
  	render :layout => "lab"  	  
  end

  def remote_logout
    logout_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["order_server_logout"]}username=" + session[:user]
    
    logout_status = JSON.parse(RestClient.get(logout_link))
	
    if (logout_status[0] rescue false)
      session[:user_token] = nil
      session[:user] = nil
      session[:user_person_name] = nil
      flash[:notice] = "You have been logged out!"      
    else
      flash[:notice] = "Remote logout failed!"      
    end
    redirect_to "/remote_login" and return
  end
end
