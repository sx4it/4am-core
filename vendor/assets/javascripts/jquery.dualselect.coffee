# https://github.com/giancarlo/ph-jquery/blob/master/js/dualselect.js

jQuery.widget "ui.dualselect",
  container: null
  sbl: null
  sbr: null
  lc: null
  ll: null
  lt: null
  rc: null
  rl: null
  rt: null
  _init_components: ->
    @lc = document.createElement("DIV")
    @rc = document.createElement("DIV")
    @ll = document.createElement("UL")
    @rl = document.createElement("UL")
    @lt = document.createElement("DIV")
    @rt = document.createElement("DIV")
    @sbl = document.createElement("DIV")
    @sbr = document.createElement("DIV")
    @_init_search @sbl, @ll
    @_init_search @sbr, @rl

  _init_search: (sb, list) ->
    self = this
    $(sb).addClass("toolbar").html("""
      <span style="float:right" class="ui-icon ui-icon-close"></span>
      <input type='text' />
    """).hide().children().eq(1).keyup(->
      self.search this, list
    ).prev().click ->
      self.closeSearch sb, list

  _init_size: ->
    _calculateHeight = (obj) ->
      size = obj.attr("size")
      (if (size) then size * 25 else 125)

    @rl.style.height = _calculateHeight(@element) + "px"
    @ll.style.height = @rl.style.height

  _init_elements: ->
    self = this
    @element.children().each (i) ->
      li = "<li value="#{ @value }" class="#{ @className }" index="#{ i } " onclick="$(this).toggleClass('selected')">#{ @innerHTML }</li>"
      $((if @selected then self.rl else self.ll)).append li

  _init: ->
    @container = $("<div id='#{ @element.attr("id") }' class='dual-select'></div>")
    @container.data "dualselect", @element.data("dualselect")
    self = this
    @_init_components()
    @_init_elements()
    @container.append(@lc).append @rc
    @lc.appendChild @ll
    @lc.appendChild @sbl
    @lc.appendChild @lt
    @rc.appendChild @rl
    @rc.appendChild @sbr
    @rc.appendChild @rt
    $(@lt).html("""
      <button type="button" class="ui-corner-all search">Search</button>
      <button type="button" class="ui-corner-all add">Add</button>
      """).addClass("toolbar").children(".add").click ->
      self.add()

    $(@lt).children(".search").click ->
      self.showSearch self.sbl, self.ll

    $(@rt).html("""
      <button type="button" class="ui-corner-all search">Search</button>
      <button type="button" class="ui-corner-all remove">Remove</button>
    """).addClass("toolbar").children(".remove").click ->
      self.remove()

    $(@rt).children(".search").click ->
      self.showSearch self.sbr, self.rl

    @_init_size()
    @element.before(@container).remove()
    @element = @container

  add: (indices) ->
    @move @notSelected(".selected:visible").removeClass("selected"), @rl

  _sort: (elements) ->

  move: (elements, list) ->
    if @options.sorted
      l2 = $(list).children()
      return $(list).append(elements)  if l2.length is 0
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
    @move @selected(".selected:visible").removeClass("selected"), @ll

  selected: (selector) ->
    $(@rl).children selector

  notSelected: (selector) ->
    $(@ll).children selector

  search: (input, list) ->
    regex = new RegExp(input.value, "i")
    $(list).children().show().each ->
      $(this).hide()  unless regex.test($(this).text())

  resetSearch: (list) ->
    $(list).children().show()

  showSearch: (sb, list) ->
    if $(sb).is(":visible")
      @closeSearch sb, list
    else
      $(sb).show()
      $(list).height $(list).height() - $(sb).outerHeight()

  closeSearch: (sb, list) ->
    $(list).height $(list).height() + $(sb).outerHeight()
    $(sb).hide()
    @resetSearch list

  values: ->
    v = []
    @selected().each ->
      v.push @getAttribute("value")
    v

  selectedText: ->
    v = []
    @selected().each ->
      v.push $(this).text()
    v

  selectedHtml: ->
    v = []
    @selected().each ->
      v.push $(this).html()
    v

jQuery.ui.dualselect.getter = [ "selected", "notSelected", "values", "selectedText", "selectedHtml" ]
