


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
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
HOLLERITH                 = require 'hollerith'
# DEMO                      = require './demo'
KWIC                      = require 'kwic'
XNCHR                     = require './XNCHR'
ƒ                         = CND.format_number.bind CND

#-----------------------------------------------------------------------------------------------------------
options =
  sample:         null
  # sample:         [ '國', ]
  # sample:         [ '⿓', '龍', '龍', '邔', '𨙬', '國', '金', '釒', ]
  # sample:         [ '高', ]
  # sample:         [ '𡬜', '國', '𠵓', ]
  # sample:         [ '𡬜', '國', '𠵓', '后', '花', '醒', ]

# #-----------------------------------------------------------------------------------------------------------
# @$show_progress = ( size ) ->
#   size   ?= 1e3
#   count   = 0
#   return $ ( data, send ) =>
#     count += 1
#     echo ƒ count if count % size is 0
#     send data

#-----------------------------------------------------------------------------------------------------------
@$show_progress = ( size ) ->
  size         ?= 1e3
  phrase_count  = 0
  glyph_count   = 0
  last_glyph    = null
  return D.$observe ( phrase, has_ended ) =>
    unless has_ended
      phrase_count += 1
      echo ƒ phrase_count if phrase_count % size is 0
      glyph_count  += +1 if ( glyph = phrase[ 0 ] ) isnt last_glyph
      last_glyph    = glyph
    else
      help "read #{ƒ phrase_count} phrases for #{ƒ glyph_count} glyphs"
      help "(#{( phrase_count / glyph_count ).toFixed 2} phrases per glyph)"

#-----------------------------------------------------------------------------------------------------------
@$keep_small_sample = ->
  return $ ( key, send ) =>
    return send key unless options[ 'sample' ]?
    [ glyph, prd, obj, idx, ] = key
    send key if glyph in options[ 'sample' ]

#-----------------------------------------------------------------------------------------------------------
@$throw_out_pods = ->
  return $ ( key, send ) =>
    [ glyph, prd, obj, idx, ] = key
    send key unless prd is 'pod'

#-----------------------------------------------------------------------------------------------------------
@$remove_duplicate_kana_readings = ->
  readings_by_glyph = {}
  return $ ( key, send ) =>
    [ glyph, prd, obj, idx, ] = key
    if prd in [ 'reading/hi', ]
      target = readings_by_glyph[ glyph ]?= []
      if obj in target
        return warn "skipping duplicate reading #{glyph} #{obj}"
      target.push obj
    send key

#-----------------------------------------------------------------------------------------------------------
@$cast_types = ( ds_options ) ->
  return $ ( [ sbj, prd, obj, idx, ], send ) =>
    type_description = ds_options[ 'schema' ][ prd ]
    unless type_description?
      warn "no type description for predicate #{rpr prd}"
    else
      switch type = type_description[ 'type' ]
        when 'int'
          obj = parseInt obj, 10
        when 'text'
          ### TAINT we have no booleans configured ###
          if      obj is 'true'   then obj = true
          else if obj is 'false'  then obj = false
    send if idx? then [ sbj, prd, obj, idx, ] else [ sbj, prd, obj, ]

#-----------------------------------------------------------------------------------------------------------
@$collect_lists = ->
  objs          = null
  sbj_prd       = null
  last_digest   = null
  context_keys  = []
  has_errors    = false
  #.........................................................................................................
  return $ ( key, send, end ) =>
    #.......................................................................................................
    if key?
      context_keys.push key; context_keys.shift() if context_keys.length > 10
      [ sbj, prd, obj, idx, ] = key
      digest                  = JSON.stringify [ sbj, prd, ]
      #.....................................................................................................
      if digest is last_digest
        if idx?
          objs[ idx ] = obj
        else
          ### A certain subject/predicate combination can only ever be repeated if an index is
          present in the key ###
          alert()
          alert "erroneous repeated entry; context:"
          alert context_keys
          has_errors = true
      else
        send [ sbj_prd..., objs, ] if objs?
        objs            = null
        last_digest     = digest
        if idx?
          objs            = []
          objs[ idx ]     = obj
          sbj_prd         = [ sbj, prd, ]
        else
          send key
    #.......................................................................................................
    if end?
      send [ sbj_prd..., objs, ] if objs?
      return send.error new Error "there were errors; see alerts above" if has_errors
      end()
    #.......................................................................................................
    return null

