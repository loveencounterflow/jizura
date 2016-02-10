


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
    include             = 500
    include             = Infinity
    prefix_max_length   = 3
    suffix_max_length   = 3
    window_width        = prefix_max_length + 1 + suffix_max_length + 1
    # include           = [ '𡳵', '𣐤', '𦾔', '𥈺', '𨂻', '寿', '邦', '帮', '畴', '铸', ]
    # include       = [ '寿', '邦', '帮', '畴', '铸', '筹', '涛', '祷', '绑', '綁',    ]
    # include       = Array.from '未釐犛剺味昧眛魅鮇沬妹業寐鄴澲末抹茉枺沫袜妺'
    include             = Array.from '虫𨙻𥦤曗𩡏鬱𡤇𥜹'
    glyph_sample        = null
    factor_sample       = null
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
            ### !!!!!!!!!!!!!!!!!!!!!!! ###
            # send event
            # # send event if glyph is '辭'
            # if 3 < lineup_length < 8
            #   count += +1
            #   send event if count < 100
            ### !!!!!!!!!!!!!!!!!!!!!!! ###
            if true # lineup_length is 8
              send event
              counts[ lineup_length ] = ( counts[ lineup_length ] ? 0 ) + 1
          #...................................................................................................
          else
            send event
        #.....................................................................................................
        if end?
          for length in [ 1 ... counts.length ]
            count_txt = TEXT.flush_right ( ƒ counts[ length ] ? 0 ), 10
            help "found #{count_txt} lineups of length #{length}"
          end()
    #.........................................................................................................
    $_XXX_sort = =>
      buffer  = []
      #.......................................................................................................
      return $ ( event, send, end ) =>
        throw new Error "sort not possible with intermittent text events" if event? and not CND.isa_list event
        buffer.push event
        #.....................................................................................................
        if end?
          buffer.sort ( event_a, event_b ) ->
            [ glyph_a, sortcode_a, ]            = event_a
            [ glyph_b, sortcode_b, ]            = event_b
            [ _, infix_a, suffix_a, prefix_a, ] = sortcode_a
            [ _, infix_b, suffix_b, prefix_b, ] = sortcode_b
            return +1 if prefix_a.length + suffix_a.length > prefix_b.length + suffix_b.length
            return -1 if prefix_a.length + suffix_a.length < prefix_b.length + suffix_b.length
            return +1 if glyph_a > glyph_b
            return -1 if glyph_a < glyph_b
            return +1 if suffix_a.length > suffix_b.length
            return -1 if suffix_a.length < suffix_b.length
            return  0
          send event for event in buffer
          end()
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
    $insert_many_keeplines = =>
      in_keeplines  = no
      last_glyph    = null
      return $ ( event, send, end ) =>
        if event?
          if CND.isa_list event
            [ glyph, sortcode, ] = event
            if last_glyph? and glyph isnt last_glyph
              send "<<keep-lines)>>" if in_keeplines
              send ''
              # send "*******************************************"
              in_keeplines = no
            last_glyph = glyph
            send "<<(keep-lines>>" unless in_keeplines
            in_keeplines = yes
            send event
          else
            send event
        if end?
          send "<<keep-lines)>>" if in_keeplines
          end()
    #.........................................................................................................
    $insert_single_keepline = =>
      is_first      = yes
      last_glyph    = null
      return $ ( event, send, end ) =>
        if event?
          if is_first
            send "<<(keep-lines>>"
            is_first = no
          if CND.isa_list event
            [ glyph, sortcode, ] = event
            if last_glyph? and glyph isnt last_glyph
              send ''
              # send "*******************************************"
            last_glyph = glyph
            send event
          else
            send event
        if end?
          send "<<keep-lines)>>"
          end()
    #.........................................................................................................
    $align_affixes = =>
      return $ ( event, send ) =>
        #.....................................................................................................
        if CND.isa_list event
          [ glyph, sortcode, ]          = event
          [ _, infix, suffix, prefix, ] = sortcode
          #...................................................................................................
          prefix_length                 = prefix.length
          suffix_length                 = suffix.length
          prefix_delta                  = prefix_length - prefix_max_length
          suffix_delta                  = suffix_length - suffix_max_length
          prefix_excess_max_length      = suffix_max_length - suffix_length
          suffix_excess_max_length      = prefix_max_length - prefix_length
          prefix_excess                 = []
          suffix_excess                 = []
          prefix_padding                = []
          suffix_padding                = []
          prefix_is_shortened           = no
          suffix_is_shortened           = no
          #...................................................................................................
          if prefix_delta > 0
            prefix_excess = prefix.splice 0, prefix_delta
          if suffix_delta > 0
            suffix_excess = suffix.splice suffix.length - suffix_delta, suffix_delta
          #...................................................................................................
          while prefix_excess.length > 0 and prefix_excess.length > prefix_excess_max_length
            prefix_is_shortened = yes
            prefix_excess.pop()
          while suffix_excess.length > 0 and suffix_excess.length > suffix_excess_max_length
            suffix_is_shortened = yes
            suffix_excess.shift()
          #...................................................................................................
          while prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length
            prefix_padding.unshift '\u3000'
          #...................................................................................................
          while suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length
            suffix_padding.unshift '\u3000'
          #...................................................................................................
          if prefix_excess.length > 0 then prefix_excess.unshift '「' unless prefix_is_shortened
          else                                    prefix.unshift '「'
          if suffix_excess.length > 0 then suffix_excess.push    '」' unless suffix_is_shortened
          else                                    suffix.push    '」'
          #...................................................................................................
          prefix.splice 0, 0, prefix_padding...
          prefix.splice 0, 0, suffix_excess...
          suffix.splice suffix.length, 0, suffix_padding...
          suffix.splice suffix.length, 0, prefix_excess...
          #...................................................................................................
          urge ( prefix.join '' ) + '【' + infix + '】' + ( suffix.join '' )
          # send [ glyph, [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ], ]
          send [ glyph, [ prefix, infix, suffix, ], ]
        #.....................................................................................................
        else
          send event
    #.........................................................................................................
    $show = =>
      last_glyph = null
      return D.$observe ( event ) ->
        if CND.isa_list event
          [ glyph, sortcode, ]          = event
          [ _, prefix, infix, suffix, ] = sortcode
          prefix = prefix.join ''
          suffix = suffix.join ''
          lineup = prefix + '〔' + infix + '〕' + suffix
          # lineup = prefix + '|' + infix + '|' + suffix
          unless glyph is last_glyph
            echo ''
            last_glyph = glyph
          echo lineup + glyph # + '<<<\\\\>>>'
        else
          echo event
    # #.........................................................................................................
    # $align_affixes = =>
    #   return $ ( event, send ) =>
    #     #.....................................................................................................
    #     if CND.isa_list event
    #       [ glyph, sortcode, ]          = event
    #       [ _, infix, suffix, prefix, ] = sortcode
    #       overall_length                =  prefix.length + 1 + suffix.length
    #       if overall_length < window_width
    #         prefix.unshift '\u3007' until prefix.length >=  lineup_left_count
    #         suffix.push    '\u3007' until suffix.length >= lineup_right_count
    #       prefix_copy = Object.assign [], prefix
    #       suffix_copy = Object.assign [], suffix
    #       prefix.unshift '」'
    #       prefix.splice 0, 0, suffix_copy...
    #       suffix.push '「'
    #       suffix.splice suffix.length, 0, prefix_copy...
    #       send [ glyph, [ sortcode, infix, suffix, prefix, ], ]
    #     #.....................................................................................................
    #     else
    #       send event
    #.........................................................................................................
    $count_glyphs_etc = =>
      glyphs        = new Set()
      lineup_count  = 0
      #.......................................................................................................
      return D.$observe ( event, has_ended ) =>
        if event?
          #...................................................................................................
          if CND.isa_list event
            [ glyph, _, ] = event
            glyphs.add glyph
            lineup_count += +1
        #.....................................................................................................
        if has_ended
          help "built KWIC for #{ƒ glyphs.size} glyphs"
          help "containing #{ƒ lineup_count} lineups"
    #.........................................................................................................
    $show = =>
      last_glyph = null
      return D.$observe ( event ) ->
        if CND.isa_list event
          [ glyph, lineup, ]          = event
          [ prefix, infix, suffix, ]  = lineup
          # [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ]  = lineup
          # prefix_padding = prefix_padding.join ''
          # suffix_excess = suffix_excess.join ''
          prefix        = prefix.join ''
          suffix        = suffix.join ''
          lineup        = prefix + '【' + infix + '】' + suffix
          unless glyph is last_glyph
            # echo ''
            last_glyph = glyph
          echo lineup + '\u3000' + glyph
        else
          echo event
    #.........................................................................................................
    $transform_v3 = => D.combine [
        $reorder_phrase()
        $exclude_gaiji()
        $include_sample()
        # D.$show()
        $count_lineup_lengths()
        $_XXX_sort()
        # $insert_hr()
        # $insert_many_keeplines()
        $insert_single_keepline()
        $align_affixes()
        $count_glyphs_etc()
        $show()
        ]
    #.........................................................................................................
    query_v3  = { prefix: [ 'pos', 'guide/kwic/v3/sortcode', ], }
    input_v3  = ( HOLLERITH.create_phrasestream db, query_v3 ).pipe $transform_v3()
      # .pipe D.$observe ( [ glyph, lineup, ] ) -> help glyph, lineup if glyph is '畴'
    #.........................................................................................................
    # input_v3
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
  # debug '©AoOAS', options
  # @find_good_kwic_sample_glyphs_3()
  @show_kwic_v3()
  # @show_codepoints_with_missing_predicates()
  # @show_encoding_sample()
  # @compile_encodings()


