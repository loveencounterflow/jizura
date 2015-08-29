


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'HOLLERITH/copy'
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
# DEMO                      = require './demo'
CHR                       = require 'coffeenode-chr'
ƒ                         = CND.format_number.bind CND

#-----------------------------------------------------------------------------------------------------------
options =
  # sample:         null
  # sample:         [ '疈', '國', '𠵓', ]
  # sample:         [ '𡬜', '國', '𠵓', ]

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
  return D.$observe ( _, has_ended ) =>
    unless has_ended
      phrase_count += 1
      echo ƒ phrase_count if phrase_count % size is 0
    else
      help "read #{ƒ phrase_count} records"

# #-----------------------------------------------------------------------------------------------------------
# @$keep_small_sample = ->
#   return $ ( key, send ) =>
#     return send key unless options[ 'sample' ]?
#     [ glyph, prd, obj, idx, ] = key
#     send key if glyph in options[ 'sample' ]

# #-----------------------------------------------------------------------------------------------------------
# @$throw_out_pods = ->
#   return $ ( key, send ) =>
#     [ glyph, prd, obj, idx, ] = key
#     send key unless prd is 'pod'

# #-----------------------------------------------------------------------------------------------------------
# @$cast_types = ( ds_options ) ->
#   return $ ( [ sbj, prd, obj, idx, ], send ) =>
#     type_description = ds_options[ 'schema' ][ prd ]
#     unless type_description?
#       warn "no type description for predicate #{rpr prd}"
#     else
#       switch type = type_description[ 'type' ]
#         when 'int'
#           obj = parseInt obj, 10
#         when 'text'
#           ### TAINT we have no booleans configured ###
#           if      obj is 'true'   then obj = true
#           else if obj is 'false'  then obj = false
#     send if idx? then [ sbj, prd, obj, idx, ] else [ sbj, prd, obj, ]

# #-----------------------------------------------------------------------------------------------------------
# @$collect_lists = ->
#   objs          = null
#   sbj_prd       = null
#   last_digest   = null
#   context_keys  = []
#   has_errors    = false
#   #.........................................................................................................
#   return $ ( key, send, end ) =>
#     #.......................................................................................................
#     if key?
#       context_keys.push key; context_keys.shift() if context_keys.length > 10
#       [ sbj, prd, obj, idx, ] = key
#       digest                  = JSON.stringify [ sbj, prd, ]
#       #.....................................................................................................
#       if digest is last_digest
#         if idx?
#           objs[ idx ] = obj
#         else
#           ### A certain subject/predicate combination can only ever be repeated if an index is
#           present in the key ###
#           alert()
#           alert "erroneous repeated entry; context:"
#           alert context_keys
#           has_errors = true
#       else
#         send [ sbj_prd..., objs, ] if objs?
#         objs            = null
#         last_digest     = digest
#         if idx?
#           objs            = []
#           objs[ idx ]     = obj
#           sbj_prd         = [ sbj, prd, ]
#         else
#           send key
#     #.......................................................................................................
#     if end?
#       send [ sbj_prd..., objs, ] if objs?
#       return send.error new Error "there were errors; see alerts above" if has_errors
#       end()
#     #.......................................................................................................
#     return null

# #-----------------------------------------------------------------------------------------------------------
# @$compact_lists = ->
#   return $ ( [ sbj, prd, obj, ], send ) =>
#     ### Compactify sparse lists so all `undefined` elements are removed; warn about this ###
#     if ( CND.type_of obj ) is 'list'
#       new_obj = ( element for element in obj when element isnt undefined )
#       if obj.length isnt new_obj.length
#         warn "phrase #{rpr [ sbj, prd, obj, ]} contained undefined elements; compactified"
#       obj = new_obj
#     send [ sbj, prd, obj, ]

# #-----------------------------------------------------------------------------------------------------------
# @$add_version_to_kwic_v1 = ->
#   ### mark up all predicates `guide/kwic/*` as `guide/kwic/v1/*` ###
#   return $ ( [ sbj, prd, obj, ], send ) =>
#     if prd.startsWith 'guide/kwic/'
#       prd = prd.replace /^guide\/kwic\//, 'guide/kwic/v1/'
#     send [ sbj, prd, obj, ]

