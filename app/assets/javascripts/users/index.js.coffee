
$(document).ready ->

  $('.check_all').click ->
    $(this).parents('table').find('input:checkbox').attr 'checked', $(this).is(':checked')

