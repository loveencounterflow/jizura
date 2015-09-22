


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/copy-jizuradb-to-Hollerith2-format'
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
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
HOLLERITH                 = require 'hollerith'
# DEMO                      = require 'hollerith/lib/demo'
KWIC                      = require 'kwic'
ƒ                         = CND.format_number.bind CND



#-----------------------------------------------------------------------------------------------------------
@$parse_tsv = ( options ) ->
  #.........................................................................................................
  return $ ( record, send ) =>
    fields  = record.split /\s+/
    fields  = ( field.trim() for field in fields )
    fields  = ( field for field in fields when field.length > 0 )
    if fields.length > 0 and not fields[ 0 ].startsWith '#'
      [ glyph, frequency_txt, _, ] = fields
      frequency = parseInt frequency_txt, 10
      send [ glyph, frequency, ]

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
  unless db?
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
@read_chtsai_frequencies = ( handler ) ->
  route = njs_path.join __dirname, '../../jizura-datasources/data/flat-files/usage/usage-counts-zhtw-chtsai-13000chrs-3700ranks.txt'
  input = njs_fs.createReadStream route
  Z     = {}
  input
    .pipe D.$split()
    .pipe @$parse_tsv()
    .pipe $ ( glyph_and_frequency, send, end ) =>
      if glyph_and_frequency?
        [ glyph, frequency, ] = glyph_and_frequency
        Z[ glyph ]            = frequency
      if end?
        handler null, Z
        end()