# #-----------------------------------------------------------------------------------------------------------
# @_long_wrapped_lineups_from_guides = ( guides ) ->
#   ### Extending lineups to accommodate for glyphs with 'overlong' factorials (those with more than 6
#   factors; these were previously excluded from the gamut in `feed-db.coffee`, line 2135,
#   `@KWIC.$compose_lineup_facets`). ###
#   ### TAINT here be magic numbers ###
#   lineup      = guides[ .. ]
#   last_idx    = lineup.length - 1 + 6
#   lineup.push    '\u3000' while lineup.length < 19
#   lineup.unshift '\u3000' while lineup.length < 25
#   R           = []
#   for idx in [ 6 .. last_idx ]
#     infix   = lineup[ idx ]
#     suffix  = lineup[ idx + 1 .. idx + 6 ].join ''
#     prefix  = lineup[ idx - 6 .. idx - 1 ].join ''
#     R.push [ infix, suffix, prefix, ].join ','
#   return R

# #-----------------------------------------------------------------------------------------------------------
# @$add_kwic_v2 = ->
#   ### see `demo/show_kwic_v2_and_v3_sample` ###
#   last_glyph            = null
#   long_wrapped_lineups  = null
#   return $ ( [ sbj, prd, obj, ], send ) =>
#     #.......................................................................................................
#     if prd is 'guide/has/uchr'
#       last_glyph            = sbj
#       long_wrapped_lineups  = @_long_wrapped_lineups_from_guides obj
#     #.......................................................................................................
#     return send [ sbj, prd, obj, ] unless prd.startsWith 'guide/kwic/v1/'
#     #.......................................................................................................
#     switch prd.replace /^guide\/kwic\/v1\//, ''
#       when 'lineup/wrapped/infix', 'lineup/wrapped/prefix', 'lineup/wrapped/suffix', 'lineup/wrapped/single'
#         ### copy to target ###
#         send [ sbj, prd, obj, ]
#       when 'sortcode'
#         [ glyph, _, sortcodes_v1, ] = [ sbj, prd, obj, ]
#         sortcodes_v2                = []
#         #...................................................................................................
#         ### The difference between KWIC sortcodes of version 1 and version 2 lies in the re-arrangement
#         of the factor codes and the index codes. In v1, the index codes appeared interspersed with
#         the factor codes; in v2, the index codes come up front and the index codes come in the latter half
#         of the sortcode strings. The effect of this rearrangement is that now that all of the indexes
#         (which indicate the position of each factor in the lineup) are weaker than any of the factor codes,
#         like sequences of factor codes (and, therefore, factors) will always be grouped together (whereas
#         in v1, only like factors with like positions appeared together, and often like sequences appeared
#         with other sequences interspersed where their indexes demanded it so). ###
#         for sortcode_v1 in sortcodes_v1
#           sortrow_v1 = ( x for x in sortcode_v1.split /(........,..),/ when x.length > 0 )
#           sortrow_v1 = ( x.split ',' for x in sortrow_v1 )
#           sortrow_v2 = []
#           sortrow_v2.push sortcode for [ sortcode, _, ] in sortrow_v1
#           sortrow_v2.push position for [ _, position, ] in sortrow_v1
#           sortcodes_v2.push sortrow_v2.join ','
#         #...................................................................................................
#         unless glyph is last_glyph
#           return send.error new Error "unexpected mismatch: #{rpr glyph}, #{rpr last_glyph}"
#         #...................................................................................................
#         unless long_wrapped_lineups?
#           return send.error new Error "missing long wrapped lineups for glyph #{rpr glyph}"
#         #...................................................................................................
#         unless sortcodes_v2.length is long_wrapped_lineups.length
#           warn 'sortcodes_v2:         ', sortcodes_v2
#           warn 'long_wrapped_lineups: ', long_wrapped_lineups
#           return send.error new Error "length mismatch for glyph #{rpr glyph}"
#         #...................................................................................................
#         sortcodes_v1[ idx ] += ";" + lineup for lineup, idx in long_wrapped_lineups
#         sortcodes_v2[ idx ] += ";" + lineup for lineup, idx in long_wrapped_lineups
#         send [ glyph, 'guide/kwic/v2/lineup/wrapped/single', long_wrapped_lineups, ]
#         long_wrapped_lineups  = null
#         #...................................................................................................
#         send [ glyph, prd, sortcodes_v1, ]
#         send [ glyph, 'guide/kwic/v2/sortcode', sortcodes_v2, ]
#       else
#         send.error new Error "unhandled predicate #{rpr prd}"

