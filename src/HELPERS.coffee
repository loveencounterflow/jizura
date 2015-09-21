



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
Html_parser               = ( require 'htmlparser2' ).Parser
new_md_inline_plugin      = require 'markdown-it-regexp'


#-----------------------------------------------------------------------------------------------------------
@provide_tmp_folder = ( options ) ->
  njs_fs.mkdirSync options[ 'tmp-home' ] unless njs_fs.existsSync options[ 'tmp-home' ]
  return null

#-----------------------------------------------------------------------------------------------------------
@tmp_locator_for_extension = ( layout_info, extension ) ->
  tmp_home            = layout_info[ 'tmp-home' ]
  tex_locator         = layout_info[ 'tex-locator' ]
  ### TAINT should extension be sanitized? maybe just check for /^\.?[-a-z0-9]$/? ###
  throw new Error "need non-empty extension" unless extension.length > 0
  extension           = ".#{extension}" unless ( /^\./ ).test extension
  return njs_path.join CND.swap_extension tex_locator, extension

#-----------------------------------------------------------------------------------------------------------
@new_layout_info = ( options, source_route ) ->
  pdf_command           = options[ 'pdf-command' ]
  tmp_home              = options[ 'tmp-home' ]
  source_locator        = njs_path.resolve process.cwd(), source_route
  source_home           = njs_path.dirname source_locator
  source_name           = njs_path.basename source_locator
  ### TAINT use `tmp_locator_for_extension` ###
  tex_locator           = njs_path.join tmp_home, CND.swap_extension source_name, '.tex'
  aux_locator           = njs_path.join tmp_home, CND.swap_extension source_name, '.aux'
  pdf_source_locator    = njs_path.join tmp_home, CND.swap_extension source_name, '.pdf'
  pdf_target_locator    = njs_path.join source_home, CND.swap_extension source_name, '.pdf'
  tex_inputs_home       = njs_path.resolve __dirname, '..', 'tex-inputs'
  settings_name         = options[ 'settings' ][ 'filename' ]
  settings_ext          = njs_path.extname settings_name
  settings_name_bare    = njs_path.basename settings_name, settings_ext
  settings_locator      = njs_path.join source_home, settings_name
  settings_locator_bare = njs_path.join source_home, settings_name_bare
  #.........................................................................................................
  R =
    'aux-locator':                aux_locator
    'latex-run-count':            0
    'mkts-settings-locator':      settings_locator
    'mkts-settings-locator.bare': settings_locator_bare
    'mkts-settings-name':         settings_name
    'pdf-command':                pdf_command
    'pdf-source-locator':         pdf_source_locator
    'pdf-target-locator':         pdf_target_locator
    'source-home':                source_home
    'source-locator':             source_locator
    'source-name':                source_name
    'source-route':               source_route
    'tex-inputs-home':            tex_inputs_home
    'tex-locator':                tex_locator
    'tmp-home':                   tmp_home
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@write_pdf = ( layout_info, handler ) ->
  #.........................................................................................................
  pdf_command         = layout_info[ 'pdf-command'          ]
  tmp_home            = layout_info[ 'tmp-home'             ]
  tex_locator         = layout_info[ 'tex-locator'          ]
  aux_locator         = layout_info[ 'aux-locator'          ]
  pdf_source_locator  = layout_info[ 'pdf-source-locator'   ]
  pdf_target_locator  = layout_info[ 'pdf-target-locator'   ]
  last_digest         = null
  last_digest         = CND.id_from_route aux_locator if njs_fs.existsSync aux_locator
  digest              = null
  count               = 0
  #.........................................................................................................
  pdf_from_tex = ( next ) =>
    count += 1
    urge "run ##{count} #{pdf_command}"
    whisper "$1: #{tmp_home}"
    whisper "$2: #{tex_locator}"
    CND.spawn pdf_command, [ tmp_home, tex_locator, ], ( error, data ) =>
      error = undefined if error is 0
      if error?
        alert error
        return handler error
      digest = CND.id_from_route aux_locator
      if digest is last_digest
        echo ( CND.grey badge ), CND.lime "done."
        layout_info[ 'latex-run-count' ] = count
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
@TYPO.$fix_typography_for_tex = ->
  return $ ( event, send ) =>
    if @isa event, '.', 'text'
      [ type, name, text, meta, ] = event
      text = @fix_typography_for_tex text
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
@TYPO.fix_typography_for_tex = ( text, settings ) ->
  ### An improved version of `XELATEX.tag_from_chr` ###
  settings             ?= options
  glyph_styles          = settings[ 'tex' ]?[ 'glyph-styles'             ] ? {}
  tex_command_by_rsgs   = settings[ 'tex' ]?[ 'tex-command-by-rsgs'      ]
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

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._new_html_parser = ( stream ) ->
#   ### https://github.com/fb55/htmlparser2/wiki/Parser-options ###
#   settings =
#     xmlMode:                 no   # Indicates whether special tags (<script> and <style>) should get special
#                                   # treatment and if "empty" tags (eg. <br>) can have children. If false,
#                                   # the content of special tags will be text only.
#                                   # For feeds and other XML content (documents that don't consist of HTML),
#                                   # set this to true. Default: false.
#     decodeEntities:          no   # If set to true, entities within the document will be decoded. Defaults
#                                   # to false.
#     lowerCaseTags:           no   # If set to true, all tags will be lowercased. If xmlMode is disabled,
#                                   # this defaults to true.
#     lowerCaseAttributeNames: no   # If set to true, all attribute names will be lowercased. This has
#                                   # noticeable impact on speed, so it defaults to false.
#     recognizeCDATA:          yes  # If set to true, CDATA sections will be recognized as text even if the
#                                   # xmlMode option is not enabled. NOTE: If xmlMode is set to true then
#                                   # CDATA sections will always be recognized as text.
#     recognizeSelfClosing:    yes  # If set to true, self-closing tags will trigger the onclosetag event even
#                                   # if xmlMode is not set to true. NOTE: If xmlMode is set to true then
#                                   # self-closing tags will always be recognized.
#   #.........................................................................................................
#   handlers =
#     onopentag:  ( name, attributes )  -> stream.write [ 'open-tag',  name, attributes, ]
#     ontext:     ( text )              -> stream.write [ 'text',      text, ]
#     onclosetag: ( name )              -> stream.write [ 'close-tag', name, ]
#     onerror:    ( error )             -> stream.error error
#     oncomment:  ( text )              -> stream.write [ 'comment',   text, ]
#     onend:                            -> stream.write [ 'end', ]; stream.end()
#     # oncdatastart:            ( P... ) -> debug 'cdatastart           ', P  # 0
#     # oncdataend:              ( P... ) -> debug 'cdataend             ', P  # 0
#     # onprocessinginstruction: ( P... ) -> debug 'processinginstruction', P  # 2
#   #.........................................................................................................
#   return new Html_parser handlers, settings

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._preprocess_regions = ( md_source ) ->
#   opening_pattern   = /(\n|^)@@@(\S.+)(\n|$)/g
#   closing_pattern   = /(\n|^)@@@\s*(\n|$)/g
#   md_source         = md_source.replace opening_pattern, "$1<mkts-mark x-role='start-region' x-name='$2'></mkts-mark>$3"
#   md_source         = md_source.replace closing_pattern, "$1<mkts-mark x-role='end-region'></mkts-mark>$2"
#   return md_source

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._preprocess_commands = ( md_source ) ->
#   pattern     = /(\n|^)∆∆∆(\S.+)(\n|$)/g
#   md_source   = md_source.replace pattern, "$1<mkts-mark x-role='command' x-name='$2'></mkts-mark>$3"
#   return md_source

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._$remove_superfluous_tags = ->
#   skip_next_text            = no
#   skip_next_closing_anchor  = no
#   skip_next_closing_hr      = no
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     [ type, tag_name, attributes, ] = event
#     #.......................................................................................................
#     if type is 'text'
#       if skip_next_text
#         skip_next_text = no
#         return
#     #.......................................................................................................
#     else if type is 'close-tag'
#       return if tag_name is 'mkts-mark'
#       if skip_next_closing_anchor and tag_name is 'a'
#         skip_next_closing_anchor = no
#         return
#       if skip_next_closing_hr and tag_name is 'hr'
#         skip_next_closing_hr = no
#         return
#     #.......................................................................................................
#     else if type is 'open-tag'
#       if tag_name is 'a' and attributes[ 'class' ] is 'footnote-backref'
#         skip_next_text            = yes
#         skip_next_closing_anchor  = yes
#         return
#       if tag_name is 'hr' and attributes[ 'class' ] is 'footnotes-sep'
#         skip_next_closing_hr      = yes
#         return
#     #.......................................................................................................
#     send event

