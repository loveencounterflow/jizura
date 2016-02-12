



###


`@$align_affixes_with_braces`

<<(keep-lines>>
　　　「【虫】」　　　　虫

　　「冄【阝】」　　　　𨙻
　　　「【冄】阝」　　　𨙻

　「穴扌【未】」　　　　𥦤
　　「穴【扌】未」　　　𥦤
　　　「【穴】扌未」　　𥦤

「日业䒑【未】」　　　　曗
　「日业【䒑】未」　　　曗
　　「日【业】䒑未」　　曗
　　　「【日】业䒑未」　曗

日𠂇⺝【阝】」　　「禾　𩡏
「禾日𠂇【⺝】阝」　　　𩡏
　「禾日【𠂇】⺝阝」　　𩡏
　　「禾【日】𠂇⺝阝」　𩡏
阝」　　「【禾】日𠂇⺝　𩡏

木冖鬯【彡】」　「木缶　鬱
缶木冖【鬯】彡」　「木　鬱
「木缶木【冖】鬯彡」　　鬱
　「木缶【木】冖鬯彡」　鬱
彡」　「木【缶】木冖鬯　鬱
鬯彡」　「【木】缶木冖　鬱

山一几【夊】」「女山彳　𡤇
彳山一【几】夊」「女山　𡤇
山彳山【一】几夊」「女　𡤇
「女山彳【山】一几夊」　𡤇
夊」「女山【彳】山一几　𡤇
几夊」「女【山】彳山一　𡤇
一几夊」「【女】山彳山　𡤇

目𠃊八【夊】」「二小　𥜹
匕目𠃊【八】夊」「二　𥜹
小匕目【𠃊】八夊」「　𥜹
二小匕【目】𠃊八夊」　𥜹
「二小【匕】目𠃊八　𥜹
夊」「二【小】匕目𠃊　𥜹
八夊」「【二】小匕目　𥜹
𠃊八夊」「【】二小匕　𥜹
<<keep-lines)>>


`align_affixes_with_spaces`

<<(keep-lines>>
　　　【虫】　　　　虫

　　冄【阝】　　　　𨙻
　　　【冄】阝　　　𨙻

　穴扌【未】　　　　𥦤
　　穴【扌】未　　　𥦤
　　　【穴】扌未　　𥦤

日业䒑【未】　　　　曗
　日业【䒑】未　　　曗
　　日【业】䒑未　　曗
　　　【日】业䒑未　曗

日𠂇⺝【阝】　　禾　𩡏
禾日𠂇【⺝】阝　　　𩡏
　禾日【𠂇】⺝阝　　𩡏
　　禾【日】𠂇⺝阝　𩡏
阝　　【禾】日𠂇⺝　𩡏

木冖鬯【彡】　木缶　鬱
缶木冖【鬯】彡　木　鬱
木缶木【冖】鬯彡　　鬱
　木缶【木】冖鬯彡　鬱
彡　木【缶】木冖鬯　鬱
鬯彡　【木】缶木冖　鬱

山一几【夊】　女山　𡤇
彳山一【几】夊　女　𡤇
山彳山【一】几夊　　𡤇
女山彳【山】一几夊　𡤇
　女山【彳】山一几　𡤇
夊　女【山】彳山一　𡤇
几夊　【女】山彳山　𡤇

目𠃊八【夊】　二　𥜹
匕目𠃊【八】夊　　𥜹
小匕目【𠃊】八夊　　𥜹
二小匕【目】𠃊八夊　𥜹
二小【匕】目𠃊八　𥜹
　二【小】匕目𠃊　𥜹
夊　【二】小匕目　𥜹
八夊　【】二小匕　𥜹
<<keep-lines)>>



