



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
@TYPO._escape_replacements = [
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
  [ ///  (^|[^\\])& ///g, '\\&',                    ]
  # [ ///  &   ///g,  '\\&',                  ]
  # [ ///  ([^\\])&   ///g,  '$1\\&',                  ]
  # '`'   # these two are very hard to catch when TeX's character handling is switched on
  # "'"   #
  ]

#-----------------------------------------------------------------------------------------------------------
@TYPO.escape_for_tex = ( text ) =>
  R = text
  R = R.replace matcher, replacement for [ matcher, replacement, ] in @TYPO._escape_replacements
  return R

#-----------------------------------------------------------------------------------------------------------
@TYPO.$fix_typography_for_tex = =>
  return $ ( event, send ) =>
    [ type, tail..., ] = event
    if type is 'text'
      send [ 'text', ( @TYPO.as_tex_text tail[ 0 ] ), ]
    else
      send event

# #-----------------------------------------------------------------------------------------------------------
# @TYPO.supply_cjk_markup = =>
#   tag_stack = []
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     [ type, tail..., ] = event
#     return send event unless type is 'text'
#     text  = tail[ 0 ]
#     tex   = H1.cjk_as_tex_text text
#     # tex   = tex.replace /\\latin\{([^]+)\}/g, '$1'
#     send [ 'tex', tex, ]

#-----------------------------------------------------------------------------------------------------------
@TYPO.as_tex_text = ( text, settings ) =>
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
      debug '©zDJqU', last_command, JSON.stringify stretch.join '.'
      if last_command in [ null, 'latin', ]
        R.push @TYPO.escape_for_tex stretch.join ''
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

# #-----------------------------------------------------------------------------------------------------------
# @TYPO.cjk_as_tex_text = ( text ) =>
#   chrs    = XNCHR.chrs_from_text text
#   R       = []
#   is_cjk  = ( x ) => /^(u-cjk|u-halfull|u-hang-syl|jzr-fig|u-pua)/.test XNCHR.as_rsg x
#   for chr in chrs
#     R.push if ( is_cjk chr ) then ( XELATEX.tag_rpr_from_chr options[ 'glyph-styles' ], chr ) else chr
#   return R.join ''

















