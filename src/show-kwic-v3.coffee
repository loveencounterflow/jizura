
###


`@$align_affixes_with_braces`

```keep-lines squish: yes
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
```


`align_affixes_with_spaces`

```keep-lines squish: yes
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
```



###











############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
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
  #.........................................................................................................
  if CND.isa_list limit_or_list
    Z[ glyph ] = 1 for glyph in limit_or_list
    return handler null, Z
  #.........................................................................................................
  return handler null, null if limit_or_list < 0 or limit_or_list is Infinity
  #.........................................................................................................
  throw new Error "expected list or number, got a #{type}" unless CND.isa_number limit_or_list
  #.........................................................................................................
  db_route  = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  db       ?= HOLLERITH.new_db db_route, create: no
  #.........................................................................................................
  lo      = [ 'pos', 'rank/cjt', 0, ]
  hi      = [ 'pos', 'rank/cjt', limit_or_list, ]
  query   = { lo, hi, }
  input   = HOLLERITH.create_phrasestream db, query
  #.........................................................................................................
  input
    .pipe $ ( phrase, send ) =>
        [ _, _, _, glyph, ] = phrase
        Z[ glyph ]          = 1
    .pipe D.$on_end -> handler null, Z

#-----------------------------------------------------------------------------------------------------------
@_describe_glyph_sample = ( S ) ->
  if S.glyph_sample is Infinity
    ### TAINT font substitution should be configured in options or other appropriate place ###
    return "gamut of *N* <<<{\\mktsFontfileOptima{}≈}>>> #{CND.format_number 75000, ','} glyphs"
  else if CND.isa_number S.glyph_sample
    return "gamut of *N* = #{CND.format_number S.glyph_sample, ','} glyphs"
  else
    return "selected glyphs: #{S.glyph_sample.join ''}"

#-----------------------------------------------------------------------------------------------------------
@describe_glyphs = ( S ) ->
  R       = []
  R.push "<<(em>> ___KWIC___ Index for "
  if S.factor_sample? and ( factors = Object.keys S.factor_sample ).length > 0
    plural = if factors.length > 1 then 's' else ''
    R.push "factor#{plural} #{factors.join ''}; "
  R.push ( @_describe_glyph_sample S ) + ':<<)>>'
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@describe_stats = ( S ) ->
  # debug '9080', S
  return "(no stats)" unless S.do_stats
  return "XXXXX" unless S.factor_sample?
  factors = Object.keys S.factor_sample
  if factors.length is 1
    plural  = ""
    pronoun = "its"
  else
    plural  = "s"
    pronoun = "their"
  R       = []
  R.push "<<(em>>Statistics for factor#{plural} #{factors.join ''}"
  if S.two_stats then R.push "and #{pronoun} immediate suffix and prefix factors"
  else                R.push "and #{pronoun} immediate suffix factors"
  R.push " (\ue045 indicates first/last position);"
  R.push ( @_describe_glyph_sample S ) + ':<<)>>'
  return R.join '\n'

#-----------------------------------------------------------------------------------------------------------
@show_kwic_v3 = ( S ) ->
  #.........................................................................................................
  # factor_sample =
  #   '旧日卓桌𠦝東車更㯥䡛轟𨏿昍昌晶𣊭早畢果𣛕𣡗𣡾曱甲𤳅𤳵申𤱓禺𥝉㬰电田畕畾𤳳由甴𡆪白㿟皛鱼魚䲆𩺰鱻䲜'
  # factor_sample = '旧日卓桌𠦝昍昌晶𣊭早白㿟皛'
  # factor_sample = '耂'
  #.........................................................................................................
  ### TAINT temporary; going to use sets ###
  if S.factor_sample?
    _fs = {}
    _fs[ factor ] = 1 for factor in S.factor_sample
    S.factor_sample = _fs
  #.........................................................................................................
  S.glyphs_description  = @describe_glyphs S
  S.stats_description   = @describe_stats S
  urge S.glyphs_description
  urge S.stats_description
  #.........................................................................................................
  S.query       = { prefix: [ 'pos', 'guide/kwic/v3/sortcode/wrapped-lineups', ], }
  S.db_route    = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  S.db          = HOLLERITH.new_db S.db_route, create: no
  # S         = { db_route, db, query, glyph_sample, factor_sample, handler, }
  help "using DB at #{S.db[ '%self' ][ 'location' ]}"
  #.........................................................................................................
  step ( resume ) =>
    #.......................................................................................................
    S.glyph_sample = yield @read_sample S.db, S.glyph_sample, resume
    # debug '9853', ( Object.keys S.glyph_sample ).length
    input           = ( HOLLERITH.create_phrasestream S.db, S.query ).pipe $transform_v3 S
    # handler null
    return null
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
$reorder_phrase = ( S ) =>
  return $ ( phrase, send ) =>
    ### extract sortcode ###
    [ _, _, sortrow, glyph, _, ]  = phrase
    [ _, infix, suffix, prefix, ] = sortrow
    send [ glyph, prefix, infix, suffix, ]

