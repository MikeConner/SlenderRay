LOCAL_FACILITY = ENV['LOCAL_FACILITY_NAME'].nil? ? TreatmentFacility.first : TreatmentFacility.find_by_facility_name(ENV['LOCAL_FACILITY_NAME'])
