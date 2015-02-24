class OrderController < ApplicationController

  before_filter :set_connection, :only => [:search_by_name_and_gender, :search_by_name_and_dob, :search_by_npid,
                                           :patient, :place_order]

  def index
  end

  def search
    @cat = params["target"] rescue nil
  end

  def place_order

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

      shorts[name] = sname

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

    @patient = @request.get_patient_by_npid(params[:id]).first rescue nil

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
    orc.entered_by = "1^Super^User"
    orc.enterers_location = "^^^^^^^^MEDICINE"
    orc.ordering_facility_name = "KCH"

    msg << orc # add the ORC segment to the message

    tests = params[:test_name].split(",")

    i = 0
    tests.each do |test|

      next if test.blank?

      test_name, test_code, priority = test.split("|")

      i += 1

      obr = HL7::Message::Segment::OBR.new
      obr.set_id = i
      obr.universal_service_id = "#{test_code rescue nil}^#{test_name rescue nil}^LOINC"
      obr.observation_date = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
      obr.relevant_clinical_info = "Rule out diagnosis"
      obr.ordering_provider = "439234^Moyo^Chris"

      msg << obr # add the OBR segment to the message

      tq1 = HL7::Message::Segment::TQ1.new
      tq1.set_id = i
      tq1.priority = priority

      msg << tq1 # add the TQ1 segment to the message

    end

    spm = HL7::Message::Segment::SPM.new
    spm.set_id = "1"
    spm.specimen_id = ""
    spm.specimen_type = "#{params[:specimen] rescue nil}^#{params[:specimen_code] rescue nil}"

    msg << spm # add the SPM segment to the message

    nte = HL7::Message::Segment::NTE.new
    nte.set_id = "1"
    nte.source = "P"
    nte.comment = "#{params[:status] rescue nil}"

    msg << nte # add the NTE segment to the message

    # raise msg.to_s.inspect

    result = RestClient.post("#{CONFIG["order_transport_protocol"]}://#{CONFIG["order_username"]}:#{CONFIG["order_password"]}" +
                                 "@#{CONFIG["order_server"]}:#{CONFIG["order_port"]}/#{CONFIG["test_order_path"]}", {:hl7 => msg.to_s})

    # raise result.inspect

    # "\n\n{\"sendingFacility\":\"KCH\",\"receivingFacility\":\"KCH\",\"messageDatetime\":\"20150130162135\",\"messageType\":\"OML_O21\",\"messageControlID\":\"20150130162135\",\"processingID\":\"T\",\"hl7VersionID\":\"2.5\",\"obrSetID\":\"3\",\"testCode\":\"626-2\",\"timestampForSpecimenCollection\":\"20150130162135\",\"reasonTestPerformed\":\"Rule out diagnosis\",\"whoOrderedTest\":\"Chris Moyo (3)\",\"healthFacilitySiteCodeAndName\":\"KCH\",\"pidSetID\":\"1\",\"nationalID\":\"P129500000229\",\"patientName\":\"Mevis N\\/A Kadammanja \",\"dateOfBirth\":\"19631027\",\"gender\":\"F\",\"spmSetID\":\"1\",\"accessionNumber\":\"20150130-11\",\"typeOfSample\":\"Urine\",\"tq1SetID\":\"1\",\"priority\":\"S\",\"enteredBy\":\"User Super (1)\",\"enterersLocation\":\"\",\"testName\":\"Glucose\"}\n"

    render :text => result

  end

  def receptor

    render :text => params[:id].to_s

  end

  protected

  def set_connection

    @request = SoapService.new

  end

end
