




############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/MKTS-interim'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
ASYNC                     = require 'async'
#...........................................................................................................
ƒ                         = CND.format_number.bind CND
HELPERS                   = require './HELPERS'
TYPO                      = HELPERS[ 'TYPO' ]
# options                   = require './options'
TEXLIVEPACKAGEINFO        = require './TEXLIVEPACKAGEINFO'
options_route             = '../options.coffee'
{ CACHE, OPTIONS, }       = require './OPTIONS'
SEMVER                    = require 'semver'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@compile_options = ->
  options_locator                   = require.resolve njs_path.resolve __dirname, options_route
  # debug '©zNzKn', options_locator
  options_home                      = njs_path.dirname options_locator
  @options                          = OPTIONS.from_locator options_locator
  @options[ 'home' ]                = options_home
  @options[ 'locator' ]             = options_locator
  cache_route                       = @options[ 'cache' ][ 'route' ]
  @options[ 'cache' ][ 'locator' ]  = cache_locator = njs_path.resolve options_home, cache_route
  @options[ 'xelatex-command' ]     = njs_path.resolve options_home, @options[ 'xelatex-command' ]
  #.........................................................................................................
  unless njs_fs.existsSync cache_locator
    @options[ 'cache' ][ '%self' ] = {}
    CACHE.save options
  #.........................................................................................................
  @options[ 'cache' ][ '%self' ]    = require cache_locator
  #.........................................................................................................
  if ( texinputs_routes = @options[ 'texinputs' ]?[ 'routes' ] )?
    locators = []
    for route in texinputs_routes
      has_single_slash  = ( /\/$/   ).test route
      has_double_slash  = ( /\/\/$/ ).test route
      locator           = njs_path.resolve options_home, route
      if      has_double_slash then locator += '//'
      else if has_single_slash then locator += '/'
      locators.push locator
    ### TAINT duplication: tex_inputs_home, texinputs_value ###
    ### TAINT path separator depends on OS ###
    @options[ 'texinputs' ][ 'value' ] = locators.join ':'
  # @options[ 'locators' ] = {}
  # for key, route of @options[ 'routes' ]
  #   @options[ 'locators' ][ key ] = njs_path.resolve options_home, route
  #.........................................................................................................
  # debug '©ed8gv', JSON.stringify @options, null, '  '
  CACHE.update options
#...........................................................................................................
@compile_options()