# #-----------------------------------------------------------------------------------------------------------
# @$add_kwic_v3 = ( factor_infos ) ->
#   ### see `demo/show_kwic_v2_and_v3_sample` ###
#   #.........................................................................................................
#   return $ ( [ sbj, prd, obj, ], send ) =>
#     send [ sbj, prd, obj, ]
#     return unless prd is 'guide/kwic/v1/sortcode'
#     #.......................................................................................................
#     [ glyph, _, [ sortcode_v1, ... ], ] = [ sbj, prd, obj, ]
#     #.......................................................................................................
#     sortrow_v1    = ( x for x in sortcode_v1.split /(........,..),/ when x.length > 0 )
#     weights       = ( x.split ',' for x in sortrow_v1 )
#     weights.pop()
#     weights       = ( sortcode for [ sortcode, _, ] in weights )
#     weights       = ( sortcode for sortcode in weights when sortcode isnt '--------' )
#     weights       = ( ( sortcode.replace    /~/g, '-'    ) for sortcode in weights )
#     weights       = ( ( sortcode.replace /----/g, 'f---' ) for sortcode in weights )
#     #.......................................................................................................
#     factors       = ( factor_infos[ sortcode ] for sortcode in weights )
#     factors       = ( ( if factor? then factor else '〓' ) for factor in factors )
#     #.......................................................................................................
#     unless weights.length is factors.length
#       warn glyph, weights, factors, weights.length, factors.length
#       return
#     #.......................................................................................................
#     permutations = KWIC.get_permutations factors, weights
#     send [ glyph, 'guide/kwic/v3/sortcode', permutations, ]

# #-----------------------------------------------------------------------------------------------------------
# @v1_split_so_bkey = ( bkey ) ->
#   R       = bkey.toString 'utf-8'
#   R       = R.split '|'
#   idx_txt = R[ 3 ]
#   R       = [ ( R[ 1 ].split ':' )[ 1 ], ( R[ 2 ].split ':' )..., ]
#   R.push ( parseInt idx_txt, 10 ) if idx_txt? and idx_txt.length > 0
#   for r, idx in R
#     continue unless CND.isa_text r
#     continue unless 'µ' in r
#     R[ idx ] = @v1_unescape r
#   return R

# #-----------------------------------------------------------------------------------------------------------
# @v1_$split_so_bkey = -> $ ( bkey, send ) => send @v1_split_so_bkey bkey

# #-----------------------------------------------------------------------------------------------------------
# @v1_lte_from_gte = ( gte ) ->
#   R = new Buffer ( last_idx = Buffer.byteLength gte ) + 1
#   R.write gte
#   R[ last_idx ] = 0xff
#   return R

# #-----------------------------------------------------------------------------------------------------------
# @v1_unescape = ( text_esc ) ->
#   matcher = /µ([0-9a-f]{2})/g
#   return text_esc.replace matcher, ( _, cid_hex ) ->
#     return String.fromCharCode parseInt cid_hex, 16

# #-----------------------------------------------------------------------------------------------------------
# @read_factors = ( db, handler ) ->
#   #.........................................................................................................
#   Z         = {}
#   #.......................................................................................................
#   gte         = 'os|factor/sortcode'
#   lte         = @v1_lte_from_gte gte
#   input       = db[ '%self' ].createKeyStream { gte, lte, }
#   XNCHR       = require '../../jizura-datasources/lib/XNCHR'
#   #.......................................................................................................
#   input
#     .pipe @v1_$split_so_bkey()
#     .pipe D.$observe ( [ sortcode, _, factor, ] ) =>
#       Z[ sortcode ] = XNCHR.as_uchr factor
#     .pipe D.$on_end -> handler null, Z


