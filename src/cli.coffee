

############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
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
# #...........................................................................................................
# ƒ                         = CND.format_number.bind CND
# HELPERS                   = require './HELPERS'
# # options                   = require './options'
# TEXLIVEPACKAGEINFO        = require './TEXLIVEPACKAGEINFO'
# options_route             = '../options.coffee'
# { CACHE, OPTIONS, }       = require './OPTIONS'
# SEMVER                    = require 'semver'
# #...........................................................................................................
# MKTS                      = require './MKTS'


###

app       = require 'commander'
app_name  = process.argv[ 1 ]

app
  .version ( require '../package.json' )[ 'version' ]
  .command 'mkts <filename>'
  .action ( filename ) ->
    help ( CND.grey "#{app_name}" ), ( CND.gold 'mkts' ), ( CND.lime filename )
    MKTS = require './mkts-typesetter-interim'
    CND.dir MKTS
    MKTS.pdf_from_md filename

app.parse process.argv
# debug '©nES6R', process.argv

###


#-----------------------------------------------------------------------------------------------------------
app       = require 'commander'
app_name  = process.argv[ 1 ]
app.version ( require '../package.json' )[ 'version' ]

#-----------------------------------------------------------------------------------------------------------
get_stats_route = ( input, fallback = null ) ->
  return fallback unless input?
  return input

#-----------------------------------------------------------------------------------------------------------
get_glyph_sample = ( input, fallback = 1000 ) ->
  return fallback unless input?
  return Infinity if input in [ Infinity, 'all', 'infinity', 'Infinity', ]
  return R if CND.isa_number ( R = parseInt input, 10 )
  return Array.from input

#-----------------------------------------------------------------------------------------------------------
get_factor_sample = ( input, fallback = null ) ->
  return fallback unless input?
  return Array.from input

#-----------------------------------------------------------------------------------------------------------
app
  .command      "mkts <filename>"
  .description  "typeset MD source in <filename>, output PDF"
  #.........................................................................................................
  .action ( filename ) ->
    help ( CND.grey "#{app_name}" ), ( CND.gold 'mkts' ), ( CND.lime filename )
    MKTS = require './mkts-typesetter-interim'
    CND.dir MKTS
    MKTS.pdf_from_md filename

#-----------------------------------------------------------------------------------------------------------
app
  #.........................................................................................................
  .command      "kwic <output_route>"
  .description  "render (excerpt of) KWIC index to <output_route>"
  .option       "-s --stats [stats-filename]",  "render KWIC infix statistics"
  .option       "-g --glyphs [glyphs]",         "which glyphs to include"
  .option       "-f --factors [factors]",       "which factors to include"
  #.........................................................................................................
  .action ( output_route, options ) ->
    help ( CND.white "#{app_name}" ), ( CND.gold 'kwic' )#, ( CND.lime kwic_route )
    #.......................................................................................................
    stats_route     = get_stats_route   options.stats
    glyph_sample    = get_glyph_sample  options.glyphs
    factor_sample   = get_factor_sample options.factors
    #.......................................................................................................
    help "KWIC index will be written to #{output_route}"
    if stats_route? then    help "statistics will be written to #{stats_route}"
    else                    help "no statistics will be written"
    help "glyph_sample is #{rpr glyph_sample}"
    if factor_sample? then  help "factors: #{factor_sample.join ''}"
    else                    help "all factors will be included"
    #.......................................................................................................
    S = { glyph_sample, factor_sample, output_route, stats_route, }
    #.......................................................................................................
    SHOW_KWIC_V3 = require './show-kwic-v3'
    SHOW_KWIC_V3.show_kwic_v3 S


############################################################################################################
# app.on '--help', -> info "here's the rundown"
app.parse process.argv
unless app.args?.length > 0
  warn "missing arguments"
  app.help()
