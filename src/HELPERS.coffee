



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
#...........................................................................................................
options                   = require './options'


#-----------------------------------------------------------------------------------------------------------
@provide_tmp_folder = ->
  njs_fs.mkdirSync options[ 'tmp-home' ] unless njs_fs.existsSync options[ 'tmp-home' ]
  return null

#-----------------------------------------------------------------------------------------------------------
@new_layout_info = ( source_route ) ->
  pdf_command         = options[ 'pdf-command' ]
  tmp_home            = options[ 'tmp-home' ]
  source_locator      = njs_path.resolve process.cwd(), source_route
  source_home         = njs_path.dirname source_locator
  source_name         = njs_path.basename source_locator
  tex_locator         = njs_path.join tmp_home, CND.swap_extension source_name, '.tex'
  aux_locator         = njs_path.join tmp_home, CND.swap_extension source_name, '.aux'
  pdf_source_locator  = njs_path.join tmp_home, CND.swap_extension source_name, '.pdf'
  pdf_target_locator  = njs_path.join source_home, CND.swap_extension source_name, '.pdf'
  #.........................................................................................................
  R =
    'pdf-command':          pdf_command
    'tmp-home':             tmp_home
    'source-route':         source_route
    'source-locator':       source_locator
    'source-home':          source_home
    'source-name':          source_name
    'tex-locator':          tex_locator
    'aux-locator':          aux_locator
    'pdf-source-locator':   pdf_source_locator
    'pdf-target-locator':   pdf_target_locator
    'latex-run-count':      0
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
@TYPO = {}

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

