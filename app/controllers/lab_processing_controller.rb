class LabProcessingController < RemoteSessionsController

  before_filter :check_device_location, :only => [:index, :search_for_samples, :check_sample_state, :enter_results,
                                                  :rejection_reason, :reject_sample]

  before_filter :set_connection, :only => [:check_sample_state, :enter_results]

  after_filter :unlock_specimen, :only => [:enter_results]

  def index

    redirect_to "/lab_processing/capture_location" and return if @location.empty?

    redirect_to "/search_for_samples?target=receive_samples" and return if @location[:dept].downcase.match(/reception/)

    @settings = YAML.load_file(Rails.root.join('config', 'application.yml'))

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

    elsif status.strip.upcase == "DRAWN" and !params[:sample_viablility].blank? and params[:sample_viablility].downcase == "viable"

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

      save_group_state(parameters)

      flash[:notice] = "Sample with ID #{params[:id]} recorded as received!"

    elsif status.strip.upcase == "DRAWN" and !params[:sample_viablility].blank? and params[:sample_viablility].downcase == "nonviable"

      link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:id]}"

      tests = RestClient.get(link)

      list = JSON.parse(tests).keys.first.split("|") rescue nil

      if list.blank?

        flash[:error] = "ERROR: Test or specimen details extracting failed!"

        redirect_to "/search_for_samples?target=receive_samples" and return

      end

      barcode = params[:id].strip

      test_name = CGI.escape(list[0])

      test_code = CGI.escape(list[3])

      specimen = CGI.escape(list[2])

      state = CGI.escape("Sample Rejected")

      redirect_to "/rejection_reason?barcode=#{barcode}&test_name=#{test_name}&test_code=#{test_code}&specimen=#{specimen}&state=#{state}" and return

    elsif status.strip.upcase == "DRAWN"

      # redirect_to "/sample_status?id=#{params[:id]}" and return

    end

    redirect_to "/search_for_samples?target=receive_samples" and return

  end

  def enter_results

    @test_name = params[:test_name]

    @test_code = params[:test_code]

    @barcode = params[:id]

    @dept = @location[:dept]

    tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                               "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}" +
                               "#{CONFIG["panel_info_path"].gsub(/<<LOINC_CODE>>/, @test_code).gsub(/<<ACCESSION_NUMBER>>/, @barcode)}")

    @list = JSON.parse(tests)

	@user_details = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                            "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["order_server_user_details"]}#{session[:user]}")) rescue []
                                           
    patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                            "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["patient_by_acc_num_path"]}#{params[:id]}")).first rescue []

    @patient = @request.get_patient_by_npid(patient["surrogateId"]).first rescue nil

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

    # arp -H ether 192.168.15.104 | awk 'FNR==2 {print $3}'

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

    status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
        "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["specimen_status_path"]}#{params[:barcode]}"

    status = RestClient.get(status_link).strip rescue "TEMPORARY SERVER ERROR"

    render :text => status.strip

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

      flash[:notice] = "Sample with ID #{params[:id]} recorded as #{(state.strip.downcase.match(/received/) ? "received" : "being processed")} in #{dept}!"

    end

    redirect_to "/lab/" and return

  end

  def list_rejection_reasons

    reasons = ["Insufficient Quantity", "Bad Sample", "Expired Sample", "Wrong Container", "Wrong Sample", "Patient Died", "Missing Sample"]

    render :text => reasons.to_json

  end

  def rejection_reason

    @barcode = params[:barcode]

    @test_name = params[:test_name]

    @test_code = params[:test_code]

    @specimen = params[:specimen]

    @state = params[:state]

    @dept = @location[:dept]

    render :layout => "lab"

  end

  def reject_sample

    if !params[:test_name].blank? and !params[:barcode].blank?

      status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
          "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["specimen_status_path"]}#{params[:barcode]}&test_name=#{params[:test_name].gsub(/\s/, "+")}"

    elsif !params[:barcode].blank?

      status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
          "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:barcode]}"

    else

      flash[:error] = "ERROR: Insufficient parameters!"

      redirect_to "/lab/" and return

    end

    status = RestClient.get(status_link)

    if status.strip.upcase.match(/REJECTED/)

      flash[:error] = "Sample with ID #{params[:id]} was already registered as rejected"

    elsif status.strip.upcase.match(/DRAWN/) and !@location[:dept].strip.downcase.match(/reception/)

      flash[:error] = "Sample with ID #{params[:id]} was not received at the reception first!"

    elsif params[:state].strip.upcase.match(/TEST/)

      dept = params[:location] rescue "undefined"

      parameters = {
          :id => params[:barcode].strip,
          :test_name => params[:test_name],
          :test_code => params[:test_code],
          :state => params[:state].titleize,
          :specimen => params[:specimen],
          :location => dept.strip
      }

      save_state(parameters)

      flash[:notice] = "Test #{params[:test_name]} with ID #{params[:id]} recorded as rejected in #{dept}!"

    else

      dept = @location[:dept] rescue "undefined"

      tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:barcode]}")

      list = JSON.parse(tests).keys.first.split("|") rescue nil

      if list.nil?

        flash[:error] = "ERROR: Test or specimen details extracting failed!"

        redirect_to "/lab/" and return

      end

      parameters = {
          :id => params[:barcode].strip,
          :test => list[0],
          :state => params[:state].titleize,
          :specimen => list[2],
          :location => "#{dept.strip.upcase.gsub(/\_/, " ").titleize}"
      }

      save_group_state(parameters)

      flash[:notice] = "Sample with ID #{params[:id]} recorded as rejected in #{dept}!"

    end

    redirect_to "/lab/" and return

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

     #raise params.inspect

    patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                            "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["patient_by_acc_num_path"]}#{params[:barcode]}")).first

    # raise params[:testtime].inspect

    # create a message
    msg = HL7::Message.new

    # create a MSH segment for our new message
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = "^~\&"
    msh.sending_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.recv_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.time = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") }"
    msh.message_type = "ORU^R01^ORU_R01"
    msh.message_control_id = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.processing_id = "T"
    msh.version_id = "2.5.1"

    msg << msh # add the MSH segment to the message

    name = patient["name"].split(" ")

    fname = name[0] rescue nil
    mname = (name.length > 2 ? name[1] : "")
    lname = (name.length > 2 ? name[2] : name[1])

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = patient["surrogateId"] rescue nil
    pid.patient_name = "#{lname}^#{fname}^#{mname}"
    pid.patient_dob = patient["dob"].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = patient["sex"] rescue nil

    msg << pid # add the PID segment to the message

    pv1 = HL7::Message::Segment::PV1.new

    msg << pv1 # add the PV1 segment to the message

    orc = HL7::Message::Segment::ORC.new

    username = session[:user].gsub(/\s+/, "_") rescue 1
    if session[:user_person_names].class.to_s.downcase != "hash"
    	usernames = session[:user_person_names]
    else
    	f_name = session[:user_person_names]['first_name'] rescue "Unknown"
    	l_name = session[:user_person_names]['last_name'] rescue "Unknown"
    	usernames = "#{f_name} #{l_name}"
    end
    
    r = usernames.split(/\s+/)

    orc.entered_by = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
    orc.enterers_location = "^^^^^^^^#{params[:location]}"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    finished = true

    params[:test_result].each do |code, result|

      if result.blank?

        finished = false

        next

      end

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = "1"
      tq1.priority = "R^Routine^HL70485"

      msg << tq1 # add the TQ1 segment to the message

      obr = HL7::Message::Segment::OBR.new
      obr.set_id = "1"
      obr.universal_service_id = "#{code rescue nil}^#{params[:test_name][code] rescue nil}^LOINC"
      obr.observation_date = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") rescue Time.now.strftime("%Y%m%d%H%M%S")}"
      obr.relevant_clinical_info = "Rule out diagnosis"
      obr.ordering_provider = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
      # obr.result_status = "Tested"

      msg << obr # add the OBR segment to the message

      obx = HL7::Message::Segment::OBX.new
      obx.set_id = "1"
      obx.value_type = "CE"
      obx.observation_id = "#{code rescue nil}^#{params[:test_name][code]}^ISO"
      obx.observation_value = "^#{result}"
      obx.units = "#{params[:test_units][code]}"
      obx.references_range = "#{params[:test_range][code]}"
      obx.observation_result_status = "F"
      obx.observation_date = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") rescue Time.now.strftime("%Y%m%d%H%M%S")}"
      obx.responsible_observer = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
      obx.analysis_date = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") rescue Time.now.strftime("%Y%m%d%H%M%S")}"
      obx.performing_organization_name = "KCH Laboratory"
      obx.performing_organization_address = "^^Lilongwe^^^Malawi"
      obx.performing_organization_medical_director = "Limula^Henry"

      msg << obx # add the OBR segment to the message

      nte = HL7::Message::Segment::NTE.new
      nte.set_id = "1"
      nte.source = "P"
      nte.comment = "#{params[:state] rescue "Tested"}^#{params[:test_remark][code]}"

      msg << nte # add the NTE segment to the message

    end

    if finished and (!params[:ispanel].blank? and params[:ispanel])

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = "1"
      tq1.priority = "R^Routine^HL70485"

      msg << tq1 # add the TQ1 segment to the message

      obr = HL7::Message::Segment::OBR.new
      obr.set_id = "1"
      obr.universal_service_id = "#{params[:testcode] rescue nil}^#{params[:testname] rescue nil}^LOINC"
      obr.observation_date = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") rescue Time.now.strftime("%Y%m%d%H%M%S")}"
      obr.relevant_clinical_info = "Rule out diagnosis"
      obr.ordering_provider = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
      # obr.result_status = "Tested"

      msg << obr # add the OBR segment to the message

      obx = HL7::Message::Segment::OBX.new
      obx.set_id = "1"
      obx.value_type = "CE"
      obx.observation_id = "#{params[:testcode] rescue nil}^#{params[:testname]}^ISO"
      obx.observation_value = nil
      obx.units = nil
      obx.references_range = nil
      obx.observation_result_status = "F"
      obx.observation_date = "#{params[:testtime].to_datetime.strftime("%Y%m%d%H%M%S") rescue Time.now.strftime("%Y%m%d%H%M%S")}"
      obx.responsible_observer = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
      obx.analysis_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
      obx.performing_organization_name = "KCH Laboratory"
      obx.performing_organization_address = "^^Lilongwe^^^Malawi"
      obx.performing_organization_medical_director = "Limula^Henry"

      msg << obx # add the OBR segment to the message

      nte = HL7::Message::Segment::NTE.new
      nte.set_id = "1"
      nte.source = "P"
      nte.comment = "#{params[:state] rescue "Tested"}^"

      msg << nte

    end

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:barcode]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen] rescue nil}"

    msg << spm # add the SPM segment to the message

    # raise msg.to_s.inspect

    # result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
    #                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["test_result_path"]}", {:hl7 => msg.to_s})

    result = RestClient.post("#{CONFIG["lab_state_update_protocol"]}://#{CONFIG["lab_state_update_server"]}:" +
                                 "#{CONFIG["lab_state_update_port"]}#{CONFIG["lab_state_update_path"]}",
                             msg.to_s, {:content_type => 'application/text'})

    # raise result.inspect

    flash[:notice] = "Result #{(params[:state] rescue "Tested").titleize == "Verified" ? "verified" : "saved!"}"

    redirect_to "/lab/" and return

  end

  def save_group_state(params)

    patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                            "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["patient_by_acc_num_path"]}#{params[:id]}")).first

    group_tests = JSON.parse(RestClient.get("#{CONFIG["lab_repo_protocol"]}://#{CONFIG["lab_repo_server"]}:#{CONFIG["lab_repo_port"]}#{CONFIG["lab_get_spacific_labs_path"]}#{params[:id]}")) rescue []

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

    name = patient["name"].split(" ")

    fname = name[0] rescue nil
    mname = (name.length > 2 ? name[1] : "")
    lname = (name.length > 2 ? name[2] : name[1])

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = patient["surrogateId"] rescue nil
    pid.patient_name = "#{lname}^#{fname}^#{mname}"
    pid.patient_dob = patient["dob"].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = patient["sex"] rescue nil

    msg << pid # add the PID segment to the message

    pv1 = HL7::Message::Segment::PV1.new

    msg << pv1 # add the PV1 segment to the message

    orc = HL7::Message::Segment::ORC.new

    username = session[:user].gsub(/\s+/, "_") rescue 1
    usernames = session[:user_person_names]
    r = usernames.split(/\s+/)

    orc.entered_by = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
    orc.enterers_location = "^^^^^^^^#{params[:location]}"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tests = group_tests.first["orders"][params[:id]]["results"].keys # rescue nil

    i = 0
    tests.each do |test_code|

      next if test_code.blank?

      test_name = group_tests.first["orders"][params[:id]]["results"][test_code]["test_name"]

      i += 1

      obr = HL7::Message::Segment::OBR.new
      obr.set_id = i
      obr.universal_service_id = "#{test_code rescue nil}^#{test_name rescue nil}^LOINC"
      obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
      obr.relevant_clinical_info = "Rule out diagnosis"
      obr.ordering_provider = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"

      msg << obr # add the OBR segment to the message

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = i

      msg << tq1 # add the TQ1 segment to the message

      nte = HL7::Message::Segment::NTE.new
      nte.set_id = i
      nte.source = "P"
      nte.comment = "#{params[:state] rescue nil}^"

      msg << nte # add the NTE segment to the message

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

    end

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:id]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen] rescue nil}"

    msg << spm # add the SPM segment to the message

    result = RestClient.post("#{CONFIG["lab_state_update_protocol"]}://#{CONFIG["lab_state_update_server"]}:" +
                                 "#{CONFIG["lab_state_update_port"]}#{CONFIG["lab_state_update_path"]}",
                             msg.to_s, {:content_type => 'application/text'})

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

    name = patient["name"].split(" ")

    fname = name[0] rescue nil
    mname = (name.length > 2 ? name[1] : "")
    lname = (name.length > 2 ? name[2] : name[1])

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = patient["surrogateId"] rescue nil
    pid.patient_name = "#{lname}^#{fname}^#{mname}"
    pid.patient_dob = patient["dob"].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = patient["sex"] rescue nil

    msg << pid # add the PID segment to the message

    pv1 = HL7::Message::Segment::PV1.new

    msg << pv1 # add the PV1 segment to the message

    orc = HL7::Message::Segment::ORC.new
    username = session[:user].gsub(/\s+/, "_") rescue 1
    usernames = session[:user_person_names]
    r = usernames.split(/\s+/)

    orc.entered_by = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"
    orc.enterers_location = "^^^^^^^^#{params[:location]}"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tq1 = HL7::Message::Segment::TQ1.new
    tq1.set_id = "1"
    tq1.priority = "R^Routine^HL70485"

    msg << tq1 # add the TQ1 segment to the message

    obr = HL7::Message::Segment::OBR.new
    obr.set_id = "1"
    obr.universal_service_id = "#{params[:test_code] rescue nil}^#{params[:test_name] rescue nil}"
    obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obr.relevant_clinical_info = "Rule out diagnosis"
    obr.ordering_provider = "#{username}^#{(r.length > 2 ? r[r.length - 1] : r[1])}^#{r[0]}^#{(r.length > 2 ? r[1] : nil)}"

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

    nte = HL7::Message::Segment::NTE.new
    nte.set_id = "1"
    nte.source = "P"
    nte.comment = "#{params[:state] rescue nil}^"

    msg << nte # add the NTE segment to the message

    result = RestClient.post("#{CONFIG["lab_state_update_protocol"]}://#{CONFIG["lab_state_update_server"]}:" +
                                 "#{CONFIG["lab_state_update_port"]}#{CONFIG["lab_state_update_path"]}",
                             msg.to_s, {:content_type => 'application/text'})

  end

  def check_sample_state

    status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
        "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["specimen_status_path"]}#{params[:barcode]}"

    @status = RestClient.get(status_link).strip rescue nil

    if @status.strip.downcase == "drawn"

      flash[:error] = "Sample has not been seen yet at the Reception!"

      redirect_to "/lab/" and return

    elsif @status.strip.downcase == "received at reception"

      dept = @location[:dept].strip rescue "undefined"

      tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:barcode]}")

      list = JSON.parse(tests).keys.first.split("|") rescue nil

      if list.nil?

        flash[:error] = "ERROR: Test or specimen details extracting failed!"

        redirect_to "/lab/" and return

      end

      state = (@status.strip.upcase == "RECEIVED AT RECEPTION" ? "Received in department" : "Testing")

      parameters = {
          :id => params[:barcode].strip,
          :test => list[0],
          :state => state.titleize,
          :specimen => list[2],
          :location => "#{dept.strip.upcase.gsub(/\_/, " ").titleize}"
      }

      save_group_state(parameters)

      flash[:notice] = "Sample with ID #{params[:barcode]} recorded as #{(state.strip.downcase.match(/received/) ? "received" : "being processed")} in #{dept}!"

      redirect_to "/lab/" and return

    elsif @status.strip.downcase == "received in department" and params[:test_name].blank? and params[:test_code].blank?

      tests = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:barcode]}")

      @barcode = params[:barcode]

      list = JSON.parse(tests) rescue {}

      @tests = {}

      keys = list.keys

      keys.each do |key|

        item = key.split("|") rescue []

        next if item.empty?

        @tests[item[0]] = "#{item[3]}|#{item[2]}|#{item[4]}"

      end

      patient = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["patient_by_acc_num_path"]}#{params[:barcode]}")).first rescue []

      @patient = @request.get_patient_by_npid(patient["surrogateId"]).first rescue nil

      render :layout => "lab" and return

    elsif @status.strip.downcase == "received in department" and !params[:test_name].blank? and !params[:test_code].blank? and !params[:state].blank?

      status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
          "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["specimen_status_path"]}#{params[:barcode]}&test_name=#{params[:test_name].gsub(/\s/, "+")}"

      @status = RestClient.get(status_link).strip # rescue nil

      dept = @location[:dept]

      # raise params.inspect

      if @status.strip.downcase == "unknown"

        state = "Testing"

        parameters = {
            :id => params[:barcode].strip,
            :test_name => params[:test_name],
            :test_code => params[:test_code],
            :state => state.titleize,
            :specimen => params[:specimen],
            :location => @location[:dept]
        }

        # TODO: Need to find a way of calling one method only here
        save_state(parameters)

        save_group_state(parameters)

        flash[:notice] = "Test #{params[:test_name]} for sample with ID #{params[:barcode]} recorded as in #{state} in #{dept}!"

        redirect_to "/lab/" and return

      else

        flash[:notice] = "Sample with ID #{params[:barcode]} currently has status #{@status}!"

        redirect_to "/lab/" and return

      end

    else

      flash[:notice] = "Sample with ID #{params[:barcode]} currently has status #{@status}!"

      redirect_to "/lab/" and return

    end

  end

  def check_test_state

    status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@" +
        "#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["specimen_status_path"]}#{params[:barcode]}&test_name=#{params[:test_name].gsub(/\s/, "+")}"

    status = RestClient.get(status_link).strip # rescue nil

    render :text => status.strip

  end

  protected

  # Check if device location is set
  def check_device_location

    if params[:action].match(/enter_results/)

      ip = request.env["REMOTE_ADDR"]

      locks = Dir.glob("#{Rails.root}/tmp/#{params[:id]}*")

      if locks.length == 0

        Tempfile.open("#{params[:id]}", "tmp") do |f|

          f.print("#{params[:id]}")

          f.flush;

        end

        # flash[:notice] = "Locked " + params[:id] + " to " + ip

      else

        flash[:error] = "Patient record locked!"

        redirect_to "/lab/" and return

      end

    end

    # arp -H ether 192.168.15.104 | awk 'FNR==2 {print $3}'

    target = "" #`arp -H ether #{request.env["REMOTE_ADDR"]} | awk 'FNR==2 {print $3}'`

    target = request.env["REMOTE_ADDR"] if target.blank?

    @location = {}

    file = "#{Rails.root}/config/workstations.yml"

    if File.exists?(file) and !target.blank?

      locations = YAML.load_file("#{Rails.root}/config/workstations.yml")[Rails.env] rescue {}

      locations.each do |dept, benches|

        benches.each do |bench, mac|

          if !mac.blank? and mac.strip.downcase == target.strip.downcase

            @location = {
                :dept => "#{dept.gsub(/\_/, " ").titleize}",
                :bench => "#{bench.strip}"
            }

            break

          end

        end

      end

    end

    @location

  end

  def unlock_specimen

    locks = Dir.glob("#{Rails.root}/tmp/#{params[:id]}*")

    if locks.length > 0

      locks.each do |name|

        ip = File.open(name).read

        file = File.delete(name)

        # flash[:notice] = "Unlocked " + params[:id] + " from " + ip

      end

    end

  end

  def set_connection

    @request = SoapService.new

  end

end
