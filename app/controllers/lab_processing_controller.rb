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

      locations[Rails.env][params["dept"].strip.gsub(/\s/, "_").downcase][params["device"].strip.gsub(/\s/, "_").downcase] = params["mac"].strip

      hnd = File.open(file, "w")

      hnd.write(locations.to_yaml)

      hnd.close

    end

    redirect_to "/lab_processing/index" and return

  end

  def receive_samples

    render :layout => "lab"

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

    target = params[:id] rescue ""

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

end
