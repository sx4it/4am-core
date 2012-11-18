
# Create dualselect control for group selection
$ ->
  val = $("#user_roles").data("val")
  $("#user_roles").val(val).select2()
  val = $("#user_user_group").data("val")
  $("#user_user_group").val(val).select2()

