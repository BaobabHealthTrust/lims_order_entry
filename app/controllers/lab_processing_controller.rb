class LabProcessingController < ApplicationController

  def index

    render :layout => "lab"

  end

  def capture_location

    render :layout => "lab"

  end

  def set_location

    file = "#{Rails.root}/config/workstations.yml"

    if File.exists?(file)

      locations = YAML.load_file("#{Rails.root}/config/workstations.yml") rescue {}

      locations[Rails.env][params["dept"].strip.gsub(/\s/, "_").downcase][params["device"].strip.gsub(/\s/, "_").downcase] = params["mac"].strip.gsub(/\_/, ".")

      hnd = File.open(file, "w")

      hnd.write(locations.to_yaml)

      hnd.close

    end

    redirect_to "/lab_processing/index" and return

  end

  def receive_samples

    result = {}

    file = "#{Rails.root}/config/samples.yml"

    if File.exists?(file)

      result = YAML.load_file(file) rescue {}

      if (!result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and !result[Rails.env][params[:id].strip]["rejection_reason"].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was rejected and cannot be processed further!"

      elsif !result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank?

        flash[:notice] = "Sample with ID #{params[:id]} already received!"

      else

        result = {} if result.blank?

        result[Rails.env] = {} if result[Rails.env].blank?

        result[Rails.env][params[:id].strip] = {
            "received_at_reception" => Time.now.strftime("%Y%m%d%H%M%S"),
            "state" => "RECEIVED AT RECEPTION"
        }

        hnd = File.open(file, "w")

        hnd.write(result.to_yaml)

        hnd.close

        flash[:notice] = "Sample with ID #{params[:id]} recorded as received!"

      end

    end

    redirect_to "/search_for_samples?target=receive_samples" and return

  end

  def enter_results

    render :layout => "lab"

  end

  def verify_results

    render :layout => "lab"

  end

  def dispose_samples

    render :layout => "lab"

  end

  # Check if device location is set
  def check_location

    result = ""

    target = params[:id].gsub(/\_/, ".") rescue ""

    file = "#{Rails.root}/config/workstations.yml"

    if File.exists?(file) and !target.blank?

      locations = YAML.load_file("#{Rails.root}/config/workstations.yml")[Rails.env] rescue {}

      locations.each do |dept, benches|

        benches.each do |bench, mac|

          if !mac.blank? and mac.strip.downcase == target.strip.downcase

            result = "#{dept.gsub(/\_/, " ").titleize}:#{bench.strip}"

            break

          end

        end

      end

    end

    render :text => result

  end

  def list_locations

    result = {}

    file = "#{Rails.root}/config/workstations.yml"

    if File.exists?(file)

      result = YAML.load_file("#{Rails.root}/config/workstations.yml")[Rails.env] rescue {}

    end

    render :text => result.to_json

  end

  def search_for_samples

    @target = "/#{params["target"] rescue "/lab_processing/index"}/"

    render :layout => "lab"

  end

  def sample_status


  end

  def process_sample

    result = {}

    file = "#{Rails.root}/config/samples.yml"

    if File.exists?(file)

      result = YAML.load_file(file) rescue {}

      dept = params[:location].split(":")[0].strip rescue "undefined"

      if (!result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and !result[Rails.env][params[:id].strip]["rejection_reason"].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was rejected and cannot be processed further!"

      elsif !result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and
          !result[Rails.env][params[:id].strip]["processing_started_in_#{dept.strip.downcase.gsub(/\s/, "_")}"].blank?

        flash[:notice] = "Sample with ID #{params[:id]} already being processed in this section!"

      elsif (result.blank?) or (!result.blank? and result[Rails.env].blank?) or (!result.blank? and !result[Rails.env].blank? and result[Rails.env][params[:id].strip].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"

      else

        result = {} if result.blank?

        result[Rails.env] = {} if result[Rails.env].blank?

        result[Rails.env][params[:id].strip]["processing_started_in_#{dept.strip.downcase.gsub(/\s/, "_")}"] = Time.now.strftime("%Y%m%d%H%M%S")
        result[Rails.env][params[:id].strip]["state"] = "SAMPLE PROCESSING STARTED IN #{dept.strip.upcase.gsub(/\_/, " ")}"

        hnd = File.open(file, "w")

        hnd.write(result.to_yaml)

        hnd.close

        flash[:notice] = "Sample with ID #{params[:id]} recorded as being processed in #{dept}!"

      end

    end

    redirect_to "/search_for_samples?target=process_sample" and return

  end

  def list_rejection_reasons

    reasons = ["Insufficient Quantity", "Bad Sample", "Expired Sample", "Wrong Container", "Wrong Sample", "Patient Died"]

    render :text => reasons.to_json

  end

  def rejection_reason

    @sample = params[:id]

    @dept = params[:location]

    render :layout => "lab"

  end

  def reject_sample

    result = {}

    file = "#{Rails.root}/config/samples.yml"

    if File.exists?(file)

      result = YAML.load_file(file) rescue {}

      dept = params[:location].split(":")[0].strip rescue "undefined"


      if (!result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and !result[Rails.env][params[:id].strip]["rejection_reason"].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was rejected and cannot be processed further!"

      elsif !result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and
          !result[Rails.env][params[:id].strip]["sample_rejected_in_#{dept.strip.downcase.gsub(/\s/, "_")}"].blank?

        flash[:notice] = "Sample with ID #{params[:id]} already rejected in this section!"

      elsif (result.blank?) or (!result.blank? and result[Rails.env].blank?) or (!result.blank? and !result[Rails.env].blank? and result[Rails.env][params[:id].strip].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"

      else

        result = {} if result.blank?

        result[Rails.env] = {} if result[Rails.env].blank?

        result[Rails.env][params[:id].strip]["rejection_reason"] = params[:reason]
        result[Rails.env][params[:id].strip]["sample_rejected_in_#{dept.strip.downcase.gsub(/\s/, "_")}"] = Time.now.strftime("%Y%m%d%H%M%S")
        result[Rails.env][params[:id].strip]["state"] = "SAMPLE REJECTED IN #{dept.strip.upcase.gsub(/\_/, " ")}"

        hnd = File.open(file, "w")

        hnd.write(result.to_yaml)

        hnd.close

        flash[:notice] = "Sample with ID #{params[:id]} recorded as rejected in #{dept}!"

      end

    end

    redirect_to "/search_for_samples?target=rejection_reason" and return

  end

  def dispose_sample

    result = {}

    file = "#{Rails.root}/config/samples.yml"

    if File.exists?(file)

      result = YAML.load_file(file) rescue {}

      dept = params[:location].split(":")[0].strip rescue "undefined"

      if !result.blank? and !result[Rails.env].blank? and !result[Rails.env][params[:id].strip].blank? and
          !result[Rails.env][params[:id].strip]["sample_disposed_in_#{dept.strip.downcase.gsub(/\s/, "_")}"].blank?

        flash[:notice] = "Sample with ID #{params[:id]} already disposed in this section!"

      elsif (result.blank?) or (!result.blank? and result[Rails.env].blank?) or (!result.blank? and !result[Rails.env].blank? and result[Rails.env][params[:id].strip].blank?)

        flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"

      else

        result = {} if result.blank?

        result[Rails.env] = {} if result[Rails.env].blank?

        result[Rails.env][params[:id].strip]["sample_disposed_in_#{dept.strip.downcase.gsub(/\s/, "_")}"] = Time.now.strftime("%Y%m%d%H%M%S")
        result[Rails.env][params[:id].strip]["state"] = "SAMPLE DISPOSED IN #{dept.strip.upcase.gsub(/\_/, " ")}"

        hnd = File.open(file, "w")

        hnd.write(result.to_yaml)

        hnd.close

        flash[:notice] = "Sample with ID #{params[:id]} recorded as disposed in #{dept}!"

      end

    end

    redirect_to "/search_for_samples?target=dispose_sample" and return

  end

end
