(function() {
  var $, $async, CND, D, HOLLERITH, KWIC, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ;

  njs_path = require('path');

  njs_fs = require('fs');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/copy-jizuradb-to-Hollerith2-format';

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

  HOLLERITH = require('hollerith');

  KWIC = require('kwic');

  ƒ = CND.format_number.bind(CND);

  this.$parse_tsv = function(options) {
    return $((function(_this) {
      return function(record, send) {
        var _, field, fields, frequency, frequency_txt, glyph;
        fields = record.split(/\s+/);
        fields = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = fields.length; i < len; i++) {
            field = fields[i];
            results.push(field.trim());
          }
          return results;
        })();
        fields = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = fields.length; i < len; i++) {
            field = fields[i];
            if (field.length > 0) {
              results.push(field);
            }
          }
          return results;
        })();
        if (fields.length > 0 && !fields[0].startsWith('#')) {
          glyph = fields[0], frequency_txt = fields[1], _ = fields[2];
          frequency = parseInt(frequency_txt, 10);
          return send([glyph, frequency]);
        }
      };
    })(this));
  };

  this.read_sample = function(db, limit_or_list, handler) {

    /* Return a gamut of select glyphs from the DB. `limit_or_list` may be a list of glyphs or a number
    representing an upper bound to the usage rank recorded as `rank/cjt`. If `limit_or_list` is a list,
    a POD whose keys are the glyphs in the list is returned; if it is a number, a similar POD with all the
    glyphs whose rank is not worse than the given limit is returned. If `limit_or_list` is smaller than zero
    or equals infinity, `null` is returned to indicate absence of a filter.
     */
    var Z, db_route, glyph, hi, i, input, len, lo, query;
    Z = {};
    if (CND.isa_list(limit_or_list)) {
      for (i = 0, len = limit_or_list.length; i < len; i++) {
        glyph = limit_or_list[i];
        Z[glyph] = 1;
      }
      return handler(null, Z);
    }
    if (limit_or_list < 0 || limit_or_list === Infinity) {
      return handler(null, null);
    }
    if (!CND.isa_number(limit_or_list)) {
      throw new Error("expected list or number, got a " + type);
    }
    if (db == null) {
      db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
      if (db == null) {
        db = HOLLERITH.new_db(db_route, {
          create: false
        });
      }
    }
    lo = ['pos', 'rank/cjt', 0];
    hi = ['pos', 'rank/cjt', limit_or_list];
    query = {
      lo: lo,
      hi: hi
    };
    input = HOLLERITH.create_phrasestream(db, query);
    return input.pipe($((function(_this) {
      return function(phrase, send) {
        var _;
        _ = phrase[0], _ = phrase[1], _ = phrase[2], glyph = phrase[3];
        return Z[glyph] = 1;
      };
    })(this))).pipe(D.$on_end(function() {
      return handler(null, Z);
    }));
  };

  this.read_chtsai_frequencies = function(handler) {
    var Z, input, route;
    route = njs_path.join(__dirname, '../../jizura-datasources/data/flat-files/usage/usage-counts-zhtw-chtsai-13000chrs-3700ranks.txt');
    input = njs_fs.createReadStream(route);
    Z = {};
    return input.pipe(D.$split()).pipe(this.$parse_tsv()).pipe($((function(_this) {
      return function(glyph_and_frequency, send, end) {
        var frequency, glyph;
        if (glyph_and_frequency != null) {
          glyph = glyph_and_frequency[0], frequency = glyph_and_frequency[1];
          Z[glyph] = frequency;
        }
        if (end != null) {
          handler(null, Z);
          return end();
        }
      };
    })(this)));
  };

  this.main = function() {
    var db, db_route;
    db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    db = HOLLERITH.new_db(db_route, {
      create: false
    });
    help("using DB at " + db['%self']['location']);
    return step((function(_this) {
      return function*(resume) {
        var $count_guides, $filter_by_frequencies, $filter_sample, $rank_counts, $select_glyph_and_guide, $show_counts, $sort_counts, frequencies, include, input, prefix, query, ranks, sample;
        ranks = {};
        include = 10000;
        sample = null;
        frequencies = (yield _this.read_chtsai_frequencies(resume));
        if (sample != null) {
          help("using sample of " + (ƒ((Object.keys(sample)).length)) + " glyphs");
        }
        prefix = ['pos', 'guide/has/uchr'];

        /* TAINT use of star not correct */
        query = {
          prefix: prefix,
          star: '*'
        };
        input = HOLLERITH.create_phrasestream(db, query);
        input.on('end', function() {
          return help("ok");
        });
        $select_glyph_and_guide = function() {
          return $(function(phrase, send) {
            var _, glyph, guide;
            _ = phrase[0], _ = phrase[1], guide = phrase[2], glyph = phrase[3], _ = phrase[4];
            return send([glyph, guide]);
          });
        };
        $filter_sample = function(sample) {
          return $(function(arg, send) {
            var event, glyph, guide;
            glyph = arg[0], guide = arg[1];
            event = ['glyph-and-guide', glyph, guide];
            if (sample != null) {
              if (sample[glyph] != null) {
                return send(event);
              }
            } else {
              return send(event);
            }
          });
        };
        $filter_by_frequencies = function(frequencies) {
          return $(function(arg, send) {
            var event, frequency, glyph, guide;
            glyph = arg[0], guide = arg[1];
            if ((frequency = frequencies[glyph]) != null) {
              event = ['glyph-guide-and-frequency', glyph, guide, frequency];
              return send(event);
            }
          });
        };
        $count_guides = function() {
          var counts;
          counts = {};
          return $(function(event, send, end) {
            var glyph, guide, ref, type;
            if (event != null) {
              type = event[0], glyph = event[1], guide = event[2];
              counts[guide] = ((ref = counts[guide]) != null ? ref : 0) + 1;
            }
            if (end != null) {
              send(['counts', counts]);
              return end();
            }
          });
        };
        $sort_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide;
            _ = event[0], counts = event[1];
            counts = (function() {
              var results;
              results = [];
              for (guide in counts) {
                count = counts[guide];
                results.push([guide, count]);
              }
              return results;
            })();
            counts.sort(function(a, b) {
              if (a[1] < b[1]) {
                return +1;
              }
              if (a[1] > b[1]) {
                return -1;
              }
              return 0;
            });
            return send(['counts', counts]);
          });
        };
        $rank_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide, i, idx, last_count, len, rank, ref;
            _ = event[0], counts = event[1];
            rank = 0;
            last_count = null;
            for (idx = i = 0, len = counts.length; i < len; idx = ++i) {
              ref = counts[idx], guide = ref[0], count = ref[1];
              if (count !== last_count) {
                rank += +1;
                last_count = count;
              }
              counts[idx] = [guide, count, rank];
            }
            return send(['counts', counts]);
          });
        };
        $show_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide, i, len, rank, ref, results;
            _ = event[0], counts = event[1];
            results = [];
            for (i = 0, len = counts.length; i < len; i++) {
              ref = counts[i], guide = ref[0], count = ref[1], rank = ref[2];
              results.push(echo(rank + "\t" + count + "\t" + guide));
            }
            return results;
          });
        };
        input.pipe($select_glyph_and_guide()).pipe($filter_by_frequencies(frequencies)).pipe(D.$show());
        return null;
      };
    })(this));
  };

  this.count_guides_with_frequencies = function() {
    var db, db_route;
    db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    db = HOLLERITH.new_db(db_route, {
      create: false
    });
    help("using DB at " + db['%self']['location']);
    return step((function(_this) {
      return function*(resume) {
        var $count_guides_with_frequencies, $filter_by_frequencies, $filter_sample, $rank_counts, $select_glyph_and_guide, $show_counts, $sort_counts, frequencies, input, prefix, query, ranks;
        ranks = {};
        frequencies = (yield _this.read_chtsai_frequencies(resume));
        prefix = ['pos', 'guide/has/uchr'];

        /* TAINT use of star not correct */
        query = {
          prefix: prefix,
          star: '*'
        };
        input = HOLLERITH.create_phrasestream(db, query);
        input.on('end', function() {
          return help("ok");
        });
        $select_glyph_and_guide = function() {
          return $(function(phrase, send) {
            var _, glyph, guide;
            _ = phrase[0], _ = phrase[1], guide = phrase[2], glyph = phrase[3], _ = phrase[4];
            return send([glyph, guide]);
          });
        };
        $filter_sample = function(sample) {
          return $(function(arg, send) {
            var event, glyph, guide;
            glyph = arg[0], guide = arg[1];
            event = ['glyph-and-guide', glyph, guide];
            if (sample != null) {
              if (sample[glyph] != null) {
                return send(event);
              }
            } else {
              return send(event);
            }
          });
        };
        $filter_by_frequencies = function(frequencies) {
          return $(function(arg, send) {
            var event, frequency, glyph, guide;
            glyph = arg[0], guide = arg[1];
            if ((frequency = frequencies[glyph]) != null) {
              event = ['glyph-guide-and-frequency', glyph, guide, frequency];
              return send(event);
            }
          });
        };
        $count_guides_with_frequencies = function() {
          var counts;
          counts = {};
          return $(function(event, send, end) {
            var frequency, glyph, guide, ref, type;
            if (event != null) {
              type = event[0], glyph = event[1], guide = event[2], frequency = event[3];
              counts[guide] = ((ref = counts[guide]) != null ? ref : 0) + frequency;
            }
            if (end != null) {
              send(['counts', counts]);
              return end();
            }
          });
        };
        $sort_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide;
            _ = event[0], counts = event[1];
            counts = (function() {
              var results;
              results = [];
              for (guide in counts) {
                count = counts[guide];
                results.push([guide, count]);
              }
              return results;
            })();
            counts.sort(function(a, b) {
              if (a[1] < b[1]) {
                return +1;
              }
              if (a[1] > b[1]) {
                return -1;
              }
              return 0;
            });
            return send(['counts', counts]);
          });
        };
        $rank_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide, i, idx, len, rank, ref;
            _ = event[0], counts = event[1];
            rank = 0;
            for (idx = i = 0, len = counts.length; i < len; idx = ++i) {
              ref = counts[idx], guide = ref[0], count = ref[1];
              rank += +1;
              counts[idx] = [guide, count, rank];
            }
            return send(['counts', counts]);
          });
        };
        $show_counts = function() {
          return $(function(event, send) {
            var _, count, counts, guide, i, len, rank, ref, results;
            _ = event[0], counts = event[1];
            results = [];
            for (i = 0, len = counts.length; i < len; i++) {
              ref = counts[i], guide = ref[0], count = ref[1], rank = ref[2];
              results.push(echo(rank + "\t" + count + "\t" + guide));
            }
            return results;
          });
        };
        input.pipe($select_glyph_and_guide()).pipe($filter_by_frequencies(frequencies)).pipe($count_guides_with_frequencies()).pipe($sort_counts()).pipe($rank_counts()).pipe($show_counts());
        return null;
      };
    })(this));
  };

  if (module.parent == null) {
    this.count_guides_with_frequencies();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/show-factor-usages.js.map