#-----------------------------------------------------------------------------------------------------------
@$compact_lists = ->
  return $ ( [ sbj, prd, obj, ], send ) =>
    ### Compactify sparse lists so all `undefined` elements are removed; warn about this ###
    if ( CND.type_of obj ) is 'list'
      new_obj = ( element for element in obj when element isnt undefined )
      if obj.length isnt new_obj.length
        warn "phrase #{rpr [ sbj, prd, obj, ]} contained undefined elements; compactified"
      obj = new_obj
    send [ sbj, prd, obj, ]

#-----------------------------------------------------------------------------------------------------------
@$add_version_to_kwic_v1 = ->
  ### mark up all predicates `guide/kwic/*` as `guide/kwic/v1/*` ###
  return $ ( [ sbj, prd, obj, ], send ) =>
    if prd.startsWith 'guide/kwic/'
      prd = prd.replace /^guide\/kwic\//, 'guide/kwic/v1/'
    send [ sbj, prd, obj, ]

#-----------------------------------------------------------------------------------------------------------
@_long_wrapped_lineups_from_guides = ( guides ) ->
  ### Extending lineups to accommodate for glyphs with 'overlong' factorials (those with more than 6
  factors; these were previously excluded from the gamut in `feed-db.coffee`, line 2135,
  `@KWIC.$compose_lineup_facets`). ###
  ### TAINT here be magic numbers ###
  lineup      = guides[ .. ]
  last_idx    = lineup.length - 1 + 6
  lineup.push    '\u3000' while lineup.length < 19
  lineup.unshift '\u3000' while lineup.length < 25
  R           = []
  for idx in [ 6 .. last_idx ]
    infix   = lineup[ idx ]
    suffix  = lineup[ idx + 1 .. idx + 6 ].join ''
    prefix  = lineup[ idx - 6 .. idx - 1 ].join ''
    R.push [ infix, suffix, prefix, ].join ','
  return R

#-----------------------------------------------------------------------------------------------------------
@$add_kwic_v2 = ->
  ### see `demo/show_kwic_v2_and_v3_sample` ###
  last_glyph            = null
  long_wrapped_lineups  = null
  return $ ( [ sbj, prd, obj, ], send ) =>
    #.......................................................................................................
    if prd is 'guide/has/uchr'
      last_glyph            = sbj
      long_wrapped_lineups  = @_long_wrapped_lineups_from_guides obj
    #.......................................................................................................
    return send [ sbj, prd, obj, ] unless prd.startsWith 'guide/kwic/v1/'
    #.......................................................................................................
    switch prd.replace /^guide\/kwic\/v1\//, ''
      when 'lineup/wrapped/infix', 'lineup/wrapped/prefix', 'lineup/wrapped/suffix', 'lineup/wrapped/single'
        ### copy to target ###
        send [ sbj, prd, obj, ]
      when 'sortcode'
        [ glyph, _, sortcodes_v1, ] = [ sbj, prd, obj, ]
        sortcodes_v2                = []
        #...................................................................................................
        ### The difference between KWIC sortcodes of version 1 and version 2 lies in the re-arrangement
        of the factor codes and the index codes. In v1, the index codes appeared interspersed with
        the factor codes; in v2, the index codes come up front and the index codes come in the latter half
        of the sortcode strings. The effect of this rearrangement is that now that all of the indexes
        (which indicate the position of each factor in the lineup) are weaker than any of the factor codes,
        like sequences of factor codes (and, therefore, factors) will always be grouped together (whereas
        in v1, only like factors with like positions appeared together, and often like sequences appeared
        with other sequences interspersed where their indexes demanded it so). ###
        for sortcode_v1 in sortcodes_v1
          sortrow_v1 = ( x for x in sortcode_v1.split /(........,..),/ when x.length > 0 )
          sortrow_v1 = ( x.split ',' for x in sortrow_v1 )
          sortrow_v2 = []
          sortrow_v2.push sortcode for [ sortcode, _, ] in sortrow_v1
          sortrow_v2.push position for [ _, position, ] in sortrow_v1
          sortcodes_v2.push sortrow_v2.join ','
        #...................................................................................................
        unless glyph is last_glyph
          return send.error new Error "unexpected mismatch: #{rpr glyph}, #{rpr last_glyph}"
        #...................................................................................................
        unless long_wrapped_lineups?
          return send.error new Error "missing long wrapped lineups for glyph #{rpr glyph}"
        #...................................................................................................
        unless sortcodes_v2.length is long_wrapped_lineups.length
          warn 'sortcodes_v2:         ', sortcodes_v2
          warn 'long_wrapped_lineups: ', long_wrapped_lineups
          return send.error new Error "length mismatch for glyph #{rpr glyph}"
        #...................................................................................................
        sortcodes_v1[ idx ] += ";" + lineup for lineup, idx in long_wrapped_lineups
        sortcodes_v2[ idx ] += ";" + lineup for lineup, idx in long_wrapped_lineups
        send [ glyph, 'guide/kwic/v2/lineup/wrapped/single', long_wrapped_lineups, ]
        long_wrapped_lineups  = null
        #...................................................................................................
        send [ glyph, prd, sortcodes_v1, ]
        send [ glyph, 'guide/kwic/v2/sortcode', sortcodes_v2, ]
      else
        send.error new Error "unhandled predicate #{rpr prd}"

