
###
 Dual Select JQuery Widget
 @author Giancarlo Bellido

 Options:
 	sorted       Boolean. Determines whether the list is sorted or not.

 https://github.com/giancarlo/ph-jquery/blob/master/js/dualselect.js
###

jQuery.widget "ui.dualselect",

  container: null
  s0: null #Searchbox
  c0: null #Container
  l0: null #List
  t0: null #Toolbar
  s1: null
  c1: null
  l1: null
  t1: null

  _init_components: ->
    @c0 = document.createElement("DIV")
    @c1 = document.createElement("DIV")
    @l0 = document.createElement("UL")
    @l1 = document.createElement("UL")
    @t0 = document.createElement("DIV")
    @t1 = document.createElement("DIV")
    @s0 = document.createElement("DIV")
    @s1 = document.createElement("DIV")
    @_init_search @s0, @l0
    @_init_search @s1, @l1

  _init_search: (sb, list) ->
    self = this
    $(sb).html("""<input type='text' />""").children().keyup(->
      self.search this, list
    )


  _init: ->
    @container = $("""<div id="#{ @element.attr("id") }" class='dual-select'></div>""")
    @container.data "dualselect", @element.data("dualselect")
    self = this
    @_init_components()

    # Populate the two lists
    @element.children().each (i) =>
      li = """<li value="#{ @value }" class="#{ @className }" index="#{ i } " onclick="$(this).toggleClass('selected')">#{ @innerHTML }</li>"""
      $((if @selected then @l1 else @l0)).append li


    @container.append(@c0).append @c1
    @c0.appendChild @l0
    @c0.appendChild @s0
    @c0.appendChild @t0
    @c1.appendChild @l1
    @c1.appendChild @s1
    @c1.appendChild @t1
    $(@t0).html("""
      <button type="button" class="ui-corner-all add">Add</button>
      """).addClass("toolbar").children(".add").click ->
      self.add()

    $(@t1).html("""
      <button type="button" class="ui-corner-all remove">Remove</button>
    """).addClass("toolbar").children(".remove").click ->
      self.remove()

    @element.before(@container).remove()
    @element = @container

  add: (indices) ->
    @move @notSelected(".selected:visible").removeClass("selected"), @l1


  move: (elements, list) ->
    if @options.sorted
      l2 = $(list).children()
      return $(list).append(elements) if l2.length is 0
      elements.each ->
        i = 0
        a = @getAttribute("index") * 1
        i = i + 1  while a > (l2.eq(i).attr("index") * 1)
        if i is l2.length
          $(list).append this
        else
          l2.eq(i).before this
    else
      $(list).append elements

  remove: ->
    @move @selected(".selected:visible").removeClass("selected"), @l0

  selected: (selector) ->
    $(@l1).children selector

  notSelected: (selector) ->
    $(@l0).children selector

  search: (input, list) ->
    regex = new RegExp(input.value, "i")
    $(list).children().show().each ->
      $(this).hide() unless regex.test($(this).text())

  values: ->
    v = []
    @selected().each ->
      v.push @getAttribute("value")
    console.log("VALUES", v)
    alert("WAZA")
    v

  selectedText: ->
    v = []
    @selected().each ->
      v.push $(this).text()
    console.log("SELECTED TEXT", v)
    v

  selectedHtml: ->
    v = []
    @selected().each ->
      v.push $(this).html()
    console.log("SELECTED HTML", v)
    v

jQuery.ui.dualselect.getter = [ "selected", "notSelected", "values", "selectedText", "selectedHtml" ]