#-----------------------------------------------------------------------------------------------------------
options =
  'comment-marks':              [ '#', ';', ]
  'cjkvi-ncr-kernel-pattern':   /^(?:(U)\+|(CDP)-)([0-9A-F]{4,5})$/
  'cjkvi-ncr-pattern':          /&([^;]+);/g
  'blank-line-tester':          /^\s*$/
  'known-ref-mismatches':
    '鿉鿈':                     '鿉'

#-----------------------------------------------------------------------------------------------------------
@read_glyph_categories = ( db, handler ) ->
  Z     = {}
  count = 0
  query = { prefix: [ 'pos', 'cp/' ], star: '*', }
  input = HOLLERITH.create_phrasestream db, query
  input
    # .pipe D.$show()
    .pipe $ ( phrase, send ) =>
      [ _, prd, _, glyph, ] = phrase
      if prd in [ 'cp/inner/original', 'cp/inner/mapped', 'cp/outer/original', 'cp/outer/mapped', ]
        Z[ glyph ]  = prd
        count      += +1
        send glyph
    .pipe @$show_progress 1e4
    .pipe D.$on_end =>
      help "read categories for #{ƒ count} glyphs"
      njs_fs.writeFileSync '/tmp/glyph-categories.json', JSON.stringify Z, null, '  '
      handler null, Z

#-----------------------------------------------------------------------------------------------------------
@$filter_comments_and_empty_lines = ->
  return $ ( line, send ) =>
    if ( options[ 'blank-line-tester' ].test line ) or line[ 0 ] in options[ 'comment-marks' ]
      null # warn line
    else
      send line

#-----------------------------------------------------------------------------------------------------------
@chr_from_cjkvi_ncr_kernel = ( cjkvi_ncr_kernel ) ->
  match = cjkvi_ncr_kernel.match options[ 'cjkvi-ncr-kernel-pattern' ]
  unless match?
    throw new Error "unexpected CJVKI NCR kernel: #{rpr cjkvi_ncr_kernel}"
  else
    csg = ( match[ 1 ] ? match[ 2 ] ).toLowerCase()
    cid = parseInt match[ 3 ], 16
    return CHR._as_chr csg, cid

#-----------------------------------------------------------------------------------------------------------
@$resolve_cjkvi_kernel = ->
  return $ ( fields, send ) =>
    return if fields.length is 0
    [ cjkvi_ncr_kernel, glyph, cjkvi_formulas..., ] = fields
    glyph_reference = @chr_from_cjkvi_ncr_kernel cjkvi_ncr_kernel
    send [ glyph_reference, glyph, cjkvi_formulas..., ]

#-----------------------------------------------------------------------------------------------------------
@$normalize_cjkvi_ncrs = ->
  pattern = options[ 'cjkvi-ncr-pattern' ]
  return $ ( fields, send ) =>
    for field_idx in [ 1 ... fields.length ]
      fields[ field_idx ] = fields[ field_idx ].replace pattern, ( $0, $1 ) =>
        return @chr_from_cjkvi_ncr_kernel $1
    send fields

#-----------------------------------------------------------------------------------------------------------
@$check_glyph_reference = ->
  return $ ( fields, send ) =>
    [ glyph_reference, glyph, cjkvi_formulas..., ] = fields
    unless glyph_reference is glyph
      key         = glyph_reference + glyph
      replacement = options[ 'known-ref-mismatches' ][ key ]
      unless replacement?
        warn "unknown glyph reference mismatch: #{rpr glyph_reference}, #{rpr glyph}"
      glyph = replacement
    send [ glyph, cjkvi_formulas, ]

