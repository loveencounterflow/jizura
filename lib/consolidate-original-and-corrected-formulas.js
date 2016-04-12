(function() {
  var $, $add_fncr, $async, $query, $reorder, $show, $sort, $transform, ASYNC, CND, D, HOLLERITH, XNCHR, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/show-repeated-factors';

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

  XNCHR = require('./XNCHR');

  HOLLERITH = require('hollerith');

  this.consolidate_formulas = function(S) {
    var consolidated_route, corrected_route, input, options, orginal_route, output;
    options = require('../../jizura-datasources/options');
    orginal_route = options['ds-routes']['formulas'];
    consolidated_route = options['ds-routes']['formulas-consolidated'];
    corrected_route = options['ds-routes']['formulas-corrected'];
    help("Collecting formulas from\n" + orginal_route + "\nand\n" + corrected_route + "\ninto\n" + consolidated_route);
    process.exit();
    output = njs_fs.createWriteStream(corrected_route);
    input = njs_fs.createReadStream(route);
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
        return input.pipe($(function(phrase, _) {
          var formula, formulas, i, idx, len;
          formulas = phrase[phrase.length - 1];
          for (idx = i = 0, len = formulas.length; i < len; idx = ++i) {
            formula = formulas[idx];
            send([glyph, formula, idx]);
          }
          return send.done();
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

  $sort = (function(_this) {
    return function(S) {
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
        glyph = XNCHR.as_chr(glyph);
        return send([fncr, glyph, formula]);
      });
    };
  })(this);

  $show = (function(_this) {
    return function(S) {
      return D.$observe(function(fields) {
        return echo(fields.join('\t'));
      });
    };
  })(this);

  $transform = (function(_this) {
    return function(S) {
      return D.combine([
        $query(S), $add_fncr(S), $sort(S), $reorder(S), $show(S), D.$on_end(function() {
          if (S.handler != null) {
            return S.handler(null);
          }
        })
      ]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/consolidate-original-and-corrected-formulas.js.map
