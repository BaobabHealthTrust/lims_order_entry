class OrderController < ApplicationController

  before_filter :set_connection, :only => [:search_by_name_and_gender, :search_by_name_and_dob, :search_by_npid,
                                           :patient, :place_order]

  def index

    if !session[:patient_id].blank? and !params[:cancel].blank?

      session[:patient_id] = nil

    elsif !session[:patient_id].blank? and params[:cancel].blank?

      redirect_to "/patient/#{session[:patient_id]}" and return

    end
    @settings = YAML.load_file(Rails.root.join('config', 'application.yml'))
  end

  def search
    @cat = params["target"] rescue nil
  end

  def place_order

    link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["search_by_acc_num_path"]}#{params[:accession_number]}" rescue nil

    tests = JSON.parse(RestClient.get(link).strip) rescue nil

    @accession_number = params[:accession_number] rescue nil

    @state = params[:state] rescue nil

    @test_code = params[:test_code] rescue nil

    @test_name = params[:test_name] rescue nil

    @specimen = nil

    @parent_test_code = nil

    @parent_test_name = nil

    if !tests.blank?

      @parent_test_name, id, @specimen, @parent_test_code = tests.keys.first.split("|") rescue [nil, nil, nil, nil]

    end

    @patient = @request.get_patient_by_npid(params[:id]).first rescue nil

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

  def catalog

    # list = JSON.parse('{"6|Sang Total":["7|CD4 Count||","9|FBS||","10|Protein Count||","11|Acide Urique||","12|Calcium||","38|Paludisme||","39|Complete Blood Count||","40|HGB||","43|HIV EIA||","44|HIV Rapid Test||","46|Western Blot||","49|HGB Electropherosis||","50|Platelet Count||","51|ESR (Sed rate)||","52|Enumeration Globules Blancs (GB)||","53|Sickling RBC||","54|Clotting Time (CT)||","57|Hepatitis C||","63|Groupe Sanguin (ABO\/Rh)||","70|Bleeding Time (BT)||","84|Random Blood Sugar||","86|T-Lymphocytes CD4||"],"7|Serum":["8|ALT\/SGPT||","13|Phosphorus||","14|Magnesium||","15|Creatine Kinase||","16|Thyroglobulin||","18|AST\/SGOT||","19|Alkaline Phosphatase||","20|Total Bilirubin||","21|Blood Urea Nitrogen||","22|Creatinine||","23|Sodium||","24|Potassium||","25|Chlore||","26|CO2 Bicarbonate||","27|Cholesterol Total||","28|Triglycerides||","29|HDL Cholesterol||","30|LDL Cholesterol||","31|Glucose||","32|Amylase||","33|Lactate||","34|Kidney Function Panel||","35|Lipid Panel||","36|Liver Function Panel||","37|HIV Monitoring Panel||","91|IONNOGRAMME||","47|RPR||","48|Hepatitis B||","55|Gamma Glutamyl||","58|VDRL||","59|Rheumatoid Factor||","62|Progesterone||","64|ASOT (Streptococcal)||","66|TPHA||","67|Toxoplasma||","68|C-Reactive Protein||","72|Prolactin||","73|Ferritin||","74|Testosterone||","90|Test de la Typhoide||","44|HIV Rapid Test||","92|Ionogramme||"],"8|Dried Blood Spot":["70|Bleeding Time (BT)||","41|HIV DNA PCR||"],"9|Crachat":["69|Zn Stain||","83|TB Smear|11545-1|"],"10|CSF":["17|Total Albumin||","60|CSF||"],"11|Urine":["56|Urine Analysis||","61|Pregnancy Test (HCG)||","88|examen bacteriologique||"],"12|Selle":["71|Stool Analysis||"],"13|Aspirate":["7|CD4 Count||","85|AFB||","32|Amylase||"],"14|Nasal Swab":["88|examen bacteriologique||"],"15|Sperme":["65|Sperm Count||"],"16|Prelevement rectal":["88|examen bacteriologique||"],"17|Prelevement de la Gorge":["83|TB Smear|11545-1|"],"18|Plasma EDTA":["41|HIV DNA PCR||","42|HIV RNA VL||"],"21|Frottis Vaginal":["89|Culture||"],"22|LCR":["88|examen bacteriologique||"]}')

    cat = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["avaialble_tests_path"]}")

    list = JSON.parse(cat)

    result = {}

    ids = {}

    assocs = {}

    codes = {
        "specimens" => {}
    }

    shorts = {}

    groups = {}

    containers = {}

    volumes = {}

    units = {}

    list.each do |group, members|

      id, name, code, sname = group.strip.split("|")

      result[[id, name, code, sname]] = []

      ids[name] = id

      assocs[name] = []

      # shorts[name] = sname

      codes["specimens"][name] = code

      containers[name] = {}

      volumes[name] = {}

      units[name] = {}

      members.each do |element|

        cid, cname, ccode, csname, ccontainer, cvolume, cunits = element.strip.split("|")

        result[[id, name, code, sname]] << [cid, cname, ccode, csname]

        ids[cname] = cid

        assocs[name] << cname

        shorts[cname] = csname

        codes[cname] = ccode

        groups[cname] = name

        containers[name][cname] = ccontainer

        volumes[name][cname] = cvolume

        units[name][cname] = cunits

      end

    end

    render :text => {:associations => assocs, :identifiers => ids, :shortnames => shorts, :codes => codes,
                     :ids => ids, :groups => groups, :containers => containers, :volumes => volumes, :units => units}.to_json

  end

  def patient

    # raise session[:patient_id].inspect

    @datetime = Time.now.strftime("%Y%m%d%H%M%S"

    @patient = @request.get_patient_by_npid(params[:id]).first rescue nil

    cat = RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["avaialble_tests_path"]}")

    if !@patient.blank?

      session[:patient_id] = @patient[:national_id] rescue nil

    end

    list = JSON.parse(cat)

    result = {}

    ids = {}

    assocs = {}

    @codes = {
        "specimens" => {}
    }

    @shorts = {}

    groups = {}

    containers = {}

    volumes = {}

    units = {}

    list.each do |group, members|

      id, name, code, sname = group.strip.split("|")

      result[[id, name, code, sname]] = []

      ids[name] = id

      assocs[name] = []

      # shorts[name] = sname

      @codes["specimens"][name] = code

      containers[name] = {}

      volumes[name] = {}

      units[name] = {}

      members.each do |element|

        cid, cname, ccode, csname, ccontainer, cvolume, cunits = element.strip.split("|")

        result[[id, name, code, sname]] << [cid, cname, ccode, csname]

        ids[cname] = cid

        assocs[name] << cname

        @shorts[cname] = csname

        @codes[cname] = ccode

        groups[cname] = name

        containers[name][cname] = ccontainer

        volumes[name][cname] = cvolume

        units[name][cname] = cunits

      end

    end



  end

  def process_order

    # raise params.inspect

    # create a message
    msg = HL7::Message.new

    # create a MSH segment for our new message
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = "^~\&"
    msh.sending_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.recv_facility = "KCH^2.16.840.1.113883.3.5986.2.15^ISO"
    msh.time = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.message_type = "OML^O21^OML_O21"
    msh.message_control_id = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    msh.processing_id = "T"
    msh.version_id = "2.5"

    msg << msh # add the MSH segment to the message

    pid = HL7::Message::Segment::PID.new
    pid.set_id = "1"
    pid.patient_id_list = params[:npid] rescue nil
    pid.patient_name = "#{params[:last_name] rescue nil}^#{params[:first_name] rescue nil}^#{params[:middle_name] rescue nil}"
    pid.patient_dob = params[:date_of_birth].to_date.strftime("%Y%m%d") rescue nil
    pid.admin_sex = params[:sex][0] rescue nil

    msg << pid # add the PID segment to the message

    orc = HL7::Message::Segment::ORC.new
    orc.entered_by = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"
    orc.enterers_location = "^^^^^^^^#{session[:location]}"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tests = params[:test_name].split(",")

    priority = "R"

    i = 0
    tests.each do |test|

      next if test.blank?

      test_name, test_code, priority = test.split("|")

      panels = JSON.parse(RestClient.get("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["panel_tests_path"]}#{test_code}"))


      if panels.length > 1

        obr = HL7::Message::Segment::OBR.new
        obr.set_id = i
        obr.universal_service_id = "#{test_code rescue nil}^#{test_name rescue nil}^LOINC"
        obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
        obr.relevant_clinical_info = "Rule out diagnosis"
        obr.ordering_provider = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"

        msg << obr # add the OBR segment to the message

        tq1 = HL7::Message::Segment::TQ1.new
        tq1.set_id = i
        tq1.priority = priority

        msg << tq1 # add the TQ1 segment to the message

        nte = HL7::Message::Segment::NTE.new
        nte.set_id = i
        nte.source = "P"
        nte.comment = "#{params[:status] rescue nil}^parent"

        msg << nte # add the NTE segment to the message

      end

      panels.each do |panel|

        id, name, code, short = panel.strip.split("|")

        i += 1

        obr = HL7::Message::Segment::OBR.new
        obr.set_id = i
        obr.universal_service_id = "#{code rescue nil}^#{name rescue nil}^LOINC"
        obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
        obr.relevant_clinical_info = "Rule out diagnosis"
        obr.ordering_provider = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"


        msg << obr # add the OBR segment to the message

        tq1 = HL7::Message::Segment::TQ1.new
        tq1.set_id = i
        tq1.priority = priority

        msg << tq1 # add the TQ1 segment to the message

        nte = HL7::Message::Segment::NTE.new
        nte.set_id = i
        nte.source = "P"
        nte.comment = "#{params[:status] rescue nil}^child^#{test_code}"

        msg << nte # add the NTE segment to the message

      end

    end

    i += 1

    if !params[:old_test_code].blank? and !params[:old_test_name].blank? and !params[:old_specimen_id].blank? and !params[:specimen].blank? and false

      obr = HL7::Message::Segment::OBR.new
      obr.set_id = i
      obr.universal_service_id = "#{params[:old_test_code] rescue nil}^#{params[:old_test_name] rescue nil}^LOINC"
      obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
      obr.relevant_clinical_info = "Rule out diagnosis"
      obr.ordering_provider = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"

      msg << obr # add the OBR segment to the message

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = i
      tq1.priority = priority

      msg << tq1 # add the TQ1 segment to the message

      nte = HL7::Message::Segment::NTE.new
      nte.set_id = i
      nte.source = "P"
      nte.comment = "Voided^"

      msg << nte # add the NTE segment to the message

    end

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:old_specimen_id]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen_code] rescue nil}"

    msg << spm # add the SPM segment to the message

    # raise msg.to_s.inspect

    # result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
    #                             "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["test_order_path"]}", {:hl7 => msg.to_s})

    result = RestClient.post("#{CONFIG["test_order_transport_protocol"]}://#{CONFIG["test_order_server"]}:#{CONFIG["test_order_port"]}" +
                                 "#{CONFIG["test_order_path"]}", msg.to_s, {:content_type => 'application/text'})

    # raise result.inspect

    # "\n\n{\"sendingFacility\":\"KCH\",\"receivingFacility\":\"KCH\",\"messageDatetime\":\"20150130162135\",\"messageType\":\"OML_O21\",\"messageControlID\":\"20150130162135\",\"processingID\":\"T\",\"hl7VersionID\":\"2.5\",\"obrSetID\":\"3\",\"testCode\":\"626-2\",\"timestampForSpecimenCollection\":\"20150130162135\",\"reasonTestPerformed\":\"Rule out diagnosis\",\"whoOrderedTest\":\"Chris Moyo (3)\",\"healthFacilitySiteCodeAndName\":\"KCH\",\"pidSetID\":\"1\",\"nationalID\":\"P129500000229\",\"patientName\":\"Mevis N\\/A Kadammanja \",\"dateOfBirth\":\"19631027\",\"gender\":\"F\",\"spmSetID\":\"1\",\"accessionNumber\":\"20150130-11\",\"typeOfSample\":\"Urine\",\"tq1SetID\":\"1\",\"priority\":\"S\",\"enteredBy\":\"User Super (1)\",\"enterersLocation\":\"\",\"testName\":\"Glucose\"}\n"

    render :text => result

  end

  def receptor

    render :text => params[:id].to_s

  end

  def get_labs

    # raise "#{CONFIG["lab_repo_protocol"]}://#{CONFIG["lab_repo_server"]}:#{CONFIG["lab_repo_port"]}#{CONFIG["lab_get_labs_path"]}#{params[:id]}".inspect

    result = RestClient.get("#{CONFIG["lab_repo_protocol"]}://#{CONFIG["lab_repo_server"]}:#{CONFIG["lab_repo_port"]}" +
                "#{CONFIG["lab_get_labs_path"]}#{params[:id]}?page=#{params[:page]}&page_size=#{params[:page_size]}")


    render :text => result

  end

  def update_state

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

    name = patient["name"].split(" ") rescue []

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
    orc.entered_by = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"
    orc.enterers_location = "^^^^^^^^#{session[:location]}"
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
      obr.ordering_provider = "439234^#{session[:user_person_names]['last_name'] rescue "Unknown"}^#{session[:user_person_names]['first_name'] rescue "Unknown"}"

      msg << obr # add the OBR segment to the message

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = i

      msg << tq1 # add the TQ1 segment to the message

      obx = HL7::Message::Segment::OBX.new
      obx.set_id = i
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

      nte = HL7::Message::Segment::NTE.new
      nte.set_id = i
      nte.source = "P"
      nte.comment = "#{params[:state] rescue nil}^"

      msg << nte # add the NTE segment to the message

    end

