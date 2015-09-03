



############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/show-usage-counts'
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
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
HOLLERITH                 = require 'hollerith'
CHR                       = require 'coffeenode-chr'
TEXT                      = require 'coffeenode-text'
ƒ                         = CND.format_number.bind CND



#-----------------------------------------------------------------------------------------------------------
@$simplify_usagecode = ->
  ### Normalize letters to lower case, thereby conflating the `C` vs `c` etc distinctions; throw out
  characters marked as `f` (facultative), `p` (positional), and `x` (extra); subsume Korea, Taiwan, Hong
  Kong and Macau under one group (`t` for 'traditional'): ###
  return $ ( [ phrase_type, prd, usagecode, glyph, ], send ) =>
    usagecode = usagecode.toLowerCase()
    usagecode = usagecode.replace /f|p|x/g,   ''
    usagecode = usagecode.replace /k|h|m|t/g, 't'
    usagecode = usagecode.replace /t+/g,      't'
    #.......................................................................................................
    if usagecode.length > 0
      send [ glyph, usagecode, ]
    return null

#-----------------------------------------------------------------------------------------------------------
@$add_rank = ( db ) ->
  return $async ( [ glyph, usagecode, ], done ) =>
    prefix  = [ 'spo', glyph, 'rank/cjt', ]
    query   = { prefix: prefix, fallback: null, }
    HOLLERITH.read_one_phrase db, query, ( error, phrase ) =>
      return done.error error if error?
      return done() if phrase is null
      [ _, _, _, rank, ]  = phrase
      done [ glyph, usagecode, rank, ]

#-----------------------------------------------------------------------------------------------------------
@$collect_sample = ( ratio ) ->
  collection = {}
  return $ ( fields, send, end ) =>
    #.......................................................................................................
    if fields?
      [ glyph, usagecode, rank, ] = fields
      ( collection[ usagecode ]?= [] ).push [ glyph, rank, ]
      send [ glyph, usagecode, ]
    #.......................................................................................................
    if end?
      for usagecode, glyphs_and_ranks of collection
        glyphs_and_ranks.sort ( a, b ) ->
          return +1 if a[ 1 ] > b[ 1 ]
          return -1 if a[ 1 ] < b[ 1 ]
          return  0
        glyphs    = ( glyph for [ glyph, rank, ] in glyphs_and_ranks )
        last_idx  = Math.floor glyphs.length * ratio + 0.5
        urge usagecode, glyphs.length, glyphs[ ... last_idx ].join ''
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$count = ->
  counts = {}
  return $ ( fields, send, end ) =>
    #.......................................................................................................
    if fields?
      [ glyph, usagecode, ] = fields
      counts[ usagecode ]   = ( counts[ usagecode ] ? 0 ) + 1
    #.......................................................................................................
    if end?
      send counts
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$report = ->
  counts  = {}
  #.........................................................................................................
  show = ( counts, title ) ->
    counts = ( [ region, count, ] for region, count of counts )
    counts.sort ( a, b ) ->
      return +1 if a[ 0 ] > b[ 0 ]
      return -1 if a[ 0 ] < b[ 0 ]
      return  0
    help title
    for [ region, count, ] in counts
      help ( TEXT.flush_left region, 12, '.' ) + \
           ( TEXT.flush_right count, 10, '.' ), "glyphs"
  #.........................................................................................................
  return $ ( counts, send ) =>
    sum   = 0
    sum  += count for _, count of counts
    show counts, "individual glyph counts:"
    for region_0, count_0 of counts
      continue if region_0.length is 1
      for region_1 in region_0
        counts[ region_1 ] += count_0
    delete counts[ key ] for key of counts when key.length > 1
    show counts, "accumulated glyph counts:"
    help "altogether, #{sum} glyphs have a regional tag"
    warn "glyphs tagged only as Facultative, Positional or eXtra have been excluded from these counts"
    send counts
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$report_v2 = ->
  counts  = {}
  #.........................................................................................................
  show = ( title, counts ) ->
    counts = ( [ region, count, ] for region, count of counts )
    counts.sort ( a, b ) ->
      return +1 if a[ 0 ] > b[ 0 ]
      return -1 if a[ 0 ] < b[ 0 ]
      return  0
    help title
    for [ region, count, ] in counts
      help ( TEXT.flush_left region, 12, '.' ) + \
           ( TEXT.flush_right count, 10, '.' ), "glyphs"
  #.........................................................................................................
  return $ ( counts, send ) =>
    sum     = 0
    sum    += count for _, count of counts
    totals  = {}
    show "individual glyph counts:", counts
    for sub_regions, sub_count of counts
      for sub_region in sub_regions
        target = switch sub_region
          when 'c' then 'Ⓒ'
          when 'j' then 'Ⓙ'
          when 't' then 'Ⓣ'
        totals[ target ] = ( totals[ target ] ? 0 ) + sub_count
    show "accumulated glyph counts:", totals
    help "altogether, #{sum} glyphs have a regional tag"
    warn "glyphs tagged only as Facultative, Positional or eXtra have been excluded from these counts"
    send counts
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@show_statistics = ->
  home            = join __dirname, '../../jizura-datasources'
  db_route        = join home, 'data/leveldb-v2'
  db              = HOLLERITH.new_db db_route
  prefix          = [ 'pos', 'usagecode/full', ]
  ### TAINT star shouldn't be necessary here ###
  query           = { prefix, star: '*' }
  input           = HOLLERITH.create_phrasestream db, query
  #.........................................................................................................
  input
    .pipe @$simplify_usagecode()
    .pipe @$add_rank db
    .pipe @$collect_sample 0.07
    .pipe @$count()
    .pipe D.$show()
    .pipe @$report_v2()


############################################################################################################
unless module.parent?
  @show_statistics()
