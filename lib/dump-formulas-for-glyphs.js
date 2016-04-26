(function() {
  var $, $add_fncr, $async, $normalize_glyph, $query, $reorder, $show, $sort, $transform, $unique, ASYNC, CND, D, HOLLERITH, IDLX, XNCHR, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/dump-formulas';

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

  eventually = suspend.eventually;

  immediately = suspend.immediately;

  repeat_immediately = suspend.repeat_immediately;

  every = suspend.every;

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  ASYNC = require('async');

  IDLX = require('idlx');

  XNCHR = require('./XNCHR');

  HOLLERITH = require('hollerith');

  this.dump_formulas = function(S) {
    var glyph, i, input, input_from_pipe, len, ref;
    S.db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    S.db = HOLLERITH.new_db(S.db_route, {
      create: false
    });
    help("using DB at " + S.db['%self']['location']);
    input = D.create_throughstream();
    input.pipe($transform(S));
    input_from_pipe = !process.stdin.isTTY;
    if (input_from_pipe) {
      if (S.glyphs.length > 0) {
        warn("unable to accept glyphs from both stdin and option -g / --glyphs");
        process.exit(1);
      }
      process.stdin.pipe(D.$split()).pipe($(function(line, send) {
        var chr, i, len, ref, results;
        ref = XNCHR.chrs_from_text(line);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          chr = ref[i];
          results.push(send(chr));
        }
        return results;
      })).pipe(input);
    } else {
      ref = S.glyphs;
      for (i = 0, len = ref.length; i < len; i++) {
        glyph = ref[i];
        input.write(glyph);
      }
      input.end();
    }
    return null;
  };

  $query = (function(_this) {
    return function(S) {
      return D.remit_async_spread(function(glyph, send) {
        var input, query;
        query = {
          prefix: ['spo', glyph, 'formula']
        };
        input = HOLLERITH.create_phrasestream(S.db, query);
        return input.pipe($(function(phrase, _, end) {
          var formula, formulas, i, idx, len;
          if (phrase != null) {
            formulas = phrase[phrase.length - 1];
            for (idx = i = 0, len = formulas.length; i < len; idx = ++i) {
              formula = formulas[idx];
              send([glyph, formula, idx]);
            }
          }
          if (end != null) {
            return send.done();
          }
        }));
      });
    };
  })(this);

  $add_fncr = (function(_this) {
    return function(S) {
      return $(function(arg, send) {
        var fncr, formula, glyph, idx;
        glyph = arg[0], formula = arg[1], idx = arg[2];
        fncr = XNCHR.as_fncr(glyph);
        return send([glyph, fncr, formula, idx]);
      });
    };
  })(this);

  $normalize_glyph = (function(_this) {
    return function(S) {
      return $(function(glyph, send) {

        /* TAINT doesn't work with Gaiji NCRs like `&gt#x4cef;` */
        var cid, csg, rsg;
        rsg = XNCHR.as_rsg(glyph);
        cid = XNCHR.as_cid(glyph);
        csg = rsg === 'u-pua' || rsg === 'jzr-fig' ? 'jzr' : 'u';
        if (csg !== 'u') {
          glyph = XNCHR.chr_from_cid_and_csg(cid, csg);
        }
        return send(glyph);
      });
    };
  })(this);

  $unique = (function(_this) {
    return function(S) {
      var seen_glyphs;
      seen_glyphs = new Set();
      return $(function(glyph, send) {
        if (seen_glyphs.has(glyph)) {
          return;
        }
        seen_glyphs.add(glyph);
        return send(glyph);
      });
    };
  })(this);

  $sort = (function(_this) {
    return function(S) {
      if (!S.sort) {
        return D.$pass_through();
      }
      return D.$sort(function(a, b) {
        var a_cid, a_fncr, a_formula, a_glyph, a_idx, b_cid, b_fncr, b_formula, b_glyph, b_idx;
        a_glyph = a[0], a_fncr = a[1], a_formula = a[2], a_idx = a[3];
        b_glyph = b[0], b_fncr = b[1], b_formula = b[2], b_idx = b[3];
        a_cid = XNCHR.as_cid(a_glyph);
        b_cid = XNCHR.as_cid(b_glyph);
        if (a_cid > b_cid) {
          return +1;
        }
        if (a_cid < b_cid) {
          return -1;
        }
        if (a_idx > b_idx) {
          return +1;
        }
        if (a_idx < b_idx) {
          return -1;
        }
        return 0;
      });
    };
  })(this);

  $reorder = (function(_this) {
    return function(S) {
      return $(function(arg, send) {
        var fncr, formula, glyph, idx;
        glyph = arg[0], fncr = arg[1], formula = arg[2], idx = arg[3];
        return send([fncr, glyph, formula]);
      });
    };
  })(this);

  $show = (function(_this) {
    return function(S) {
      return D.$observe(function(fields) {
        var fncr, formula, glyph, ic, ics;
        fncr = fields[0], glyph = fields[1], formula = fields[2];
        if (S.noidcs) {
          ics = IDLX.find_all_non_operators(formula);
        } else {
          ics = XNCHR.chrs_from_text(formula);
        }
        if (S.uchrs) {
          glyph = XNCHR.as_uchr(glyph);
          ics = (function() {
            var i, len, results;
            results = [];
            for (i = 0, len = ics.length; i < len; i++) {
              ic = ics[i];
              results.push(XNCHR.as_uchr(ic));
            }
            return results;
          })();
        }
        formula = ics.join('');
        if (formula.length === 0) {
          formula = '\ue024';
        }
        if (S.colors) {
          return echo(CND.grey(fncr), CND.gold(glyph), CND.lime(formula));
        } else {
          return echo([fncr, glyph, formula].join('\t'));
        }
      });
    };
  })(this);

  $transform = (function(_this) {
    return function(S) {
      return D.combine([
        $normalize_glyph(S), $unique(S), $query(S), $add_fncr(S), $sort(S), $reorder(S), $show(S), D.$on_end(function() {
          if (S.handler != null) {
            return S.handler(null);
          }
        })
      ]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/dump-formulas-for-glyphs.js.map