#-----------------------------------------------------------------------------------------------------------
@write_mkts_master = ( layout_info, handler ) ->
  step ( resume ) =>
    lines             = []
    write             = lines.push.bind lines
    master_locator    = layout_info[ 'master-locator'  ]
    content_locator   = layout_info[ 'content-locator' ]
    help "writing #{master_locator}"
    #-------------------------------------------------------------------------------------------------------
    write ""
    write "% #{master_locator}"
    write "% do not edit this file"
    write "% generated from #{@options[ 'locator' ]}"
    write ""
    write "\\documentclass[a4paper,twoside]{book}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    # DEFS
    #.......................................................................................................
    defs = @options[ 'defs' ]
    write ""
    write "% DEFS"
    if defs?
      write "\\def\\#{name}{#{value}}" for name, value of defs
    #-------------------------------------------------------------------------------------------------------
    # NEWCOMMANDS
    #.......................................................................................................
    newcommands = @options[ 'newcommands' ]
    write ""
    write "% NEWCOMMANDS"
    if newcommands?
      for name, value of newcommands
        warn "implicitly converting newcommand value for #{name}"
        value = njs_path.resolve __dirname, '..', value
        write "\\newcommand{\\#{name}}{%\n#{value}%\n}"
    #-------------------------------------------------------------------------------------------------------
    # PACKAGES
    #.......................................................................................................
    write ""
    write "% PACKAGES"
    write "\\usepackage{cxltx-style-base}"
    write "\\usepackage{cxltx-style-trm}"
    # write "\\usepackage{cxltx-style-accentbox}"
    write "\\usepackage{cxltx-style-pushraise}"
    write "\\usepackage{cxltx-style-hyphenation-tolerance}"
    write "\\usepackage{cxltx-style-oddeven}"
    write "\\usepackage{cxltx-style-position-absolute}"
    write "\\usepackage{cxltx-style-pushraise}"
    write "\\usepackage{cxltx-style-smashbox}"
    write "\\usepackage{mkts2015-main}"
    write "\\usepackage{mkts2015-fonts}"
    write "\\usepackage{mkts2015-article}"

    #-------------------------------------------------------------------------------------------------------
    # FONTS
    #......................................................................................................
    fontspec_version  = yield TEXLIVEPACKAGEINFO.read_texlive_package_version @options, 'fontspec', resume
    use_new_syntax    = SEMVER.satisfies fontspec_version, '>=2.4.0'
    fonts_home        = @options[ 'fonts' ][ 'home' ]
    #.......................................................................................................
    write ""
    write "% FONTS"
    write "% assuming fontspec@#{fontspec_version}"
    write "\\usepackage{fontspec}"
    #.......................................................................................................
    for { texname, home, filename, } in @options[ 'fonts' ][ 'files' ]
      home ?= fonts_home
      if use_new_syntax
        ### TAINT should properly escape values ###
        write "\\newfontface{\\#{texname}}{#{filename}}[Path=#{home}/]"
        # write "\\newcommand{\\#{texname}}{"
        # write "\\typeout{\\trmWhite{redefining #{texname}}}"
        # write "\\newfontface{\\#{texname}XXX}{#{filename}}[Path=#{home}/]"
        # write "\\renewcommand{\\#{texname}}{\\#{texname}XXX}"
        # write "}"
      else
        write "\\newfontface\\#{texname}[Path=#{home}/]{#{filename}}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    # STYLES
    #......................................................................................................
    write ""
    write "% STYLES"
    if ( styles = @options[ 'styles' ] )?
      write "\\newcommand{\\#{name}}{%\n#{value}%\n}" for name, value of styles
    #-------------------------------------------------------------------------------------------------------
    main_font_name = @options[ 'fonts' ][ 'main' ]
    throw new Error "need entry options/fonts/name" unless main_font_name?
    write ""
    write "% CONTENT"
    write "\\begin{document}#{main_font_name}"
    #-------------------------------------------------------------------------------------------------------
    # INCLUDES
    #.......................................................................................................
    write ""
    write "\\input{#{content_locator}}"
    write ""
    #-------------------------------------------------------------------------------------------------------
    write "\\end{document}"
    #-------------------------------------------------------------------------------------------------------
    text = lines.join '\n'
    # whisper text
    njs_fs.writeFile master_locator, text, handler


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@pdf_from_md = ( source_route, handler ) ->
  step ( resume ) =>
    handler                ?= ->
    layout_info             = HELPERS.new_layout_info @options, source_route
    yield @write_mkts_master layout_info, resume
    source_locator          = layout_info[ 'source-locator'  ]
    content_locator         = layout_info[ 'content-locator' ]
    tex_output              = njs_fs.createWriteStream content_locator
    # debug '©y9meI', layout_info
    # process.exit()
    ### TAINT should read MD source stream ###
    text                    = njs_fs.readFileSync source_locator, encoding: 'utf-8'
    #---------------------------------------------------------------------------------------------------------
    state =
      within_multicol:      no
      within_keeplines:     no
      within_pre:           no
      within_single_column: no
      layout_info:          layout_info
    #---------------------------------------------------------------------------------------------------------
    tex_output.on 'close', =>
      HELPERS.write_pdf layout_info, ( error ) =>
        throw error if error?
        handler null if handler?
    #---------------------------------------------------------------------------------------------------------
    input = TYPO.create_mdreadstream text
    input
      # .pipe TYPO.$resolve_html_entities()
      .pipe TYPO.$fix_typography_for_tex()
      .pipe TYPO.$show_mktsmd_events()
      .pipe @MKTX.DOCUMENT.$open          state
      .pipe @MKTX.COMMAND.$new_page       state
      # .pipe @MKTX.REGION.$single_column   state
      .pipe @MKTX.REGION.$keep_lines      state
      .pipe @MKTX.BLOCK.$heading          state
      .pipe @MKTX.BLOCK.$paragraph        state
      .pipe @MKTX.BLOCK.$hr               state
      # .pipe D.$show()
      .pipe @MKTX.INLINE.$code            state
      .pipe @MKTX.INLINE.$em_and_strong   state
      .pipe @MKTX.DOCUMENT.$close         state
      .pipe @$filter_tex()
      .pipe tex_output
    #---------------------------------------------------------------------------------------------------------
    # D.resume input
    input.resume()
    # debug '©Fad1u', TYPO.get_meta input

