


############################################################################################################
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/MKTS'
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
# ASYNC                     = require 'async'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
# $async                    = D.remit_async.bind D
#...........................................................................................................
Markdown_parser           = require 'markdown-it'
# Html_parser               = ( require 'htmlparser2' ).Parser
new_md_inline_plugin      = require 'markdown-it-regexp'
#...........................................................................................................
misfit                    = Symbol 'misfit'



#-----------------------------------------------------------------------------------------------------------
@_tex_escape_replacements = [
  [ /// \x01        ///g,  '\x01\x02',              ]
  [ /// \x5c        ///g,  '\x01\x01',              ]
  [ ///  \{         ///g,  '\\{',                   ]
  [ ///  \}         ///g,  '\\}',                   ]
  [ ///  \$         ///g,  '\\$',                   ]
  [ ///  \#         ///g,  '\\#',                   ]
  [ ///  %          ///g,  '\\%',                   ]
  [ ///  _          ///g,  '\\_',                   ]
  [ ///  \^         ///g,  '\\textasciicircum{}',   ]
  [ ///  ~          ///g,  '\\textasciitilde{}',    ]
  [ ///  &          ///g,  '\\&',                   ]
  [ /// \x01\x01    ///g,  '\\textbackslash{}',     ]
  [ /// \x01\x02    ///g,  '\x01',                  ]
  ]

#-----------------------------------------------------------------------------------------------------------
@escape_for_tex = ( text ) ->
  R = text
  for [ pattern, replacement, ], idx in @_tex_escape_replacements
    R = R.replace pattern, replacement
  return R

#-----------------------------------------------------------------------------------------------------------
@$fix_typography_for_tex = ( options ) ->
  return $ ( event, send ) =>
    if @select event, '.', 'text'
      [ type, name, text, meta, ] = event
      meta[ 'raw' ] = text
      text          = @fix_typography_for_tex text, options
      send [ type, name, text, meta, ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@fix_typography_for_tex = ( text, options ) ->
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
@_new_markdown_parser = ->
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
@$_flatten_tokens = ( S ) ->
  return $ ( token, send ) ->
    switch ( type = token[ 'type' ] )
      when 'inline' then send sub_token for sub_token in token[ 'children' ]
      else send token

#-----------------------------------------------------------------------------------------------------------
@$_reinject_html_blocks = ( S ) ->
  ### re-inject HTML blocks ###
  md_parser   = @_new_markdown_parser()
  return $ ( token, send ) =>
    { type, map, } = token
    if type is 'html_block'
      ### TAINT `map` location data is borked with this method ###
      ### add extraneous text content; this causes the parser to parse the HTML block as a paragraph
      with some inline HTML: ###
      XXX_source  = "XXX" + token[ 'content' ]
      ### for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse ###
      ### TAINT what to do with useful data appearing environment? ###
      environment = {}
      tokens      = md_parser.parse XXX_source, environment
      ### remove extraneous text content: ###
      removed     = tokens[ 1 ]?[ 'children' ]?.splice 0, 1
      unless removed[ 0 ]?[ 'content' ] is "XXX"
        throw new Error "should never happen"
      S.confluence.write token for token in tokens
    else
      send token

#-----------------------------------------------------------------------------------------------------------
get_parse_html_methods = ->
  Parser      = ( require 'parse5' ).Parser
  parser      = new Parser()
  get_message = ( source ) -> "expected single opening node, got #{rpr source}"
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
@_parse_html_open_tag = parse_methods[ '_parse_html_open_tag' ]
@_parse_html_block    = parse_methods[ '_parse_html_block'    ]

#-----------------------------------------------------------------------------------------------------------
@_parse_html_tag = ( source ) ->
  if ( match = source.match @_parse_html_tag.close_tag_pattern )?
    return [ 'end', match[ 1 ], ]
  if ( match = source.match @_parse_html_tag.comment_pattern )?
    return [ 'comment', 'comment', match[ 1 ], ]
  return @_parse_html_open_tag source
@_parse_html_tag.close_tag_pattern   = /^<\/([^>]+)>$/
@_parse_html_tag.comment_pattern     = /^<!--([\s\S]*)-->$/


#===========================================================================================================
# FENCES
#-----------------------------------------------------------------------------------------------------------
@FENCES = {}

#-----------------------------------------------------------------------------------------------------------
@FENCES.xleft   = [ '<', '{', '[', '(', ]
@FENCES.xright  = [ '>', '}', ']', ')', ]
@FENCES.left    = [      '{', '[', '(', ]
@FENCES.right   = [      '}', ']', ')', ]
@FENCES.xpairs  =
  '<':  '>'
  '{':  '}'
  '[':  ']'
  '(':  ')'
  '>':  '<'
  '}':  '{'
  ']':  '['
  ')':  '('

#-----------------------------------------------------------------------------------------------------------
@FENCES._get_opposite = ( fence, fallback ) =>
  unless ( R = @FENCES.xpairs[ fence ] )?
    return fallback unless fallback is undefined
    throw new Error "unknown fence: #{rpr fence}"
  return R

#===========================================================================================================
# TRACKER
#-----------------------------------------------------------------------------------------------------------
@TRACKER    = {}

#-----------------------------------------------------------------------------------------------------------
### TAINT shouldn't be defined at module level ###
fences_rxcc     = /// < \. \{ \[ \( \) \] \} > ///
name_rx         = /// [^ \s #{fences_rxcc.source} ]* ///
tracker_pattern = /// ^
    ( [ #{fences_rxcc.source} ]? )
    ( #{name_rx.source}          )
    ( [ #{fences_rxcc.source} ]? )
    $ ///

#-----------------------------------------------------------------------------------------------------------
@FENCES.parse = ( pattern, settings ) =>
  left_fence  = null
  name        = null
  right_fence = null
  symmetric   = settings?[ 'symmetric' ] ? yes
  #.........................................................................................................
  if ( not pattern? ) or pattern.length is 0
    throw new Error "pattern must be non-empty, got #{rpr pattern}"
  #.........................................................................................................
  match = pattern.match @TRACKER._tracker_pattern
  throw new Error "not a valid pattern: #{rpr pattern}" unless match?
  #.........................................................................................................
  [ _, left_fence, name, right_fence, ] = match
  left_fence  = null if  left_fence.length is 0
  name        = null if        name.length is 0
  right_fence = null if right_fence.length is 0
  #.........................................................................................................
  if left_fence is '.'
    ### Can not have a right fence if left fence is a dot ###
    if right_fence?
      throw new Error "fence '.' can not have right fence, got #{rpr pattern}"
  #.........................................................................................................
  else
    ### Except for dot fence, must always have no fence or both fences in case `symmetric` is set ###
    if symmetric
      if ( left_fence? and not right_fence? ) or ( right_fence? and not left_fence? )
        throw new Error "unmatched fence in #{rpr pattern}"
  #.........................................................................................................
  if left_fence? and left_fence isnt '.'
    ### Complain about unknown left fences ###
    unless left_fence in @FENCES.xleft
      throw new Error "illegal left_fence in pattern #{rpr pattern}"
    if right_fence?
      ### Complain about non-matching fences ###
      unless ( @FENCES._get_opposite left_fence, null ) is right_fence
        throw new Error "fences don't match in pattern #{rpr pattern}"
  if right_fence?
    ### Complain about unknown right fences ###
    unless right_fence in @FENCES.xright
      throw new Error "illegal right_fence in pattern #{rpr pattern}"
  #.........................................................................................................
  return [ left_fence, name, right_fence, ]

#-----------------------------------------------------------------------------------------------------------
@TRACKER._tracker_pattern = tracker_pattern

#-----------------------------------------------------------------------------------------------------------
@TRACKER.new_tracker = ( patterns... ) =>
  _MKTS = @
  #.........................................................................................................
  self = ( event ) ->
    # CND.dir self
    # debug '@763', "tracking event #{rpr event}"
    for pattern, state of self._states
      { parts } = state
      continue unless _MKTS.select event, parts...
      [ [ left_fence, right_fence, ], pattern_name, ] = parts
      [ type, event_name, ]                           = event
      if type is left_fence
        # debug '@1', pattern, yes
        self._enter state
      else
        # debug '@2', pattern, no
        self._leave state
        throw new Error "too many right fences: #{rpr event}" if state[ 'count' ] < 0
    return event
  #.........................................................................................................
  self._states = {}
  #.........................................................................................................
  self._get_state = ( pattern ) ->
    throw new Error "untracked pattern #{rpr pattern}" unless ( R = self._states[ pattern ] )?
    return R
  #.........................................................................................................
  self.within = ( patterns... ) ->
    for pattern in patterns
      return true if self._within pattern
    return false
  self._within  = ( pattern ) -> ( self._get_state pattern )[ 'count' ] > 0
  #.........................................................................................................
  self.enter    = ( pattern ) -> self._enter self._get_state pattern
  self.leave    = ( pattern ) -> self._leave self._get_state pattern
  self._enter   = ( state   ) -> state[ 'count' ] += +1
  ### TAINT should validate count when leaving ###
  self._leave   = ( state   ) -> state[ 'count' ] += -1
  #.........................................................................................................
  do ->
    for pattern in patterns
      [ left_fence, pattern_name, right_fence, ]  = _MKTS.FENCES.parse pattern
      state =
        parts:    [ [ left_fence, right_fence, ], pattern_name, ]
        count:    0
      self._states[ pattern ] = state
  #.........................................................................................................
  return self


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@$_rewrite_markdownit_tokens = ( S ) ->
  unknown_tokens  = []
  is_first        = yes
  last_map        = [ 0, 0, ]
  _send           = null
  #.........................................................................................................
  send_unknown = ( token, meta ) =>
    { type, } = token
    _send [ '?', type, token[ 'content' ], meta, ]
    unknown_tokens.push type unless type in unknown_tokens
  #.........................................................................................................
  return $ ( token, send, end ) =>
    _send = send
    if token?
      # debug '@a20g1TH9yLG', token
      { type, map, } = token
      map           ?= last_map
      line_nr        = ( map[ 0 ] ? 0 ) + 1
      col_nr         = ( map[ 1 ] ? 0 ) + 1
      #.....................................................................................................
      meta = {
        line_nr
        col_nr
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
            send [ '(', 'code', null,                        meta,    ]
            send [ '.', 'text', token[ 'content' ], ( @copy meta ),  ]
            send [ ')', 'code', null,               ( @copy meta ),  ]
          #.................................................................................................
          when 'html_block'
            # @_parse_html_block token[ 'content' ].trim()
            debug '@8873', @_parse_html_tag token[ 'content' ]
            throw new Error "should never happen"
          #.................................................................................................
          when 'fence'
            switch token[ 'tag' ]
              when 'code'
                language_name = token[ 'info' ]
                language_name = 'text' if language_name.length is 0
                send [ '{', 'code', language_name,               meta,    ]
                send [ '.', 'text', token[ 'content' ], ( @copy meta ),  ]
                send [ '}', 'code', language_name,      ( @copy meta ),  ]
              else send_unknown token, meta
          #.................................................................................................
          when 'html_inline'
            [ position, name, extra, ] = @_parse_html_tag token[ 'content' ]
            switch position
              when 'comment'
                send [ '.', 'comment', extra.trim(), meta, ]
              when 'begin'
                unless name is 'p'
                  send [ '(', name, extra, meta, ]
              when 'end'
                if name is 'p' then send [ '.', name, null, meta, ]
                else                send [ ')', name, null, meta, ]
              else throw new Error "unknown HTML tag position #{rpr position}"
          else send_unknown token, meta
        #...................................................................................................
        last_map = map
    #.......................................................................................................
    if end?
      if unknown_tokens.length > 0
        warn "unknown tokens: #{unknown_tokens.sort().join ', '}"
      send [ '>', 'document', null, {}, ]
      end()
    return null

# #-----------------------------------------------------------------------------------------------------------
# @$_preprocess_regions = ( S ) ->
#   opening_pattern     = /^@@@(\S.+)(\n|$)/
#   closing_pattern     = /^@@@\s*(\n|$)/
#   collector           = []
#   region_stack        = []
#   track               = @TRACKER.new_tracker '(code)'
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     #.......................................................................................................
#     within_code = track.within '(code)'
#     track event
#     [ type, name, text, meta, ] = event
#     #.......................................................................................................
#     if ( not within_code ) and ( @select event, '.', 'text' )
#       lines = @_split_lines_with_nl text
#       #.....................................................................................................
#       for line in lines
#         #...................................................................................................
#         if ( match = line.match opening_pattern )?
#           @_flush_text_collector send, collector, ( @copy meta )
#           region_name = match[ 1 ]
#           region_stack.push region_name
#           send [ '{', region_name, null, ( @copy meta ), ]
#         #...................................................................................................
#         else if ( match = line.match closing_pattern )?
#           @_flush_text_collector send, collector, ( @copy meta )
#           if region_stack.length > 0
#             send [ '}', region_stack.pop(), null, ( @copy meta ), ]
#           else
#             warn "ignoring end-region"
#         #...................................................................................................
#         else
#           collector.push line
#       #.....................................................................................................
#       @_flush_text_collector send, collector, ( @copy meta )
#     #.......................................................................................................
#     else if ( region_stack.length > 0 ) and ( @select event, '>', 'document' )
#       warn "auto-closing regions: #{rpr region_stack.join ', '}"
#       send [ '}', region_stack.pop(), null, ( @copy meta ), ] while region_stack.length > 0
#       send event
#     #.......................................................................................................
#     else
#       send event
#     #.......................................................................................................
#     return null

#-----------------------------------------------------------------------------------------------------------
@$_preprocess_XXXX = ( S ) ->
  ### TAINT `<xxx>` translates as `(xxx`, which is generally correct, but it should translate
  to `(xxx)` when `xxx` is a known HTML5 'lone' tag. ###
  left_meta_fence     = '<'
  right_meta_fence    = '>'
  repetitions         = 2
  fence_pattern       = ///
    #{left_meta_fence}{#{repetitions}}
    (
      (?:
        \\#{right_meta_fence}       |
        [^ #{right_meta_fence} ]    |
        #{right_meta_fence}{ #{repetitions - 1} } (?! #{right_meta_fence} )
        )*
      )
    #{right_meta_fence}{#{repetitions}}
    ///
  prefix_pattern      = ///^ ( [ !: ] ) ( .* ) ///
  collector           = []
  track               = @TRACKER.new_tracker '{code}', '(code)', '(latex)', '(latex)'
  #.........................................................................................................
  return $ ( event, send ) =>
    within_literal = track.within '{code}', '(code)', '(latex)', '(latex)'
    track event
    [ type, name, text, meta, ] = event
    if ( not within_literal ) and @select event, '.', 'text'
      is_command = yes
      for part in text.split fence_pattern
        is_command  = not is_command
        left_fence  = null
        right_fence = null
        if is_command
          last_idx    = part.length - 1
          left_fence  = part[        0 ] if part[        0 ] in @FENCES.xleft
          right_fence = part[ last_idx ] if part[ last_idx ] in @FENCES.xright
          if left_fence? and right_fence?
            command_name = part[ 1 ... last_idx ]
            if prefix_pattern.test command_name
              warn "prefix not supported in #{rpr part}"
              send [ '?', part, null, ( @copy meta ), ]
            else
              send [ left_fence,  command_name, null, ( @copy meta ), ]
              send [ right_fence, command_name, null, ( @copy meta ), ]
          else if left_fence?
            command_name  = part[ 1 ... ]
            if ( match = command_name.match prefix_pattern )?
              [ _, prefix, suffix, ] = match
              switch prefix
                when ':'
                  send [ left_fence, prefix, suffix, ( @copy meta ), ]
                else
                  warn "prefix #{rpr prefix} not supported in #{rpr part}"
                  send [ '?', part, null, ( @copy meta ), ]
            else
              send [ left_fence, command_name, null, ( @copy meta ), ]
          else if right_fence?
            ### TAINT code duplication ###
            command_name = part[ ... last_idx ]
            if ( match = command_name.match prefix_pattern )?
              [ _, prefix, suffix, ] = match
              # debug '©9nGvB', ( rpr command_name ), ( rpr prefix ), ( rpr suffix )
              switch prefix
                when ':'
                  send [ right_fence, prefix, suffix, ( @copy meta ), ]
                else
                  warn "prefix #{rpr prefix} not supported in #{rpr part}"
                  send [ '?', part, null, ( @copy meta ), ]
            else
              send [ right_fence, command_name, null, ( @copy meta ), ]
          else
            match = part.match prefix_pattern
            unless match?
              warn "not a legal command: #{rpr part}"
              send [ '?', part, null, ( @copy meta ), ]
            else
              [ _, prefix, suffix, ] = match
              switch prefix
                when '!'
                  send [ '!', suffix, null, ( @copy meta ), ]
                else
                  warn "prefix #{rpr prefix} not supported in #{rpr part}"
                  send [ '?', part, null, ( @copy meta ), ]
        else
          send [ type, name, part, ( @copy meta ), ]
    #.......................................................................................................
    else
      send event
    #.......................................................................................................
    return null

# #-----------------------------------------------------------------------------------------------------------
# @$_preprocess_commands = ( S ) ->
#   pattern             = /^∆∆∆(\S.+)(\n|$)/
#   collector           = []
#   track               = @TRACKER.new_tracker '(code)'
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     within_code = track.within '(code)'
#     track event
#     [ type, name, text, meta, ] = event
#     if ( not within_code ) and @select event, '.', 'text'
#       lines = @_split_lines_with_nl text
#       #.......................................................................................................
#       for line in lines
#         if ( match = line.match pattern )?
#           @_flush_text_collector send, collector, ( @copy meta )
#           send [ '∆', match[ 1 ], null, ( @copy meta ), ]
#         else
#           collector.push line
#       #.......................................................................................................
#       @_flush_text_collector send, collector, ( @copy meta )
#     #.......................................................................................................
#     else
#       send event
#     #.......................................................................................................
#     return null

#-----------------------------------------------------------------------------------------------------------
@$_process_end_command = ( S ) ->
  S.has_ended = no
  #.........................................................................................................
  return $ ( event, send ) =>
    # [ type, name, text, meta, ] = event
    if @select event, '!', 'end'
      [ _, _, _, meta, ]    = event
      { line_nr, }          = meta
      warn "encountered `<<!end>>` on line ##{line_nr}, ignoring further material"
      S.has_ended = yes
    else if @select event, '>', 'document'
      send event
    else
      send event unless S.has_ended
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$close_dangling_open_tags = ( S ) ->
  # throw new Error "currently not used: `$close_dangling_open_tags`"
  tag_stack = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    # debug '©nLnB5', event
    if @select event, '>', 'document'
      while tag_stack.length > 0
        sub_event                                   = tag_stack.pop()
        [ sub_type, sub_name, sub_text, sub_meta, ] = sub_event
        switch sub_type
          when '{' then sub_type = '}'
          when '[' then sub_type = ']'
          when '(' then sub_type = ')'
        S.resend [ sub_type, sub_name, sub_text, ( @copy sub_meta ), ]
      send event
    else if @select event, [ '{', '[', '(', ]
      tag_stack.push [ type, name, null, meta, ]
      send event
    else if @select event, [ '}', ']', ')', ]
      ### TAINT should check matching pairs ###
      tag_stack.pop()
      send event
    else
      send event
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@select = ( event, type, name ) ->
  ### TAINT should use the same syntax as accepted by `FENCES.parse` ###
  ### check for arity as it's easy to write `select event, '(', ')', 'latex'` when what you meant
  was `select event, [ '(', ')', ], 'latex'` ###
  return false if @is_hidden event
  if ( arity = arguments.length ) > 3
    throw new Error "expected at most 3 arguments, got #{arity}"
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


#===========================================================================================================
# STAMPING & HIDING
#-----------------------------------------------------------------------------------------------------------
@stamp = ( event ) ->
  ### 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
  ignore events that have already been marked upstream, or, inversely choose to look out for events
  that have not yet found a representation in the target document. ###
  event[ 3 ][ 'stamped' ] = yes
  return event

#-----------------------------------------------------------------------------------------------------------
@is_stamped   = ( event ) -> event[ 3 ]?[ 'stamped' ] is true
@is_unstamped = ( event ) -> not @is_stamped event

#-----------------------------------------------------------------------------------------------------------
@hide = ( event ) ->
  ### 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
  ignore events that have already been marked upstream, or, inversely choose to look out for events
  that have not yet found a representation in the target document. ###
  event[ 3 ][ 'hidden' ] = yes
  return event

#-----------------------------------------------------------------------------------------------------------
@is_hidden = ( event ) -> event[ 3 ]?[ 'hidden' ] is true

#-----------------------------------------------------------------------------------------------------------
@copy = ( x, updates... ) ->
  ### (Hopefully) fast semi-deep copying for events (i.e. lists with a possible `meta` object on
  index 3) and plain objects. The value returned will be a shallow copy in the case of objects and
  lists, but if a list has a value at index 3, that object will also be copied. Not guaranteed to
  work for general values. ###
  if ( isa_list = CND.isa_list x ) then R = []
  else if         CND.isa_pod  x   then R = {}
  else throw new Error "unable to copy a #{CND.type_of x}"
  R       = Object.assign R, x, updates...
  R[ 3 ]  = Object.assign {}, meta if isa_list and ( meta = R[ 3 ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@_split_lines_with_nl = ( text ) -> ( line for line in text.split /(.*\n)/ when line.length > 0 )

#-----------------------------------------------------------------------------------------------------------
@_flush_text_collector = ( send, collector, meta ) ->
  if collector.length > 0
    send [ '.', 'text', ( collector.join '' ), meta, ]
    collector.length = 0
  return null

#-----------------------------------------------------------------------------------------------------------
@$show_mktsmd_events = ( S ) ->
  unknown_events    = []
  indentation       = ''
  tag_stack         = []
  return D.$observe ( event, has_ended ) =>
    if event?
      [ type, name, text, meta, ] = event
      if type is '?'
        unknown_events.push name unless name in unknown_events
        warn JSON.stringify event
      else
        color = CND.blue
        #...................................................................................................
        if @is_hidden event
          color = CND.brown
        else
          switch type
            when '<', '>'      then color = CND.yellow
            when '{','[',  '(' then color = CND.lime
            when ')', ']', '}' then color = CND.olive
            when '!'           then color = CND.indigo
            when '.'
              switch name
                when 'text' then color = CND.BLUE
                # when 'code' then color = CND.orange
        #...................................................................................................
        text = if text? then ( color rpr text ) else ''
        switch type
          when 'text'
            log indentation + ( color type ) + ' ' + rpr name
          when 'tex'
            if S.show_tex_events ? no
              log indentation + ( color type ) + ( color name ) + ' ' + text
          else
            log indentation + ( color type ) + ( color name ) + ' ' + text
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
@$write_mktscript = ( S ) ->
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
          when '>', '}', ']', '!'
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
@_escape_command_fences = ( text ) ->
  R = text
  R = R.replace /♎/g,       '♎0'
  R = R.replace /\\<\\</g,  '♎1'
  R = R.replace /\\<</g,    '♎2'
  R = R.replace /<\\</g,    '♎3'
  R = R.replace /<</g,      '♎4'
  return R

# #-----------------------------------------------------------------------------------------------------------
# @_unescape_command_fences = ( text ) ->
#   R = text
#   ### TAINT remove backslashes ###
#   R = R.replace /♎4/g, '<<'
#   R = R.replace /♎3/g, '<\\<'
#   R = R.replace /♎2/g, '\\<<'
#   R = R.replace /♎1/g, '\\<\\<'
#   R = R.replace /♎0/g, '♎'
#   return R

#-----------------------------------------------------------------------------------------------------------
@_unescape_command_fences_A = ( text ) ->
  R = text
  R = R.replace /♎4/g, '<<'
  return R

#-----------------------------------------------------------------------------------------------------------
@_unescape_command_fences_B = ( text ) ->
  R = text
  R = R.replace /♎3/g, '<<'
  R = R.replace /♎2/g, '<<'
  R = R.replace /♎1/g, '<<'
  R = R.replace /♎0/g, '♎'
  return R

#-----------------------------------------------------------------------------------------------------------
@$_replace_text = ( S, method ) ->
  return $ ( event, send ) =>
    if @.select event, '.', [ 'text', 'code', 'comment', ]
      [ type, name, text, meta, ] = event
      event[ 2 ] = method text
    send event

#-----------------------------------------------------------------------------------------------------------
@create_mdreadstream = ( md_source, settings ) ->
  throw new Error "settings currently unsupported" if settings?
  #.........................................................................................................
  confluence  = D.create_throughstream()
  R           = D.create_throughstream()
  R.pause()
  #.........................................................................................................
  state       =
    confluence:           confluence
  #.........................................................................................................
  confluence
    .pipe @$_flatten_tokens                 state
    .pipe @$_reinject_html_blocks           state
    .pipe @$_rewrite_markdownit_tokens      state
    .pipe @$_replace_text                   state, @_unescape_command_fences_A
    .pipe @$_preprocess_XXXX                state
    .pipe @$_replace_text                   state, @_unescape_command_fences_B
    # .pipe @$_preprocess_commands            state
    .pipe @$_process_end_command            state
    # .pipe @$_preprocess_regions             state
    .pipe R
  #.........................................................................................................
  R.on 'resume', =>
    md_parser   = @_new_markdown_parser()
    ### for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse ###
    ### TAINT what to do with useful data appearing environment? ###
    ### TAINT environment becomes important for footnotes ###
    environment = {}
    # md_source = """front #1 #,2<<(:foo>>FOO<<:)>>. <<!foo>>, <\\<!foo>>, \\<<!foo>>, back."""
    # md_source = """front #1 #,2<<(:foo>>#FOO#<<:)>>. <<!foo>>, <\\<!foo>>, \\<<!foo>>, back."""
    # md_source = """A <<(:x>> <\\<(raw>>\\TeX{} <\\<raw)>> <<:)>>: <<!x>> Z"""
    # md_source = """A <<(:x>> <<(raw>>\\TeX{} <<raw)>> <<:)>>: <<!x>> Z"""
    md_source   = @_escape_command_fences md_source
    tokens      = md_parser.parse md_source, environment
    # @set_meta R, 'environment', environment
    confluence.write token for token in tokens
    confluence.end()
  #.........................................................................................................
  return R

### TAINT currently not used, but 'potentially useful'
#-----------------------------------------------------------------------------------------------------------
@_meta  = Symbol 'meta'

#-----------------------------------------------------------------------------------------------------------
@set_meta = ( x, name, value = true ) ->
  target          = x[ @_meta ]?= {}
  target[ name ]  = value
  return x

#-----------------------------------------------------------------------------------------------------------
@get_meta = ( x, name = null ) ->
  R = x[ @_meta ]
  R = R[ name ] if name
  return R
###


