(function() {
  var $, $async, $collect_corrections, $drop_comments, $format_line, $replace_corrected, $show, $skip_empty, $split_fields, $transform, $trim, ASYNC, CND, D, HOLLERITH, XNCHR, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper;

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
    var consolidated_route, corrections_input, corrections_route, options, originals_route, output;
    options = require('../../jizura-datasources/options');
    originals_route = options['ds-routes']['formulas'];
    consolidated_route = options['ds-routes']['formulas-consolidated'];
    corrections_route = options['ds-routes']['formulas-corrections'];
    help("Collecting formulas from\n" + originals_route + "\nand\n" + corrections_route + "\ninto\n" + consolidated_route);
    output = njs_fs.createWriteStream(consolidated_route);
    corrections_input = njs_fs.createReadStream(corrections_route);
    corrections_input.pipe($transform(S)).pipe($collect_corrections(S)).pipe($((function(_this) {
      return function(corrections, send) {
        return S.corrections = corrections;
      };
    })(this))).pipe(D.$on_end((function(_this) {
      return function() {
        var originals_input;
        originals_input = njs_fs.createReadStream(originals_route);
        return originals_input.pipe($transform(S)).pipe($replace_corrected(S)).pipe($format_line(S)).pipe(D.$on_end(function() {
          return urge("output written to " + consolidated_route);
        })).pipe(output);
      };
    })(this)));
    return null;
  };

  $collect_corrections = function(S) {
    var Z;
    Z = {};
    return $((function(_this) {
      return function(fields, send, end) {
        var fncr, formula, glyph;
        if (fields != null) {
          fncr = fields[0], glyph = fields[1], formula = fields[2];
          (Z[glyph] != null ? Z[glyph] : Z[glyph] = []).push(formula);
        }
        if (end != null) {
          send(Z);
          end();
        }
        return null;
      };
    })(this));
  };

  $replace_corrected = function(S) {
    var seen_glyphs;
    seen_glyphs = new Set();
    return $((function(_this) {
      return function(fields, send) {
        var corrected_formula, corrected_formulas, fncr, formula, glyph, i, len;
        fncr = fields[0], glyph = fields[1], formula = fields[2];
        if (seen_glyphs.has(glyph)) {
          return;
        }
        if ((corrected_formulas = S.corrections[glyph]) != null) {
          for (i = 0, len = corrected_formulas.length; i < len; i++) {
            corrected_formula = corrected_formulas[i];
            send([fncr, glyph, corrected_formula]);
          }
        } else {
          send([fncr, glyph, formula]);
        }
        return null;
      };
    })(this));
  };

  $format_line = function(S) {
    return $((function(_this) {
      return function(fields, send) {
        send((fields.join('\t')) + '\n');
        return null;
      };
    })(this));
  };

  $split_fields = function(S) {
    return $((function(_this) {
      return function(line, send) {
        send(line.split('\t'));
        return null;
      };
    })(this));
  };

  $trim = function(S) {
    return $((function(_this) {
      return function(data, send) {
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
      };
    })(this));
  };

  $drop_comments = function(S) {
    return $((function(_this) {
      return function(fields, send) {
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
      };
    })(this));
  };

  $skip_empty = function(S) {
    return $((function(_this) {
      return function(data, send) {
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
      };
    })(this));
  };

  $show = function(S) {
    return D.$observe((function(_this) {
      return function(fields) {
        echo(fields.join('\t'));
        return null;
      };
    })(this));
  };

  $transform = (function(_this) {
    return function(S) {
      return D.combine([D.$split(), $trim(), $skip_empty(), $split_fields(), $drop_comments(), $skip_empty(), $trim()]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/consolidate-original-and-corrected-formulas.js.map
