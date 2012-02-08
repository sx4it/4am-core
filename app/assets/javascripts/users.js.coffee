# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

	$("#users th a, #users .pagination a").live "click", ->
    #$.getScript @href
		console.log 'here'
		jQuery.getJSON @href, null, (data) ->
		  console.log data
		false

	delay = (->
		timer = 0
		(callback, ms) ->
			clearTimeout timer
			timer = setTimeout(callback, ms)
	)()

	$("#users_search input").keyup ->
		console.log "INPUT"
		delay (->
			console.log "SEARCH"
			$.get $("#users_search").attr("action"), $("#users_search").serialize(), null, "script"
  	), 200
		false
