
# Create dualselect control for group selection
$(document).ready ->

  # Change groups select tag
  $('#SELTEST').dualselect sorted: true

  # Activate tooltips
  $('.ds .select a, .ds .ds-control a').tooltip()

  # Activate tabs
  $('.nav.nav-tabs a:first').tab('show')
