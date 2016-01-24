(function() {
  var $, $async, CND, D, MKTS, after, alert, badge, debug, echo, help, info, join, later, log, njs_path, rpr, step, suspend, test, urge, warn, whisper;

  njs_path = require('path');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/tests';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  suspend = require('coffeenode-suspend');

  step = suspend.step;

  after = suspend.after;


  /* TAINT experimentally using `later` in place of `setImmediate` */

  later = suspend.immediately;

  test = require('guy-test');

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  MKTS = require('./MKTS');

  this["MKTS.FENCES.parse accepts dot patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['.', ['.', null, null]], ['.p', ['.', 'p', null]], ['.text', ['.', 'text', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts empty fenced patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<>', ['<', null, '>']], ['{}', ['{', null, '}']], ['[]', ['[', null, ']']], ['()', ['(', null, ')']]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts unfenced named patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['document', [null, 'document', null]], ['singlecolumn', [null, 'singlecolumn', null]], ['code', [null, 'code', null]], ['blockquote', [null, 'blockquote', null]], ['em', [null, 'em', null]], ['xxx', [null, 'xxx', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts fenced named patterns"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<document>', ['<', 'document', '>']], ['{singlecolumn}', ['{', 'singlecolumn', '}']], ['{code}', ['{', 'code', '}']], ['[blockquote]', ['[', 'blockquote', ']']], ['(em)', ['(', 'em', ')']]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe), matcher);
    }
    return done();
  };

  this["MKTS.FENCES.parse rejects empty string"] = function(T, done) {
    T.throws("pattern must be non-empty, got ''", (function() {
      return MKTS.FENCES.parse('');
    }));
    return done();
  };

  this["MKTS.FENCES.parse rejects non-matching fences etc"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['(xxx}', 'fences don\'t match in pattern \'(xxx}\''], ['.)', 'fence \'.\' can not have right fence, got \'.)\''], ['.p)', 'fence \'.\' can not have right fence, got \'.p)\''], ['.[', 'fence \'.\' can not have right fence, got \'.[\''], ['<', 'unmatched fence in \'<\''], ['{', 'unmatched fence in \'{\''], ['[', 'unmatched fence in \'[\''], ['(', 'unmatched fence in \'(\'']];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.throws(matcher, (function() {
        return MKTS.FENCES.parse(probe);
      }));
    }
    return done();
  };

  this["MKTS.FENCES.parse accepts non-matching fences when so configured"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref;
    probes_and_matchers = [['<document>', ['<', 'document', '>']], ['{singlecolumn}', ['{', 'singlecolumn', '}']], ['{code}', ['{', 'code', '}']], ['[blockquote]', ['[', 'blockquote', ']']], ['(em)', ['(', 'em', ')']], ['document>', [null, 'document', '>']], ['singlecolumn}', [null, 'singlecolumn', '}']], ['code}', [null, 'code', '}']], ['blockquote]', [null, 'blockquote', ']']], ['em)', [null, 'em', ')']], ['<document', ['<', 'document', null]], ['{singlecolumn', ['{', 'singlecolumn', null]], ['{code', ['{', 'code', null]], ['[blockquote', ['[', 'blockquote', null]], ['(em', ['(', 'em', null]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      T.eq(MKTS.FENCES.parse(probe, {
        symmetric: false
      }), matcher);
    }
    return done();
  };

  this["MKTS.TRACKER.new_tracker (short comprehensive test)"] = function(T, done) {
    var i, len, matcher, probe, probes_and_matchers, ref, track;
    track = MKTS.TRACKER.new_tracker('(code)', '{multi-column}');
    probes_and_matchers = [[['<', 'document'], [false, false]], [['{', 'multi-column'], [false, true]], [['(', 'code'], [true, true]], [['{', 'multi-column'], [true, true]], [['.', 'text'], [true, true]], [['}', 'multi-column'], [true, true]], [[')', 'code'], [false, true]], [['}', 'multi-column'], [false, false]], [['>', 'document'], [false, false]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      ref = probes_and_matchers[i], probe = ref[0], matcher = ref[1];
      track(probe);
      whisper(probe);
      help('(code):', track.within('(code)'), '{multi-column}:', track.within('{multi-column}'));
      T.eq(track.within('(code)'), matcher[0]);
      T.eq(track.within('{multi-column}'), matcher[1]);
    }
    return done();
  };

  this._main = function(handler) {
    return test(this, {
      'timeout': 2500
    });
  };

  if (module.parent == null) {
    this._main();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/tests.js.map
