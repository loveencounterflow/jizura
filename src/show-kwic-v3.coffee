


############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/show-kwic-v3'
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
CHR                       = require 'coffeenode-chr'
KWIC                      = require 'kwic'
#...........................................................................................................
new_db                    = require 'level'
# new_levelgraph            = require 'levelgraph'
# db                        = new_levelgraph '/tmp/levelgraph'
HOLLERITH                 = require 'hollerith'
ƒ                         = CND.format_number.bind CND
#...........................................................................................................
options                   = null
#-----------------------------------------------------------------------------------------------------------
@_misfit          = Symbol 'misfit'

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@initialize = ( handler ) ->
  options[ 'db' ] = HOLLERITH.new_db options[ 'route' ]
  handler null


#-----------------------------------------------------------------------------------------------------------
HOLLERITH.$pick_subject = ->
  return $ ( lkey, send ) =>
    [ pt, _, v0, _, v1, ] = lkey
    send if pt is 'so' then v0 else v1

#-----------------------------------------------------------------------------------------------------------
HOLLERITH.$pick_object = ->
  return $ ( lkey, send ) =>
    [ pt, _, v0, _, v1, ] = lkey
    send if pt is 'so' then v1 else v0

#-----------------------------------------------------------------------------------------------------------
HOLLERITH.$pick_values = ->
  return $ ( lkey, send ) =>
    [ pt, _, v0, _, v1, ] = lkey
    send if pt is 'so' then [ v0, v1, ] else [ v1, v0, ]

#-----------------------------------------------------------------------------------------------------------
@dump_jizura_db = ->
  source_db   = HOLLERITH.new_db '/Volumes/Storage/temp/jizura-hollerith2'
  prefix      = [ 'spo', '𡏠', ]
  prefix      = [ 'spo', '㔰', ]
  input       = HOLLERITH.create_phrasestream source_db, prefix
  #.........................................................................................................
  input
    .pipe D.$count ( count ) -> help "read #{count} keys"
    .pipe $ ( data, send ) => send JSON.stringify data
    .pipe D.$show()

#-----------------------------------------------------------------------------------------------------------
@read_factors = ( db, handler ) ->
  #.........................................................................................................
  step ( resume ) =>
    Z         = {}
    db_route  = join __dirname, '../../jizura-datasources/data/leveldb-v2'
    db       ?= HOLLERITH.new_db db_route, create: no
    #.......................................................................................................
    prefix  = [ 'pos', 'factor/', ]
    query   = { prefix, star: '*', }
    input   = HOLLERITH.create_phrasestream db, query
    #.......................................................................................................
    input
      .pipe do =>
        last_sbj  = null
        target    = null
        #...................................................................................................
        return $ ( phrase, send, end ) =>
          #.................................................................................................
          if phrase?
            [ _, prd, obj, sbj, ] = phrase
            prd           = prd.replace /^factor\//g, ''
            sbj           = CHR.as_uchr sbj, input: 'xncr'
            if sbj isnt last_sbj
              send target if target?
              target    = Z[ sbj ]?= { glyph: sbj, }
              last_sbj  = sbj
            target[ prd ] = obj
            Z[ obj ]      = target if prd is 'sortcode'
          #.................................................................................................
          if end?
            send target if target?
            end()
      .pipe D.$on_end -> handler null, Z

#-----------------------------------------------------------------------------------------------------------
@read_sample = ( db, limit_or_list, handler ) ->
  ### Return a gamut of select glyphs from the DB. `limit_or_list` may be a list of glyphs or a number
  representing an upper bound to the usage rank recorded as `rank/cjt`. If `limit_or_list` is a list,
  a POD whose keys are the glyphs in the list is returned; if it is a number, a similar POD with all the
  glyphs whose rank is not worse than the given limit is returned. If `limit_or_list` is smaller than zero
  or equals infinity, `null` is returned to indicate absence of a filter. ###
  Z         = {}
  #.......................................................................................................
  if CND.isa_list limit_or_list
    Z[ glyph ] = 1 for glyph in limit_or_list
    return handler null, Z
  #.......................................................................................................
  return handler null, null if limit_or_list < 0 or limit_or_list is Infinity
  #.......................................................................................................
  throw new Error "expected list or number, got a #{type}" unless CND.isa_number limit_or_list
  #.......................................................................................................
  db_route  = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  db       ?= HOLLERITH.new_db db_route, create: no
  #.......................................................................................................
  lo      = [ 'pos', 'rank/cjt', 0, ]
  hi      = [ 'pos', 'rank/cjt', limit_or_list, ]
  query   = { lo, hi, }
  input   = HOLLERITH.create_phrasestream db, query
  #.......................................................................................................
  input
    .pipe $ ( phrase, send ) =>
        [ _, _, _, glyph, ] = phrase
        Z[ glyph ]          = 1
    .pipe D.$on_end -> handler null, Z

