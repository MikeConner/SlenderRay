module TreatmentSessionsHelper  
  def add_measurement(session, form_builder, label)
    # Precompute the html for a new machine block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add Machine" and the id "add_machine"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #machine elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :measurements, session.measurements.build, :child_index => 'NEW_RECORD' do |measurement_form|
      html = render(:partial => 'measurement_row', :locals => { :f => measurement_form, :label => label })
      link_to_function 'Add Measurement', 
                       "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.measurement').length)).insertBefore('#last_#{label}')"
    end
  end
end