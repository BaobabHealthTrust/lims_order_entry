class SessionsController < ApplicationController

  def login

    if request.post?
      login_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_name"]}:#{CONFIG["user_management_password"]}@#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_login"]}"

      status = RestClient.post(login_link, {"username" => params[:username], "password" => params[:password]})

      if status.match(/error/i)
        flash[:error] = status.gsub("Error: ", "")
      else
        session[:user_token] = status
        session[:user] = params[:username]
        session[:user_person_names] = get_user_person_name(params[:username])
        redirect_to "/enter_location" and return
      end
    end

  end

  def logout
    login_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_name"]}:#{CONFIG["user_management_password"]}@#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_logout"]}"
    logout_status = RestClient.post(login_link, {"token" => session[:user_token]})

    if logout_status
      session[:user_token] = nil
      session[:user] = nil
      session[:user_person_name] = nil
      # flash[:notice] = "You have been logged out!"
      redirect_to "/login" and return
    else
    end
  end

  def enter_location
    if request.post?

      session[:location]= params[:location_name]
      redirect_to "/" and return
    end
    session[:location] = nil
    get_wards_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_name"]}:#{CONFIG["user_management_password"]}@#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_wards"]}"
    @wards = JSON.parse(RestClient.get(get_wards_link))


  end

  def location
  end

  def get_user_person_name(username)
    names_link = "#{CONFIG["user_management_protocol"]}://#{CONFIG["user_management_name"]}:#{CONFIG["user_management_password"]}@#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_names"]}"
    user_names = JSON.parse(RestClient.post(names_link, {"username" => username}))
    return user_names
  end

  def change_password

    @section = params[:section]

    if request.post?

      @username = session[:user]

      @current_password = params[:current_password]

      @new_password = params[:new_password]

      @repeat_password = params[:repeat_password]

      @username = session[:user]

      status = ""

      if @current_password.blank?
        flash[:error] = "Current password is blank"
        redirect_to "/change_password?section=#{@section}" and return
      elsif @new_password.blank?
        flash[:error] = "New password is blank!"
        redirect_to "/change_password?section=#{@section}" and return
      elsif @repeat_password.blank?
        flash[:error] = "Repeat password is blank!"
        redirect_to "/change_password?section=#{@section}" and return
      elsif @new_password.strip != @repeat_password.strip
        flash[:error] = "Repeat password mismatch!"
        redirect_to "/change_password?section=#{@section}" and return
      end

      paramz = {:username => @username, :new_password => @new_password, :repeated_password => @repeat_password}

      if @section.blank?
        login_link = "#{CONFIG["user_management_protocol"]}://#{@username}:#{@current_password}@#{CONFIG["user_management_server"]}:#{CONFIG["user_management_port"]}#{CONFIG["user_management_user_update_path"]}"
      else
        login_link = "#{CONFIG["order_transport_protocol"]}://#{@username}:#{@current_password}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["order_server_user_update_path"]}"
      end

      status = JSON.parse(RestClient.post(login_link, paramz)) rescue "Error: Failed to connect to server!"

      if (!status['ERROR'].blank? rescue false)
        status = status['ERROR']
        flash[:error] = status.gsub(/error\:/i, "")
      elsif (!status['MSG'].blank? rescue false)
        status = status['MSG']
        flash[:notice] = status.gsub(/msg\:/i, "")
      end

      if status.match(/error/i)
        flash[:error] = status.gsub(/msg\:|\error\:/i, "")
        redirect_to @section.blank? ? "/" : "/lab"
      else
        flash[:notice] = "Update successful"

        if @section.blank?
          redirect_to "/login" and return
        else
          redirect_to "/remote_login" and return
        end

      end
    end

    if !@section.blank? and @section.match(/lab/)

      render :layout => "lab"

    end

  end

end
