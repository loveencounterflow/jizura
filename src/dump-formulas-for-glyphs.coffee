



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

XNCHR.chrs_from_text "𢐨𢐮𢰅𣹎𤑜𤑨𤑵𤙗𥋡𥽮𦭲𦳪𦽙𧙭𧛴𧩿𨂳𩱆𩱌𩱍𩱎𩱒𩱓𩱖𩱗𩱚𩱜𩱞𩱟𩱠𩱡𩱣𩱤𩱥𩱦𩱧𩱨𩱪𩱫𩱭𩱮𩱯𩱰𩱱𩱲𩱳𩱶𩱷𪾞𫙆𫙇"

#-----------------------------------------------------------------------------------------------------------
@show_repeated_factors = ( S ) ->
  #.........................................................................................................
  S.query             = { prefix: [ 'spo', ], }
  S.db_route          = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  S.db                = HOLLERITH.new_db S.db_route, create: no
  S.prd_for_lineups   = 'guide/lineup/uchr'
  S.prd_for_formulas  = 'formula/ic0'
  help "using DB at #{S.db[ '%self' ][ 'location' ]}"
  input               = ( HOLLERITH.create_phrasestream S.db, S.query ).pipe $transform S
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
$filter_inner_glyphs = ( S ) =>
  return $ ( phrase, send ) =>
    [ _, glyph, prd, obj, ] = phrase
    send phrase if XNCHR.is_inner_glyph glyph

#-----------------------------------------------------------------------------------------------------------
$filter_relevant_phrases = ( S ) =>
  prds = []
  prds.push S.prd_for_lineups  if S.lineups
  prds.push S.prd_for_formulas if S.formulas
  return $ ( phrase, send ) =>
    [ _, glyph, prd, obj, ] = phrase
    send [ glyph, prd, obj, ] if prd in prds

#-----------------------------------------------------------------------------------------------------------
$show_progress = ( S ) =>
  count = 0
  return $ ( phrase, send ) =>
    send phrase
    info count if ( count += +1 ) % 1000 is 0

#-----------------------------------------------------------------------------------------------------------
$look_for_repetitions = ( S ) =>
  return $ ( phrase, send ) =>
    [ glyph, prd, components, ] = phrase
    #.......................................................................................................
    switch prd
      when S.prd_for_lineups  then components = Array.from components.trim()
      when S.prd_for_formulas then null
      else throw new Error "unknown predicate #{rpr prd}"
    #.......................................................................................................
    if ( repeated_components = LRSL.find_longest_repeating_sublist components )?
      #.....................................................................................................
      switch prd
        when S.prd_for_lineups
          sigil      = 'ℓ'
        when S.prd_for_formulas
          sigil      = 'f'
          components = ( XNCHR.as_uchr component for component in components )
        else throw new Error "unknown predicate #{rpr prd}"
      #.....................................................................................................
      components  = components.join ''
      glyph       = XNCHR.as_uchr glyph
      fncr        = XNCHR.as_fncr glyph
      key         = ( ( XNCHR.as_uchr component ) for component in repeated_components ).join ''
      send [ key, fncr, glyph, sigil, components, ]

#-----------------------------------------------------------------------------------------------------------
$aggregate = ( S ) =>
  cache = {}
  return $ ( phrase, send, end ) =>
    #.......................................................................................................
    if phrase?
      [ key, fncr, glyph, sigil, components, ] = phrase
      entry     = [ fncr, glyph, components, ].join '\t'
      target_0  = cache[ key ]?= {}
      target_1  = target_0[ entry ]?= []
      target_1.push sigil unless sigil in target_1
      debug '©77388', glyph, entry if glyph in '㢸㢽㣃䰜䰞弻弼粥鬻𢏺𢐁𢐆㵉'
      # if glyph is '桓'
      #   # debug '0921', cache
      #   # process.exit()
      #   end = send.end
    #.......................................................................................................
    if end?
      for key, entries of cache
        idx = -1
        for entry, sigils of entries
          idx += +1
          key = '\u3000' unless idx is 0
          line = "#{entry} #{sigils.join ''}"
          send [ key, line, ]
      process.exit()
      end()

#-----------------------------------------------------------------------------------------------------------
$show = ( S ) =>
  return D.$observe ( phrase ) =>
    echo phrase.join '\t'
    # [ key, fncr, glyph, components, ] = phrase
    # echo "#{key}\t#{glyph}\t#{components}"


#-----------------------------------------------------------------------------------------------------------
$transform = ( S ) =>
  return D.combine [
    $filter_inner_glyphs        S
    $filter_relevant_phrases    S
    $show_progress              S
    $look_for_repetitions       S
    $aggregate                  S
    $show                       S
    D.$on_end => S.handler null if S.handler?
    ]