###











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
    ranks               = {}
    include             = 20000
    include             = 15000
    include             = 500
    include             = 10000
    include             = Infinity
    # include           = [ '𡳵', '𣐤', '𦾔', '𥈺', '𨂻', '寿', '邦', '帮', '畴', '铸', ]
    # include       = [ '寿', '邦', '帮', '畴', '铸', '筹', '涛', '祷', '绑', '綁',    ]
    # include       = Array.from '未釐犛剺味昧眛魅鮇沬妹業寐鄴澲末抹茉枺沫袜妺'
    # include             = Array.from '虫𨙻𥦤曗𩡏鬱𡤇𥜹'
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
    factor_sample =
      '旧': 1
      '日': 1
      '卓': 1
      '桌': 1
      '𠦝': 1
      '昍': 1
      '昌': 1
      '晶': 1
      '𣊭': 1
      '早': 1
      '白': 1
      '㿟': 1
      '皛': 1
    factor_sample =
      '耂': 1
    #.........................................................................................................
    $reorder_phrase = =>
      return $ ( phrase, send ) =>
        ### extract sortcode ###
        [ _, _, sortrow, glyph, _, ]  = phrase
        [ _, infix, suffix, prefix, ] = sortrow
        send [ glyph, prefix, infix, suffix, ]
    #.........................................................................................................
    $exclude_gaiji = =>
      return D.$filter ( event ) =>
        [ glyph, ] = event
        return ( not glyph.startsWith '&' ) or ( glyph.startsWith '&jzr#' )
    #.........................................................................................................
    $include_sample = =>
      return D.$filter ( event ) =>
        # [ _, infix, suffix, prefix, ] = sortcode
        # factors = [ prefix..., infix, suffix...,]
        # return ( infix is '山' ) and ( '水' in factors )
        return true if ( not glyph_sample? ) and ( not factor_sample? )
        [ glyph, prefix, infix, suffix, ] = event
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
    # #.........................................................................................................
    # $_XXX_sort = =>
    #   buffer  = []
    #   #.......................................................................................................
    #   return $ ( event, send, end ) =>
    #     throw new Error "sort not possible with intermittent text events" if event? and not CND.isa_list event
    #     buffer.push event
    #     #.....................................................................................................
    #     if end?
    #       buffer.sort ( event_a, event_b ) ->
    #         [ glyph_a, sortcode_a, ]            = event_a
    #         [ glyph_b, sortcode_b, ]            = event_b
    #         [ _, infix_a, suffix_a, prefix_a, ] = sortcode_a
    #         [ _, infix_b, suffix_b, prefix_b, ] = sortcode_b
    #         return +1 if prefix_a.length + suffix_a.length > prefix_b.length + suffix_b.length
    #         return -1 if prefix_a.length + suffix_a.length < prefix_b.length + suffix_b.length
    #         return +1 if glyph_a > glyph_b
    #         return -1 if glyph_a < glyph_b
    #         return +1 if suffix_a.length > suffix_b.length
    #         return -1 if suffix_a.length < suffix_b.length
    #         return  0
    #       send event for event in buffer
    #       end()
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
    $insert_single_keeplines = =>
      is_first      = yes
      last_infix    = null
      return $ ( event, send, end ) =>
        if event?
          if is_first
            send "<<(keep-lines>>"
            is_first = no
          if CND.isa_list event
            [ glyph, prefix, infix, suffix, ] = event
            if last_infix? and infix isnt last_infix
              send ''
            last_infix = infix
            send event
          else
            send event
        if end?
          send "<<keep-lines)>>"
          end()
    #.........................................................................................................
    $count_glyphs_etc = =>
      glyphs        = new Set()
      factor_pairs  = {}
      lineup_count  = 0
      #.......................................................................................................
      return D.$observe ( event, has_ended ) =>
        if event?
          #...................................................................................................
          if CND.isa_list event
            [ glyph, prefix, infix, suffix, ] = event
            prefix = prefix.trim()
            suffix = suffix.trim()
            if prefix.length > 0
              prefix                = Array.from prefix
              key                   = prefix[ prefix.length - 1 ] + infix + '\u3000'
              factor_pairs[ key ]   = ( factor_pairs[ key ] ? 0 ) + 1
            if suffix.length > 0
              suffix                = Array.from suffix
              key                   = '\u3000' + infix + suffix[ 0 ]
              factor_pairs[ key ]   = ( factor_pairs[ key ] ? 0 ) + 1
            glyphs.add glyph
            lineup_count += +1
        #.....................................................................................................
        if has_ended
          help "built KWIC for #{ƒ glyphs.size} glyphs"
          help "containing #{ƒ lineup_count} lineups"
          factor_pairs = ( [ factor_pair, count, ] for factor_pair, count of factor_pairs )
          factor_pairs.sort ( a, b ) ->
            return +1 if a[ 1 ] < b[ 1 ]
            return -1 if a[ 1 ] > b[ 1 ]
            return +1 if a[ 0 ] > b[ 0 ]
            return -1 if a[ 0 ] < b[ 0 ]
            return  0
          for [ factor_pair, count, ] in factor_pairs
            urge factor_pair, count
    #.........................................................................................................
    $show = =>
      return D.$observe ( event ) ->
        if CND.isa_list event
          [ glyph, prefix, infix, suffix, ] = event
          lineup                            = prefix + '【' + infix + '】' + suffix
          echo lineup + '|' + glyph
        else
          echo event
    #.........................................................................................................
    $transform_v3 = => D.combine [
        $reorder_phrase()
        $exclude_gaiji()
        $include_sample()
        # D.$show()
        # $count_lineup_lengths()
        # $_XXX_sort()
        # # $insert_hr()
        # # $insert_many_keeplines()
        $insert_single_keeplines()
        # # @$align_affixes_with_braces()
        # @$align_affixes_with_spaces()
        $count_glyphs_etc()
        $show()
        ]
    #.........................................................................................................
    query_v3  = { prefix: [ 'pos', 'guide/kwic/v3/sortcode/wrapped-lineups', ], }
    input_v3  = ( HOLLERITH.create_phrasestream db, query_v3 ).pipe $transform_v3()
      # .pipe D.$observe ( [ glyph, lineup, ] ) -> help glyph, lineup if glyph is '畴'
    #.........................................................................................................
    # input_v3
    #.........................................................................................................
    return null


