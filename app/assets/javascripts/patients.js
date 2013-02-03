function remove_treatment_plan(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".treatment_plan").hide();
}

function remove_measurement(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".measurement").hide();
}

function add_treatment_plan(patient_id, plan_name) {
 	jQuery.ajax({url:"/patients/" + patient_id + "/clone_treatment_plan",
	             data: "name=" + plan_name,
		         type: "PUT",
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false}); 	    		  
}