#-----------------------------------------------------------------------------------------------------------
@show_kwic_v3 = ( db ) ->
  #.........................................................................................................
  step ( resume ) =>
    db_route      = join __dirname, '../../jizura-datasources/data/leveldb-v2'
    db           ?= HOLLERITH.new_db db_route, create: no
    help "using DB at #{db[ '%self' ][ 'location' ]}"
    factor_infos  = yield @read_factors db, resume
    # debug '©g5bVR', factors; process.exit()
    help "read #{( Object.keys factor_infos ).length} entries for factor_infos"
    ranks         = {}
    include       = Infinity
    include       = 10000
    include       = 15000
    include       = 10
    # include       = [ '寿', '邦', '帮', '畴', '铸', '筹', '涛', '祷', '绑', '綁',    ]
    # include       = Array.from '未釐犛剺味昧眛魅鮇沬妹業寐鄴澲末抹茉枺沫袜妺'
    # 'guide/hierarchy/uchr'
    #.........................................................................................................
    ### TAINT use sets ###
    glyph_sample  = null
    # glyph_sample  = yield @read_sample db, include, resume
    factor_sample = null
    factor_sample = 日: 1
    #.........................................................................................................
    $reorder_phrase = =>
      return $ ( phrase, send ) =>
        ### extract sortcode ###
        [ _, _, sortcode, glyph, _, ] = phrase
        send [ glyph, sortcode, ]
    #.........................................................................................................
    $exclude_gaiji = =>
      return D.$filter ( [ glyph, sortcode ] ) =>
        return ( not glyph.startsWith '&' ) or ( glyph.startsWith '&jzr#' )
    #.........................................................................................................
    $include_sample = =>
      return D.$filter ( [ glyph, sortcode ] ) =>
        # [ _, infix, suffix, prefix, ] = sortcode
        # factors = [ prefix..., infix, suffix...,]
        # return ( infix is '山' ) and ( '水' in factors )
        return true if ( not glyph_sample? ) and ( not factor_sample? )
        if glyph_sample? then return true if ( glyph of glyph_sample )
        [ _, infix, suffix, prefix, ] = sortcode
        if factor_sample then return true if ( infix of factor_sample )
        return false
    #.........................................................................................................
    $format_sortcode_v3 = =>
      return $ ( [ glyph, sortcode, ], send ) =>
        [ _, infix, suffix, prefix, ] = sortcode
        prefix.unshift '\u3000' until prefix.length >= 6
        suffix.push    '\u3000' until suffix.length >= 6
        prefix                        = prefix.join ''
        suffix                        = suffix.join ''
        lineup                        = prefix + '|' + infix + suffix
        send [ glyph, lineup, ]
    #.........................................................................................................
    $transform_v3 = => D.combine [
        $reorder_phrase()
        $exclude_gaiji()
        $include_sample()
        # D.$show()
        $format_sortcode_v3()
        ]
    #.........................................................................................................
    $show = =>
      return D.$observe ( [ glyph, lineup, ]) ->
        echo lineup + glyph
    #.........................................................................................................
    query_v3  = { prefix: [ 'pos', 'guide/kwic/v3/sortcode', ], }
    input_v3  = ( HOLLERITH.create_phrasestream db, query_v3 ).pipe $transform_v3()
      # .pipe D.$observe ( [ glyph, lineup, ] ) -> help glyph, lineup if glyph is '畴'
    #.........................................................................................................
    input_v3
      .pipe $show()
    #.........................................................................................................
    return null


############################################################################################################
unless module.parent?

  #---------------------------------------------------------------------------------------------------------
  options =
    #.......................................................................................................
    # 'route':                njs_path.join __dirname, '../dbs/demo'
    'route':                njs_path.resolve __dirname, '../../jizura-datasources/data/leveldb-v2'
    # 'route':            '/tmp/leveldb'
  #---------------------------------------------------------------------------------------------------------
  debug '©AoOAS', options
  # @find_good_kwic_sample_glyphs_3()
  @show_kwic_v3()
  # @show_codepoints_with_missing_predicates()
  # @show_encoding_sample()
  # @compile_encodings()


