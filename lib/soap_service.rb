class SoapService

  CONFIG = YAML.load_file(Rails.root.join('config', 'connection.yml'))[Rails.env]

  WSDL_URL = "http://#{CONFIG["wsdl_server"]}:#{CONFIG["wsdl_port"]}/demographics/wsdl"
  WSDL_NAMESPACE = "#{CONFIG["namespace"]}"
  WSDL_USERNAME = "#{CONFIG["username"]}"
  WSDL_PASSWORD = "#{CONFIG["password"]}"

  def initialize

    @client = Savon.client do
      wsdl WSDL_URL
      wsse_auth(WSDL_USERNAME, WSDL_PASSWORD)
    end

  end

  def get_patient_by_npid(npid)

    response = @client.call(:get_patient_by_npid, :message => {:npid => npid})

    return [] if response.soap_fault?

    useful_elements = response.to_hash[:get_patient_by_npid_results_response][:get_patient_list_result][:diffgram][:document_element][:result]

    return [] if useful_elements.nil?

    if useful_elements.class.name.downcase == "hash"

      array_of_hashes = useful_elements.reject do |key, value|
        !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                  :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
      end

      array_of_hashes = [array_of_hashes]

    else

      array_of_hashes = useful_elements.map do |test|
        test.reject do |key, value|
          !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                    :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
        end
      end

    end

    array_of_hashes

  end

  def get_patient_by_name(firstname, lastname, gender, page = 1, pagesize = 20)

    response = @client.call(:get_patient_by_name, :message => {:firstname => firstname, :lastname => lastname, :gender => gender, :page => page, :pagesize => pagesize})

    return [] if response.soap_fault?

    useful_elements = response.to_hash[:get_patient_by_name_results_response][:get_patient_list_result][:diffgram][:document_element][:result]

    return [] if useful_elements.nil?

    if useful_elements.class.name.downcase == "hash"

      array_of_hashes = useful_elements.reject do |key, value|
        !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                  :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
      end

      array_of_hashes = [array_of_hashes]

    else

      array_of_hashes = useful_elements.map do |test|
        test.reject do |key, value|
          !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                    :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
        end
      end

    end

    array_of_hashes

  end

  def get_patient_by_name_and_dob(firstname, lastname, gender, birthdate, page = 1, pagesize = 20)

    response = @client.call(:get_patient_by_name_and_dob, :message => {:firstname => firstname, :lastname => lastname, :gender => gender, :birthdate => birthdate, :page => page, :pagesize => pagesize})

    return [] if response.soap_fault?

    useful_elements = response.to_hash[:get_patient_by_name_and_dob_results_response][:get_patient_list_result][:diffgram][:document_element][:result]

    return [] if useful_elements.nil?

    if useful_elements.class.name.downcase == "hash"

      array_of_hashes = useful_elements.reject do |key, value|
        !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                  :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
      end

      array_of_hashes = [array_of_hashes]

    else

      array_of_hashes = useful_elements.map do |test|
        test.reject do |key, value|
          !key.in?([:national_id, :full_name, :sex, :age, :date_of_birth, :first_name, :last_name, :middle_name,
                    :home_village, :home_ta, :home_district, :current_village, :current_ta, :current_district, :current_residence])
        end
      end

    end

    array_of_hashes

  end

end