#-----------------------------------------------------------------------------------------------------------
@$add_kwic_v3 = ( factor_infos ) ->
  ### see `demo/show_kwic_v2_and_v3_sample` ###
  #.........................................................................................................
  return $ ( [ sbj, prd, obj, ], send ) =>
    send [ sbj, prd, obj, ]
    return unless prd is 'guide/kwic/v1/sortcode'
    #.......................................................................................................
    [ glyph, _, [ sortcode_v1, ... ], ] = [ sbj, prd, obj, ]
    #.......................................................................................................
    sortrow_v1    = ( x for x in sortcode_v1.split /(........,..),/ when x.length > 0 )
    weights       = ( x.split ',' for x in sortrow_v1 )
    weights.pop()
    weights       = ( sortcode for [ sortcode, _, ] in weights )
    weights       = ( sortcode for sortcode in weights when sortcode isnt '--------' )
    weights       = ( ( sortcode.replace    /~/g, '-'    ) for sortcode in weights )
    weights       = ( ( sortcode.replace /----/g, 'f---' ) for sortcode in weights )
    #.......................................................................................................
    factors       = ( factor_infos[ sortcode ] for sortcode in weights )
    factors       = ( ( if factor? then factor else '〓' ) for factor in factors )
    #.......................................................................................................
    unless weights.length is factors.length
      warn glyph, weights, factors, weights.length, factors.length
      return
    #.......................................................................................................
    permutations = KWIC.get_permutations factors, weights
    send [ glyph, 'guide/kwic/v3/sortcode', permutations, ]

#-----------------------------------------------------------------------------------------------------------
@$add_kwic_v3_wrapped_lineups = ( factor_infos ) ->
  prefix_max_length   = 3
  suffix_max_length   = 3
  #.........................................................................................................
  return $ ( [ sbj, prd, obj, ], send ) =>
    send [ sbj, prd, obj, ]
    return unless prd is 'guide/kwic/v3/sortcode'
    [ glyph, _, permutations, ]   = [ sbj, prd, obj, ]
    lineups                       = []
    #.......................................................................................................
    for permutation, idx in permutations
      [ sortcode, infix, suffix, prefix, ] = permutation
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
      prefix = prefix.join ''
      suffix = suffix.join ''
      lineups.push [ sortcode, infix, suffix, prefix, ]
    #.......................................................................................................
    send [ glyph, 'guide/kwic/v3/sortcode/wrapped-lineups', lineups, ]