#-----------------------------------------------------------------------------------------------------------
$exclude_gaiji = ( S ) =>
  return D.$filter ( event ) =>
    [ glyph, ] = event
    return ( not glyph.startsWith '&' ) or ( glyph.startsWith '&jzr#' )

#-----------------------------------------------------------------------------------------------------------
$include_sample = ( S ) =>
  return D.$filter ( event ) =>
    # [ _, infix, suffix, prefix, ] = sortcode
    # factors = [ prefix..., infix, suffix...,]
    # return ( infix is '山' ) and ( '水' in factors )
    return true if ( not S.glyph_sample? ) and ( not S.factor_sample? )
    [ glyph, prefix, infix, suffix, ] = event
    in_glyph_sample   = ( not  S.glyph_sample? ) or ( glyph of  S.glyph_sample )
    in_factor_sample  = ( not S.factor_sample? ) or ( infix of S.factor_sample )
    return in_glyph_sample and in_factor_sample

#-----------------------------------------------------------------------------------------------------------
$write_stats = ( S ) =>
  return D.$pass_through() unless S.do_stats
  glyphs          = new Set()
  ### NB that we use a JS `Set` to record unique infixes; it has the convenient property of keeping the
  insertion order of its elements, so afterwards we can use it to determine the infix ordering. ###
  infixes         = new Set()
  factor_pairs    = new Map()
  lineup_count    = 0
  output          = njs_fs.createWriteStream S.stats_route
  line_count      = 0
  in_suffix_part  = no
  #.........................................................................................................
  return D.$observe ( event, has_ended ) =>
    if event?
      #.....................................................................................................
      if CND.isa_list event
        [ glyph, prefix, infix, suffix, ] = event
        #...................................................................................................
        if suffix.startsWith '\u3000' then suffix = '\ue045'
        else                               suffix = suffix.trim()
        suffix  = Array.from suffix
        # if S.two_stats then key = "#{infix},#{infix}#{suffix[ 0 ]}"
        # else                key = "#{infix},#{infix}#{suffix[ 0 ]}-1"
        key = "#{infix},#{infix}#{suffix[ 0 ]},1"
        factor_pairs.set key, target = new Set() unless ( target = factor_pairs.get key )?
        target.add glyph
        #...................................................................................................
        if S.with_prefixes
          if prefix.endsWith '\u3000' then prefix = '\ue045'
          else                             prefix = prefix.trim()
          prefix  = Array.from prefix
          key     = "#{infix},#{prefix[ prefix.length - 1 ]}#{infix},2"
          factor_pairs.set key, target = new Set() unless ( target = factor_pairs.get key )?
          target.add glyph
        #...................................................................................................
        infixes.add infix
        glyphs.add  glyph
        lineup_count += +1
    #.......................................................................................................
    if has_ended
      help "built KWIC for #{ƒ glyphs.size} glyphs"
      help "containing #{ƒ lineup_count} lineups"
      infixes       = Array.from infixes
      factor_pairs  = Array.from factor_pairs
      for entry in factor_pairs
        entry[ 0 ]      = entry[ 0 ].split ','
        entry[ 0 ][ 2 ] = parseInt entry[ 0 ][ 2 ], 10
        entry[ 1 ]      = Array.from entry[ 1 ]
      #.....................................................................................................
      factor_pairs.sort ( a, b ) ->
        [ [ a_infix, a_pair, a_series, ], a_glyphs, ] = a
        [ [ b_infix, b_pair, b_series, ], b_glyphs, ] = b
        a_infix_idx                                   = infixes.indexOf a_infix
        b_infix_idx                                   = infixes.indexOf b_infix
        if S.two_stats
          return +1 if a_series > b_series
          return -1 if a_series < b_series
        return +1 if a_infix_idx     > b_infix_idx
        return -1 if a_infix_idx     < b_infix_idx
        return +1 if a_glyphs.length < b_glyphs.length
        return -1 if a_glyphs.length > b_glyphs.length
        return +1 if a_pair          > b_pair
        return -1 if a_pair          < b_pair
        return  0
      #.....................................................................................................
      ### TAINT column count should be accessible through CLI and otherwise be calculated according to
      paper size and lineup lengths ###
      output.write "<<(columns 4>><<(JZR.vertical-bar>>\n"
      output.write "```keep-lines squish: yes\n"
      #.....................................................................................................
      last_infix  = null
      last_series = null
      separator   = '】'
      for [ [ infix, factor_pair, series, ], glyphs, ] in factor_pairs
        #...................................................................................................
        if S.two_stats and last_series? and last_series isnt series
          in_suffix_part = yes
          output.write "```\n"
          # output.write "<<)>><<)>>\n"
          output.write "\n/0------------------------------0/\n\n"
          # output.write "<<(columns 4>><<(JZR.vertical-bar>>\n"
          output.write "```keep-lines squish: yes\n"
          output.write "——.\ue023#{infix}.——\n"
        #...................................................................................................
        else if last_infix isnt infix
          if S.two_stats
            unless in_suffix_part then  output.write "——.#{infix}\ue023.——\n"
            else                        output.write "——.\ue023#{infix}.——\n"
          else
            output.write "——.\ue023#{infix}\ue023.——\n"
        last_infix = infix
        last_series = series
        #...................................................................................................
        glyph_count = glyphs.length
        # if glyph_count > 999 then glyph_count_txt = "<<<{\\tfScale{0.5}{1}#{glyph_count}}>>>#{glyph_count}"
        glyph_count_txt = "#{glyph_count}"
        if S.width?
          glyphs.push '\u3000'  while glyphs.length < S.width
          glyphs.pop()          while glyphs.length > S.width
        line = [ factor_pair, separator, ( glyphs.join '' ), '==>', glyph_count_txt, '\n', ].join ''
        output.write line
        line_count += +1
      #.....................................................................................................
      output.write "```\n"
      output.write "<<)>><<)>>\n"
      output.end()
      help "found #{infixes.length} infixes"
      help "wrote #{line_count} lines to #{S.stats_route}"
      S.handler null if S.handler?
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
$write_glyphs = ( S ) =>
  output        = njs_fs.createWriteStream S.glyphs_route
  line_count    = 0
  is_first      = yes
  last_infix    = null
  empty_prefix  = '\u3000\u3000\u3000'
  #.........................................................................................................
  return D.$observe ( event, has_ended ) ->
    #.......................................................................................................
    if event?
      if CND.isa_list event
        if is_first
          ### TAINT column count should be accessible through CLI and otherwise be calculated according to
          paper size and lineup lengths ###
          output.write "<<(columns 4>><<(JZR.vertical-bar>>\n"
          output.write "```keep-lines squish: yes\n"
          is_first = no
        [ glyph, prefix, infix, suffix, ] = event
        if ( infix isnt last_infix ) and ( glyph isnt infix )
          # output.write "——.#{infix}.——\n"
          output.write empty_prefix + '【' + infix + '】' + '\n'
        output.write prefix + '【' + infix + '】' + suffix + '==>' + glyph + '\n'
        last_infix = infix
      else
        output.write event + '\n'
      line_count += +1
    #.......................................................................................................
    if has_ended
      output.write "```\n"
      output.write "<<)>><<)>>\n"
      help "wrote #{line_count} lines to #{S.glyphs_route}"
      output.end()

