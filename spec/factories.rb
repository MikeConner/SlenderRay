FactoryGirl.define do
  # Random sequences
  sequence(:random_url) { |n| "http://www." + Faker::Internet.domain_name }
  sequence(:random_phone) { |n| Faker::PhoneNumber.phone_number }
  sequence(:seqential_phone) { |n| '(412) 400-' + sprintf("%04d", n) }
  sequence(:random_street) { |n| Faker::Address.street_address }
  sequence(:random_city) { |n| Faker::Address.city }
  sequence(:random_state) do
    st = ""
    until ApplicationHelper::US_STATES.member?(st)
      st = Faker::Address.state_abbr
    end
    st
  end
  sequence(:random_zip) { |n| Faker::Address.zip_code }
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:random_vendor_name) { |n| Faker::Company.name }
  sequence(:random_first_name) { |n| Faker::Name.first_name }
  sequence(:random_last_name) { |n| Faker::Name.last_name }
  sequence(:random_phrase) { |n| Faker::Company.catch_phrase }
  sequence(:random_paragraphs) { |n| Faker::Lorem.paragraphs.join("\n") }
  sequence(:sequential_serial) { |n| "00342" + sprintf("%04d", n) }
  sequence(:sequential_machine) { |n| sprintf("Machine %d", n) }
  
  factory :treatment_facility do
    facility_name { generate(:random_vendor_name) }
    facility_url { generate(:random_url) }
    first_name { generate(:random_first_name) }
    last_name { generate(:random_last_name) }
    email { generate(:random_email) }
    phone { generate(:seqential_phone) }
    address_1 { generate(:random_street) }
    city { generate(:random_city) }
    state { generate(:random_state) }
    zipcode { generate(:random_zip) }
    
    factory :facility_with_treatments do
      ignore do
        num_sessions 4
      end
      
      after(:create) do |facility, evaluator|
        machine = FactoryGirl.create(:machine, :treatment_facility => facility)
        FactoryGirl.create_list(:session_with_treatments, evaluator.num_sessions, :machine => machine)
      end
    end
    
    factory :facility_with_areas do
      ignore do
        num_areas 3
      end
      
      after(:create) do |facility, evaluator|
        FactoryGirl.create_list(:treatment_area, evaluator.num_areas, :treatment_facility => facility)
      end
    end
  end
  
  factory :machine do
    treatment_facility
    
    model { generate(:random_phrase) }
    serial_number { generate(:sequential_serial) }
    display_name { generate(:sequential_machine) }
    date_installed 1.week.ago
    
    factory :machine_with_sessions do
      ignore do
        num_sessions 4
      end
      
      after(:create) do |machine, evaluator|
        FactoryGirl.create_list(:treatment_session, evaluator.num_sessions, :machine => machine)
      end
    end
  end
  
  factory :role do
    name { [Role::SUPER_ADMIN, Role::TECHNICIAN].sample }
  end
  
  factory :patient do
    treatment_facility
    
    name "Whole lotta Rosie"
    
    factory :patient_with_testimonials do
      ignore do
        num_testimonials 2
      end
      
      after(:create) do |patient, evaluator|
        FactoryGirl.create_list(:testimonial, evaluator.num_testimonials, :patient => patient)
      end
    end
    
    factory :patient_with_plans do
      ignore do
        num_plans 2
      end
      
      after(:create) do |patient, evaluator|
        FactoryGirl.create_list(:treatment_plan, evaluator.num_plans, :patient => patient)
      end      
    end
  end
  
  factory :testimonial do
    patient
    
    comment { generate(:random_paragraphs) }
    date_entered 2.weeks.ago
    displayable true
    
    factory :undisplayed_testimonial do
      displayable false
    end
  end
  
  factory :protocol do
    name 'Reduce Pain'
    frequency 532
  end
  
  factory :plan1, :class => TreatmentPlanTemplate do
    description { generate(:random_paragraphs) }
    num_sessions 2
    treatments_per_session 2
    price 1750
    type 'TreatmentPlanTemplate'
  end
  
  factory :plan2, :class => TreatmentPlanTemplate do
    description { generate(:random_paragraphs) }
    num_sessions 3
    treatments_per_session 2
    price 2800
    type 'TreatmentPlanTemplate'
  end
  
  factory :treatment_plan do
    patient
    
    description { generate(:random_paragraphs) }
    num_sessions 2
    treatments_per_session 2
    price 1750
    type 'TreatmentPlan'
    
    factory :plan_with_sessions do
      ignore do
        num_treatment_sessions 2
      end
      
      after(:create) do |plan, evaluator|
        FactoryGirl.create_list(:treatment_session, evaluator.num_treatment_sessions, :treatment_plan => plan)
      end
    end
    
    factory :plan_with_treatments do
      ignore do
        num_treatment_sessions 2
      end
      
      after(:create) do |plan, evaluator|
        FactoryGirl.create_list(:session_with_treatments, evaluator.num_treatment_sessions, :treatment_plan => plan)
      end
    end
  end
  
  factory :treatment_session do
    treatment_plan
    machine
    
    remote_patient_image_url 'http://s1.static.gotsmile.net/images/2011/05/31/very-fat-woman-eating_130682670469.jpg'
    notes { generate(:random_paragraphs) }
    
    factory :session_with_treatments do
      ignore do
        num_treatments 2
      end
      
      after(:create) do |session, evaluator|
        FactoryGirl.create_list(:treatment, evaluator.num_treatments, :treatment_session => session)
      end
    end   
    
    factory :session_with_measurements do
      ignore do
        num_measurements 6
      end
      
      after(:create) do |session, evaluator|
        FactoryGirl.create_list(:measurement, evaluator.num_measurements, :treatment_session => session)
      end            
    end 
    
    factory :first_session_with_measurements do
      ignore do
        num_measurements 4
      end
      
      after(:create) do |session, evaluator|
        FactoryGirl.create_list(:before_measurement, evaluator.num_measurements, :treatment_session => session)
        FactoryGirl.create_list(:after_measurement, evaluator.num_measurements, :treatment_session => session)
      end            
    end
  end
  
  factory :treatment_process, :class => Treatment do
    treatment_session
    protocol

    duration 8    
  end

  factory :area_process, :class => TreatmentArea do
    area_name { generate(:random_phrase) }
  end
  
  factory :treatment_timer, :class => ProcessTimer do
    process_state ProcessTimer::IDLE
    duration_seconds 480
    
    process { FactoryGirl.create(:treatment_process) }
  end

  factory :area_timer, :class => ProcessTimer do
    process_state ProcessTimer::IDLE
    duration_seconds 600
    
    process { FactoryGirl.create(:area_process) }
  end

  factory :treatment do
    treatment_session
    protocol
    
    duration 8

    after(:create) do |process|
      FactoryGirl.create(:process_timer, :process => process)
    end
  end

  factory :process_timer do
    process_state ProcessTimer::IDLE
    duration_seconds 600 
  end
  
  factory :treatment_area do
    area_name { generate(:random_phrase) }
    
    after(:create) do |process|
      FactoryGirl.create(:process_timer, :process => process)
    end
  end
  
  factory :measurement do
    treatment_session
    
    location { ['navel', '- 2cm', '+ 2cm', '+ 5cm'].sample }
    circumference 42.5
    
    factory :before_measurement do
      label 'Before'
    end
    
    factory :after_measurement do
      label 'After'
    end
  end  
  
  factory :user do
    email { generate(:random_email) }
    password "Password"
    password_confirmation "Password"
     
    factory :user_with_role do
      role
    end
  end  
end