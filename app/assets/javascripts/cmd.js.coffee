# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/S
#
updateOldCommands = ->
  id = $(".modal.in").attr('id')
  scroll = $(".modal-body").scrollTop()
  bottom = false
  elem = $(".modal-body")
  if elem && elem[0].scrollHeight - scroll == elem.outerHeight()
    bottom = true

  $.getScript $("#refresh").attr("href") + ".js", ->
    $('.modal-backdrop').hide()
    $("#" + id).modal("show")
    if bottom
      $(".modal-body").scrollTop($(".modal-body")[0].scrollHeight)
    else
      $(".modal-body").scrollTop(scroll)
  if $("#OldCommands").length > 0
    setTimeout updateOldCommands, 5000

$ ->
  if $("#OldCommands").length > 0
    setTimeout updateOldCommands, 5000
