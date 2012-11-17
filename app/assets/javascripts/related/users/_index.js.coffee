$ ->
  $('.check_all').click ->
    $(this).parents('table').find('input:checkbox').attr 'checked', $(this).is(':checked')

  $("#users th a, #users .pagination a").live "click", ->
    $.getScript @href
    false

  delay = (->
    timer = 0
    (callback, ms) ->
      clearTimeout timer
      timer = setTimeout(callback, ms)
  )()

  $("#users_search input").keyup ->
    delay (->
      $.get $("#users_search").attr("action"), $("#users_search").serialize(), null, "script"
    ), 200
    false
