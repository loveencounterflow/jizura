

############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/cli'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND

#-----------------------------------------------------------------------------------------------------------
app       = require 'commander'
app_name  = process.argv[ 1 ]
app.version ( require '../package.json' )[ 'version' ]
is_tty    =

#-----------------------------------------------------------------------------------------------------------
get_do_stats = \
get_with_prefixes = \
get_uchrs = \
get_two_stats = \
get_boolean = ( input, fallback = false ) ->
  return fallback unless input?
  return input

#-----------------------------------------------------------------------------------------------------------
get_colors = ( input, is_tty, fallback = false ) ->
  return true if input?
  return if is_tty then true else false

#-----------------------------------------------------------------------------------------------------------
get_width = ( input, fallback = null ) ->
  return fallback unless input?
  return null if input in [ Infinity, 'full', 'infinity', 'Infinity', ]
  R = parseInt input, 10
  unless ( R is parseFloat input ) and ( CND.isa_number R ) and ( R >= 0 )
    throw new Error "expected non-negative integer number for width, got #{rpr input}"
  return R

#-----------------------------------------------------------------------------------------------------------
get_glyph_sample = ( input, fallback = Infinity ) ->
  return fallback unless input?
  return Infinity if input in [ Infinity, 'all', 'infinity', 'Infinity', ]
  return R if CND.isa_number ( R = parseInt input, 10 )
  return Array.from input

#-----------------------------------------------------------------------------------------------------------
get_factor_sample = ( input, fallback = null ) ->
  return fallback unless input?
  return Array.from input

#-----------------------------------------------------------------------------------------------------------
isa_folder = ( route ) ->
  try
    fstats = njs_fs.statSync route
  catch error
    return false if error.code is 'ENOENT'
    throw error
  return fstats.isDirectory()

# #-----------------------------------------------------------------------------------------------------------
# app
#   .command      "mkts <filename>"
#   .description  "typeset MD source in <filename>, output PDF"
#   #.........................................................................................................
#   .action ( filename ) ->
#     help ( CND.grey "#{app_name}" ), ( CND.gold 'mkts' ), ( CND.lime filename )
#     MKTS = require './mkts-typesetter-interim'
#     CND.dir MKTS
#     MKTS.pdf_from_md filename

#-----------------------------------------------------------------------------------------------------------
app
  .command      "repetitions"
  .description  "find repeated components in formulas or lineups"
  .option       "--lineups",  "look in lineups"
  .option       "--formulas", "look in formulas"
  #.........................................................................................................
  .action ( options ) ->
    #.......................................................................................................
    command   = options[ 'command' ]
    lineups   = options[ 'lineups'  ] ? false
    formulas  = options[ 'formulas' ] ? false
    #.......................................................................................................
    if ( not lineups ) and ( not formulas )
      throw new Error "must indicate source (--lineups, --formulas, or both)"
    #.......................................................................................................
    S = {
      command
      lineups
      formulas
      }
    #.......................................................................................................
    help ( CND.grey "#{app_name}" ), ( CND.gold 'repetitions' )
    SRF = require './show-repeated-factors'
    SRF.show_repeated_factors S

#-----------------------------------------------------------------------------------------------------------
app
  .command      "formulas"
  .description  "dump formulas for glyphs"
  .option       "-g, --glyphs [glyphs]",     "glyphs to be searched for"
  .option       "-c, --colors",              "use colors even when redirecting to file [false]"
  .option       "-u, --uchrs",               "use characters instead of NCRs for PUA codepoints [false]"
  .option       "-i, --noidcs",              "omit IDCs [false]"
  .option       "-s, --sort",                "sort results by CID [false]"
  #.........................................................................................................
  .action ( options ) ->
    XNCHR   = require './XNCHR'
    DFFG    = require './dump-formulas-for-glyphs'
    glyphs  = XNCHR.chrs_from_text  options[ 'glyphs' ] ? ''
    colors  = get_colors            options[ 'colors' ], process.stdout.isTTY
    uchrs   = get_uchrs             options[ 'uchrs' ]
    noidcs  = get_uchrs             options[ 'noidcs' ]
    sort    = get_boolean           options[ 'sort' ], false
    #.......................................................................................................
    S = {
      glyphs
      colors
      uchrs
      noidcs
      sort
      }
    #.......................................................................................................
    help ( CND.grey "#{app_name}" ), ( CND.gold 'formulas' ), ( CND.lime glyphs.join '' )
    DFFG.dump_formulas S

