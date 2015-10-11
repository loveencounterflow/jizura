





############################################################################################################
njs_path                  = require 'path'
# njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/tests'
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
# eventually                = suspend.eventually
### TAINT experimentally using `later` in place of `setImmediate` ###
later                     = suspend.immediately
#...........................................................................................................
test                      = require 'guy-test'
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
MKTS                      = require './MKTS'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse accepts dot patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '.',     [ '.', null,   null, ], ]
    [ '.p',    [ '.', 'p',    null, ], ]
    [ '.text', [ '.', 'text', null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.TRACKER.parse probe
    T.eq ( MKTS.TRACKER.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse accepts empty fenced patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '<>', [ '<', null, '>', ], ]
    [ '{}', [ '{', null, '}', ], ]
    [ '[]', [ '[', null, ']', ], ]
    [ '()', [ '(', null, ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.TRACKER.parse probe
    T.eq ( MKTS.TRACKER.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse accepts unfenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ 'document',       [ null, 'document',     null, ], ]
    [ 'singlecolumn',   [ null, 'singlecolumn', null, ], ]
    [ 'code',           [ null, 'code',         null, ], ]
    [ 'blockquote',     [ null, 'blockquote',   null, ], ]
    [ 'em',             [ null, 'em',           null, ], ]
    [ 'xxx',            [ null, 'xxx',          null, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.TRACKER.parse probe
    T.eq ( MKTS.TRACKER.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse accepts fenced named patterns" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '<document>',     [ '<', 'document',     '>', ], ]
    [ '{singlecolumn}', [ '{', 'singlecolumn', '}', ], ]
    [ '{code}',         [ '{', 'code',         '}', ], ]
    [ '[blockquote]',   [ '[', 'blockquote',   ']', ], ]
    [ '(em)',           [ '(', 'em',           ')', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # help ( rpr probe ), MKTS.TRACKER.parse probe
    T.eq ( MKTS.TRACKER.parse probe ), matcher
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse rejects empty string" ] = ( T, done ) ->
  T.throws "pattern must be non-empty, got ''", ( -> MKTS.TRACKER.parse '' )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.parse rejects non-matching fences etc" ] = ( T, done ) ->
  probes_and_matchers = [
    [ '(xxx}',  'fences don\'t match in pattern \'(xxx}\'',          ]
    [ '.)',     'fence \'.\' can not have right fence, got \'.)\'',  ]
    [ '.p)',    'fence \'.\' can not have right fence, got \'.p)\'', ]
    [ '.[',     'fence \'.\' can not have right fence, got \'.[\'',  ]
    [ '<',      'unmatched fence in \'<\'',                          ]
    [ '{',      'unmatched fence in \'{\'',                          ]
    [ '[',      'unmatched fence in \'[\'',                          ]
    [ '(',      'unmatched fence in \'(\'',                          ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    T.throws matcher, ( -> MKTS.TRACKER.parse probe )
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "MKTS.TRACKER.new_tracker (short comprehensive test)" ] = ( T, done ) ->
  track = MKTS.TRACKER.new_tracker '(code)', '{multi-column}'
  probes_and_matchers = [
    [ [ '<', 'document',     ], [  no,  no, ], ]
    [ [ '{', 'multi-column', ], [  no, yes, ], ]
    [ [ '(', 'code',         ], [ yes, yes, ], ]
    [ [ '{', 'multi-column', ], [ yes, yes, ], ]
    [ [ '.', 'text',         ], [ yes, yes, ], ]
    [ [ '}', 'multi-column', ], [ yes, yes, ], ]
    [ [ ')', 'code',         ], [  no, yes, ], ]
    [ [ '}', 'multi-column', ], [  no,  no, ], ]
    [ [ '>', 'document',     ], [  no,  no, ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    track probe
    whisper probe
    help '(code):', ( track.within '(code)' ), '{multi-column}:', ( track.within '{multi-column}' )
    T.eq ( track.within '(code)'          ), matcher[ 0 ]
    T.eq ( track.within '{multi-column}'  ), matcher[ 1 ]
  done()

#===========================================================================================================
# MAIN
#-----------------------------------------------------------------------------------------------------------
@_main = ( handler ) ->
  test @, 'timeout': 2500


############################################################################################################
unless module.parent?
  @_main()