#-----------------------------------------------------------------------------------------------------------
@main = ->
  db_route        = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  db              = HOLLERITH.new_db db_route, create: no
  help "using DB at #{db[ '%self' ][ 'location' ]}"
  #.........................................................................................................
  step ( resume ) =>
    ranks         = {}
    # include       = Infinity
    # include       = [ '櫻', '哈', ]
    include       = 10000
    #.......................................................................................................
    # sample        = yield @read_sample db, include, resume
    sample        = null
    frequencies   = yield @read_chtsai_frequencies resume
    if sample?
      help "using sample of #{ƒ ( Object.keys sample ).length} glyphs"
    #.......................................................................................................
    prefix        = [ 'pos', 'guide/has/uchr', ]
    ### TAINT use of star not correct ###
    query         = { prefix, star: '*', }
    input         = HOLLERITH.create_phrasestream db, query
    #.......................................................................................................
    input.on 'end', -> help "ok"
    #.......................................................................................................
    $select_glyph_and_guide = =>
      return $ ( phrase, send ) =>
        [ _, _, guide, glyph, _, ] = phrase
        send [ glyph, guide, ]
    #.......................................................................................................
    $filter_sample = ( sample ) =>
      return $ ( [ glyph, guide, ], send ) =>
        event = [ 'glyph-and-guide', glyph, guide, ]
        if sample?
          send event if sample[ glyph ]?
        else
          send event
    #.......................................................................................................
    $filter_by_frequencies = ( frequencies ) =>
      return $ ( [ glyph, guide, ], send ) =>
        if ( frequency = frequencies[ glyph ] )?
          event = [ 'glyph-guide-and-frequency', glyph, guide, frequency, ]
          send event
    #.......................................................................................................
    $count_guides = =>
      counts = {}
      return $ ( event, send, end ) =>
        if event?
          [ type, glyph, guide, ] = event
          counts[ guide ] = ( counts[ guide ] ? 0 ) + 1
        if end?
          send [ 'counts', counts, ]
          end()
    #.......................................................................................................
    $sort_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        counts          = ( [ guide, count, ] for guide, count of counts )
        counts.sort ( a, b ) ->
          return +1 if a[ 1 ] < b[ 1 ]
          return -1 if a[ 1 ] > b[ 1 ]
          return  0
        send [ 'counts', counts, ]
    #.......................................................................................................
    $rank_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        rank            = 0
        last_count      = null
        for [ guide, count, ], idx in counts
          if count isnt last_count
            rank       += +1
            last_count  = count
          counts[ idx ] = [ guide, count, rank, ]
        send [ 'counts', counts, ]
    #.......................................................................................................
    $show_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        for [ guide, count, rank, ] in counts
          echo "#{rank}\t#{count}\t#{guide}"
    #.......................................................................................................
    input
      #.....................................................................................................
      .pipe $select_glyph_and_guide()
      # .pipe $filter_sample sample
      .pipe $filter_by_frequencies frequencies
      .pipe D.$show()
      # .pipe $count_guides()
      # .pipe $sort_counts()
      # .pipe $rank_counts()
      # .pipe $show_counts()
    # #.......................................................................................................
    # input
    #   #.....................................................................................................
    #   .pipe $select_glyph_and_guide()
    #   # .pipe $filter_sample sample
    #   .pipe $filter_by_frequencies frequencies
    #   .pipe D.$show()
    #   # .pipe $count_guides()
    #   # .pipe $sort_counts()
    #   # .pipe $rank_counts()
    #   # .pipe $show_counts()
    #   .pipe output
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@count_guides_with_frequencies = ->
  db_route        = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  db              = HOLLERITH.new_db db_route, create: no
  help "using DB at #{db[ '%self' ][ 'location' ]}"
  #.........................................................................................................
  step ( resume ) =>
    ranks         = {}
    frequencies   = yield @read_chtsai_frequencies resume
    prefix        = [ 'pos', 'guide/has/uchr', ]
    ### TAINT use of star not correct ###
    query         = { prefix, star: '*', }
    input         = HOLLERITH.create_phrasestream db, query
    #.......................................................................................................
    input.on 'end', -> help "ok"
    #.......................................................................................................
    $select_glyph_and_guide = =>
      return $ ( phrase, send ) =>
        [ _, _, guide, glyph, _, ] = phrase
        send [ glyph, guide, ]
    #.......................................................................................................
    $filter_sample = ( sample ) =>
      return $ ( [ glyph, guide, ], send ) =>
        event = [ 'glyph-and-guide', glyph, guide, ]
        if sample?
          send event if sample[ glyph ]?
        else
          send event
    #.......................................................................................................
    $filter_by_frequencies = ( frequencies ) =>
      return $ ( [ glyph, guide, ], send ) =>
        if ( frequency = frequencies[ glyph ] )?
          event = [ 'glyph-guide-and-frequency', glyph, guide, frequency, ]
          send event
    #.......................................................................................................
    $count_guides_with_frequencies = =>
      counts = {}
      return $ ( event, send, end ) =>
        if event?
          [ type, glyph, guide, frequency, ] = event
          counts[ guide ] = ( counts[ guide ] ? 0 ) + frequency
        if end?
          send [ 'counts', counts, ]
          end()
    #.......................................................................................................
    $sort_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        counts          = ( [ guide, count, ] for guide, count of counts )
        counts.sort ( a, b ) ->
          return +1 if a[ 1 ] < b[ 1 ]
          return -1 if a[ 1 ] > b[ 1 ]
          return  0
        send [ 'counts', counts, ]
    #.......................................................................................................
    $rank_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        rank            = 0
        for [ guide, count, ], idx in counts
          rank         += +1
          counts[ idx ] = [ guide, count, rank, ]
        send [ 'counts', counts, ]
    #.......................................................................................................
    $show_counts = =>
      return $ ( event, send ) =>
        [ _, counts, ]  = event
        for [ guide, count, rank, ] in counts
          echo "#{rank}\t#{count}\t#{guide}"
    #.......................................................................................................
    input
      #.....................................................................................................
      .pipe $select_glyph_and_guide()
      .pipe $filter_by_frequencies frequencies
      # .pipe D.$show()
      .pipe $count_guides_with_frequencies()
      .pipe $sort_counts()
      .pipe $rank_counts()
      .pipe $show_counts()
    #.......................................................................................................
    return null

############################################################################################################
unless module.parent?
  # @main()
  @count_guides_with_frequencies()
