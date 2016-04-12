(function() {
  var $, $add_fncr, $async, $drop_comments, $query, $show, $skip_empty, $sort, $split_fields, $transform, $trim, ASYNC, CND, D, HOLLERITH, XNCHR, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper;

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
    var consolidated_route, corrections_route, input, options, original_route, output;
    options = require('../../jizura-datasources/options');
    original_route = options['ds-routes']['formulas'];
    consolidated_route = options['ds-routes']['formulas-consolidated'];
    corrections_route = options['ds-routes']['formulas-corrections'];
    help("Collecting formulas from\n" + original_route + "\nand\n" + corrections_route + "\ninto\n" + consolidated_route);
    output = njs_fs.createWriteStream(consolidated_route);
    input = njs_fs.createReadStream(corrections_route);
    input.pipe($transform(S));
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

  $split_fields = (function(_this) {
    return function(S) {
      return $(function(line, send) {
        send(line.split('\t'));
        return null;
      });
    };
  })(this);

  $trim = (function(_this) {
    return function(S) {
      return $(function(data, send) {
        var d, type;
        switch (type = CND.type_of(data)) {
          case 'text':
            send(data.trim());
            break;
          case 'list':
            send((function() {
              var i, len, results;
              results = [];
              for (i = 0, len = data.length; i < len; i++) {
                d = data[i];
                if (CND.isa_text(d)) {
                  results.push(d.trim());
                }
              }
              return results;
            })());
            break;
          default:
            throw new Error("unable to split a " + type);
        }
        return null;
      });
    };
  })(this);

  $drop_comments = (function(_this) {
    return function(S) {
      return $(function(fields, send) {
        var Z, field, i, len;
        Z = [];
        for (i = 0, len = fields.length; i < len; i++) {
          field = fields[i];
          if (field.startsWith('#')) {
            break;
          }
          Z.push(field);
        }
        send(Z);
        return null;
      });
    };
  })(this);

  $skip_empty = (function(_this) {
    return function(S) {
      return $(function(data, send) {
        var type;
        if (data == null) {
          return null;
        }
        switch (type = CND.type_of(data)) {
          case 'text':
          case 'list':
            if (data.length !== 0) {
              send(data);
            }
            break;
          default:
            send(data);
        }
        return null;
      });
    };
  })(this);

  $show = (function(_this) {
    return function(S) {
      return D.$observe(function(fields) {
        echo(fields.join('\t'));
        return null;
      });
    };
  })(this);

  $transform = (function(_this) {
    return function(S) {
      return D.combine([
        D.$split(), $trim(), $skip_empty(), $split_fields(), $drop_comments(), $skip_empty(), $trim(), D.$show(), D.$on_end(function() {
          if (S.handler != null) {
            return S.handler(null);
          }
        })
      ]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/consolidate-original-and-corrected-formulas.js.map
