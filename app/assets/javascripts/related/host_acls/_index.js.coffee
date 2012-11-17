# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#$ ->
#  $(".auto_search_complete").autocomplete({
#  dataType: "json",
#  source: '/books.js',
#  minLength: 3
#  }).data("autocomplete")._renderItem = (ul, item) {
#    return $("<li></li>")
#      .data("item.autocomplete", item)
#      .append("<a>" +"<img src='" + item.img + "'>" + item.label + "</a>")
#      .appendTo(container);
#  }
$ ->
  format = (item)->
    return item.text unless !item.id
    text = "user" if (item.text == "User")
    text = "group" if (item.text == "UserGroup")
    text = "host" if (item.text == "Host")
    text = "group" if (item.text == "HostGroup")
    return "<i class='custom-icon icon_" + text + "'/>" + item.text
  $("#acl_form_hosts").select2(
    placeHolder: "Select a host or a host group"
    formatResult: format
    formatSelection: format
  ).on("change", (v)->
    b = $(v.target).val().split(':')
    if b.length > 1
      $('#acl_form_host_id').attr('value', b[0]);
      $('#acl_form_host_type').attr('value', b[1]);
  )

  $("#acl_form_users").select2(
    placeHolder: "Select a user or a user group"
    formatResult: format
    formatSelection: format
  ).on("change", (v)->
    b = $(v.target).val().split(':')
    console.log "change"
    if b.length > 1
      $('#acl_form_user_id').attr('value', b[0]);
      $('#acl_form_user_type').attr('value', b[1]);
    else
      $('#acl_form_user_id').attr('value', "");
      $('#acl_form_user_type').attr('value', "");
  )
