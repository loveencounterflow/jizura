(function() {
  var $, $async, CHR, CND, D, HOLLERITH, TEXT, alert, badge, debug, echo, help, info, join, log, njs_path, rpr, step, suspend, urge, warn, whisper, ƒ;

  njs_path = require('path');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/show-usage-counts';

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

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  HOLLERITH = require('hollerith');

  CHR = require('coffeenode-chr');

  TEXT = require('coffeenode-text');

  ƒ = CND.format_number.bind(CND);

  this.$simplify_usagecode = function() {

    /* Normalize letters to lower case, thereby conflating the `C` vs `c` etc distinctions; throw out
    characters marked as `f` (facultative), `p` (positional), and `x` (extra); subsume Korea, Taiwan, Hong
    Kong and Macau under one group (`t` for 'traditional'):
     */
    return $((function(_this) {
      return function(arg, send) {
        var glyph, phrase_type, prd, usagecode;
        phrase_type = arg[0], prd = arg[1], usagecode = arg[2], glyph = arg[3];
        usagecode = usagecode.toLowerCase();
        usagecode = usagecode.replace(/f|p|x/g, '');
        usagecode = usagecode.replace(/k|h|m|t/g, 't');
        usagecode = usagecode.replace(/t+/g, 't');
        if (usagecode.length > 0) {
          send([glyph, usagecode]);
        }
        return null;
      };
    })(this));
  };

  this.$add_rank = function(db) {
    return $async((function(_this) {
      return function(arg, done) {
        var glyph, prefix, query, usagecode;
        glyph = arg[0], usagecode = arg[1];
        prefix = ['spo', glyph, 'rank/cjt'];
        query = {
          prefix: prefix,
          fallback: null
        };
        return HOLLERITH.read_one_phrase(db, query, function(error, phrase) {
          var _, rank;
          if (error != null) {
            return done.error(error);
          }
          if (phrase === null) {
            return done();
          }
          _ = phrase[0], _ = phrase[1], _ = phrase[2], rank = phrase[3];
          return done([glyph, usagecode, rank]);
        });
      };
    })(this));
  };

  this.$collect_sample = function(ratio) {
    var collection;
    collection = {};
    return $((function(_this) {
      return function(fields, send, end) {
        var glyph, glyphs, glyphs_and_ranks, last_idx, rank, usagecode;
        if (fields != null) {
          glyph = fields[0], usagecode = fields[1], rank = fields[2];
          (collection[usagecode] != null ? collection[usagecode] : collection[usagecode] = []).push([glyph, rank]);
          send([glyph, usagecode]);
        }
        if (end != null) {
          for (usagecode in collection) {
            glyphs_and_ranks = collection[usagecode];
            glyphs_and_ranks.sort(function(a, b) {
              if (a[1] > b[1]) {
                return +1;
              }
              if (a[1] < b[1]) {
                return -1;
              }
              return 0;
            });
            glyphs = (function() {
              var i, len, ref, results;
              results = [];
              for (i = 0, len = glyphs_and_ranks.length; i < len; i++) {
                ref = glyphs_and_ranks[i], glyph = ref[0], rank = ref[1];
                results.push(glyph);
              }
              return results;
            })();
            last_idx = Math.floor(glyphs.length * ratio + 0.5);
            urge(usagecode, glyphs.length, glyphs.slice(0, last_idx).join(''));
          }
          end();
        }
        return null;
      };
    })(this));
  };

  this.$count = function() {
    var counts;
    counts = {};
    return $((function(_this) {
      return function(fields, send, end) {
        var glyph, ref, usagecode;
        if (fields != null) {
          glyph = fields[0], usagecode = fields[1];
          counts[usagecode] = ((ref = counts[usagecode]) != null ? ref : 0) + 1;
        }
        if (end != null) {
          send(counts);
          end();
        }
        return null;
      };
    })(this));
  };

  this.$report = function() {
    var counts, show;
    counts = {};
    show = function(counts, title) {
      var count, i, len, ref, region, results;
      counts = (function() {
        var results;
        results = [];
        for (region in counts) {
          count = counts[region];
          results.push([region, count]);
        }
        return results;
      })();
      counts.sort(function(a, b) {
        if (a[0] > b[0]) {
          return +1;
        }
        if (a[0] < b[0]) {
          return -1;
        }
        return 0;
      });
      help(title);
      results = [];
      for (i = 0, len = counts.length; i < len; i++) {
        ref = counts[i], region = ref[0], count = ref[1];
        results.push(help((TEXT.flush_left(region, 12, '.')) + (TEXT.flush_right(count, 10, '.')), "glyphs"));
      }
      return results;
    };
    return $((function(_this) {
      return function(counts, send) {
        var _, count, count_0, i, key, len, region_0, region_1, sum;
        sum = 0;
        for (_ in counts) {
          count = counts[_];
          sum += count;
        }
        show(counts, "individual glyph counts:");
        for (region_0 in counts) {
          count_0 = counts[region_0];
          if (region_0.length === 1) {
            continue;
          }
          for (i = 0, len = region_0.length; i < len; i++) {
            region_1 = region_0[i];
            counts[region_1] += count_0;
          }
        }
        for (key in counts) {
          if (key.length > 1) {
            delete counts[key];
          }
        }
        show(counts, "accumulated glyph counts:");
        help("altogether, " + sum + " glyphs have a regional tag");
        warn("glyphs tagged only as Facultative, Positional or eXtra have been excluded from these counts");
        send(counts);
        return null;
      };
    })(this));
  };

  this.$report_v2 = function() {
    var counts, show;
    counts = {};
    show = function(title, counts) {
      var count, i, len, ref, region, results;
      counts = (function() {
        var results;
        results = [];
        for (region in counts) {
          count = counts[region];
          results.push([region, count]);
        }
        return results;
      })();
      counts.sort(function(a, b) {
        if (a[0] > b[0]) {
          return +1;
        }
        if (a[0] < b[0]) {
          return -1;
        }
        return 0;
      });
      help(title);
      results = [];
      for (i = 0, len = counts.length; i < len; i++) {
        ref = counts[i], region = ref[0], count = ref[1];
        results.push(help((TEXT.flush_left(region, 12, '.')) + (TEXT.flush_right(count, 10, '.')), "glyphs"));
      }
      return results;
    };
    return $((function(_this) {
      return function(counts, send) {
        var _, count, i, len, ref, sub_count, sub_region, sub_regions, sum, target, totals;
        sum = 0;
        for (_ in counts) {
          count = counts[_];
          sum += count;
        }
        totals = {};
        show("individual glyph counts:", counts);
        for (sub_regions in counts) {
          sub_count = counts[sub_regions];
          for (i = 0, len = sub_regions.length; i < len; i++) {
            sub_region = sub_regions[i];
            target = (function() {
              switch (sub_region) {
                case 'c':
                  return 'Ⓒ';
                case 'j':
                  return 'Ⓙ';
                case 't':
                  return 'Ⓣ';
              }
            })();
            totals[target] = ((ref = totals[target]) != null ? ref : 0) + sub_count;
          }
        }
        show("accumulated glyph counts:", totals);
        help("altogether, " + sum + " glyphs have a regional tag");
        warn("glyphs tagged only as Facultative, Positional or eXtra have been excluded from these counts");
        send(counts);
        return null;
      };
    })(this));
  };

  this.show_statistics = function() {
    var db, db_route, home, input, prefix, query;
    home = join(__dirname, '../../jizura-datasources');
    db_route = join(home, 'data/leveldb-v2');
    db = HOLLERITH.new_db(db_route);
    prefix = ['pos', 'usagecode/full'];

    /* TAINT star shouldn't be necessary here */
    query = {
      prefix: prefix,
      star: '*'
    };
    input = HOLLERITH.create_phrasestream(db, query);
    return input.pipe(this.$simplify_usagecode()).pipe(this.$add_rank(db)).pipe(this.$collect_sample(0.07)).pipe(this.$count()).pipe(D.$show()).pipe(this.$report_v2());
  };

  if (module.parent == null) {
    this.show_statistics();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/show-usage-statistics.js.map