# # #-----------------------------------------------------------------------------------------------------------
# # @TYPO._$collect_footnotes = =>
# #   collector         = []
# #   within_footnotes  = no
# #   #.........................................................................................................
# #   return $ ( event, send ) =>
# #     [ type, tag_name, attributes, ] = event
# #     if type is 'open-tag'
# #       if ( tag_name is 'section' ) and ( attributes[ 'class' ] is 'footnotes' )
# #         within_footnotes = yes
# #         return
# #     else if type is 'close-tag'
# #       if within_footnotes and tag_name is 'section'
# #         within_footnotes = no
# #         return
# #     send event

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._$add_regions = ->
#   region_stack              = []
#   #.........................................................................................................
#   return $ ( event, send, end ) =>
#     #.......................................................................................................
#     if event?
#       [ type, tag_name, attributes, ] = event
#       #.....................................................................................................
#       if ( type is 'open-tag' )
#         if ( tag_name is 'mkts-mark' ) and ( attributes[ 'x-role' ] is 'start-region' )
#           region_name = attributes[ 'x-name' ]
#           region_stack.push region_name
#           send [ 'start-region', region_name, ]
#         else if ( tag_name is 'mkts-mark' ) and ( attributes[ 'x-role' ] is 'end-region' )
#           if region_stack.length > 0
#             send [ 'end-region', region_stack.pop(), ]
#           else
#             warn "ignoring end-region"
#         else
#           send event
#       #...................................................................................................
#       else
#         send event
#     #.......................................................................................................
#     if end?
#       if region_stack.length > 0
#         warn "auto-closing regions: #{rpr region_stack.join ', '}"
#         send [ 'end-region', region_stack.pop(), ] while region_stack.length > 0
#       end()

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._$add_commands = ->
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     [ type, tag_name, attributes, ] = event
#     #.....................................................................................................
#     if ( type is 'open-tag' )
#       if ( tag_name is 'mkts-mark' ) and ( attributes[ 'x-role' ] is 'command' )
#         command = attributes[ 'x-name' ]
#         send [ 'command', command, ]
#       else
#         send event
#     #...................................................................................................
#     else
#       send event

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._$remove_block_tags_from_keeplines = =>
#   within_keeplines = no
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     [ type, tag, tail..., ] = event
#     #.......................................................................................................
#     if type is 'start-region' and tag is 'keeplines'
#       within_keeplines = yes
#       return send event
#     #.......................................................................................................
#     if type is 'end-region' and tag is 'keeplines'
#       within_keeplines = no
#       return send event
#     #.......................................................................................................
#     if within_keeplines
#       if type in [ 'open-tag', 'close-tag', ]
#         ###TAINT apply to other block-level tags? ###
#         send event unless tag is 'p'
#       else
#         send event
#     #.......................................................................................................
#     else
#       send event

