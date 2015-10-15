




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
MKTS                      = require './MKTS'
# options                   = require './options'
TEXLIVEPACKAGEINFO        = require './TEXLIVEPACKAGEINFO'
options_route             = '../options.coffee'
{ CACHE, OPTIONS, }       = require './OPTIONS'
SEMVER                    = require 'semver'



#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@compile_options = ->
  ### TAINT this method should go to OPTIONS ###
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
  CACHE.update @options
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
@MKTX =
  DOCUMENT:   {}
  COMMAND:    {}
  REGION:     {}
  BLOCK:      {}
  INLINE:     {}

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.$protocoll = ( S ) =>
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     if S.write_protocoll
#       [ type, name, text, meta, ] = event
#       line_nr = meta[ 'map' ]?[ 0 ] ? '?'
#       send [ 'text', "% #{line_nr} #{type}#{name}" ]
#     send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$definition = ( S ) =>
  ### TAINT reject nested definitions ###
  # ### Must start `<literal>` (?) section on command definition ###
  track       = MKTS.TRACKER.new_tracker '(:)', '[:]'
  identifier  = null
  values      = {}
  #.........................................................................................................
  return $ ( event, send ) =>
    within_definition = track.within '(:)', '[:]'
    track event
    #.......................................................................................................
    if MKTS.isa event, [ '(', '[', ], ':'
      [ type, _, identifier, meta, ] = event
      send @stamp event
      urge '©Rnsg0', event
    else if MKTS.isa event, [ ')', ']', ], ':'
      # [ type, _, identifier, meta, ] = event
      send @stamp event
      urge '©YON2b', event
    #.......................................................................................................
    else if within_definition
      urge '©S63sG', identifier
      urge '©S63sG', event
      ( values[ identifier ]?= [] ).push event
      # xxxx
      ### TAINT `MKTS.isa` must not match stamped events ###
      send @stamp event
      # [ type, name, text, meta, ] = event
      # send [ '?', name, text, meta, ]
    #.......................................................................................................
    else if MKTS.isa event, '∆'
      if ( definition = values[ identifier ] )?
        send @stamp event
        send sub_event for sub_event in definition
      else
        send event
    #.......................................................................................................
    else
      debug '©YLxXy', event
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless MKTS.isa event, '∆', 'new-page'
    send [ 'tex', "\\null\\newpage{}", ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$begin= ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, '<', 'document'
      send @stamp event
      send [ 'tex', "\n% begin of MD document\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.DOCUMENT.$end = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, '>', 'document'
      send @stamp event
      send [ 'tex', "\n% end of MD document\n", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION._begin_multi_column  = ( meta ) =>
  ### TAINT Column count must come from layout / options / MKTS-MD command ###
  return [ 'tex', '\\begin{multicols}{2}' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION._end_multi_column    = ( meta ) =>
  return [ 'tex', '\\end{multicols}' ]

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$multi_column = ( S ) =>
  track = MKTS.TRACKER.new_tracker '{multi-column}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    if MKTS.isa event, [ '{', '}', ], 'multi-column'
      send @stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        if within_multi_column
          whisper "ignored #{type}#{name}"
        else
          send track @MKTX.REGION._begin_multi_column()
      #.....................................................................................................
      else
        if within_multi_column
          send track @MKTX.REGION._end_multi_column()
        else
          whisper "ignored #{type}#{name}"
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$single_column = ( S ) =>
  ### TAINT consider to implement command `change_column_count = ( send, n )` ###
  track = MKTS.TRACKER.new_tracker '{multi-column}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if MKTS.isa event, [ '{', '}', ], 'single-column'
      send @stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        if within_multi_column
          send track @MKTX.REGION._end_multi_column()
        else
          whisper "ignored #{type}#{name}"
      #.....................................................................................................
      else
        if within_multi_column
          send track @MKTX.REGION._begin_multi_column()
        else
          whisper "ignored #{type}#{name}"
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$correct_p_tags_before_regions = ( S ) =>
  last_was_p              = no
  last_was_begin_document = no
  #.........................................................................................................
  return $ ( event, send ) =>
    # debug '©MwBAv', event
    #.......................................................................................................
    if MKTS.isa event, 'tex'
      send event
    #.......................................................................................................
    else if MKTS.isa event, '<', 'document'
      # debug '©---1', last_was_begin_document
      # debug '©---2', last_was_p
      last_was_p              = no
      last_was_begin_document = yes
      send event
    #.......................................................................................................
    else if MKTS.isa event, '.', 'p'
      # debug '©---3', last_was_begin_document
      # debug '©---4', last_was_p
      last_was_p              = yes
      last_was_begin_document = no
      send event
    #.......................................................................................................
    else if MKTS.isa event, [ '{', '[', ]
      # debug '©---5', last_was_begin_document
      # debug '©---6', last_was_p
      if ( not last_was_begin_document ) and ( not last_was_p )
        [ ..., meta, ] = event
        send [ '.', 'p', null, ( MKTS._copy meta ), ]
      send event
      last_was_p              = no
      last_was_begin_document = no
    #.......................................................................................................
    else
      last_was_p              = no
      last_was_begin_document = no
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$keep_lines = ( S ) =>
  track = MKTS.TRACKER.new_tracker '{keep-lines}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_keep_lines = track.within '{keep-lines}'
    track event
    #.......................................................................................................
    if MKTS.isa event, '.', 'text'
      [ type, name, text, meta, ] = event
      ### TAINT other replacements possible; use API ###
      ### TAINT U+00A0 (nbsp) might be too wide ###
      text = text.replace /\u0020/g, '\u00a0' if within_keep_lines
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if MKTS.isa event, [ '{', '}', ], 'keep-lines'
      send @stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        track.enter '{keep-lines}'
        send [ 'tex', "\\begingroup\\obeyalllines{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
        track.leave '{keep-lines}'
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$code = ( S ) =>
  ### TAINT code duplication with `REGION.$keep_lines` possible ###
  track = MKTS.TRACKER.new_tracker '{code}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code = track.within '{code}'
    track event
    #.......................................................................................................
    if MKTS.isa event, '.', 'text'
      [ type, name, text, meta, ] = event
      if within_code
        text = text.replace /\u0020/g, '\u00a0'
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if MKTS.isa event, [ '{', '}', ], 'code'
      send @stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        send [ 'tex', "\\begingroup\\obeyalllines\\mktsStyleCode{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$remove_empty_p_tags = ( S ) =>
  text_count = 0
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, [ ']', '}', ]
      text_count = 0
      send event
    #.......................................................................................................
    else if MKTS.isa event, '.', 'text'
      text_count += +1
      send event
    #.......................................................................................................
    else if MKTS.isa event, '.', 'p'
      if text_count > 0 then send event
      else whisper "ignoring empty `p` tag"
      text_count = 0
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  restart_multicols = no
  track             = MKTS.TRACKER.new_tracker '{multi-column}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_multi_column = track.within '{multi-column}'
    track event
    #.......................................................................................................
    if MKTS.isa event, [ '[', ']', ], [ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', ]
      send @stamp event
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      # OPEN
      #.....................................................................................................
      if type is '['
        #...................................................................................................
        if within_multi_column and ( name in [ 'h1', 'h2', ] )
          send track @MKTX.REGION._end_multi_column meta
          restart_multicols = yes
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
        if restart_multicols
          send track @MKTX.REGION._begin_multi_column meta
          restart_multicols = no
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph = ( S ) =>
  ### TAINT should unify the two observers ###
  track = MKTS.TRACKER.new_tracker '{code}', '{keep-lines}'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_code       = track.within '{code}'
    within_keep_lines = track.within '{keep-lines}'
    track event
    #.......................................................................................................
    if MKTS.isa event, '.', 'p'
      [ type, name, text, meta, ] = event
      if within_code or within_keep_lines
        send @stamp event
        send [ 'text', '\n\n' ]
      else
        send @stamp event
        ### TAINT use command from sty ###
        ### TAINT make configurable ###
        send [ 'tex', '\\mktsShowpar\\par\n' ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$hr = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, '.', 'hr'
      send @stamp event
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
    if MKTS.isa event, [ '(', ')', ], 'code'
      send @stamp event
      [ type, name, text, meta, ] = event
      if type is '('
        send [ 'tex', '{\\mktsStyleCode{}', ]
      else
        send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$latex = ( S ) =>
  track = MKTS.TRACKER.new_tracker '(latex)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_latex = track.within '(latex)'
    track event
    #.......................................................................................................
    if within_latex and MKTS.isa event, '.', 'text'
      [ type, name, text, meta, ] = event
      raw_text = meta[ 'raw' ]
      ### TAINT could the added `{}` conflict with some (La)TeX commands? ###
      send @stamp [ '.', 'latex', raw_text, meta, ]
    #.......................................................................................................
    else if MKTS.isa event, [ '(', ')', ], 'latex'
      send @stamp event
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$translate_i_and_b = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, [ '(', ')', ], [ 'i', 'b', ]
      [ type, name, text, meta, ] = event
      new_name = if name is 'i' then 'em' else 'strong'
      send [ type, new_name, text, meta, ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$em_and_strong = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if MKTS.isa event, [ '(', ')', ], [ 'em', 'strong', ]
      send @stamp event
      [ type, name, text, meta, ] = event
      if type is '('
        if name is 'em'
          send [ 'tex', '{\\mktsStyleItalic{}', ]
        else
          send [ 'tex', '{\\mktsStyleBold{}', ]
      else
        send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$show_unhandled_tags = ( S ) ->
  return $ ( event, send ) =>
    ### TAINT selection could be simpler, less repetitive ###
    if event[ 0 ] in [ 'tex', 'text', ]
      send event
    else if MKTS.isa event, '.', 'text'
      send event
    else unless @is_stamped event
      [ type, name, text, meta, ] = event
      if text?
        if ( CND.isa_pod text )
          if ( Object.keys text ).length is 0
            text = ''
          else
            text = rpr text
      else
        text = ''
      if type in MKTS.FENCES.xleft
        [ first, last, ]  = [ type, name, ]
        pre               = '█'
        post              = ''
      else
        [ first, last, ]  = [ name, type, ]
        pre               = ''
        post              = '█'
      event_txt         = first + last + text
      event_tex         = MKTS.fix_typography_for_tex event_txt, @options
      ### TAINT use mkts command ###
      send [ 'tex', "{\\mktsStyleBold\\color{violet}{\\mktsStyleSymbol#{pre}}#{event_tex}{\\mktsStyleSymbol#{post}}}" ]
      send event
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$filter_tex = ->
  return $ ( event, send ) =>
    if event[ 0 ] in [ 'tex', 'text', ]
      send event[ 1 ]
    else if MKTS.isa event, '.', [ 'text', 'latex', ]
      send event[ 2 ]
    else
      warn "unhandled event: #{JSON.stringify event}" unless @is_stamped event

#-----------------------------------------------------------------------------------------------------------
@stamp = ( event ) ->
  event[ 3 ][ 'stamped' ] = yes
  return event

#-----------------------------------------------------------------------------------------------------------
@is_stamped = ( event ) -> event[ 3 ][ 'stamped' ] is true

#===========================================================================================================
# PDF FROM MD
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
      # write_protocoll:      yes
      options:              @options
      layout_info:          layout_info
    #---------------------------------------------------------------------------------------------------------
    tex_output.on 'close', =>
      HELPERS.write_pdf layout_info, ( error ) =>
        throw error if error?
        handler null if handler?
    #---------------------------------------------------------------------------------------------------------
    input = MKTS.create_mdreadstream text
    input
      .pipe MKTS.$fix_typography_for_tex                    @options
      .pipe @MKTX.DOCUMENT.$begin                           state
      .pipe @MKTX.COMMAND.$definition                       state
      .pipe @MKTX.COMMAND.$new_page                         state
      .pipe @MKTX.REGION.$correct_p_tags_before_regions     state
      .pipe @MKTX.REGION.$multi_column                      state
      .pipe @MKTX.REGION.$single_column                     state
      .pipe @MKTX.REGION.$keep_lines                        state
      .pipe @MKTX.REGION.$code                              state
      .pipe @MKTX.BLOCK.$remove_empty_p_tags                state
      .pipe @MKTX.BLOCK.$heading                            state
      .pipe @MKTX.BLOCK.$paragraph                          state
      .pipe @MKTX.BLOCK.$hr                                 state
      # .pipe D.$show()
      .pipe @MKTX.INLINE.$code                              state
      .pipe @MKTX.INLINE.$latex                             state
      .pipe @MKTX.INLINE.$translate_i_and_b                 state
      .pipe @MKTX.INLINE.$em_and_strong                     state
      .pipe @MKTX.DOCUMENT.$end                             state
      .pipe MKTS.$show_mktsmd_events                        state
      .pipe MKTS.$write_mktscript                           state
      .pipe @$show_unhandled_tags                           state
      .pipe @$filter_tex()
      .pipe tex_output
    #---------------------------------------------------------------------------------------------------------
    # D.resume input
    input.resume()
    # debug '©Fad1u', MKTS.get_meta input




############################################################################################################
unless module.parent?
  # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
  @pdf_from_md 'texts/demo'

  # debug '©nL12s', MKTS.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
  # debug '©nL12s', MKTS.as_tex_text 'helo さし'
  # event = [ '{', 'single-column', ]
  # event = [ '}', 'single-column', ]
  # event = [ '{', 'new-page', ]
  # debug '©Gpn1J', MKTS.isa event, [ '{', '}'], [ 'single-column', 'new-page', ]

