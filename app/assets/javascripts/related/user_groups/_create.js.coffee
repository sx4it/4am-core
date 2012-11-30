
# Create dualselect control for group selection
$ ->
  val = $("#user_group_user").data("val")
  $("#user_group_user").val(val).select2()

