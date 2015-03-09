class SessionsController < ApplicationController
  def login

   if request.post?
    login_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_login"]}"

    status = RestClient.post(login_link, {"username" => params[:username], "password" => params[:password]})

    if status.match(/error/i)
     flash[:error] = status.gsub("Error: ", "")
    else
     session[:user_token] = status
     session[:user] = params[:username]
     redirect_to "/enter_location" and return
    end
   end
   render :layout => "lab"
  end

  def logout
   login_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_logout"]}"
   logout_status = RestClient.post(login_link, {"token" => session[:user_token]})

   if logout_status
    session[:user_token] = nil
    session[:user] = nil
    flash[:notice] = "You have been logged out!"
    redirect_to "/login" and return
   else
   end
  end

  def enter_location
   if request.post?
    session[:location]= params[:location]
    redirect_to "/" and return
   end
     session[:location] = nil
   get_wards_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_wards"]}"
   @wards = JSON.parse(RestClient.get(get_wards_link))

  end

  def location
  end

end