#-----------------------------------------------------------------------------------------------------------
@$add_factor_membership = ( factor_infos ) ->
  glyphs_by_factors = {}
  #.........................................................................................................
  return $ ( phrase, send, end ) =>
    if phrase?
      send phrase
      [ glyph, prd, obj, ] = phrase
      return unless prd is 'guide/has/uchr'
      for factor in obj
        continue if factor is glyph
        ( glyphs_by_factors[ factor ]?= new Set() ).add glyph
    if end?
      for factor, glyphs of glyphs_by_factors
        send [ factor, 'factor/has/glyph/uchr', Array.from glyphs.keys(), ]
        # glyphs.forEach ( glyph ) =>
        #   send [ factor, 'factor/has/glyph/uchr', glyph, ]
      end()

#-----------------------------------------------------------------------------------------------------------
@$add_sims = ->
  sims_by_glyph = {}
  #.........................................................................................................
  return $ ( phrase, send, end ) =>
    if phrase?
      send phrase
      [ source_glyph, prd, target_glyph, ] = phrase
      return unless prd.startsWith 'sim/'
      return unless XNCHR.is_inner_glyph source_glyph
      [ _, tag, ] = prd.match /\/(.+)$/
      target      = sims_by_glyph[ target_glyph ]?= {}
      ( target[ tag ]?= [] ).push source_glyph
    if end?
      for target_glyph, sims of sims_by_glyph
        send [ target_glyph, "sims/from", sims, ]
        # for tag, source_glyphs of sims
        #   send [ target_glyph, "sims/from/#{tag}", source_glyphs, ]
      end()

#-----------------------------------------------------------------------------------------------------------
@$add_guide_pairs = ( factor_infos ) ->
  sortcode_by_factors = {}
  sortcode_by_factors[ guide_uchr ] = sortcode for sortcode, guide_uchr of factor_infos
  #.........................................................................................................
  ### TAINT code duplication ###
  ### TAIN make configurable / store in options ###
  home              = njs_path.resolve __dirname, '../../jizura-datasources'
  derivatives_home  = njs_path.resolve home, 'data/5-derivatives'
  derivatives_route = njs_path.resolve derivatives_home, 'guide-pairs.txt'
  derivatives       = njs_fs.createWriteStream derivatives_route, { encoding: 'utf-8', }
  collector         = []
  excludes          = [ '一', ]
  help "writing results of `add_guide_pairs` to #{derivatives_route}"
  derivatives.write """
    # generated on #{new Date()}
    # by #{__filename}
    \n\n"""
  #.........................................................................................................
  get_pairs = ( glyph, guides ) ->
    ### TAINT allow or eliminate duplicates? use pairs and reversed pairs? ###
    length      = guides.length
    chrs        = []
    sortcodes   = []
    entries     = []
    seen        = {}
    R           = { chrs, entries, }
    #.......................................................................................................
    return R if length < 2
    #.......................................................................................................
    for i in [ 0 ... length - 1 ]
      for j in [ i + 1 ... length ]
        guide_0     = guides[ i ]
        guide_1     = guides[ j ]
        continue if guide_0 in excludes or guide_1 in excludes
        sortcode_0  = sortcode_by_factors[ guide_0 ]
        sortcode_1  = sortcode_by_factors[ guide_1 ]
        sortcode_0 ?= 'zzzzzzzz'
        sortcode_1 ?= 'zzzzzzzz'
        # return send.error new Error "unknown guide: #{guide_0}" unless sortcode_0?
        # return send.error new Error "unknown guide: #{guide_1}" unless sortcode_1?
        #...................................................................................................
        key         = guide_0 + guide_1
        unless key of seen
          chrs.push key
          entries.push "#{sortcode_0} #{sortcode_1}\t#{key}\t#{glyph}"
          seen[ key ] = 1
        #...................................................................................................
        key         = guide_1 + guide_0
        unless key of seen
          chrs.push key
          entries.push "#{sortcode_1} #{sortcode_0}\t#{key}\t#{glyph}"
          seen[ key ] = 1
    #.......................................................................................................
    return R
  #.........................................................................................................
  return $ ( phrase, send, end ) =>
    #.......................................................................................................
    if phrase?
      send phrase
      [ sbj, prd, obj, ] = phrase
      #.....................................................................................................
      if prd is 'guide/has/uchr'
        [ glyph, _, guides, ] = [ sbj, prd, obj, ]
        if XNCHR.is_inner_glyph glyph
          { chrs, entries, }    = get_pairs glyph, guides
          # debug '©VrqrO', glyph, chrs
          # debug '©VrqrO', glyph, entries
          collector.push entry for entry in entries
          send [ glyph, 'guide/pair/uchr',    chrs, ]
          send [ glyph, 'guide/pair/entry',   entries, ]
    #.......................................................................................................
    if end?
      debug '©70RRX', new Date()
      whisper "sorting guide pairs..."
      collector.sort()
      whisper "done"
      debug '©70RRX', new Date()
      whisper "writing guide pairs..."
      for entry in collector
        derivatives.write entry + '\n'
      derivatives.end()
      whisper "done"
      debug '©70RRX', new Date()
      end()

