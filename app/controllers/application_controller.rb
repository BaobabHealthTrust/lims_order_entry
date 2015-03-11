class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, :except => ['login']
  def authenticate

   if session[:user_token].blank?
    redirect_to "/login" and return
   else
    auth_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_authenticate"]}"
    auth_status = RestClient.post(auth_link, {"token" => session[:user_token]})

    if auth_status == "true"
     return true
    else
     redirect_to "/login" and return
    end
   end
  end

end
