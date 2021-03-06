



############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/dump-formulas'
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
IDLX                      = require 'idlx'
XNCHR                     = require './XNCHR'
#...........................................................................................................
# new_db                    = require 'level'
HOLLERITH                 = require 'hollerith'
# LRSL                      = require 'longest-repeating-sublist'

# XNCHR.chrs_from_text "𢐨𢐮𢰅𣹎𤑜𤑨𤑵𤙗𥋡𥽮𦭲𦳪𦽙𧙭𧛴𧩿𨂳𩱆𩱌𩱍𩱎𩱒𩱓𩱖𩱗𩱚𩱜𩱞𩱟𩱠𩱡𩱣𩱤𩱥𩱦𩱧𩱨𩱪𩱫𩱭𩱮𩱯𩱰𩱱𩱲𩱳𩱶𩱷𪾞𫙆𫙇"

#-----------------------------------------------------------------------------------------------------------
@dump_formulas = ( S ) ->
  #.........................................................................................................
  S.db_route          = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  S.db                = HOLLERITH.new_db S.db_route, create: no
  help "using DB at #{S.db[ '%self' ][ 'location' ]}"
  input               = D.create_throughstream()
  input.pipe $transform S
  #.........................................................................................................
  input_from_pipe = not process.stdin.isTTY
  #.........................................................................................................
  if input_from_pipe
    if S.glyphs.length > 0
      warn "unable to accept glyphs from both stdin and option -g / --glyphs"
      process.exit 1
    process.stdin
      .pipe D.$split()
      .pipe $ ( line, send ) ->
        for chr in XNCHR.chrs_from_text line
          send chr
      .pipe input
  else
    for glyph in S.glyphs
      input.write glyph
    input.end()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
$query = ( S ) =>
  return D.remit_async_spread ( glyph, send ) =>
    query   = { prefix: [ 'spo', glyph, 'formula' ], }
    # query = { prefix: [ 'spo', glyph, 'guide/lineup/uchr' ], }
    input = ( HOLLERITH.create_phrasestream S.db, query )
    input
      .pipe $ ( phrase, _, end ) =>
        if phrase?
          [ ..., formulas, ] = phrase
          send [ glyph, formula, idx, ] for formula, idx in formulas
        if end?
          send.done()

#-----------------------------------------------------------------------------------------------------------
$add_fncr = ( S ) =>
  return $ ( [ glyph, formula, idx, ], send ) =>
    fncr = XNCHR.as_fncr glyph
    send [ glyph, fncr, formula, idx, ]

#-----------------------------------------------------------------------------------------------------------
$normalize_glyph = ( S ) =>
  return $ ( glyph, send ) =>
    ### TAINT doesn't work with Gaiji NCRs like `&gt#x4cef;` ###
    rsg   = XNCHR.as_rsg glyph
    cid   = XNCHR.as_cid glyph
    csg   = if rsg in [ 'u-pua', 'jzr-fig', ] then 'jzr' else 'u'
    glyph = XNCHR.chr_from_cid_and_csg cid, csg if csg isnt 'u'
    send glyph

#-----------------------------------------------------------------------------------------------------------
$unique = ( S ) =>
  seen_glyphs = new Set()
  return $ ( glyph, send ) =>
    return if seen_glyphs.has glyph
    seen_glyphs.add glyph
    send glyph

#-----------------------------------------------------------------------------------------------------------
$sort = ( S ) =>
  return D.$pass_through() unless S.sort
  return D.$sort ( a, b ) =>
    [ a_glyph, a_fncr, a_formula, a_idx, ] = a
    [ b_glyph, b_fncr, b_formula, b_idx, ] = b
    a_cid = XNCHR.as_cid a_glyph
    b_cid = XNCHR.as_cid b_glyph
    return +1 if a_cid > b_cid
    return -1 if a_cid < b_cid
    return +1 if a_idx > b_idx
    return -1 if a_idx < b_idx
    return  0

#-----------------------------------------------------------------------------------------------------------
$reorder = ( S ) =>
  return $ ( [ glyph, fncr, formula, idx, ], send ) =>
    # glyph = XNCHR.as_chr glyph
    send [ fncr, glyph, formula, ]

#-----------------------------------------------------------------------------------------------------------
$show = ( S ) =>
  return D.$observe ( fields ) =>
    [ fncr, glyph, formula, ] = fields
    #.......................................................................................................
    if S.noidcs then  ics = IDLX.find_all_non_operators formula
    else              ics = XNCHR.chrs_from_text formula
    #.......................................................................................................
    if S.uchrs
      glyph = XNCHR.as_uchr glyph
      ics   = ( ( XNCHR.as_uchr ic ) for ic in ics )
    #.......................................................................................................
    formula = ics.join ''
    formula = '\ue024' if formula.length is 0
    #.......................................................................................................
    if S.colors
      echo ( CND.grey fncr ), ( CND.gold glyph ), ( CND.lime formula )
    else
      echo [ fncr, glyph, formula, ].join '\t'

#-----------------------------------------------------------------------------------------------------------
$transform = ( S ) =>
  return D.combine [
    $normalize_glyph            S
    $unique                     S
    $query                      S
    $add_fncr                   S
    $sort                       S
    $reorder                    S
    $show                       S
    D.$on_end => S.handler null if S.handler?
    ]