#-----------------------------------------------------------------------------------------------------------
@MKTX =
  DOCUMENT:   {}
  COMMAND:    {}
  REGION:     {}
  BLOCK:      {}
  INLINE:     {}

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless TYPO.isa event, '∆', 'new-page'
    # [ type, name, text, meta, ] = event
    send [ 'tex', "\\null\\newpage{}", ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$open = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '{', 'document'
      send [ 'tex', "\n% begin of MD document\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$close = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '}', 'document'
      send [ 'tex', "\n% end of MD document\n", ]
    #.......................................................................................................
    else
      send event

### Pending ###
# #-----------------------------------------------------------------------------------------------------------
# @MKTX.change_column_count = ( S, send, end ) =>

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.REGION.$single_column = ( S ) =>
#   ### TAINT consider to implement command `change_column_count = ( send, n )` ###
#   #.........................................................................................................
#   return $ ( event, send, end ) =>
#     if event?
#       if TYPO.isa event, [ '{', '}', ], 'single-column'
#         [ type, name, text, meta, ] = event
#         #...................................................................................................
#         if type is '{'
#           send [ 'tex', '% ### MKTS @@@single-column ###\n', ]
#           debug '©x1ESw', '---------------------------single-column('
#           S.within_single_column = yes
#           if S.within_multicol
#             send [ 'tex', '\\end{multicols}' ]
#             S.within_multicol = no
#           send [ 'tex', '\n\n', ]
#         #...................................................................................................
#         else
#           debug '©x1ESw', ')single-column---------------------------'
#           send [ 'tex', '\\begin{multicols}{2}\n' ]
#           S.within_multicol       = yes
#           S.within_single_column  = no
#       #.....................................................................................................
#       else
#         send event
#     #.......................................................................................................
#     if end?
#       if S.within_multicol
#         send [ 'tex', '\\end{multicols}' ]
#         S.within_multicol = no
#       end()
#     #.......................................................................................................
#     return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$keep_lines = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '.', 'text'
      ### TAINT differences between pre and keep-lines? ###
      [ type, name, text, meta, ] = event
      # if S.within_keeplines
      #   text = text.replace /\n\n/g, '~\\\\\n'
      if S.within_pre
        text = text.replace /\u0020/g, '\u00a0'
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if TYPO.isa event, [ '{', '}', ], 'keep-lines'
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        # send [ 'tex', '% ### MKTS @@@keep-lines ###\n', ]
        S.within_pre        = yes
        S.within_keeplines  = yes
        send [ 'tex', "\\begingroup\\obeyalllines{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
        S.within_keeplines    = no
        S.within_pre          = no
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  restart_multicols = no
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '[', ']', ], [ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', ]
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      # OPEN
      #.....................................................................................................
      if type is '['
        #...................................................................................................
        ### TAINT Pending
        if S.within_multicol and name in [ 'h1', 'h2', ]
          send [ 'tex', '\\end{multicols}' ]
          S.within_multicol = no
          restart_multicols = yes
        ###
        #...................................................................................................
        send [ 'tex', "\n", ]
        #...................................................................................................
        switch name
          when 'h1' then  send [ 'tex', "\\chapter{", ]
          when 'h2' then  send [ 'tex', "\\section{", ]
          else            send [ 'tex', "\\subsection{", ]
      #.....................................................................................................
      # CLOSE
      #.....................................................................................................
      else
        ### Placing the closing brace on a new line seems to improve line breaking ###
        send [ 'tex', "\n", ]
        send [ 'tex', "}", ]
        send [ 'tex', "\n", ]
        ### TAINT Pending
        if restart_multicols
          send [ 'tex', '\\begin{multicols}{2}\n' ]
          S.within_multicol = yes
        ###
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '[', ']', ], 'p'
      [ type, name, text, meta, ] = event
      if type is '['
        send [ 'text', '\n\n' ]
      else
        send [ 'tex', '\\par' ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$hr = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '.', 'hr'
      [ type, name, text, meta, ] = event
      switch chr = text[ 0 ]
        when '-' then send [ 'text', '\n--------------\n' ]
        when '*' then send [ 'text', '\n**************\n' ]
        else warn "ignored hr markup #{rpr text}"
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$code = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '(', ')', ], 'code'
      [ type, name, text, meta, ] = event
      ### TAINT should use proper command ###
      if type is '(' then send [ 'tex', "{\\mktsFontfileSourcecodeproregular{}", ]
      else                send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$em_and_strong = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '(', ')', ], [ 'em', 'strong', ]
      [ type, name, text, meta, ] = event
      if type is '('
        if name is 'em'
          send [ 'tex', '\\textit{', ]
        else
          send [ 'tex', '\\bold{', ]
      else
        send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$filter_tex = ->
  return $ ( event, send ) =>
    if event[ 0 ] in [ 'tex', 'text', ]
      send event[ 1 ]
    else if TYPO.isa event, '.', 'text'
      send event[ 2 ]
    else
      warn "unhandled event: #{JSON.stringify event}"




############################################################################################################
unless module.parent?
  # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
  @pdf_from_md 'texts/demo'

  # debug '©nL12s', TYPO.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
  # debug '©nL12s', TYPO.as_tex_text 'helo さし'
  # event = [ '{', 'single-column', ]
  # event = [ '}', 'single-column', ]
  # event = [ '{', 'new-page', ]
  # debug '©Gpn1J', TYPO.isa event, [ '{', '}'], [ 'single-column', 'new-page', ]