# #===========================================================================================================
# find_duplicated_guides = ->
#   D = require 'pipedreams'
#   $ = D.remit.bind D
#   ### TAINT code duplication ###
#   ### TAIN make configurable / store in options ###
#   home              = njs_path.resolve __dirname, '../../jizura-datasources'
#   derivatives_home  = njs_path.resolve home, 'data/5-derivatives'
#   # derivatives_route = njs_path.resolve derivatives_home, 'guide-pairs.txt'
#   input             = njs_fs.createReadStream  njs_path.resolve derivatives_home, 'guide-pairs.txt'
#   output            = njs_fs.createWriteStream njs_path.resolve derivatives_home, 'guide-pairs-duplicated.txt'
#   input
#     .pipe D.$split()
#     # .pipe D.$parse_csv headers: no
#     .pipe $ ( line, send ) => send line unless line.length is 0
#     .pipe $ ( line, send ) => send line unless line.startsWith '#'
#     .pipe $ ( line, send ) => send [ line, ( line.split '\t' )... ]
#     .pipe $ ( [ line, _, guides, glyph, ], send ) => send [ line, glyph, guides, ]
#     .pipe $ ( fields, send ) =>
#       [ line, glyph, guides, ] = fields
#       # debug '0912', rpr fields
#       unless CND.isa_text guides
#         warn line, fields
#       send fields
#     .pipe $ ( [ line, glyph, guides, ], send ) =>
#       send [ line, glyph, ( Array.from guides )... ]
#     .pipe $ ( fields, send ) =>
#       [ line, glyph, guide_0, guide_1, ] = fields
#       send fields unless guide_0 is '一' or guide_1 is '一'
#     .pipe $ ( fields, send ) =>
#       [ line, glyph, guide_0, guide_1, ] = fields
#       send fields if guide_0 is guide_1
#     # .pipe D.$show()
#     .pipe $ ( [ line, glyph, guide_0, guide_1, ], send ) => send line + '\n'
#     .pipe output
# find_duplicated_guides()

#-----------------------------------------------------------------------------------------------------------
@v1_split_so_bkey = ( bkey ) ->
  R       = bkey.toString 'utf-8'
  R       = R.split '|'
  idx_txt = R[ 3 ]
  R       = [ ( R[ 1 ].split ':' )[ 1 ], ( R[ 2 ].split ':' )..., ]
  R.push ( parseInt idx_txt, 10 ) if idx_txt? and idx_txt.length > 0
  for r, idx in R
    continue unless CND.isa_text r
    continue unless 'µ' in r
    R[ idx ] = @v1_unescape r
  return R

#-----------------------------------------------------------------------------------------------------------
@v1_$split_so_bkey = -> $ ( bkey, send ) => send @v1_split_so_bkey bkey

#-----------------------------------------------------------------------------------------------------------
@v1_lte_from_gte = ( gte ) ->
  R = new Buffer ( last_idx = Buffer.byteLength gte ) + 1
  R.write gte
  R[ last_idx ] = 0xff
  return R

