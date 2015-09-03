


############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/compare-cjkvi-ids'
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
illegal_component         = Symbol 'illegal_component'

#-----------------------------------------------------------------------------------------------------------
options =
  'comment-marks':              [ '#', ';', ]
  'cjkvi-ncr-kernel-pattern':   /^(?:(U)\+|(CDP)-)([0-9A-F]{4,5})$/
  'cjkvi-ncr-pattern':          /&([^;]+);/g
  'blank-line-tester':          /^\s*$/
  'known-ref-mismatches':
    '鿉鿈':                     '鿉'
  'cjvki-jzr-sims':
    'α':        '§'
    'ℓ':        '§'
    # '△':        '△'
    '①':        '〓'
    '②':        '〓'
    '③':        '〓'
    '④':        '〓'
    '⑤':        '〓'
    '⑥':        '〓'
    '⑦':        '〓'
    '⑧':        '〓'
    '⑨':        '〓'
    '⑩':        '〓'
    '⑪':        '〓'
    '⑫':        '〓'
    '⑬':        '〓'
    '⑭':        '〓'
    '⑮':        '〓'
    '⑯':        '〓'
    '⑰':        '〓'
    '⑱':        '〓'
    '⑲':        '〓'
    '⑳':        '〓'
    'い':        illegal_component
    'よ':        illegal_component
    'キ':        illegal_component
    'サ':        illegal_component



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
@read_global_sims = ( db, handler ) ->
  count = 0
  Z     = {}
  for source_glyph, target_glyph of options[ 'cjvki-jzr-sims' ]
    count            += +1
    Z[ source_glyph ] = target_glyph
  ### TAINT we schouldn't need `star: '*'` here, since the phrases concerned look like
  `[ 'pos', 'sim/global', '鼅', '&c3#x5c2f;' ]` ###
  # query = { prefix: [ 'pos', 'sim/global' ], }
  query = { prefix: [ 'pos', 'sim/global' ], star: '*', }
  input = HOLLERITH.create_phrasestream db, query
  input
    # .pipe D.$show()
    .pipe $ ( phrase, send ) =>
      [ _, _, target_glyph, source_glyph, ] = phrase
      Z[ source_glyph ]   = target_glyph
      count              += +1
      send source_glyph
    .pipe @$show_progress 1e4
    .pipe D.$on_end =>
      help "read global SIMs for #{ƒ count} glyphs"
      njs_fs.writeFileSync '/tmp/global-sims.json', JSON.stringify Z, null, '  '
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
@$filter_outer_mapped_and_unknown_glyphs_A = ( glyph_categories ) ->
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
@$filter_outer_mapped_and_unknown_glyphs_B = ( global_sims ) ->
  counts =
    'cp/inner/original':        0
    'cp/inner/mapped':          0
    'cp/outer/original':        0
    'cp/outer/mapped':          0
  unknown_non_cjk_xe = []
  #.........................................................................................................
  return $ ( fields, send, end ) =>
    #.......................................................................................................
    if fields?
      [ source_glyph, cjkvi_formulas, ] = fields
      csg                               = CHR.as_csg source_glyph, input: 'xncr'
      target_glyph                      = global_sims[ source_glyph ]
      if csg in [ 'u', 'jzr', ]
        if target_glyph? then category = 'cp/inner/mapped'
        else                  category = 'cp/inner/original'
      else
        if target_glyph? then category = 'cp/outer/mapped'
        else                  category = 'cp/outer/original'
      counts[ category ] += +1
      send [ source_glyph, cjkvi_formulas, ] if category is 'cp/inner/original'
    #.......................................................................................................
    if end?
      help "filtering counts:"
      help '\n' + rpr counts
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

#-----------------------------------------------------------------------------------------------------------
@normalize_formula = ( global_sims, formula ) =>
  chrs = CHR.chrs_from_text formula, input: 'xncr'
  for chr, idx in chrs
    chrs[ idx ] = new_chr = global_sims[ chr ] ? chr
    throw new Error "illegal component in formula #{rpr formula}" if new_chr is illegal_component
  return chrs.join ''

#-----------------------------------------------------------------------------------------------------------
@$normalize_formulas = ( global_sims ) ->
  counts =
    'jzr':      0
    'cjkvi':    0
  #.........................................................................................................
  return $ ( fields, send, end ) =>
    if fields?
      [ glyph, cjkvi_formulas, jzr_formulas, ] = fields
      #.....................................................................................................
      for formula, idx in cjkvi_formulas
        normalized_formula    = @normalize_formula global_sims, formula
        if normalized_formula isnt formula
          counts[ 'cjkvi' ]    += +1
          cjkvi_formulas[ idx ] = normalized_formula
      ### skipping JZR formulas since they're normalized already ###
      ###
      #.....................................................................................................
      for formula, idx in jzr_formulas
        normalized_formula    = @normalize_formula global_sims, formula
        if normalized_formula isnt formula
          counts[ 'jzr' ]      += +1
          jzr_formulas[ idx ]   = normalized_formula
      ###
      #.....................................................................................................
      send fields
    #.......................................................................................................
    if end?
      help "formula normalization counts:"
      help '\n' + rpr counts
      end()

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
    # glyph_categories = yield @read_glyph_categories db, resume
    global_sims = yield @read_global_sims db, resume
    input
      .pipe D.$split()
      .pipe @$filter_comments_and_empty_lines()
      # .pipe D.$sample 0.001, seed: 1
      .pipe D.$parse_csv headers: no, delimiter: '\t'
      .pipe @$resolve_cjkvi_kernel()
      .pipe @$normalize_cjkvi_ncrs()
      .pipe @$check_glyph_reference()
      .pipe @$show_progress 1e4
      # .pipe @$filter_outer_mapped_and_unknown_glyphs_A glyph_categories
      .pipe @$filter_outer_mapped_and_unknown_glyphs_B global_sims
      .pipe @$remove_region_annotations()
      .pipe @$retrieve_jzr_formulas db
      .pipe @$normalize_formulas global_sims
      .pipe @$compare_formulas()
      # .pipe D.$show()


############################################################################################################
unless module.parent?
  @compare()
