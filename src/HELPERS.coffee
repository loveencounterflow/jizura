



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/HELPERS'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#-----------------------------------------------------------------------------------------------------------
XNCHR                     = require './XNCHR'
ASYNC                     = require 'async'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
Markdown_parser           = require 'markdown-it'
# Html_parser               = ( require 'htmlparser2' ).Parser
new_md_inline_plugin      = require 'markdown-it-regexp'


# #-----------------------------------------------------------------------------------------------------------
# @provide_tmp_folder = ( options ) ->
#   njs_fs.mkdirSync options[ 'tmp-home' ] unless njs_fs.existsSync options[ 'tmp-home' ]
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @tmp_locator_for_extension = ( layout_info, extension ) ->
#   tmp_home            = layout_info[ 'tmp-home' ]
#   tex_locator         = layout_info[ 'tex-locator' ]
#   ### TAINT should extension be sanitized? maybe just check for /^\.?[-a-z0-9]$/? ###
#   throw new Error "need non-empty extension" unless extension.length > 0
#   extension           = ".#{extension}" unless ( /^\./ ).test extension
#   return njs_path.join CND.swap_extension tex_locator, extension

#-----------------------------------------------------------------------------------------------------------
@new_layout_info = ( options, source_route ) ->
  xelatex_command       = options[ 'xelatex-command' ]
  source_home           = njs_path.resolve process.cwd(), source_route
  source_name           = options[ 'main' ][ 'filename' ]
  source_locator        = njs_path.join source_home, source_name
  #.........................................................................................................
  throw new Error "unable to locate #{source_home}"     unless njs_fs.existsSync source_home
  throw new Error "not a directory: #{source_home}"     unless ( njs_fs.statSync source_home ).isDirectory()
  throw new Error "unable to locate #{source_locator}"  unless njs_fs.existsSync source_locator
  throw new Error "not a file: #{source_locator}"       unless ( njs_fs.statSync source_locator ).isFile()
  #.........................................................................................................
  # tex_locator           = njs_path.join tmp_home, CND.swap_extension source_name, '.tex'
  job_name              = njs_path.basename source_home
  aux_locator           = njs_path.join source_home, "#{job_name}.aux"
  pdf_locator           = njs_path.join source_home, "#{job_name}.pdf"
  mkscript_locator           = njs_path.join source_home, "#{job_name}.mkscript"
  # tex_inputs_home       = njs_path.resolve __dirname, '..', 'tex-inputs'
  master_name           = options[ 'master' ][ 'filename' ]
  master_ext            = njs_path.extname master_name
  master_locator        = njs_path.join source_home, master_name
  content_name          = options[ 'content' ][ 'filename' ]
  content_locator       = njs_path.join source_home, content_name
  ### TAINT duplication: tex_inputs_home, texinputs_value ###
  texinputs_value       = options[ 'texinputs' ][ 'value' ]
  #.........................................................................................................
  R =
    'aux-locator':                aux_locator
    'content-locator':            content_locator
    'job-name':                   job_name
    'master-locator':             master_locator
    'master-name':                master_name
    'pdf-locator':                pdf_locator
    'mkscript-locator':           mkscript_locator
    'source-home':                source_home
    'source-locator':             source_locator
    'source-name':                source_name
    'source-route':               source_route
    # 'tex-inputs-home':            tex_inputs_home
    'tex-inputs-value':           texinputs_value
    'xelatex-command':            xelatex_command
    'xelatex-run-count':          0
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@write_pdf = ( layout_info, handler ) ->
  #.........................................................................................................
  job_name            = layout_info[ 'job-name'             ]
  source_home         = layout_info[ 'source-home'          ]
  xelatex_command     = layout_info[ 'xelatex-command'      ]
  master_locator      = layout_info[ 'master-locator'       ]
  aux_locator         = layout_info[ 'aux-locator'          ]
  pdf_locator         = layout_info[ 'pdf-locator'          ]
  last_digest         = null
  last_digest         = CND.id_from_route aux_locator if njs_fs.existsSync aux_locator
  digest              = null
  count               = 0
  texinputs_value     = layout_info[ 'tex-inputs-value' ]
  parameters          = [ texinputs_value, source_home, job_name, master_locator, ]
  error_lines         = []
  urge "#{xelatex_command}"
  whisper "$#{idx + 1}: #{parameters[ idx ]}" for idx in [ 0 ... parameters.length ]
  log "#{xelatex_command} #{parameters.join ' '}"
  #.........................................................................................................
  pdf_from_tex = ( next ) =>
    count += 1
    urge "run ##{count}"
    # CND.spawn xelatex_command, parameters, ( error, data ) =>
    cp = ( require 'child_process' ).spawn xelatex_command, parameters
    #.......................................................................................................
    cp.stdout
      .pipe D.$split()
      .pipe D.$observe ( line ) =>
        echo CND.grey line
    #.......................................................................................................
    cp.stderr
      .pipe D.$split()
      .pipe D.$observe ( line ) =>
        error_lines.push line
        echo CND.red line
    #.......................................................................................................
    cp.on 'close', ( error ) =>
      error = undefined if error is 0
      if error?
        alert error
        return handler error
      if error_lines.length > 0
        ### TAINT looks like we're getting empty lines on stderr? ###
        message = ( line for line in error_lines when line.length > 0 ).join '\n'
        if message.length > 0
          alert message
          return handler message
      digest = CND.id_from_route aux_locator
      if digest is last_digest
        echo ( CND.grey badge ), CND.lime "done."
        layout_info[ 'xelatex-run-count' ] = count
        ### TAINT move pdf to layout_info[ 'source-home' ] ###
        handler null
      else
        last_digest = digest
        next()
  #.........................................................................................................
  ASYNC.forever pdf_from_tex


