(function() {
  var $, $aggregate, $async, $filter_inner_glyphs, $filter_relevant_phrases, $look_for_repetitions, $show, $show_progress, $transform, ASYNC, CND, D, HOLLERITH, LRSL, XNCHR, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  LRSL = require('longest-repeating-sublist');

  this.show_repeated_factors = function(S) {
    var input;
    S.query = {
      prefix: ['spo']
    };
    S.db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    S.db = HOLLERITH.new_db(S.db_route, {
      create: false
    });
    S.prd_for_lineups = 'guide/lineup/uchr';
    S.prd_for_formulas = 'formula/ic0';
    help("using DB at " + S.db['%self']['location']);
    input = (HOLLERITH.create_phrasestream(S.db, S.query)).pipe($transform(S));
    return null;
  };

  $filter_inner_glyphs = (function(_this) {
    return function(S) {
      return $(function(phrase, send) {
        var _, glyph, obj, prd;
        _ = phrase[0], glyph = phrase[1], prd = phrase[2], obj = phrase[3];
        if (XNCHR.is_inner_glyph(glyph)) {
          return send(phrase);
        }
      });
    };
  })(this);

  $filter_relevant_phrases = (function(_this) {
    return function(S) {
      var prds;
      prds = [];
      if (S.lineups) {
        prds.push(S.prd_for_lineups);
      }
      if (S.formulas) {
        prds.push(S.prd_for_formulas);
      }
      return $(function(phrase, send) {
        var _, glyph, obj, prd;
        _ = phrase[0], glyph = phrase[1], prd = phrase[2], obj = phrase[3];
        if (indexOf.call(prds, prd) >= 0) {
          return send([glyph, prd, obj]);
        }
      });
    };
  })(this);

  $show_progress = (function(_this) {
    return function(S) {
      var count;
      count = 0;
      return $(function(phrase, send) {
        send(phrase);
        if ((count += +1) % 1000 === 0) {
          return info(count);
        }
      });
    };
  })(this);

  $look_for_repetitions = (function(_this) {
    return function(S) {
      return $(function(phrase, send) {
        var component, components, fncr, glyph, key, prd, repeated_components, sigil;
        glyph = phrase[0], prd = phrase[1], components = phrase[2];
        switch (prd) {
          case S.prd_for_lineups:
            components = Array.from(components.trim());
            break;
          case S.prd_for_formulas:
            null;
            break;
          default:
            throw new Error("unknown predicate " + (rpr(prd)));
        }
        if ((repeated_components = LRSL.find_longest_repeating_sublist(components)) != null) {
          switch (prd) {
            case S.prd_for_lineups:
              sigil = 'Ｌ';
              break;
            case S.prd_for_formulas:
              sigil = 'Ｆ';
              components = (function() {
                var i, len, results;
                results = [];
                for (i = 0, len = components.length; i < len; i++) {
                  component = components[i];
                  results.push(XNCHR.as_uchr(component));
                }
                return results;
              })();
              break;
            default:
              throw new Error("unknown predicate " + (rpr(prd)));
          }
          components = sigil + components.join('');
          glyph = XNCHR.as_uchr(glyph);
          fncr = XNCHR.as_fncr(glyph);
          key = ((function() {
            var i, len, results;
            results = [];
            for (i = 0, len = repeated_components.length; i < len; i++) {
              component = repeated_components[i];
              results.push(XNCHR.as_uchr(component));
            }
            return results;
          })()).join('');
          return send([key, fncr, glyph, components]);
        }
      });
    };
  })(this);

  $aggregate = (function(_this) {
    return function(S) {
      var cache;
      cache = {};
      return $(function(phrase, send, end) {
        var components, entries, entry, fncr, glyph, i, idx, key, len, target;
        if (phrase != null) {
          key = phrase[0], fncr = phrase[1], glyph = phrase[2], components = phrase[3];
          entry = [fncr, glyph, components].join('\t');
          target = cache[key] != null ? cache[key] : cache[key] = [];
          if (indexOf.call(target, entry) < 0) {
            target.push(entry);
          }
        }
        if (end != null) {
          for (key in cache) {
            entries = cache[key];
            for (idx = i = 0, len = entries.length; i < len; idx = ++i) {
              entry = entries[idx];
              if (idx !== 0) {
                key = '\u3000';
              }
              send([key, entry]);
            }
          }
          return end();
        }
      });
    };
  })(this);

  $show = (function(_this) {
    return function(S) {
      return D.$observe(function(phrase) {
        return echo(phrase.join('\t'));
      });
    };
  })(this);

  $transform = (function(_this) {
    return function(S) {
      return D.combine([
        $filter_inner_glyphs(S), $filter_relevant_phrases(S), $show_progress(S), $look_for_repetitions(S), $aggregate(S), $show(S), D.$on_end(function() {
          if (S.handler != null) {
            return S.handler(null);
          }
        })
      ]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/show-repeated-factors.js.map