=begin
    tq1 = HL7::Message::Segment::TQ1.new
    tq1.set_id = "1"
    tq1.priority = "R^Routine^HL70485"

    msg << tq1 # add the TQ1 segment to the message

    obr = HL7::Message::Segment::OBR.new
    obr.set_id = "1"
    obr.universal_service_id = "#{params[:test_code] rescue nil}^#{params[:test_name] rescue nil}"
    obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    obr.relevant_clinical_info = "Rule out diagnosis"
    obr.ordering_provider = "439234^Moyo^Chris"
    # obr.result_status = "#{params[:state]}"

    msg << obr # add the OBR segment to the message
=end

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = "#{params[:id]}"
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen] rescue nil}"

    msg << spm # add the SPM segment to the message

    # raise msg.to_s.inspect

    # raise "#{CONFIG["lab_state_update_protocol"]}://#{CONFIG["lab_state_update_server"]}:#{CONFIG["lab_state_update_port"]}#{CONFIG["lab_state_update_path"]}"

    result = RestClient.post("#{CONFIG["lab_state_update_protocol"]}://#{CONFIG["lab_state_update_server"]}:" +
                                 "#{CONFIG["lab_state_update_port"]}#{CONFIG["lab_state_update_path"]}",
                             msg.to_s, {:content_type => 'application/text'})

    # raise result.inspect

    render :text => result

  end

  def ward_work_list
    result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:" +
                                 "#{CONFIG["order_port"]}#{CONFIG["specimen_details_link"]}", {:type => 'ward', :department => session[:location]}  )

    terminal_states = ['SAMPLE REJECTED','TEST REJECTED','RESULT REJECTED']
    data = {}
    pre_processed = JSON.parse(result)

    (pre_processed || []).each do |patient|
      data[patient['national_id']] = {'name' => patient['patient_name'], 'test' => [], 'terminal' => []} if data[patient['national_id']].blank?
      data[patient['national_id']]['test'] << [patient['accession_number'], patient['status']] if !data[patient['national_id']]['test'].include? [patient['accession_number'], patient['status']]
      data[patient['national_id']]['terminal'] << {'accession_number' => patient['accession_number'],'test_code' => patient['test_code'],
                                                   'test_name' => patient['test_type_name']} if terminal_states.include?patient['status'].upcase
    end
    render :text => data.to_json
  end

  def get_state
    status_link = "#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}#{CONFIG["status_path"]}#{params[:id]}"

    status = RestClient.get(status_link)

    render :text => status
  end

  protected

  def set_connection

    @request = SoapService.new

  end

end