#-----------------------------------------------------------------------------------------------------------
@$filter_outer_mapped_and_unknown_glyphs = ( glyph_categories ) ->
  counts =
    'unknown':                  0
    'cp/inner/original':        0
    'cp/inner/mapped':          0
    'cp/outer/original':        0
    'cp/outer/mapped':          0
  unknown_non_cjk_xe = []
  #.........................................................................................................
  return $ ( fields, send, end ) =>
    #.......................................................................................................
    if fields?
      [ glyph, cjkvi_formulas, ]  = fields
      category                    = glyph_categories[ glyph ] ? 'unknown'
      counts[ category ]         += +1
      rsg = CHR.as_rsg glyph, input: 'xncr'
      if category is 'unknown' and not ( rsg in [ 'cdp', 'u-cjk-xe', ] )
        fncr = CHR.as_fncr glyph, input: 'xncr'
        unknown_non_cjk_xe.push "glyph #{fncr} #{glyph}"
      send [ glyph, cjkvi_formulas, ] if category is 'cp/inner/original'
    #.......................................................................................................
    if end?
      help "filtering counts:"
      help '\n' + rpr counts
      help()
      help "of the #{ƒ counts[ 'unknown' ]} unknown codepoints,"
      help "#{ƒ unknown_non_cjk_xe.length} are *not* from Unicode V8 CJK Ext. E:"
      help '\n' + rpr unknown_non_cjk_xe
      end()

#-----------------------------------------------------------------------------------------------------------
@$remove_region_annotations = ->
  return $ ( fields, send ) =>
    [ glyph, cjkvi_formulas, ]    = fields
    for formula, idx in cjkvi_formulas
      cjkvi_formulas[ idx ] = formula.replace /\[[^\]]+\]/g, ''
    send [ glyph, cjkvi_formulas, ]
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@$retrieve_jzr_formulas = ( db ) ->
  return $async ( fields, done ) =>
    step ( resume ) =>
      [ glyph, cjkvi_formulas, ]    = fields
      prefix                        = [ 'spo', glyph, 'formula', ]
      query                         = { prefix: prefix, fallback: [ null, null, null, [], ], }
      phrase                        = yield HOLLERITH.read_one_phrase db, query, resume
      [ _, _, _, jzr_formulas, ]    = phrase
      done [ glyph, cjkvi_formulas, jzr_formulas, ]
  #.........................................................................................................
  return R

# #-----------------------------------------------------------------------------------------------------------
# @$retrieve_jzr_formulas = ( db ) ->
#   R = D.create_throughstream()
#   R
#     .pipe $async ( fields, done ) =>
#       step ( resume ) =>
#         [ glyph, cjkvi_formulas, ]    = fields
#         prefix                        = [ 'spo', glyph, 'formula', ]
#         query                         = { prefix: prefix, fallback: [ null, null, null, [], ], }
#         phrase                        = yield HOLLERITH.read_one_phrase db, query, resume
#         [ _, _, _, jzr_formulas, ]    = phrase
#         done [ glyph, cjkvi_formulas, jzr_formulas, ]
#     .pipe D.$on_end =>
#       debug '©VUMHz', 'ok'
#   #.........................................................................................................
#   return R

#-----------------------------------------------------------------------------------------------------------
@$compare_formulas = ->
  glyph_count   = 0
  diff_count    = 0
  missing_count = 0
  #.........................................................................................................
  return $ ( fields, send, end ) =>
    #.......................................................................................................
    if fields?
      [ glyph, cjkvi_formulas, jzr_formulas, ] = fields
      glyph_count += +1
      if jzr_formulas.length is 0
        fncr = CHR.as_fncr glyph, input: 'xncr'
        warn "no formulas found for glyph #{fncr} #{glyph}"
        missing_count += +1
      else
        for cjkvi_formula in cjkvi_formulas
          ### Skip identity formulas like `X = X` which we express as `X = ●` ###
          continue if cjkvi_formula is glyph
          if not ( cjkvi_formula in jzr_formulas )
            fncr = CHR.as_fncr glyph, input: 'xncr'
            diff_count += +1
            echo 'difference:', "#{fncr} #{glyph} #{cjkvi_formula} #{rpr jzr_formulas}"
    #.......................................................................................................
    if end?
      help "differences in formulas:"
      help "glyphs:             #{ƒ glyph_count}"
      help "missing formulas:   #{ƒ missing_count}"
      help "different formulas: #{ƒ diff_count}"
      end()

