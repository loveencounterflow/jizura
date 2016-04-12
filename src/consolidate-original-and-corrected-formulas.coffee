



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/show-repeated-factors'
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
after                     = suspend.after
eventually                = suspend.eventually
immediately               = suspend.immediately
repeat_immediately        = suspend.repeat_immediately
every                     = suspend.every
#...........................................................................................................
# BYTEWISE                  = require 'bytewise'
# through                   = require 'through2'
# LevelBatch                = require 'level-batch-stream'
# BatchStream               = require 'batch-stream'
# parallel                  = require 'concurrent-writable'
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
ASYNC                     = require 'async'
XNCHR                     = require './XNCHR'
#...........................................................................................................
# new_db                    = require 'level'
HOLLERITH                 = require 'hollerith'
# LRSL                      = require 'longest-repeating-sublist'

# XNCHR.chrs_from_text "𢐨𢐮𢰅𣹎𤑜𤑨𤑵𤙗𥋡𥽮𦭲𦳪𦽙𧙭𧛴𧩿𨂳𩱆𩱌𩱍𩱎𩱒𩱓𩱖𩱗𩱚𩱜𩱞𩱟𩱠𩱡𩱣𩱤𩱥𩱦𩱧𩱨𩱪𩱫𩱭𩱮𩱯𩱰𩱱𩱲𩱳𩱶𩱷𪾞𫙆𫙇"

#-----------------------------------------------------------------------------------------------------------
@consolidate_formulas = ( S ) ->
  options             = require '../../jizura-datasources/options'
  originals_route     = options[ 'ds-routes' ][ 'formulas'              ]
  consolidated_route  = options[ 'ds-routes' ][ 'formulas-consolidated' ]
  corrections_route   = options[ 'ds-routes' ][ 'formulas-corrections'  ]
  help """Collecting formulas from
    #{originals_route}
    and
    #{corrections_route}
    into
    #{consolidated_route}"""
  #.........................................................................................................
  output              = njs_fs.createWriteStream consolidated_route
  corrections_input   = njs_fs.createReadStream corrections_route
  corrections_input
    .pipe $transform            S
    .pipe $collect_corrections  S
    .pipe $ ( corrections, send ) => S.corrections = corrections
    .pipe D.$on_end =>
      originals_input = njs_fs.createReadStream originals_route
      originals_input
        .pipe $transform          S
        .pipe $replace_corrected  S
        .pipe $format_line        S
        .pipe D.$on_end =>
          urge "output written to #{consolidated_route}"
        .pipe output
  #.........................................................................................................
  # S.db_route          = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  # S.db                = HOLLERITH.new_db S.db_route, create: no
  # help "using DB at #{S.db[ '%self' ][ 'location' ]}"
  # input               = D.create_throughstream()
  # #.........................................................................................................
  # for glyph in S.glyphs
  #   input.write glyph
  # input.end()
  # #.........................................................................................................
  return null

# #-----------------------------------------------------------------------------------------------------------
# $query = ( S ) ->
#   return D.remit_async_spread ( glyph, send ) =>
#     query = { prefix: [ 'spo', glyph, 'formula' ], }
#     input = ( HOLLERITH.create_phrasestream S.db, query )
#     input
#       .pipe $ ( phrase, _ ) =>
#         [ ..., formulas, ] = phrase
#         send [ glyph, formula, idx, ] for formula, idx in formulas
#         send.done()

# #-----------------------------------------------------------------------------------------------------------
# $add_fncr = ( S ) ->
#   return $ ( [ glyph, formula, idx, ], send ) =>
#     fncr = XNCHR.as_fncr glyph
#     send [ glyph, fncr, formula, idx, ]

# #-----------------------------------------------------------------------------------------------------------
# $sort = ( S ) ->
#   return D.$sort ( a, b ) =>
#     [ a_fncr, a_glyph, a_formula, a_idx, ] = a
#     [ b_fncr, b_glyph, b_formula, b_idx, ] = b
#     a_cid = XNCHR.as_cid a_glyph
#     b_cid = XNCHR.as_cid b_glyph
#     return +1 if a_cid > b_cid
#     return -1 if a_cid < b_cid
#     return +1 if a_idx > b_idx
#     return -1 if a_idx < b_idx
#     return  0

#-----------------------------------------------------------------------------------------------------------
$collect_corrections = ( S ) ->
  Z = {}
  return $ ( fields, send, end ) =>
    if fields?
      [ fncr, glyph, formula, ] = fields
      ( Z[ glyph ]?= [] ).push formula
    if end?
      send Z
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$replace_corrected = ( S ) ->
  seen_glyphs = new Set()
  return $ ( fields, send ) =>
    [ fncr, glyph, formula, ] = fields
    return if seen_glyphs.has glyph
    if ( corrected_formulas = S.corrections[ glyph ] )?
      for corrected_formula in corrected_formulas
        send [ fncr, glyph, corrected_formula, ]
    else
      send [ fncr, glyph, formula, ]
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$format_line = ( S ) ->
  return $ ( fields, send ) =>
    send ( fields.join '\t' ) + '\n'
    #.......................................................................................................
    return null


#===========================================================================================================
# GENERICS
# (should really be in PipeDreams)
#-----------------------------------------------------------------------------------------------------------
$split_fields = ( S ) ->
  return $ ( line, send ) =>
    send line.split '\t'
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$trim = ( S ) ->
  return $ ( data, send ) =>
    switch type = CND.type_of data
      when 'text' then send data.trim()
      when 'list' then send ( d.trim() for d in data when CND.isa_text d )
      else throw new Error "unable to split a #{type}"
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$drop_comments = ( S ) ->
  return $ ( fields, send ) =>
    Z = []
    for field in fields
      break if field.startsWith '#'
      Z.push field
    send Z
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$skip_empty = ( S ) ->
  return $ ( data, send ) =>
    return null unless data?
    switch type = CND.type_of data
      when 'text', 'list' then send data unless data.length is 0
      else send data
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$show = ( S ) ->
  return D.$observe ( fields ) =>
    echo fields.join '\t'
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
$transform = ( S ) =>
  return D.combine [
    D.$split()
    $trim()
    $skip_empty()
    $split_fields()
    $drop_comments()
    $skip_empty()
    $trim()
    # D.$show()
    # $show                       S
    # D.$on_end => S.handler null if S.handler?
    ]


