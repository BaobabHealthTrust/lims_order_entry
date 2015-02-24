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

    status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:id]}"

    status = RestClient.get(status_link)


    if status.strip.upcase == "REJECTED"
     flash[:error] = "Sample with ID #{params[:id]} was rejected and cannot be processed further!"
    elsif status.strip.upcase == "RECEIVED AT RECEPTION"
     flash[:notice] = "Sample with ID #{params[:id]} already received!"
    elsif status.strip.upcase == "DRAWN"

     link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}"

     tests = RestClient.get(link)

     list = JSON.parse(tests).keys.first.split("|") rescue nil

     if list.blank?

      flash[:error] = "ERROR: Test or specimen details extracting failed!"

      redirect_to "/search_for_samples?target=receive_samples" and return

     end

     parameters = {
       :id => params[:id].strip,
       :test => list[0],
       :state => "Received At Reception",
       :specimen => list[2],
       :location => "Reception"
     }

     save_state(parameters)

     flash[:notice] = "Sample with ID #{params[:id]} recorded as received!"

    end

    redirect_to "/search_for_samples?target=receive_samples" and return

  end

  def enter_results

    @sample = params[:id]

    @dept = params[:location]

    tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}")

    @list = JSON.parse(tests)

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

   status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:id]}"

   status = RestClient.get(status_link)

   if status.strip.upcase == "REJECTED"
    flash[:error] = "Sample with ID #{params[:id]} was rejected and cannot be processed further!"
   elsif status.strip.upcase == "DISPOSED"
    flash[:error] = "Sample with ID #{params[:id]} was disposed and cannot be processed further!"
   else

    dept = params[:location].split(":")[0].strip rescue "undefined"

    tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}")

    list = JSON.parse(tests).keys.first.split("|") rescue nil

    if list.nil?

     flash[:error] = "ERROR: Test or specimen details extracting failed!"

     redirect_to "/search_for_samples?target=process_sample" and return

    end

    state = (status.strip.upcase == "RECEIVED AT RECEPTION" ? "Received in department" : "Testing")

    parameters = {
      :id => params[:id].strip,
      :test => list[0],
      :state => state,
      :specimen => list[2],
      :location => "#{dept.strip.upcase.gsub(/\_/, " ").titleize}"
    }

    save_state(parameters)

    flash[:notice] = "Sample with ID #{params[:id]} recorded as being processed in #{dept}!"

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

   status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:id]}"

   status = RestClient.get(status_link)

   if status.strip.upcase == "REJECTED"
    flash[:error] = "Sample with ID #{params[:id]} was already registered as rejected"
   elsif status.strip.upcase == "DRAWN"
    flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"
   else
    dept = params[:location].split(":")[0].strip rescue "undefined"
    tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}")

    list = JSON.parse(tests).keys.first.split("|") rescue nil

    if list.nil?

     flash[:error] = "ERROR: Test or specimen details extracting failed!"

     redirect_to "/search_for_samples?target=rejection_reason" and return

    end

    parameters = {
      :id => params[:id].strip,
      :test => list[0],
      :state => "Rejected",
      :specimen => list[2],
      :location => "#{dept.strip.upcase.gsub(/\_/, " ").titleize}"
    }

    save_state(parameters)

    flash[:notice] = "Sample with ID #{params[:id]} recorded as rejected in #{dept}!"

   end

    redirect_to "/search_for_samples?target=rejection_reason" and return

  end

  def dispose_sample

   status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:id]}"

   status = RestClient.get(status_link)

   if status.strip.upcase == "DISPOSED"
    flash[:notice] = "Sample with ID #{params[:id]} already disposed!"
   elsif status.strip.upcase == "DRAWN"
    flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"
   else
    dept = params[:location].split(":")[0].strip rescue "undefined"
    tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}")

    list = JSON.parse(tests).keys.first.split("|") rescue nil

    if list.nil?

     flash[:error] = "ERROR: Test or specimen details extracting failed!"

     redirect_to "/search_for_samples?target=rejection_reason" and return

    end

    parameters = {
      :id => params[:id].strip,
      :test => list[0],
      :state => "Disposed",
      :specimen => list[2],
      :location => "#{dept.strip.upcase.gsub(/\_/, " ").titleize}"
    }

    save_state(parameters)

    flash[:notice] = "Sample with ID #{params[:id]} recorded as disposed in #{dept}!"

   end

    redirect_to "/search_for_samples?target=dispose_sample" and return

  end

  def save_result

    patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["patient_by_acc_num_path"]}#{params[:id]}")).first

    # create a message
    msg = HL7::Message.new

    # create a MSH segment for our new message
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = "^~\&"
    msh.sending_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.recv_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.time = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.message_type = "ORU^R01^ORU_R01"
    msh.message_control_id = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.processing_id = "T"
    msh.version_id = "2.5.1"

    msg << msh # add the MSH segment to the message

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = patient["surrogateId"] rescue nil
    pid.patient_name = "#{patient["name"] rescue nil}"
    pid.patient_dob = patient["dob"].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = patient["sex"] rescue nil

    msg << pid # add the PID segment to the message

    pv1 = HL7::Message::Segment::PV1.new

    msg << pv1 # add the PV1 segment to the message

    orc = HL7::Message::Segment::ORC.new
    orc.entered_by = "1^Super^User"
    orc.enterers_location = "^^^^^^^^#{params[:location]}"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tq1 = HL7::Message::Segment::TQ1.new
    tq1.set_id = "1"
    tq1.priority = "R^Routine^HL70485"

    msg << tq1 # add the TQ1 segment to the message

    obr = HL7::Message::Segment::OBR.new
    obr.set_id = "1"
    obr.universal_service_id = "#{params[:test] rescue nil}^#{params[:test] rescue nil}^LOINC"
    obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obr.relevant_clinical_info = "Rule out diagnosis"
    obr.ordering_provider = "439234^Moyo^Chris"
    obr.result_status = "Tested"

    msg << obr # add the OBR segment to the message

    obx = HL7::Message::Segment::OBX.new
    obx.set_id = "1"
    obx.value_type = "CE"
    obx.observation_id = "#{params[:test_id]}^#{params[:test]}^ISO"
    obx.observation_value = "^#{params[:result]}"
    obx.units = "#{nil}"
    obx.references_range = "#{nil}"
    obx.observation_result_status = "F"
    obx.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obx.responsible_observer = "439234^Moyo^Chris"
    obx.analysis_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obx.performing_organization_name = "KCH Laboratory"
    obx.performing_organization_address = "^^Lilongwe^^^Malawi"
    obx.performing_organization_medical_director = "Limula^Henry"

    msg << obx # add the OBR segment to the message

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:id]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen] rescue nil}"

    msg << spm # add the SPM segment to the message

    # raise msg.to_s.inspect

    result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["test_result_path"]}", {:hl7 => msg.to_s})

    # raise result.inspect

    flash[:notice] = "Result saved!"

    redirect_to "/search_for_samples?target=enter_results" and return

  end

  def save_state(params)

    patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                            "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["patient_by_acc_num_path"]}#{params[:id]}")).first

    # create a message
    msg = HL7::Message.new

    # create a MSH segment for our new message
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = "^~\&"
    msh.sending_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.recv_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.time = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.message_type = "ORU^R01^ORU_R01"
    msh.message_control_id = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.processing_id = "T"
    msh.version_id = "2.5.1"

    msg << msh # add the MSH segment to the message

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = patient["surrogateId"] rescue nil
    pid.patient_name = "#{patient["name"] rescue nil}"
    pid.patient_dob = patient["dob"].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = patient["sex"] rescue nil

    msg << pid # add the PID segment to the message

    pv1 = HL7::Message::Segment::PV1.new

    msg << pv1 # add the PV1 segment to the message

    orc = HL7::Message::Segment::ORC.new
    orc.entered_by = "1^Super^User"
    orc.enterers_location = "^^^^^^^^MEDICINE"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tq1 = HL7::Message::Segment::TQ1.new
    tq1.set_id = "1"
    tq1.priority = "R^Routine^HL70485"

    msg << tq1 # add the TQ1 segment to the message

    obr = HL7::Message::Segment::OBR.new
    obr.set_id = "1"
    obr.universal_service_id = "#{params[:test] rescue nil}^#{params[:test] rescue nil}^LOINC"
    obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obr.relevant_clinical_info = "Rule out diagnosis"
    obr.ordering_provider = "439234^Moyo^Chris"
    obr.result_status = "#{params[:state]}"

    msg << obr # add the OBR segment to the message

    obx = HL7::Message::Segment::OBX.new
    obx.set_id = "#{nil}"
    obx.value_type = "#{nil}"
    obx.observation_id = "#{nil}"
    obx.observation_value = "#{nil}"
    obx.units = "#{nil}"
    obx.references_range = "#{nil}"
    obx.observation_result_status = "#{nil}"
    obx.observation_date = "#{nil}"
    obx.responsible_observer = "#{nil}"
    obx.analysis_date = "#{nil}"
    obx.performing_organization_name = "#{nil}"
    obx.performing_organization_address = "#{nil}"
    obx.performing_organization_medical_director = "#{nil}"

    msg << obx # add the OBR segment to the message

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:id]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen] rescue nil}"

    msg << spm # add the SPM segment to the message

    # raise msg.to_s.inspect

    result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["test_result_path"]}", {:hl7 => msg.to_s})

    # raise result.inspect

  end

end
