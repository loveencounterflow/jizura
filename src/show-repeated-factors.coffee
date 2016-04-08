
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
LRSL                      = require 'longest-repeating-sublist'

#-----------------------------------------------------------------------------------------------------------
@show_repeated_factors = ( S ) ->
  #.........................................................................................................
  S.query       = { prefix: [ 'spo', ], }
  S.db_route    = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  S.db          = HOLLERITH.new_db S.db_route, create: no
  help "using DB at #{S.db[ '%self' ][ 'location' ]}"
  input         = ( HOLLERITH.create_phrasestream S.db, S.query ).pipe $transform S
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
$filter_inner_glyphs = ( S ) =>
  return $ ( phrase, send ) =>
    [ _, glyph, prd, obj, ] = phrase
    send phrase if XNCHR.is_inner_glyph glyph

#-----------------------------------------------------------------------------------------------------------
$filter_ic0_phrases = ( S ) =>
  predicate = if S.source is 'lineups' then 'guide/lineup/uchr' else 'formula/ic0'
  return $ ( phrase, send ) =>
    [ _, glyph, prd, obj, ] = phrase
    send [ glyph, obj, ] if prd is predicate

#-----------------------------------------------------------------------------------------------------------
$look_for_repetitions = ( S ) =>
  return $ ( phrase, send ) =>
    [ glyph, components, ] = phrase
    components = ( Array.from components.trim() ) if S.source is 'lineups'
    if ( repeated_components = LRSL.find_longest_repeating_sublist components )?
      if S.lineups is 'lineups'
        components = components.join ''
      else
        components = ( ( XNCHR.as_uchr component ) for component in components ).join ''
      glyph = XNCHR.as_uchr glyph
      fncr  = XNCHR.as_fncr glyph
      key   = ( ( XNCHR.as_uchr component ) for component in repeated_components ).join ''
      send [ key, fncr, glyph, components, ]

#-----------------------------------------------------------------------------------------------------------
$aggregate = ( S ) =>
  cache = {}
  return $ ( phrase, send, end ) =>
    if phrase?
      [ key, fncr, glyph, components, ] = phrase
      ( cache[ key ]?= [] ).push [ fncr, glyph, components, ]
    if end?
      for key, entry of cache
        for [ fncr, glyph, components, ], idx in entry
          key = '\u3000' unless idx is 0
          send [ key, fncr, glyph, components, ]
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
    $filter_ic0_phrases         S
    $look_for_repetitions       S
    $aggregate                  S
    $show                       S
    D.$on_end => S.handler null if S.handler?
    ]