#-----------------------------------------------------------------------------------------------------------
app
  .command      "consolidate-formulas"
  .description  """
    consolidate formulas from `shape-breakdown-formula.txt`
                                   and `shape-breakdown-formula-corrections.txt` into new
                                   source file `shape-breakdown-formula-merged.txt`. Notice
                                   that the formulas in `shape-breakdown-formula-naive.txt`
                                   will *not* be merged."""
  #.........................................................................................................
  .action ( glyphs ) ->
    COCF = require './consolidate-original-and-corrected-formulas'
    #.......................................................................................................
    S = {}
    #.......................................................................................................
    help ( CND.grey "#{app_name}" ), ( CND.gold 'consolidate-formulas' )
    COCF.consolidate_formulas S

#-----------------------------------------------------------------------------------------------------------
app
  #.........................................................................................................
  .command      "kwic [output_route]"
  .description  """
    render (excerpt of) KWIC index (to
                                   output_route where given; must be a folder)"""
  .option       "-s, --stats",              "show KWIC infix statistics [false]"
  .option       "-p, --prefixes",           "infix statistics to include prefixes (only with -s) [false]"
  .option       "-2, --two",                "separate prefix and suffix stats (only with -sp) [false]"
  .option       "-w, --width [count]",      "maximum number of glyphs in infix statistics [full]"
  .option       "-g, --glyphs [glyphs]",    "which glyphs to include"
  .option       "-f, --factors [factors]",  "which factors to include"
  #.........................................................................................................
  .action ( output_route, options ) ->
    help ( CND.white "#{app_name}" ), ( CND.gold 'kwic' )#, ( CND.lime glyphs_route )
    #.......................................................................................................
    do_stats                    = get_do_stats      options[ 'stats'    ]
    with_prefixes               = get_with_prefixes options[ 'prefixes' ]
    two_stats                   = get_two_stats     options[ 'two'      ]
    width                       = get_width         options[ 'width'    ]
    glyph_sample                = get_glyph_sample  options[ 'glyphs'   ]
    factor_sample               = get_factor_sample options[ 'factors'  ]
    output_route               ?= null
    glyphs_route                = null
    glyphs_description_route    = null
    stats_route                 = null
    stats_description_route     = null
    #.......................................................................................................
    if with_prefixes and not do_stats
      throw new Error "switch -p (--prefixes) only valid with -s (--stats)"
    if two_stats and not ( do_stats and with_prefixes )
      throw new Error "switch -2 only valid with -sp (--prefixes and --stats)"
    #.......................................................................................................
    if glyph_sample is Infinity         then glyph_sample_key = 'all'
    else if CND.isa_number glyph_sample then glyph_sample_key = rpr glyph_sample
    else                                     glyph_sample_key = glyph_sample.join ''
    key = [ "g.#{glyph_sample_key}", ]
    key.push "f.#{factor_sample.join ''}" if factor_sample?
    if      do_stats and with_prefixes and two_stats  then key.push "sp2"
    else if do_stats and with_prefixes                then key.push "sp"
    else if do_stats                                  then key.push "s"
    key.push "w.#{width}" if width?
    key = key.join '-'
    key = "kwic-#{CND.id_from_text key, 4}-#{key}"
    #.......................................................................................................
    if output_route?
      output_route  = njs_path.resolve process.cwd(), output_route
      throw new Error "#{output_route}:\nnot a folder" unless isa_folder output_route
      glyphs_route              = njs_path.join output_route, "#{key}-glyphs.md"
      glyphs_description_route  = njs_path.join output_route, "#{key}-glyphs-description.md"
      if do_stats
        stats_route             = njs_path.join output_route, "#{key}-stats.md"
        stats_description_route = njs_path.join output_route, "#{key}-stats-description.md"
    #.......................................................................................................
    help "key for this collection is #{key}"
    if output_route? then   help "KWIC index will be written to #{glyphs_route}"
    if stats_route? then    help "statistics will be written to #{stats_route}"
    help "glyph_sample is #{rpr glyph_sample}"
    if factor_sample? then  help "factors: #{factor_sample.join ''}"
    else                    help "all factors will be included"
    #.......................................................................................................
    S = {
      command: 'kwic'
      glyph_sample
      factor_sample
      output_route
      glyphs_route
      stats_route
      glyphs_description_route
      stats_description_route
      do_stats
      with_prefixes
      two_stats
      width
      key                       }
    #.......................................................................................................
    SHOW_KWIC_V3 = require './show-kwic-v3'
    SHOW_KWIC_V3.show_kwic_v3 S


############################################################################################################
# app.on '--help', -> info "here's the rundown"
app.parse process.argv

unless app.args?.length > 0
  warn "missing arguments"
  app.help()


