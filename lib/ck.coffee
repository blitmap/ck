#[coffeekup](http://github.com/mauricemach/coffeekup) rewrite

doctypes =
  '1.1':          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  '5':            '<!DOCTYPE html>'
  'basic':        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'frameset':     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  'mobile':       '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  'strict':       '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'xml':          '<?xml version="1.0" encoding="utf-8" ?>'

tagsNormal = 'a abbr acronym address applet article aside audio b bdo big blockquote body button canvas caption center cite code colgroup command datalist dd del details dfn dir div dl dt em embed fieldset figcaption figure font footer form frameset h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins keygen kbd label legend li map mark menu meter nav noframes noscript object ol optgroup option output p pre progress q rp rt ruby s samp script section select small source span strike strong style sub summary sup table tbody td textarea tfoot th thead time title tr tt u ul var video wbr xmp'.split ' '
tagsSelfClosing = 'area base basefont br col frame hr img input link meta param'.split ' '

html = null

context = {}

makeIsType = (typename, constructor) -> (x) -> typeof x is typename or x instanceof constructor
isString   = makeIsType 'string', String
isFunction = makeIsType 'function', Function

escapeXML = (str) ->
  str.replace /[&<>"']/g, (c) ->
    switch c
      when '&' then '&amp;'
      when '<' then '&lt;'
      when '>' then '&gt;'
      when '"' then '&quot;'
      when "'" then '&#39;'

nest = (arg) ->
  if isFunction arg
    arg = arg.call context

  if isString arg
    html += arg
#    html += if options.autoescape then scope.esc arg else arg

compileTag = (tag, selfClosing) ->
  scope[tag] = (args...) ->
    html += "<#{tag}"

    if args[0]? and typeof args[0] is 'object'
      # truthyness test that includes +0, -0, NaN, ''
      for attr, val of args.shift() when val? and val isnt false
        html += " #{attr}=\"#{val}\""

    html += ">"

    return if selfClosing

    nest arg for arg in args

    html += "</#{tag}>"

    return

scope =
  coffeescript: (fn) ->
    @script fn.toString().replace 'function () ', ''
    return
  comment: (str) ->
    html += "<!--#{str}-->"
    return
  doctype: (key=5) ->
    html += doctypes[key]
    return
  esc: (str) ->
    return escapeXML str
  ie: (expr, arg) ->
    html += "<!--[if #{expr}]>#{nest arg}<![endif]-->"
    return

for tag in tagsNormal
  compileTag tag, false # don't self close
for tag in tagsSelfClosing
  compileTag tag, true # self close

@compile = (code) ->
  code = code.toString().replace 'function () ', ''

  fn = Function 'scope', "with (scope) { #{code} }"
  (_context) ->
    context = _context
    html    = ''
    fn.call _context, scope
    html
