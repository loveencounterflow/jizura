# fences (``` lang, ~~~ lang)
'use strict'




############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/markdown-it-wall'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge


module.exports = (state, startLine, endLine, silent) ->
  marker = undefined
  len = undefined
  params = undefined
  nextLine = undefined
  mem = undefined
  token = undefined
  markup = undefined
  haveEndMarker = false
  debug '©fa4Vl', 'WALL'
  # CND.dir state
  pos = state.bMarks[startLine] + state.tShift[startLine]
  max = state.eMarks[startLine]
  if pos + 3 > max
    return false
  marker = state.src.charCodeAt(pos)

    # case 0x0A/* \n */:
    # case 0x21/* ! */:
    # case 0x23/* # */:
    # case 0x24/* $ */:
    # case 0x25/* % */:
    # case 0x26/* & */:
    # case 0x2A/* * */:
    # case 0x2B/* + */:
    # case 0x2D/* - */:
    # case 0x3A/* : */:
    # case 0x3C/* < */:
    # case 0x3D/* = */:
    # case 0x3E/* > */:
    # case 0x40/* @ */:
    # case 0x5B/* [ */:
    # case 0x5C/* \ */:
    # case 0x5D/* ] */:
    # case 0x5E/* ^ */:
    # case 0x5F/* _ */:
    # case 0x60/* ` */:
    # case 0x7B/* { */:
    # case 0x7D/* } */:
    # case 0x7E/* ~ */:

  # ### ~, ` ###
  # if marker != 0x7E and marker != 0x60
  if marker != 0x40 # @ #
    return false
  # scan marker length
  mem = pos
  pos = state.skipChars(pos, marker)
  len = pos - mem
  if len < 3
    return false
  markup = state.src.slice(mem, pos)
  params = state.src.slice(pos, max)
  if params.indexOf('@') >= 0
    return false
  # Since start is found, we can report success here in validation mode
  if silent
    return true
  # search end of block
  nextLine = startLine
  loop
    nextLine++
    if nextLine >= endLine
      # unclosed block should be autoclosed by end of document.
      # also block seems to be autoclosed by end of parent
      break
    pos = mem = state.bMarks[nextLine] + state.tShift[nextLine]
    max = state.eMarks[nextLine]
    CND.dir state
    if pos < max and state.sCount[nextLine] < state.blkIndent
      # non-empty line with negative indent should stop the list:
      # - ```
      #  test
      break
    if state.src.charCodeAt(pos) != marker
      continue
    if state.sCount[nextLine] - (state.blkIndent) >= 4
      # closing fence should be indented less than 4 spaces
      continue
    pos = state.skipChars(pos, marker)
    # closing code fence must be at least as long as the opening one
    if pos - mem < len
      continue
    # make sure tail has spaces only
    pos = state.skipSpaces(pos)
    if pos < max
      continue
    haveEndMarker = true
    # found!
    break
  # If a fence has heading spaces, they should be removed from its inner block
  len = state.sCount[startLine]
  state.line = nextLine + (if haveEndMarker then 1 else 0)
  token = state.push('fence', 'code', 0)
  token.info = params
  token.content = state.getLines(startLine + 1, nextLine, len, true)
  token.markup = markup
  token.map = [
    startLine
    state.line
  ]
  true

