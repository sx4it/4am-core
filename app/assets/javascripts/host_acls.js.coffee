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
  $("input[data-autocomplete]").each (i, u) ->
    $(u).autocomplete().data("autocomplete")._renderItem = (ul, item) ->
      type = "user" if (item.type == "User")
      type = "group" if (item.type == "UserGroup")
      type = "host" if (item.type == "Host")
      type = "group" if (item.type == "HostGroup")
      $( "<li></li>" ).data( "item.autocomplete", item).append( $( "<a></a>" ).text(" " + item.label ).prepend("<i class='custom-icon icon_" + type + "'>") ).appendTo( ul )
