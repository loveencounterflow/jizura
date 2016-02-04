


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
TEXT                      = require 'coffeenode-text'
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
    ### !!!!!!!!!!!!!!!!!!!!!!! ###
    # factor_infos  = yield @read_factors db, resume
    # # debug '©g5bVR', factors; process.exit()
    # help "read #{( Object.keys factor_infos ).length} entries for factor_infos"
    ### !!!!!!!!!!!!!!!!!!!!!!! ###
    ranks               = {}
    include             = 15000
    include             = 10000
    include             = 20000
    include             = 5000
    include             = Infinity
    lineup_left_count   = 3
    lineup_right_count  = 3
    # include           = [ '𡳵', '𣐤', '𦾔', '𥈺', '𨂻', '寿', '邦', '帮', '畴', '铸', ]
    # include       = [ '寿', '邦', '帮', '畴', '铸', '筹', '涛', '祷', '绑', '綁',    ]
    # include       = Array.from '未釐犛剺味昧眛魅鮇沬妹業寐鄴澲末抹茉枺沫袜妺'
    # 'guide/hierarchy/uchr'
    glyph_sample      = null
    factor_sample     = null
    #.........................................................................................................
    ### TAINT use sets ###
    glyph_sample  = yield @read_sample db, include, resume
    # factor_sample =
    #   '旧': 1
    #   '日': 1
    #   '卓': 1
    #   '桌': 1
    #   '𠦝': 1
    #   '東': 1
    #   '車': 1
    #   '更': 1
    #   '㯥': 1
    #   '䡛': 1
    #   '轟': 1
    #   '𨏿': 1
    #   '昍': 1
    #   '昌': 1
    #   '晶': 1
    #   '𣊭': 1
    #   '早': 1
    #   '': 1
    #   '畢': 1
    #   '': 1
    #   '果': 1
    #   '𣛕': 1
    #   '𣡗': 1
    #   '𣡾': 1
    #   # '曱': 1
    #   '甲': 1
    #   '𤳅': 1
    #   '𤳵': 1
    #   '申': 1
    #   '𤱓': 1
    #   '禺': 1
    #   '𥝉': 1
    #   '': 1
    #   '㬰': 1
    #   '': 1
    #   '电': 1
    #   '': 1
    #   '田': 1
    #   '畕': 1
    #   '畾': 1
    #   '𤳳': 1
    #   '由': 1
    #   '甴': 1
    #   '𡆪': 1
    #   '白': 1
    #   '㿟': 1
    #   '皛': 1
    #   '': 1
    #   '鱼': 1
    #   '魚': 1
    #   '䲆': 1
    #   '𩺰': 1
    #   '鱻': 1
    #   '䲜': 1
    # factor_sample =
    #   '旧': 1
    #   '日': 1
    #   '卓': 1
    #   '桌': 1
    #   '𠦝': 1
    #   '昍': 1
    #   '昌': 1
    #   '晶': 1
    #   '𣊭': 1
    #   '早': 1
    #   '白': 1
    #   '㿟': 1
    #   '皛': 1
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
        [ _, infix, suffix, prefix, ] = sortcode
        in_glyph_sample   = ( not  glyph_sample? ) or ( glyph of  glyph_sample )
        in_factor_sample  = ( not factor_sample? ) or ( infix of factor_sample )
        return in_glyph_sample and in_factor_sample
    #.........................................................................................................
    $insert_hr = =>
      in_keeplines  = no
      last_infix    = null
      return $ ( event, send, end ) =>
        if event?
          [ glyph, sortcode, ]          = event
          [ _, infix, suffix, prefix, ] = sortcode
          if last_infix? and infix isnt last_infix
            send "<<keep-lines)>>" if in_keeplines
            send "*******************************************"
            in_keeplines = no
          last_infix = infix
          send "<<(keep-lines>>" unless in_keeplines
          in_keeplines = yes
          send event
        if end?
          send "<<keep-lines)>>" if in_keeplines
          end()
    #.........................................................................................................
    $count_lineup_lengths = =>
      counts  = []
      count   = 0
      #.......................................................................................................
      return $ ( event, send, end ) =>
        if event?
          #...................................................................................................
          if CND.isa_list event
            [ glyph, sortcode, ]          = event
            [ _, infix, suffix, prefix, ] = sortcode
            lineup                        = ( prefix.join '' ) + infix + ( suffix.join '' )
            lineup_length                 = ( Array.from lineup.replace /\u3000/g, '' ).length
            counts[ lineup_length ]       = ( counts[ lineup_length ] ? 0 ) + 1
            ### !!!!!!!!!!!!!!!!!!!!!!! ###
            send event
            # # send event if glyph is '辭'
            # if 3 < lineup_length < 8
            #   count += +1
            #   send event if count < 100
            send event if lineup_length > 6
            ### !!!!!!!!!!!!!!!!!!!!!!! ###
          #...................................................................................................
          else
            send event
        #.....................................................................................................
        if end?
          for length in [ 1 ... counts.length ]
            count_txt = TEXT.flush_right ( ƒ counts[ length ] ), 10
            help "found #{count_txt} lineups of length #{length}"
          end()
    #.........................................................................................................
    $align_affixes = =>
      return $ ( event, send ) =>
        #.....................................................................................................
        if CND.isa_list event
          [ glyph, sortcode, ]          = event
          [ _, infix, suffix, prefix, ] = sortcode
          pre_prefix                    = []
          post_suffix                   = []
          pre_prefix.unshift  suffix.pop()   while suffix.length > lineup_right_count
          post_suffix.push    prefix.shift() while prefix.length >  lineup_left_count
          prefix.unshift '\u3000' until prefix.length >=  lineup_left_count -  pre_prefix.length
          suffix.push    '\u3000' until suffix.length >= lineup_right_count - post_suffix.length
          # log ( pre_prefix.join '' ), ( prefix.join ''), '|', infix, '|', ( suffix.join '' ), ( post_suffix.join '' ) + glyph
          send [ glyph, [ pre_prefix, prefix, infix, suffix, post_suffix, ], ]
        #.....................................................................................................
        else
          send event
    #.........................................................................................................
    $transform_v3 = => D.combine [
        $reorder_phrase()
        $exclude_gaiji()
        $include_sample()
        # D.$show()
        $insert_hr()
        $count_lineup_lengths()
        $align_affixes()
        ]
    #.........................................................................................................
    $show = =>
      return D.$observe ( event ) ->
        if CND.isa_list event
          [ glyph, lineup, ]  = event
          [ pre_prefix
            prefix
            infix
            suffix
            post_suffix ]     = lineup
          prefix                        = ( pre_prefix.join '' ) + (      prefix.join '' )
          suffix                        = (     suffix.join '' ) + ( post_suffix.join '' )
          lineup                        = prefix + '|' + infix + '|' + suffix
          echo lineup + glyph # + '<<<\\\\>>>'
        else
          echo event
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