#===========================================================================================================
# TYPO
#-----------------------------------------------------------------------------------------------------------
@TYPO   = {}
@_meta  = Symbol 'meta'

#-----------------------------------------------------------------------------------------------------------
@TYPO.set_meta = ( x, name, value = true ) ->
  target          = x[ @_meta ]?= {}
  target[ name ]  = value
  return x

#-----------------------------------------------------------------------------------------------------------
@TYPO.get_meta = ( x, name = null ) ->
  R = x[ @_meta ]
  R = R[ name ] if name
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO._tex_escape_replacements = [
  [ ///  \\         ///g,  '\\textbackslash{}',     ]
  [ ///  \{         ///g,  '\\{',                   ]
  [ ///  \}         ///g,  '\\}',                   ]
  [ ///  \$         ///g,  '\\$',                   ]
  [ ///  \#         ///g,  '\\#',                   ]
  [ ///  %          ///g,  '\\%',                   ]
  [ ///  _          ///g,  '\\_',                   ]
  [ ///  \^         ///g,  '\\textasciicircum{}',   ]
  [ ///  ~          ///g,  '\\textasciitilde{}',    ]
  [ ///  ‰          ///g, '\\permille{}',           ]
  [ ///  &amp;      ///g, '\\&',                    ]
  [ ///  &quot;     ///g, '"',                      ]
  [ ///  '([^\s]+)’ ///g, '‘$1’',                   ]
  [ ///  &   ///g,  '\\&',                  ]
  # [ ///  (^|[^\\])& ///g, '$1\\&',                    ]
  # [ ///  ([^\\])&   ///g,  '$1\\&',                  ]
  # '`'   # these two are very hard to catch when TeX's character handling is switched on
  # "'"   #
  ]

#-----------------------------------------------------------------------------------------------------------
@TYPO.escape_for_tex = ( text ) ->
  R = text
  for [ pattern, replacement, ] in @_tex_escape_replacements
    R = R.replace pattern, replacement
  return R

# #-----------------------------------------------------------------------------------------------------------
# @TYPO.$resolve_html_entities = ->
#   return $ ( event, send ) =>
#     [ type, tail..., ] = event
#     if type is 'text'
#       send [ 'text', ( @resolve_html_entities tail[ 0 ] ), ]
#     else
#       send event

#-----------------------------------------------------------------------------------------------------------
@TYPO.$fix_typography_for_tex = ( options ) ->
  return $ ( event, send ) =>
    if @isa event, '.', 'text'
      [ type, name, text, meta, ] = event
      text = @fix_typography_for_tex text, options
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@TYPO.resolve_html_entities = ( text ) ->
  R = text
  R = R.replace /&lt;/g,    '<'
  R = R.replace /&gt;/g,    '>'
  R = R.replace /&quot;/g,  '"'
  R = R.replace /&amp;/g,   '&'
  R = R.replace /&[^a-z0-9]+;/g, ( match ) ->
    warn "unable to resolve HTML entity #{match}"
    return match
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO.fix_typography_for_tex = ( text, options ) ->
  ### An improved version of `XELATEX.tag_from_chr` ###
  ### TAINT should accept settings, fall back to `require`d `options.coffee` ###
  glyph_styles          = options[ 'tex' ]?[ 'glyph-styles'             ] ? {}
  tex_command_by_rsgs   = options[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
  last_command          = null
  R                     = []
  stretch               = []
  last_rsg              = null
  #.........................................................................................................
  unless tex_command_by_rsgs?
    throw new Error "need setting 'tex-command-by-rsgs'"
  #.........................................................................................................
  advance = =>
    if stretch.length > 0
      # debug '©zDJqU', last_command, JSON.stringify stretch.join '.'
      if last_command in [ null, 'latin', ]
        R.push @escape_for_tex stretch.join ''
      else
        R.push stretch.join ''
        R.push '}'
    stretch.length = 0
    return null
  #.........................................................................................................
  for chr in XNCHR.chrs_from_text text
    chr_info    = XNCHR.analyze chr
    { chr
      uchr
      fncr
      rsg   }   = chr_info
    #.......................................................................................................
    switch rsg
      when 'jzr-fig'  then chr = uchr
      when 'u-pua'    then rsg = 'jzr-fig'
    #.......................................................................................................
    if ( replacement = glyph_styles[ chr ] )?
      advance()
      R.push replacement
      last_command = null
      continue
    #.......................................................................................................
    unless ( command = tex_command_by_rsgs[ rsg ] )?
      warn "unknown RSG #{rpr rsg}: #{fncr} #{chr}"
      advance()
      stretch.push chr
      continue
    #.......................................................................................................
    if last_command isnt command
      advance()
      last_command = command
      stretch.push "\\#{command}{" unless command is 'latin'
    #.......................................................................................................
    stretch.push chr
  #.........................................................................................................
  advance()
  return R.join ''


#===========================================================================================================
# MD / HTML PARSING
#-----------------------------------------------------------------------------------------------------------
@TYPO._new_markdown_parser = ->
  #.........................................................................................................
  ### https://markdown-it.github.io/markdown-it/#MarkdownIt.new ###
  # feature_set = 'commonmark'
  feature_set = 'zero'
  #.........................................................................................................
  settings    =
    html:           yes,            # Enable HTML tags in source
    xhtmlOut:       no,             # Use '/' to close single tags (<br />)
    breaks:         no,             # Convert '\n' in paragraphs into <br>
    langPrefix:     'language-',    # CSS language prefix for fenced blocks
    linkify:        yes,            # Autoconvert URL-like text to links
    typographer:    yes,
    quotes:         '“”‘’'
    # quotes:         '""\'\''
    # quotes:         '""`\''
    # quotes:         [ '<<', '>>', '!!!', '???', ]
    # quotes:   ['«\xa0', '\xa0»', '‹\xa0', '\xa0›'] # French
  #.........................................................................................................
  R = new Markdown_parser feature_set, settings
  # R = new Markdown_parser settings
  R
    .enable 'text'
    # .enable 'newline'
    .enable 'escape'
    .enable 'backticks'
    .enable 'strikethrough'
    .enable 'emphasis'
    .enable 'link'
    .enable 'image'
    .enable 'autolink'
    .enable 'html_inline'
    .enable 'entity'
    # .enable 'code'
    .enable 'fence'
    .enable 'blockquote'
    .enable 'hr'
    .enable 'list'
    .enable 'reference'
    .enable 'heading'
    .enable 'lheading'
    .enable 'html_block'
    .enable 'table'
    .enable 'paragraph'
    .enable 'normalize'
    .enable 'block'
    .enable 'inline'
    .enable 'linkify'
    .enable 'replacements'
    .enable 'smartquotes'
  #.......................................................................................................
  R.use require 'markdown-it-footnote'
  # R.use require 'markdown-it-mark'
  # R.use require 'markdown-it-sub'
  # R.use require 'markdown-it-sup'
  # #.......................................................................................................
  # ### sample plugin ###
  # user_pattern  = /@(\w+)/
  # user_handler  = ( match, utils ) ->
  #   url = 'http://example.org/u/' + match[ 1 ]
  #   return '<a href="' + utils.escape(url) + '">' + utils.escape(match[1]) + '</a>'
  # user_plugin = new_md_inline_plugin user_pattern, user_handler
  # R.use user_plugin
  #.......................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO.$flatten_tokens = ( S ) ->
  return $ ( token, send ) ->
    switch ( type = token[ 'type' ] )
      when 'inline' then send sub_token for sub_token in token[ 'children' ]
      else send token

#-----------------------------------------------------------------------------------------------------------
get_parse_html_methods = ->
  Parser      = ( require 'parse5' ).Parser
  parser      = new Parser()
  get_message = ( source ) -> "expected single openening node, got #{rpr source}"
  R           = {}
  #.........................................................................................................
  R[ '_parse_html_open_tag' ] = ( source ) ->
    tree    = parser.parseFragment source
    throw new Error get_message source unless ( cns = tree[ 'childNodes' ] ).length is 1
    cn = cns[ 0 ]
    throw new Error get_message source unless cn[ 'childNodes' ]?.length is 0
    return [ 'begin', cn[ 'tagName' ], cn[ 'attrs' ][ 0 ] ? {}, ]
  #.........................................................................................................
  R[ '_parse_html_block' ] = ( source ) ->
    tree    = parser.parseFragment source
    debug '@88817', tree
    return null
  #.........................................................................................................
  return R
#...........................................................................................................
parse_methods = get_parse_html_methods()
@TYPO._parse_html_open_tag = parse_methods[ '_parse_html_open_tag' ]
@TYPO._parse_html_block    = parse_methods[ '_parse_html_block'    ]

#-----------------------------------------------------------------------------------------------------------
@TYPO._parse_html_tag = ( source ) ->
  if ( match = source.match @_parse_html_tag.close_tag_pattern )?
    return [ 'end', match[ 1 ], ]
  if ( match = source.match @_parse_html_tag.comment_pattern )?
    return [ 'comment', 'comment', match[ 1 ], ]
  return @_parse_html_open_tag source
@TYPO._parse_html_tag.close_tag_pattern   = /^<\/([^>]+)>$/
@TYPO._parse_html_tag.comment_pattern     = /^<!--([\s\S]*)-->$/

#-----------------------------------------------------------------------------------------------------------
@TYPO._fence_pairs =
  '<':  '>'
  '{':  '}'
  '[':  ']'
  '(':  ')'
  '>':  '<'
  '}':  '{'
  ']':  '['
  ')':  '('

#-----------------------------------------------------------------------------------------------------------
@TYPO._get_opposite_fence = ( fence, fallback ) ->
  unless ( R = @_fence_pairs[ fence ] )?
    return fallback unless fallback is undefined
    throw new Error "unknown fence: #{rpr fence}"
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO.$rewrite_markdownit_tokens = ( S ) ->
  unknown_tokens  = []
  is_first        = yes
  last_map        = [ 0, 0, ]
  _send           = null
  #.........................................................................................................
  send_unknown = ( token ) =>
    debug '@8876', token
    send [ '?', token[ 'tag' ], token[ 'content' ], meta, ]
    unknown_tokens.push type unless type in unknown_tokens
  #.........................................................................................................
  return $ ( token, send, end ) =>
    _send = send
    if token?
      { type, map, } = token
      map           ?= last_map
      line_nr        = ( map[ 0 ] ? 0 ) + 1
      col_nr         = ( map[ 1 ] ? 0 ) + 1
      #.....................................................................................................
      meta = {
        line_nr
        col_nr
        # within_keep_lines:      no
        # within_single_column:   no
        }
      if is_first
        is_first = no
        send [ '<', 'document', null, meta, ]
      #.....................................................................................................
      unless S.has_ended
        switch type
          # blocks
          when 'heading_open'       then send [ '[', token[ 'tag' ],  null,               meta, ]
          when 'heading_close'      then send [ ']', token[ 'tag' ],  null,               meta, ]
          when 'paragraph_open'     then null
          when 'paragraph_close'    then send [ '.', 'p',             null,               meta, ]
          when 'list_item_open'     then send [ '[', 'li',            null,               meta, ]
          when 'list_item_close'    then send [ ']', 'li',            null,               meta, ]
          # inlines
          when 'strong_open'        then send [ '(', 'strong',        null,               meta, ]
          when 'strong_close'       then send [ ')', 'strong',        null,               meta, ]
          when 'em_open'            then send [ '(', 'em',            null,               meta, ]
          when 'em_close'           then send [ ')', 'em',            null,               meta, ]
          # singles
          when 'text'               then send [ '.', 'text',          token[ 'content' ], meta, ]
          when 'hr'                 then send [ '.', 'hr',            token[ 'markup' ],  meta, ]
          #.................................................................................................
          # specials
          when 'code_inline'
            S.within_text_literal = yes
            send [ '(', 'code', null,                        meta,    ]
            send [ '.', 'text', token[ 'content' ], ( @_copy meta ),  ]
            send [ ')', 'code', null,               ( @_copy meta ),  ]
            S.within_text_literal = no
          #.................................................................................................
          when 'html_block'
            # @_parse_html_block token[ 'content' ].trim()
            debug '@8873', @_parse_html_tag token[ 'content' ]
          #.................................................................................................
          when 'fence'
            switch token[ 'tag' ]
              when 'code'
                language_name = token[ 'info' ]
                language_name = 'text' if language_name.length is 0
                send [ '{', 'code', language_name,               meta,    ]
                send [ '.', 'text', token[ 'content' ], ( @_copy meta ),  ]
                send [ '}', 'code', language_name,      ( @_copy meta ),  ]
              else send_unknown token
          #.................................................................................................
          when 'html_inline'
            [ position, name, extra, ] = @_parse_html_tag token[ 'content' ]
            switch position
              when 'comment'  then whisper "ignoring comment: #{rpr extra}"
              when 'begin'
                unless name is 'p'
                  send [ '(', name, extra, meta, ]
              when 'end'
                if name is 'p' then send [ '.', name, null, meta, ]
                else                send [ ')', name, null, meta, ]
              else throw new Error "unknown HTML tag position #{rpr position}"
          else send_unknown token
        #...................................................................................................
        last_map = map
    #.......................................................................................................
    if end?
      if unknown_tokens.length > 0
        warn "unknown tokens: #{unknown_tokens.sort().join ', '}"
      ### TAINT could send end document earlier in case of `∆∆∆end` ###
      send [ '>', 'document', null, {}, ]
      end()
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$preprocess_regions = ( S ) ->
  opening_pattern   = /^@@@(\S.+)(\n|$)/
  closing_pattern   = /^@@@\s*(\n|$)/
  collector         = []
  region_stack      = []
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    [ type, name, text, meta, ] = event
    # debug '©p09E6', S
    # debug '©p09E6', event
    if ( not S.within_text_literal ) and ( @isa event, '.', 'text' )
      lines = @_split_lines_with_nl text
      #...................................................................................................
      for line in lines
        if ( match = line.match opening_pattern )?
          @_flush_text_collector send, collector, ( @_copy meta )
          region_name = match[ 1 ]
          region_stack.push region_name
          send [ '{', region_name, null, ( @_copy meta ), ]
        else if ( match = line.match closing_pattern )?
          @_flush_text_collector send, collector, ( @_copy meta )
          if region_stack.length > 0
            send [ '}', region_stack.pop(), null, ( @_copy meta ), ]
          else
            warn "ignoring end-region"
        else
          collector.push line
      #...................................................................................................
      @_flush_text_collector send, collector, ( @_copy meta )
    #.....................................................................................................
    else if ( region_stack.length > 0 ) and ( @isa event, '>', 'document' )
      warn "auto-closing regions: #{rpr region_stack.join ', '}"
      send [ '}', region_stack.pop(), null, ( @_copy meta, block: true ), ] while region_stack.length > 0
      send event
    #.....................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$preprocess_commands = ( S ) ->
  pattern   = /^∆∆∆(\S.+)(\n|$)/
  collector = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    if @isa event, '.', 'text'
      lines = @_split_lines_with_nl text
      #.......................................................................................................
      for line in lines
        if ( match = line.match pattern )?
          @_flush_text_collector send, collector, ( @_copy meta )
          send [ '∆', match[ 1 ], null, ( @_copy meta ), ]
        else
          collector.push line
      #.......................................................................................................
      @_flush_text_collector send, collector, ( @_copy meta )
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$process_end_command = ( S ) ->
  S.has_ended = no
  #.........................................................................................................
  return $ ( event, send ) =>
    # [ type, name, text, meta, ] = event
    if @isa event, '∆', 'end'
      [ _, _, _, meta, ]    = event
      { line_nr, }          = meta
      warn "encountered `∆∆∆end` on line ##{line_nr}, ignoring further material"
      S.has_ended = yes
    else if @isa event, '>', 'document'
      send event
    else
      send event unless S.has_ended
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$close_dangling_open_tags = ( S ) ->
  tag_stack = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    # debug '©nLnB5', event
    if @isa event, [ '{', '[', '(', ]
      tag_stack.push [ type, name, null, meta, ]
      send event
    else if @isa event, [ '}', ']', ')', ]
      if @isa event, '>', 'document'
        while tag_stack.length > 0
          sub_event                         = tag_stack.pop()
          [ sub_type, sub_name, sub_meta, ] = sub_event
          switch sub_type
            when '{' then sub_type = '}'
            when '[' then sub_type = ']'
            when '(' then sub_type = ')'
          send [ sub_type, sub_name, null, ( @_copy sub_meta ), ]
        send event
      else
        tag_stack.pop()
        send event
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.isa = ( event, type, name ) ->
  if type?
    switch type_of_type = CND.type_of type
      when 'text' then return false unless event[ 0 ] is type
      when 'list' then return false unless event[ 0 ] in type
      else throw new Error "expected text or list, got a #{type_of_type}"
  if name?
    switch type_of_name = CND.type_of name
      when 'text' then return false unless event[ 1 ] is name
      when 'list' then return false unless event[ 1 ] in name
      else throw new Error "expected text or list, got a #{type_of_name}"
  return true

#-----------------------------------------------------------------------------------------------------------
@TYPO._copy = ( meta, overwrites ) ->
  ### TAINT use `Object.assign` or similar ###
  R = {}
  R[ name ] = value for name, value of meta
  R[ name ] = value for name, value of overwrites if overwrites?
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO._split_lines_with_nl = ( text ) -> ( line for line in text.split /(.*\n)/ when line.length > 0 )

#-----------------------------------------------------------------------------------------------------------
@TYPO._flush_text_collector = ( send, collector, meta ) ->
  if collector.length > 0
    send [ '.', 'text', ( collector.join '' ), meta, ]
    collector.length = 0
  return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.new_area_observer = ( area_names... ) ->
  state               = {}
  #.........................................................................................................
  for area_name in area_names
    throw new Error "repeated area_name #{rpr area_name}" if state[ area_name ]?
    state[ area_name ] = false
  #.........................................................................................................
  track = ( event ) =>
    if event?
      [ type, area_name, text, meta, ] = event
      if area_name of state
        if      type in [ '<', '{', '[', '(', ] then state[ area_name ] = true
        else if type in [ '>', '}', ']', ')', ] then state[ area_name ] = false
    return event
  #.........................................................................................................
  within = ( pattern ) =>
    throw new Error "untracked pattern #{rpr pattern}" unless ( R = state[ pattern ] )?
    return R
  #.........................................................................................................
  return [ track, within, ]

#-----------------------------------------------------------------------------------------------------------
@TYPO.$show_mktsmd_events = ( S ) ->
  unknown_events    = []
  indentation       = ''
  tag_stack         = []
  return D.$observe ( event, has_ended ) ->
    if event?
      [ type, name, text, meta, ] = event
      if type is '?'
        unknown_events.push name unless name in unknown_events
        warn JSON.stringify event
      else
        color = CND.blue
        #...................................................................................................
        switch type
          when '<', '>'
            color         = CND.yellow
          when '{', '∆'
            color         = CND.red
          when ')', ']', '}'
            color         = CND.grey
          when '.'
            switch name
              when 'text' then color = CND.green
              # when 'code' then color = CND.orange
        #...................................................................................................
        text = if text? then ( color rpr text ) else ''
        switch type
          when 'text'
            log indentation + ( color type ) + ' ' + rpr name
          when 'tex'
            if S.show_tex_events ? no
              log indentation + ( CND.grey type ) + ( color name ) + ' ' + text
          else
            log indentation + ( CND.grey type ) + ( color name ) + ' ' + text
        #...................................................................................................
        switch type
          #.................................................................................................
          when '{', '[', '(', ')', ']', '}'
            switch type
              when '{', '[', '('
                tag_stack.push [ type, name, ]
              when ')', ']', '}'
                if tag_stack.length > 0
                  [ topmost_type, topmost_name, ] = tag_stack.pop()
                  unless topmost_name is name
                    topmost_type = { '{': '}', '[': ']', '(', ')', }[ topmost_type ]
                    warn "encountered #{type}#{name} when #{topmost_type}#{topmost_name} was expected"
                else
                  warn "level below zero"
            indentation = ( new Array tag_stack.length ).join '  '
    #.......................................................................................................
    if has_ended
      if tag_stack.length > 0
        warn "unclosed tags: #{tag_stack.join ', '}"
      if unknown_events.length > 0
        warn "unknown events: #{unknown_events.sort().join ', '}"
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$write_mktscript = ( S ) ->
  indentation       = ''
  tag_stack         = []
  mkscript_locator  = S.layout_info[ 'mkscript-locator' ]
  output            = njs_fs.createWriteStream mkscript_locator
  confluence        = D.create_throughstream()
  write             = confluence.write.bind confluence
  confluence.pipe output
  #.........................................................................................................
  return D.$observe ( event, has_ended ) ->
    if event?
      [ type, name, text, meta, ] = event
      unless type in [ 'tex', 'text', ]
        { line_nr, }                = meta
        anchor                      = "█ #{line_nr} █ "
        #.....................................................................................................
        switch type
          when '?'
            write "\n#{anchor}#{type}#{name}\n"
          when '<', '{', '['
            write "#{anchor}#{type}#{name}"
          when '>', '}', ']', '∆'
            write "#{type}\n"
          when '('
            write "#{type}#{name}"
          when ')'
            write "#{type}"
          when '.'
            switch name
              when 'hr'
                write "\n#{anchor}#{type}#{name}\n"
              when 'p'
                write "¶\n"
              when 'text'
                ### TAINT doesn't recognize escaped backslash ###
                text_rpr = ( rpr text ).replace /\\n/g, '\n'
                write text_rpr
              else
                write "\n#{anchor}IGNORED: #{rpr event}"
          else
            write "\n#{anchor}IGNORED: #{rpr event}"
    if has_ended
      output.end()
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.create_mdreadstream = ( md_source, settings ) ->
  throw new Error "settings currently unsupported" if settings?
  #.........................................................................................................
  state       =
    within_text_literal:  no
  confluence  = D.create_throughstream()
  R           = D.create_throughstream()
  R.pause()
  #.........................................................................................................
  confluence
    .pipe @$flatten_tokens                  state
    #.......................................................................................................
    .pipe do =>
      ### re-inject HTML blocks ###
      md_parser   = @_new_markdown_parser()
      return $ ( token, send ) =>
        { type, map, } = token
        if type is 'html_block'
          ### TAINT `map` location data is borked with this method ###
          ### add extraneous text content; this causes the parser to parse the HTML block as a paragraph
          with some inline HTML: ###
          XXX_source  = "XXX" + token[ 'content' ]
          environment = {}
          tokens      = md_parser.parse XXX_source, environment
          ### remove extraneous text content: ###
          removed     = tokens[ 1 ]?[ 'children' ]?.splice 0, 1
          unless removed[ 0 ]?[ 'content' ] is "XXX"
            throw new Error "should never happen"
          confluence.write token for token in tokens
        else
          send token
    #.......................................................................................................
    .pipe @$rewrite_markdownit_tokens       state
    # .pipe D.$show()
    .pipe @$preprocess_commands             state
    .pipe @$process_end_command             state
    .pipe @$preprocess_regions              state
    .pipe @$close_dangling_open_tags        state
    # .pipe @$update_meta                     state
    # .pipe @$preprocess_keeplines_regions    state
    .pipe R
  #.........................................................................................................
  R.on 'resume', =>
    md_parser   = @_new_markdown_parser()
    environment = {}
    tokens      = md_parser.parse md_source, environment
    @set_meta R, 'environment', environment
    confluence.write token for token in tokens
    confluence.end()
  #.........................................................................................................
  return R


