#-----------------------------------------------------------------------------------------------------------
$write_glyphs_description = ( S ) =>
  output = njs_fs.createWriteStream S.glyphs_description_route
  #.........................................................................................................
  return D.$observe ( event, has_ended ) ->
    if has_ended
      output.write S.glyphs_description
      help "wrote glyphs description to #{S.glyphs_description_route}"
      output.end()

#-----------------------------------------------------------------------------------------------------------
$write_stats_description = ( S ) =>
  return D.$pass_through() unless S.do_stats
  output = njs_fs.createWriteStream S.stats_description_route
  #.........................................................................................................
  return D.$observe ( event, has_ended ) ->
    if has_ended
      output.write S.stats_description
      help "wrote stats description to #{S.stats_description_route}"
      output.end()


# #-----------------------------------------------------------------------------------------------------------
# $count_lineup_lengths = ( S ) =>
#   counts  = []
#   count   = 0
#   #.........................................................................................................
#   return $ ( event, send, end ) =>
#     if event?
#       #.....................................................................................................
#       if CND.isa_list event
#         [ glyph, sortcode, ]          = event
#         [ _, infix, suffix, prefix, ] = sortcode
#         lineup                        = ( prefix.join '' ) + infix + ( suffix.join '' )
#         lineup_length                 = ( Array.from lineup.replace /\u3000/g, '' ).length
#         if true # lineup_length is 8
#           send event
#           counts[ lineup_length ] = ( counts[ lineup_length ] ? 0 ) + 1
#       #.....................................................................................................
#       else
#         send event
#     #.......................................................................................................
#     if end?
#       for length in [ 1 ... counts.length ]
#         count_txt = TEXT.flush_right ( ƒ counts[ length ] ? 0 ), 10
#         help "found #{count_txt} lineups of length #{length}"
#       end()

