function remove_treatment_plan(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".treatment_plan").hide();
}

function remove_measurement(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".measurement").hide();
}

function update_machine() {
    var patient_id = $('#resume_patient_id').val();
	jQuery.ajax({url:"/patients/" + patient_id + "/current_session_machine",
	             //data: "key=" + name,
		         type: "GET",
	             success: function(data) { 
	               $('#resume_machine_id').val(data)
	             },
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    	
	
}
