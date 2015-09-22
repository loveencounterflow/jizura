


############################################################################################################
njs_path                  = require 'path'
# # njs_fs                    = require 'fs'
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
@main = ->
  db_route        = join __dirname, '../../jizura-datasources/data/leveldb-v2'
  db              = HOLLERITH.new_db db_route, create: no
  help "using DB at #{db[ '%self' ][ 'location' ]}"
  #.........................................................................................................
  step ( resume ) =>
    ranks         = {}
    include       = Infinity
    include       = 100
    # include       = [ '寿', '邦', '帮', '畴', '铸', '筹', '涛', '祷', '绑', '綁',    ]
    #.......................................................................................................
    sample        = yield @read_sample db, include, resume
    debug '©u2o8L', ( Object.keys sample ).join ' '
    #.......................................................................................................
    prefix        = [ 'pos', 'guide/has/uchr', ]
    query         = { prefix, }
    input         = HOLLERITH.create_phrasestream db, query
    #.......................................................................................................
    input.on 'end', -> help "ok"
    #.......................................................................................................
    input
      #.....................................................................................................
      .pipe D.$show()
    #   .pipe @v1_$split_so_bkey()
    #   .pipe @$show_progress 1e4
    #   .pipe @$keep_small_sample()
    #   .pipe @$throw_out_pods()
    #   .pipe @$cast_types ds_options
    #   .pipe @$collect_lists()
    #   .pipe @$compact_lists()
    #   .pipe @$add_version_to_kwic_v1()
    #   .pipe @$add_kwic_v2()
    #   .pipe @$add_kwic_v3 factor_infos
    #   .pipe D.$count ( count ) -> help "kept #{ƒ count} phrases"
    #   .pipe D.$stop_time "copy Jizura DB"
    #   .pipe output
    #.......................................................................................................
    return null

############################################################################################################
unless module.parent?
  @main()