#-----------------------------------------------------------------------------------------------------------
@v1_unescape = ( text_esc ) ->
  matcher = /µ([0-9a-f]{2})/g
  return text_esc.replace matcher, ( _, cid_hex ) ->
    return String.fromCharCode parseInt cid_hex, 16

#-----------------------------------------------------------------------------------------------------------
@read_factors = ( db, handler ) ->
  #.........................................................................................................
  Z         = {}
  #.......................................................................................................
  gte         = 'os|factor/sortcode'
  lte         = @v1_lte_from_gte gte
  input       = db[ '%self' ].createKeyStream { gte, lte, }
  #.......................................................................................................
  input
    .pipe @v1_$split_so_bkey()
    .pipe D.$observe ( [ sortcode, _, factor, ] ) =>
      Z[ sortcode ] = XNCHR.as_uchr factor
    .pipe D.$on_end -> handler null, Z

#-----------------------------------------------------------------------------------------------------------
@copy_jizura_db = ->
  home            = njs_path.resolve __dirname, '../../jizura-datasources'
  source_route    = njs_path.resolve home, 'data/leveldb'
  target_route    = njs_path.resolve home, 'data/leveldb-v2'
  # ### # # # # # # # # # # # # # # # # # # # # # ###
  # target_route    = '/tmp/leveldb-v2'; alert "using temp DB"
  # ### # # # # # # # # # # # # # # # # # # # # # ###
  target_db_size  = 1e6
  ds_options      = require njs_path.resolve home, 'options'
  source_db       = HOLLERITH.new_db source_route
  target_db       = HOLLERITH.new_db target_route, size: target_db_size, create: yes
  #.........................................................................................................
  ### TAINT this setting should come from Jizura DB options ###
  # solids          = [ 'guide/kwic/v3/sortcode', ]
  solids          = []
  #.........................................................................................................
  help "using DB at #{source_db[ '%self' ][ 'location' ]}"
  help "using DB at #{target_db[ '%self' ][ 'location' ]}"
  #.........................................................................................................
  step ( resume ) =>
    yield HOLLERITH.clear target_db, resume
    #.........................................................................................................
    factor_infos  = yield @read_factors source_db, resume
    help "read #{( Object.keys factor_infos ).length} entries for factor_infos"
    #.........................................................................................................
    # gte         = 'so|glyph:中'
    if ( CND.isa_list sample = options[ 'sample' ] ) and ( sample.length is 1 )
      gte         = "so|glyph:#{sample[ 0 ]}"
    else
      gte         = 'so|'
    lte         = @v1_lte_from_gte gte
    input       = source_db[ '%self' ].createKeyStream { gte, lte, }
    batch_size  = 1e4
    output      = HOLLERITH.$write target_db, { batch: batch_size, solids }
    #.........................................................................................................
    help "copying from  #{source_route}"
    help "to            #{target_route}"
    help "reading records with prefix #{rpr gte}"
    help "writing with batch size #{ƒ batch_size}"
    #.........................................................................................................
    input
      #.......................................................................................................
      .pipe @v1_$split_so_bkey()
      .pipe @$show_progress 1e4
      .pipe @$keep_small_sample()
      .pipe @$throw_out_pods()
      .pipe @$remove_duplicate_kana_readings()
      .pipe @$cast_types ds_options
      .pipe @$collect_lists()
      .pipe @$compact_lists()
      .pipe @$add_version_to_kwic_v1()
      .pipe @$add_kwic_v2()
      .pipe @$add_kwic_v3                 factor_infos
      .pipe @$add_kwic_v3_wrapped_lineups factor_infos
      # .pipe @$add_guide_pairs             factor_infos
      .pipe @$add_factor_membership       factor_infos
      .pipe @$add_sims()
      # .pipe D.$show()
      .pipe D.$count ( count ) -> help "kept #{ƒ count} phrases"
      .pipe D.$stop_time "copy Jizura DB"
      .pipe output


############################################################################################################
unless module.parent?
  @copy_jizura_db()
