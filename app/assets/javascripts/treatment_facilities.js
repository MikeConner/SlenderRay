function remove_machine(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".machine").hide();
}

function remove_treatment_area(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".treatment_area").hide();
}

function remove_user(link) {
  $(link).prev("input[type=hidden]").val("true");
  $(link).closest(".user").hide();
}