# #-----------------------------------------------------------------------------------------------------------
# @$align_affixes_with_braces = ( S ) =>
#   prefix_max_length   = 3
#   suffix_max_length   = 3
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     #.......................................................................................................
#     if CND.isa_list event
#       [ glyph, sortcode, ]          = event
#       [ _, infix, suffix, prefix, ] = sortcode
#       #.....................................................................................................
#       prefix_length                 = prefix.length
#       suffix_length                 = suffix.length
#       prefix_delta                  = prefix_length - prefix_max_length
#       suffix_delta                  = suffix_length - suffix_max_length
#       prefix_excess_max_length      = suffix_max_length - suffix_length
#       suffix_excess_max_length      = prefix_max_length - prefix_length
#       prefix_excess                 = []
#       suffix_excess                 = []
#       prefix_padding                = []
#       suffix_padding                = []
#       prefix_is_shortened           = no
#       suffix_is_shortened           = no
#       #.....................................................................................................
#       if prefix_delta > 0
#         prefix_excess = prefix.splice 0, prefix_delta
#       if suffix_delta > 0
#         suffix_excess = suffix.splice suffix.length - suffix_delta, suffix_delta
#       #.....................................................................................................
#       while prefix_excess.length > 0 and prefix_excess.length > prefix_excess_max_length
#         prefix_is_shortened = yes
#         prefix_excess.pop()
#       while suffix_excess.length > 0 and suffix_excess.length > suffix_excess_max_length
#         suffix_is_shortened = yes
#         suffix_excess.shift()
#       #.....................................................................................................
#       while prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length
#         prefix_padding.unshift '\u3000'
#       while suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length
#         suffix_padding.unshift '\u3000'
#       #.....................................................................................................
#       if prefix_excess.length > 0 then prefix_excess.unshift '「' unless prefix_excess.length is 0
#       else                                    prefix.unshift '「' unless prefix_delta > 0
#       if suffix_excess.length > 0 then suffix_excess.push    '」' unless suffix_excess.length is 0
#       else                                    suffix.push    '」' unless suffix_delta > 0
#       #.....................................................................................................
#       prefix.splice 0, 0, prefix_padding...
#       prefix.splice 0, 0, suffix_excess...
#       suffix.splice suffix.length, 0, suffix_padding...
#       suffix.splice suffix.length, 0, prefix_excess...
#       #.....................................................................................................
#       urge ( prefix.join '' ) + '【' + infix + '】' + ( suffix.join '' )
#       # send [ glyph, [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ], ]
#       send [ glyph, [ prefix, infix, suffix, ], ]
#     #.......................................................................................................
#     else
#       send event

