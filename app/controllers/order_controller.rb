class OrderController < ApplicationController

  before_filter :set_connection, :only => [:search_by_name_and_gender, :search_by_name_and_dob]

  def index
  end

  def search
    @cat = params["target"] rescue nil
  end

  def place_order
  end

  def review_results
  end

  def print_results
  end

  def print_order
  end

  def search_by_name_and_gender

    query = @client.call(:get_patient_by_name, :message => { :firstname => params[:first_name].strip,
                                                             :lastname => params[:last_name].strip,
                                                             :gender => params[:gender].strip }) rescue nil


    render :text => query

  end

  def search_by_name_and_dob



  end

  protected

  def set_connection

    @client = Savon::Client.new(wsdl: "http://#{CONFIG[:wsdl_server]}:#{CONFIG[:wsdl_port]}/demographics/wsdl")

  end

end
