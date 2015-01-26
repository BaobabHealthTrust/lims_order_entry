class OrderController < ApplicationController

  before_filter :set_connection, :only => [:search_by_name_and_gender, :search_by_name_and_dob, :search_by_npid]

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

    query = @request.get_patient_by_name(params[:firstname], params[:lastname], params[:gender]) rescue nil

    render :text => query.to_json

  end

  def search_by_name_and_dob

    query = @request.get_patient_by_name_and_dob(params[:firstname], params[:lastname], params[:gender], params[:birthdate]) rescue nil

    render :text => query.to_json

  end

  def search_by_npid

    query = @request.get_patient_by_npid(params[:id])

    render :text => query.to_json

  end

  protected

  def set_connection

    @request = SoapService.new

  end

end
