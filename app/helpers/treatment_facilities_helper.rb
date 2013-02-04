module TreatmentFacilitiesHelper  
  def add_machine(facility, form_builder)
    # Precompute the html for a new machine block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add Machine" and the id "add_machine"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #machine elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :machines, facility.machines.build, :child_index => 'NEW_RECORD' do |machine_form|
      html = render(:partial => 'machine', :locals => { :f => machine_form })
      link_to_function 'Add Machine', 
                       "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.machine').length)).insertBefore('#add_machine')",
                       :id  => "add_machine"
    end
  end

  def add_treatment_plan_template(facility, form_builder)
    form_builder.fields_for :treatment_plan_templates, facility.treatment_plan_templates.build, :child_index => 'NEW_RECORD' do |template_form|
      html = render(:partial => 'shared/treatment_plan', :locals => { :f => template_form, :type => 'TreatmentPlanTemplate' })
      link_to_function 'Add Treatment Plan Template', 
                       "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.treatment_plan').length)).insertBefore('#add_treatment_plan_template')",
                       :id  => "add_treatment_plan_template"
    end
  end

  def add_treatment_area(facility, form_builder)
    form_builder.fields_for :treatment_areas, facility.treatment_areas.build, :child_index => 'NEW_RECORD' do |area_form|
      html = render(:partial => 'treatment_area', :locals => { :f => area_form })
      link_to_function 'Add Treatment Area', 
                       "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.treatment_area').length)).insertBefore('#add_treatment_area')",
                       :id  => "add_treatment_area"
    end
  end

  def add_user(facility, form_builder)
    form_builder.fields_for :users, facility.users.build, :child_index => 'NEW_RECORD' do |user_form|
      html = render(:partial => 'user', :locals => { :f => user_form, :facility => facility })
      link_to_function 'Add User', 
                       "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.user').length)).insertBefore('#add_user')",
                       :id  => "add_user"
    end
  end
end