# #-----------------------------------------------------------------------------------------------------------
# @$align_affixes_with_spaces = ( S ) =>
#   ### This code has been used in `copy-jizuradb-to-Hollerith2-format#add_kwic_v3_wrapped_lineups` ###
#   prefix_max_length   = 3
#   suffix_max_length   = 3
#   #.........................................................................................................
#   return $ ( event, send ) =>
#     #.......................................................................................................
#     if CND.isa_list event
#       [ glyph, sortcode, ]          = event
#       [ _, infix, suffix, prefix, ] = sortcode
#       #.....................................................................................................
#       prefix_length                 = prefix.length
#       suffix_length                 = suffix.length
#       prefix_delta                  = prefix_length - prefix_max_length
#       suffix_delta                  = suffix_length - suffix_max_length
#       prefix_excess_max_length      = suffix_max_length - suffix_length
#       suffix_excess_max_length      = prefix_max_length - prefix_length
#       prefix_excess                 = []
#       suffix_excess                 = []
#       prefix_padding                = []
#       suffix_padding                = []
#       #.....................................................................................................
#       if prefix_delta > 0
#         prefix_excess = prefix.splice 0, prefix_delta
#       if suffix_delta > 0
#         suffix_excess = suffix.splice suffix.length - suffix_delta, suffix_delta
#       #.....................................................................................................
#       while prefix_excess.length > 0 and prefix_excess.length > prefix_excess_max_length - 1
#         prefix_excess.pop()
#       while suffix_excess.length > 0 and suffix_excess.length > suffix_excess_max_length - 1
#         suffix_excess.shift()
#       #.....................................................................................................
#       while prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length
#         prefix_padding.unshift '\u3000'
#       while suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length
#         suffix_padding.unshift '\u3000'
#       #.....................................................................................................
#       prefix.splice 0, 0, prefix_padding...
#       prefix.splice 0, 0, suffix_excess...
#       suffix.splice suffix.length, 0, suffix_padding...
#       suffix.splice suffix.length, 0, prefix_excess...
#       #.....................................................................................................
#       urge ( prefix.join '' ) + '【' + infix + '】' + ( suffix.join '' )
#       # send [ glyph, [ prefix_padding, suffix_excess, prefix, infix, suffix, prefix_excess, ], ]
#       send [ glyph, [ prefix, infix, suffix, ], ]
#     #.......................................................................................................
#     else
#       send event


#-----------------------------------------------------------------------------------------------------------
$transform_v3 = ( S ) =>
  return D.combine [
    $reorder_phrase                 S
    $exclude_gaiji                  S
    $include_sample                 S
    # $count_lineup_lengths           S
    # @$align_affixes_with_braces     S
    # @$align_affixes_with_spaces     S
    $write_stats                    S
    $write_glyphs                   S
    $write_glyphs_description       S
    $write_stats_description        S
    D.$on_end => S.handler null if S.handler?
    ]



# ############################################################################################################
# unless module.parent?

#   #---------------------------------------------------------------------------------------------------------
#   options =
#     #.......................................................................................................
#     # 'route':                njs_path.join __dirname, '../dbs/demo'
#     'route':                njs_path.resolve __dirname, '../../jizura-datasources/data/leveldb-v2'
#     # 'route':            '/tmp/leveldb'
#   #---------------------------------------------------------------------------------------------------------
#   @show_kwic_v3()