#-----------------------------------------------------------------------------------------------------------
@compare = ->
  home            = join __dirname, '../../jizura-datasources'
  cjkvi_route     = join home, 'data/flat-files/shape/github.com´cjkvi´cjkvi-ids/ids.txt'
  input           = njs_fs.createReadStream cjkvi_route
  #.........................................................................................................
  db_route        = join home, 'data/leveldb-v2'
  db              = HOLLERITH.new_db db_route
  #.........................................................................................................
  step ( resume ) =>
    glyph_categories = yield @read_glyph_categories db, resume
    input
      .pipe D.$split()
      .pipe @$filter_comments_and_empty_lines()
      # .pipe D.$sample 0.01, seed: 1
      .pipe D.$parse_csv headers: no, delimiter: '\t'
      .pipe @$resolve_cjkvi_kernel()
      .pipe @$normalize_cjkvi_ncrs()
      .pipe @$check_glyph_reference()
      .pipe @$show_progress 1e4
      .pipe @$filter_outer_mapped_and_unknown_glyphs glyph_categories
      .pipe @$remove_region_annotations()
      .pipe @$retrieve_jzr_formulas db
      .pipe @$compare_formulas()
      # .pipe D.$show()

  # source_route    = join home, 'data/leveldb'
  # target_route    = join home, 'data/leveldb-v2'
  # # target_route    = '/tmp/leveldb-v2'
  # target_db_size  = 1e6
  # ds_options      = require join home, 'options'
  # source_db       = HOLLERITH.new_db source_route
  # target_db       = HOLLERITH.new_db target_route, size: target_db_size, create: yes
  # #.........................................................................................................
  # ### TAINT this setting should come from Jizura DB options ###
  # # solids          = [ 'guide/kwic/v3/sortcode', ]
  # solids          = []
  # #.........................................................................................................
  # help "using DB at #{source_db[ '%self' ][ 'location' ]}"
  # help "using DB at #{target_db[ '%self' ][ 'location' ]}"
  # #.........................................................................................................
  # step ( resume ) =>
  #   yield HOLLERITH.clear target_db, resume
  #   #.........................................................................................................
  #   factor_infos  = yield @read_factors source_db, resume
  #   help "read #{( Object.keys factor_infos ).length} entries for factor_infos"
  #   #.........................................................................................................
  #   # gte         = 'so|glyph:中'
  #   # gte         = 'so|glyph:覆'
  #   gte         = 'so|'
  #   lte         = @v1_lte_from_gte gte
  #   input       = source_db[ '%self' ].createKeyStream { gte, lte, }
  #   batch_size  = 1e4
  #   output      = HOLLERITH.$write target_db, { batch: batch_size, solids }
  #   #.........................................................................................................
  #   help "copying from  #{source_route}"
  #   help "to            #{target_route}"
  #   help "reading records with prefix #{rpr gte}"
  #   help "writing with batch size #{ƒ batch_size}"
  #   #.........................................................................................................
  #   input
  #     #.......................................................................................................
  #     .pipe @v1_$split_so_bkey()
  #     .pipe @$show_progress 1e4
  #     .pipe @$keep_small_sample()
  #     .pipe @$throw_out_pods()
  #     .pipe @$cast_types ds_options
  #     .pipe @$collect_lists()
  #     .pipe @$compact_lists()
  #     .pipe @$add_version_to_kwic_v1()
  #     .pipe @$add_kwic_v2()
  #     .pipe @$add_kwic_v3 factor_infos
  #     # .pipe D.$show()
  #     .pipe D.$count ( count ) -> help "kept #{ƒ count} phrases"
  #     .pipe D.$stop_time "copy Jizura DB"
  #     .pipe output


############################################################################################################
unless module.parent?
  @compare()