#-----------------------------------------------------------------------------------------------------------
@$align_affixes_with_braces = =>
  prefix_max_length   = 3
  suffix_max_length   = 3
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if CND.isa_list event
      [ glyph, sortcode, ]          = event
      [ _, infix, suffix, prefix, ] = sortcode
      #.....................................................................................................
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
      #.....................................................................................................
      if prefix_delta > 0
        prefix_excess = prefix.splice 0, prefix_delta
      if suffix_delta > 0
        suffix_excess = suffix.splice suffix.length - suffix_delta, suffix_delta
      #.....................................................................................................
      while prefix_excess.length > 0 and prefix_excess.length > prefix_excess_max_length
        prefix_is_shortened = yes
        prefix_excess.pop()
      while suffix_excess.length > 0 and suffix_excess.length > suffix_excess_max_length
        suffix_is_shortened = yes
        suffix_excess.shift()
      #.....................................................................................................
      while prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length
        prefix_padding.unshift '\u3000'
      while suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length
        suffix_padding.unshift '\u3000'
      #.....................................................................................................
      if prefix_excess.length > 0 then prefix_excess.unshift '「' unless prefix_excess.length is 0
      else                                    prefix.unshift '「' unless prefix_delta > 0
      if suffix_excess.length > 0 then suffix_excess.push    '」' unless suffix_excess.length is 0
      else                                    suffix.push    '」' unless suffix_delta > 0
      #.....................................................................................................
      prefix.splice 0, 0, prefix_padding...
      prefix.splice 0, 0, suffix_excess...
      suffix.splice suffix.length, 0, suffix_padding...
      suffix.splice suffix.length, 0, prefix_excess...
      #.....................................................................................................
      urge ( prefix.join '' ) + '【' + infix + '】' + ( suffix.join '' )
      # send [ glyph, [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ], ]
      send [ glyph, [ prefix, infix, suffix, ], ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$align_affixes_with_spaces = =>
  ### This code has been used in `copy-jizuradb-to-Hollerith2-format#add_kwic_v3_wrapped_lineups` ###
  prefix_max_length   = 3
  suffix_max_length   = 3
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if CND.isa_list event
      [ glyph, sortcode, ]          = event
      [ _, infix, suffix, prefix, ] = sortcode
      #.....................................................................................................
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
      #.....................................................................................................
      if prefix_delta > 0
        prefix_excess = prefix.splice 0, prefix_delta
      if suffix_delta > 0
        suffix_excess = suffix.splice suffix.length - suffix_delta, suffix_delta
      #.....................................................................................................
      while prefix_excess.length > 0 and prefix_excess.length > prefix_excess_max_length - 1
        prefix_excess.pop()
      while suffix_excess.length > 0 and suffix_excess.length > suffix_excess_max_length - 1
        suffix_excess.shift()
      #.....................................................................................................
      while prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length
        prefix_padding.unshift '\u3000'
      while suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length
        suffix_padding.unshift '\u3000'
      #.....................................................................................................
      prefix.splice 0, 0, prefix_padding...
      prefix.splice 0, 0, suffix_excess...
      suffix.splice suffix.length, 0, suffix_padding...
      suffix.splice suffix.length, 0, prefix_excess...
      #.....................................................................................................
      urge ( prefix.join '' ) + '【' + infix + '】' + ( suffix.join '' )
      # send [ glyph, [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ], ]
      send [ glyph, [ prefix, infix, suffix, ], ]
    #.......................................................................................................
    else
      send event


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