#-----------------------------------------------------------------------------------------------------------
@TYPO.$resolve_html_entities = ->
  return $ ( event, send ) =>
    [ type, tail..., ] = event
    if type is 'text'
      send [ 'text', ( @resolve_html_entities tail[ 0 ] ), ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@TYPO.$fix_typography_for_tex = ->
  return $ ( event, send ) =>
    [ type, tail..., ] = event
    if type is 'text'
      send [ 'text', ( @fix_typography_for_tex tail[ 0 ] ), ]
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@TYPO.resolve_html_entities = ( text ) ->
  R = text
  R = R.replace /&lt;/g, '<'
  R = R.replace /&gt;/g, '>'
  R = R.replace /&quot;/g, '"'
  R = R.replace /&amp;/g, '&'
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
  last_tag_name         = null
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
  # feature_set = 'zero'
  #.........................................................................................................
  settings    =
    html:           yes,            # Enable HTML tags in source
    xhtmlOut:       no,             # Use '/' to close single tags (<br />)
    breaks:         no,             # Convert '\n' in paragraphs into <br>
    langPrefix:     'language-',    # CSS language prefix for fenced blocks
    linkify:        yes,            # Autoconvert URL-like text to links
    typographer:    yes,
    # quotes:         '“”‘’'
    # quotes:         '""\'\''
    # quotes:         '""`\''
    # quotes:         [ '<<', '>>', '!!!', '???', ]
    quotes:   ['«\xA0', '\xA0»', '‹\xA0', '\xA0›'] # French
  #.........................................................................................................
  # R = new Markdown_parser feature_set, settings
  R = new Markdown_parser settings
  #.......................................................................................................
  ### sample plugin ###
  user_pattern  = /@(\w+)/
  user_handler  = ( match, utils ) ->
    url = 'http://example.org/u/' + match[ 1 ]
    return '<a href="' + utils.escape(url) + '">' + utils.escape(match[1]) + '</a>'
  user_plugin = new_md_inline_plugin user_pattern, user_handler
  #.......................................................................................................
  R.use user_plugin
  # R.use require 'markdown-it-mark'
  # R.use require 'markdown-it-sub'
  # R.use require 'markdown-it-sup'
  R.use ( require 'markdown-it-container' ), 'keeplines', render: ( tokens, idx ) ->
    # debug '©0KgAK', rpr tokens[ idx .. idx + 20 ]
    return '<keeplines>' if tokens[ idx ][ 'nesting' ] is 1
    return '</keeplines>'
  # R.use require './markdown-it-wall'
  # debug '©1EaXq', R[ 'block' ][ 'ruler' ]
  # debug '©FVzlq', ( rule for rule in R[ 'block' ][ 'ruler' ]['__rules__'] )
  # R[ 'block' ][ 'ruler' ].before 'fence', 'wall', ( require './markdown-it-wall' ), { alt: [ 'paragraph', 'reference', 'blockquote', 'list' ] }
  # R[ 'block' ][ 'ruler' ].push require './markdown-it-wall'
  #.......................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO._new_html_parser = ( stream ) ->
  ### https://github.com/fb55/htmlparser2/wiki/Parser-options ###
  settings =
    xmlMode:                 no   # Indicates whether special tags (<script> and <style>) should get special
                                  # treatment and if "empty" tags (eg. <br>) can have children. If false,
                                  # the content of special tags will be text only.
                                  # For feeds and other XML content (documents that don't consist of HTML),
                                  # set this to true. Default: false.
    decodeEntities:          no   # If set to true, entities within the document will be decoded. Defaults
                                  # to false.
    lowerCaseTags:           no   # If set to true, all tags will be lowercased. If xmlMode is disabled,
                                  # this defaults to true.
    lowerCaseAttributeNames: no   # If set to true, all attribute names will be lowercased. This has
                                  # noticeable impact on speed, so it defaults to false.
    recognizeCDATA:          yes  # If set to true, CDATA sections will be recognized as text even if the
                                  # xmlMode option is not enabled. NOTE: If xmlMode is set to true then
                                  # CDATA sections will always be recognized as text.
    recognizeSelfClosing:    yes  # If set to true, self-closing tags will trigger the onclosetag event even
                                  # if xmlMode is not set to true. NOTE: If xmlMode is set to true then
                                  # self-closing tags will always be recognized.
  #.........................................................................................................
  handlers =
    onopentag:  ( name, attributes )  -> stream.write [ 'open-tag',  name, attributes, ]
    ontext:     ( text )              -> stream.write [ 'text',      text, ]
    onclosetag: ( name )              -> stream.write [ 'close-tag', name, ]
    onerror:    ( error )             -> stream.error error
    oncomment:  ( text )              -> stream.write [ 'comment',   text, ]
    onend:                            -> stream.write [ 'end', ]; stream.end()
    # oncdatastart:            ( P... ) -> debug 'cdatastart           ', P  # 0
    # oncdataend:              ( P... ) -> debug 'cdataend             ', P  # 0
    # onprocessinginstruction: ( P... ) -> debug 'processinginstruction', P  # 2
  #.........................................................................................................
  return new Html_parser handlers, settings

#-----------------------------------------------------------------------------------------------------------
@TYPO.create_html_readstream_from_md = ( text, settings ) ->
  throw new Error "settings currently unsupported" if settings?
  #.........................................................................................................
  R = D.create_throughstream()
  R.pause()
  #.........................................................................................................
  # setImmediate =>
  md_parser   = @_new_markdown_parser()
  html_parser = @_new_html_parser R
  html        = md_parser.render text
  # help '©YzNQP',  html
  html_parser.write html
  html_parser.end()
  #.........................................................................................................
  $remove_block_tags_from_keeplines = =>
    within_keeplines = no
    return $ ( event, send ) =>
      [ type, tag, tail..., ] = event
      if type is 'open-tag' and tag is 'keeplines'
        within_keeplines = yes
        return send event
      if type is 'close-tag' and tag is 'keeplines'
        within_keeplines = no
        return send event
      if within_keeplines
        if type in [ 'open-tag', 'close-tag', ]
          ###TAINT apply to other block-level tags? ###
          send event unless tag is 'p'
        else
          send event
      else
        send event
  #.........................................................................................................
  $consolidate_texts = =>
    collector = []
    _send     = null
    #.......................................................................................................
    flush = ->
      if collector.length > 0
        text  = collector.join ''
        text  = text.replace /^\n+/, ''
        text  = text.replace /\n+$/, ''
        # text = ( collector.join '' ).trim()
        _send [ 'text', text, ] if text.length > 0
        collector.length = 0
        return null
    #.......................................................................................................
    return $ ( event, send, end ) =>
      _send = send
      if event?
        [ type, text, ] = event
        if type is 'text'
          collector.push text
        else
          flush()
          send event
      if end?
        flush()
        end()
  #.........................................................................................................
  R = R
    .pipe $remove_block_tags_from_keeplines()
    .pipe $consolidate_texts()
  #.........................................................................................................
  return R

# source_route  = njs_path.resolve __dirname, '../jizura/texts/demo/demo.md'
# source_md     = njs_fs.readFileSync source_route, encoding: 'utf-8'
# debug '©3E4JY', source_md
# input =  @create_html_readstream_from_mdx_text source_md
# input
#   .pipe D.$show()
# input.resume()



