# #-----------------------------------------------------------------------------------------------------------
# @TYPO._$consolidate_texts = =>
#   collector = []
#   _send     = null
#   #.........................................................................................................
#   flush = ->
#     if collector.length > 0
#       text  = collector.join ''
#       # text  = text.replace /^\n+/, ''
#       # text  = text.replace /\n+$/, ''
#       _send [ 'text', text, ] if text.length > 0
#       collector.length = 0
#       return null
#   #.........................................................................................................
#   return $ ( event, send, end ) =>
#     _send = send
#     if event?
#       [ type, text, ] = event
#       if type is 'text'
#         collector.push text
#       else
#         flush()
#         send event
#     if end?
#       flush()
#       end()

###
###

#-----------------------------------------------------------------------------------------------------------
@TYPO.$flatten_tokens = ->
  return $ ( token, send ) ->
    switch ( type = token[ 'type' ] )
      when 'inline' then send sub_token for sub_token in token[ 'children' ]
      else send token

#-----------------------------------------------------------------------------------------------------------
@TYPO.$rewrite_markdownit_tokens = ->
  unknown_tokens = []
  return $ ( token, send, end ) =>
    if token?
      meta =
        within_text_literal:    no
        # within_keep_lines:      no
        # within_single_column:   no
      switch ( type = token[ 'type' ] )
        # blocks
        when 'heading_open'       then send [ '[', token[ 'tag' ],  null,               meta, ]
        when 'heading_close'      then send [ ']', token[ 'tag' ],  null,               meta, ]
        when 'paragraph_open'     then send [ '[', 'p',             null,               meta, ]
        when 'paragraph_close'    then send [ ']', 'p',             null,               meta, ]
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
        # specials
        when 'code_inline'
          send [ '(', 'code', null,               ( @_copy meta ), ]
          send [ '.', 'text', token[ 'content' ], ( @_copy meta, within_text_literal: yes, ), ]
          send [ ')', 'code', null,               ( @_copy meta ), ]
        else
          send [ '?', token[ 'tag' ], token[ 'content' ], meta, ]
          unknown_tokens.push type unless type in unknown_tokens
    if end?
      if unknown_tokens.length > 0
        warn "unknown tokens: #{unknown_tokens.sort().join ', '}"
      end()
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$preprocess_regions = ->
  opening_pattern   = /^@@@(\S.+)(\n|$)/
  closing_pattern   = /^@@@\s*(\n|$)/
  collector         = []
  region_stack      = []
  #.........................................................................................................
  return $ ( event, send, end ) =>
    #.......................................................................................................
    if event?
      [ type, name, text, meta, ] = event
      if ( not meta.within_text_literal ) and ( @isa event, '.', 'text' )
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
      else
        send event
    #.......................................................................................................
    if end?
      if region_stack.length > 0
        warn "auto-closing regions: #{rpr region_stack.join ', '}"
        send [ '}', region_stack.pop(), null, ( @_copy meta, block: true ), ] while region_stack.length > 0
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.$preprocess_commands = ->
  pattern   = /^∆∆∆(\S.+)(\n|$)/
  collector = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, name, text, meta, ] = event
    return send event unless ( type is '.' ) and ( name is 'text' )
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
    return null

