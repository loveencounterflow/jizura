(function() {
  'use strict';
  var CND, alert, badge, debug, info, log, rpr, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/markdown-it-wall';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  module.exports = function(state, startLine, endLine, silent) {
    var haveEndMarker, len, marker, markup, max, mem, nextLine, params, pos, token;
    marker = void 0;
    len = void 0;
    params = void 0;
    nextLine = void 0;
    mem = void 0;
    token = void 0;
    markup = void 0;
    haveEndMarker = false;
    debug('©fa4Vl', 'WALL');
    pos = state.bMarks[startLine] + state.tShift[startLine];
    max = state.eMarks[startLine];
    if (pos + 3 > max) {
      return false;
    }
    marker = state.src.charCodeAt(pos);
    if (marker !== 0x40) {
      return false;
    }
    mem = pos;
    pos = state.skipChars(pos, marker);
    len = pos - mem;
    if (len < 3) {
      return false;
    }
    markup = state.src.slice(mem, pos);
    params = state.src.slice(pos, max);
    if (params.indexOf('@') >= 0) {
      return false;
    }
    if (silent) {
      return true;
    }
    nextLine = startLine;
    while (true) {
      nextLine++;
      if (nextLine >= endLine) {
        break;
      }
      pos = mem = state.bMarks[nextLine] + state.tShift[nextLine];
      max = state.eMarks[nextLine];
      CND.dir(state);
      if (pos < max && state.sCount[nextLine] < state.blkIndent) {
        break;
      }
      if (state.src.charCodeAt(pos) !== marker) {
        continue;
      }
      if (state.sCount[nextLine] - state.blkIndent >= 4) {
        continue;
      }
      pos = state.skipChars(pos, marker);
      if (pos - mem < len) {
        continue;
      }
      pos = state.skipSpaces(pos);
      if (pos < max) {
        continue;
      }
      haveEndMarker = true;
      break;
    }
    len = state.sCount[startLine];
    state.line = nextLine + (haveEndMarker ? 1 : 0);
    token = state.push('fence', 'code', 0);
    token.info = params;
    token.content = state.getLines(startLine + 1, nextLine, len, true);
    token.markup = markup;
    token.map = [startLine, state.line];
    return true;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/markdown-it-wall.js.map