#-----------------------------------------------------------------------------------------------------------
@TYPO.isa = ( event, type, name ) ->
  switch type_of_type = CND.type_of type
    when 'text' then return false unless event[ 0 ] is type
    when 'list' then return false unless event[ 0 ] in type
    else throw new Error "expected text or list, got a #{type_of_type}"
  switch type_of_name = CND.type_of name
    when 'text' then return false unless event[ 1 ] is name
    when 'list' then return false unless event[ 1 ] in name
    else throw new Error "expected text or list, got a #{type_of_name}"
  return true

#-----------------------------------------------------------------------------------------------------------
@TYPO._copy = ( meta, overwrites ) ->
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
@TYPO.$add_lookahead = ->
  previous_event = null
  return $ ( event, send, end ) ->
    if event?
      # debug '©t9r7W', event
      if previous_event?
        previous_event[ 3 ][ 'ends-block' ] = event[ 3 ][ 'block' ]
        send previous_event
      previous_event = event
    if end?
      previous_event[ 3 ][ 'ends-block' ] = no
      send previous_event
      end()
    return null

# #-----------------------------------------------------------------------------------------------------------
# @TYPO.$remove_superfluous_tags = ->
#   return $ ( event, send ) ->
#     [ type, name, text, meta, ] = event

#-----------------------------------------------------------------------------------------------------------
@TYPO.$show_mktsmd_events = ->
  unknown_events    = []
  level             = 0
  indentation       = ''
  next_indentation  = indentation
  return D.$observe ( event, has_ended ) ->
    if event?
      [ type, name, text, meta, ] = event
      if type is '?'
        unknown_events.push name unless name in unknown_events
        warn JSON.stringify event
      else
        color = CND.blue
        switch type
          when '{', '[', '('
            level            += +1
            next_indentation  = ( new Array level ).join '  '
          when ')', ']', '}'
            level            += -1
            next_indentation  = ( new Array level ).join '  '
          when '.'
            switch name
              when 'text' then color = CND.green
              when 'code' then color = CND.orange
        switch type
          when '{'
            color         = CND.red
          when '∆'
            color         = CND.red
          when ')', ']', '}'
            color         = CND.grey
        text = if text? then ( color rpr text ) else ''
        log indentation + ( CND.grey type ) + ( color name ) + ' ' + text
        indentation = next_indentation
    if has_ended
      if unknown_events.length > 0
        warn "unknown events: #{unknown_events.sort().join ', '}"
    return null


#-----------------------------------------------------------------------------------------------------------
@TYPO.create_mdreadstream = ( md_source, settings ) ->
  throw new Error "settings currently unsupported" if settings?
  #.........................................................................................................
  confluence  = D.create_throughstream()
  R           = D.create_throughstream()
  R.pause()
  #.........................................................................................................
  confluence
    .pipe @$flatten_tokens()
    .pipe @$rewrite_markdownit_tokens()
    .pipe @$preprocess_regions()
    .pipe @$preprocess_commands()
    # .pipe @$remove_superfluous_tags()
    # .pipe @$add_lookahead()
    # .pipe D.$show()
    # .pipe @$show_mktsmd_events()
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


















