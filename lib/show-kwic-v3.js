(function() {
  var $, $async, ASYNC, CHR, CND, D, HOLLERITH, KWIC, TEXT, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, new_db, njs_path, options, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ,
    slice = [].slice;

  njs_path = require('path');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/show-kwic-v3';

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

  CHR = require('coffeenode-chr');

  KWIC = require('kwic');

  TEXT = require('coffeenode-text');

  new_db = require('level');

  HOLLERITH = require('hollerith');

  ƒ = CND.format_number.bind(CND);

  options = null;

  this._misfit = Symbol('misfit');

  this.initialize = function(handler) {
    options['db'] = HOLLERITH.new_db(options['route']);
    return handler(null);
  };

  HOLLERITH.$pick_subject = function() {
    return $((function(_this) {
      return function(lkey, send) {
        var _, pt, v0, v1;
        pt = lkey[0], _ = lkey[1], v0 = lkey[2], _ = lkey[3], v1 = lkey[4];
        return send(pt === 'so' ? v0 : v1);
      };
    })(this));
  };

  HOLLERITH.$pick_object = function() {
    return $((function(_this) {
      return function(lkey, send) {
        var _, pt, v0, v1;
        pt = lkey[0], _ = lkey[1], v0 = lkey[2], _ = lkey[3], v1 = lkey[4];
        return send(pt === 'so' ? v1 : v0);
      };
    })(this));
  };

  HOLLERITH.$pick_values = function() {
    return $((function(_this) {
      return function(lkey, send) {
        var _, pt, v0, v1;
        pt = lkey[0], _ = lkey[1], v0 = lkey[2], _ = lkey[3], v1 = lkey[4];
        return send(pt === 'so' ? [v0, v1] : [v1, v0]);
      };
    })(this));
  };

  this.dump_jizura_db = function() {
    var input, prefix, source_db;
    source_db = HOLLERITH.new_db('/Volumes/Storage/temp/jizura-hollerith2');
    prefix = ['spo', '𡏠'];
    prefix = ['spo', '㔰'];
    input = HOLLERITH.create_phrasestream(source_db, prefix);
    return input.pipe(D.$count(function(count) {
      return help("read " + count + " keys");
    })).pipe($((function(_this) {
      return function(data, send) {
        return send(JSON.stringify(data));
      };
    })(this))).pipe(D.$show());
  };

  this.read_factors = function(db, handler) {
    return step((function(_this) {
      return function(resume) {
        var Z, db_route, input, prefix, query;
        Z = {};
        db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
        if (db == null) {
          db = HOLLERITH.new_db(db_route, {
            create: false
          });
        }
        prefix = ['pos', 'factor/'];
        query = {
          prefix: prefix,
          star: '*'
        };
        input = HOLLERITH.create_phrasestream(db, query);
        return input.pipe((function() {
          var last_sbj, target;
          last_sbj = null;
          target = null;
          return $(function(phrase, send, end) {
            var _, obj, prd, sbj;
            if (phrase != null) {
              _ = phrase[0], prd = phrase[1], obj = phrase[2], sbj = phrase[3];
              prd = prd.replace(/^factor\//g, '');
              sbj = CHR.as_uchr(sbj, {
                input: 'xncr'
              });
              if (sbj !== last_sbj) {
                if (target != null) {
                  send(target);
                }
                target = Z[sbj] != null ? Z[sbj] : Z[sbj] = {
                  glyph: sbj
                };
                last_sbj = sbj;
              }
              target[prd] = obj;
              if (prd === 'sortcode') {
                Z[obj] = target;
              }
            }
            if (end != null) {
              if (target != null) {
                send(target);
              }
              return end();
            }
          });
        })()).pipe(D.$on_end(function() {
          return handler(null, Z);
        }));
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
    db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    if (db == null) {
      db = HOLLERITH.new_db(db_route, {
        create: false
      });
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

  this.show_kwic_v3 = function(db) {
    return step((function(_this) {
      return function*(resume) {
        var $_XXX_sort, $align_affixes, $count_glyphs_etc, $count_lineup_lengths, $exclude_gaiji, $include_sample, $insert_hr, $reorder_phrase, $show, $transform_v3, db_route, factor_sample, glyph_sample, include, input_v3, lineup_left_count, lineup_right_count, query_v3, ranks, window_width;
        db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
        if (db == null) {
          db = HOLLERITH.new_db(db_route, {
            create: false
          });
        }
        help("using DB at " + db['%self']['location']);

        /* !!!!!!!!!!!!!!!!!!!!!!! */

        /* !!!!!!!!!!!!!!!!!!!!!!! */
        ranks = {};
        include = 15000;
        include = 10000;
        include = 20000;
        include = 500;
        include = Infinity;
        lineup_left_count = 2;
        lineup_right_count = 3;
        window_width = lineup_left_count + 1 + lineup_right_count + 1;
        include = Array.from('虫𨙻𥦤曗𩡏鬱𡤇𡅹');
        glyph_sample = null;
        factor_sample = null;

        /* TAINT use sets */
        glyph_sample = (yield _this.read_sample(db, include, resume));
        $reorder_phrase = function() {
          return $(function(phrase, send) {

            /* extract sortcode */
            var _, glyph, sortcode;
            _ = phrase[0], _ = phrase[1], sortcode = phrase[2], glyph = phrase[3], _ = phrase[4];
            return send([glyph, sortcode]);
          });
        };
        $exclude_gaiji = function() {
          return D.$filter(function(arg) {
            var glyph, sortcode;
            glyph = arg[0], sortcode = arg[1];
            return (!glyph.startsWith('&')) || (glyph.startsWith('&jzr#'));
          });
        };
        $include_sample = function() {
          return D.$filter(function(arg) {
            var _, glyph, in_factor_sample, in_glyph_sample, infix, prefix, sortcode, suffix;
            glyph = arg[0], sortcode = arg[1];
            if ((glyph_sample == null) && (factor_sample == null)) {
              return true;
            }
            _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
            in_glyph_sample = (glyph_sample == null) || (glyph in glyph_sample);
            in_factor_sample = (factor_sample == null) || (infix in factor_sample);
            return in_glyph_sample && in_factor_sample;
          });
        };
        $count_lineup_lengths = function() {
          var count, counts;
          counts = [];
          count = 0;
          return $(function(event, send, end) {
            var _, count_txt, glyph, i, infix, length, lineup, lineup_length, prefix, ref, ref1, ref2, sortcode, suffix;
            if (event != null) {
              if (CND.isa_list(event)) {
                glyph = event[0], sortcode = event[1];
                _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
                lineup = (prefix.join('')) + infix + (suffix.join(''));
                lineup_length = (Array.from(lineup.replace(/\u3000/g, ''))).length;

                /* !!!!!!!!!!!!!!!!!!!!!!! */

                /* !!!!!!!!!!!!!!!!!!!!!!! */
                if (true) {
                  send(event);
                  counts[lineup_length] = ((ref = counts[lineup_length]) != null ? ref : 0) + 1;
                }
              } else {
                send(event);
              }
            }
            if (end != null) {
              for (length = i = 1, ref1 = counts.length; 1 <= ref1 ? i < ref1 : i > ref1; length = 1 <= ref1 ? ++i : --i) {
                count_txt = TEXT.flush_right(ƒ((ref2 = counts[length]) != null ? ref2 : 0), 10);
                help("found " + count_txt + " lineups of length " + length);
              }
              return end();
            }
          });
        };
        $_XXX_sort = function() {
          var buffer;
          buffer = [];
          return $(function(event, send, end) {
            var i, len;
            if ((event != null) && !CND.isa_list(event)) {
              throw new Error("sort not possible with intermittent text events");
            }
            buffer.push(event);
            if (end != null) {
              buffer.sort(function(event_a, event_b) {
                var _, glyph_a, glyph_b, infix_a, infix_b, prefix_a, prefix_b, sortcode_a, sortcode_b, suffix_a, suffix_b;
                glyph_a = event_a[0], sortcode_a = event_a[1];
                glyph_b = event_b[0], sortcode_b = event_b[1];
                _ = sortcode_a[0], infix_a = sortcode_a[1], suffix_a = sortcode_a[2], prefix_a = sortcode_a[3];
                _ = sortcode_b[0], infix_b = sortcode_b[1], suffix_b = sortcode_b[2], prefix_b = sortcode_b[3];
                if (prefix_a.length + suffix_a.length > prefix_b.length + suffix_b.length) {
                  return +1;
                }
                if (prefix_a.length + suffix_a.length < prefix_b.length + suffix_b.length) {
                  return -1;
                }
                if (glyph_a > glyph_b) {
                  return +1;
                }
                if (glyph_a < glyph_b) {
                  return -1;
                }
                if (suffix_a.length > suffix_b.length) {
                  return +1;
                }
                if (suffix_a.length < suffix_b.length) {
                  return -1;
                }
                return 0;
              });
              for (i = 0, len = buffer.length; i < len; i++) {
                event = buffer[i];
                send(event);
              }
              return end();
            }
          });
        };
        $insert_hr = function() {
          var in_keeplines, last_infix;
          in_keeplines = false;
          last_infix = null;
          return $(function(event, send, end) {
            var _, glyph, infix, prefix, sortcode, suffix;
            if (event != null) {
              glyph = event[0], sortcode = event[1];
              _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
              if ((last_infix != null) && infix !== last_infix) {
                if (in_keeplines) {
                  send("<<keep-lines)>>");
                }
                send("*******************************************");
                in_keeplines = false;
              }
              last_infix = infix;
              if (!in_keeplines) {
                send("<<(keep-lines>>");
              }
              in_keeplines = true;
              send(event);
            }
            if (end != null) {
              if (in_keeplines) {
                send("<<keep-lines)>>");
              }
              return end();
            }
          });
        };
        $align_affixes = function() {
          return $(function(event, send) {
            var _, glyph, infix, overall_length, prefix, prefix_copy, sortcode, suffix, suffix_copy;
            if (CND.isa_list(event)) {
              glyph = event[0], sortcode = event[1];
              _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
              overall_length = prefix.length + 1 + suffix.length;
              if (overall_length < window_width) {
                while (!(prefix.length >= lineup_left_count)) {
                  prefix.unshift('\u3007');
                }
                while (!(suffix.length >= lineup_right_count)) {
                  suffix.push('\u3007');
                }
              }
              prefix_copy = Object.assign([], prefix);
              suffix_copy = Object.assign([], suffix);
              prefix.unshift('」');
              prefix.splice.apply(prefix, [0, 0].concat(slice.call(suffix_copy)));
              suffix.push('「');
              suffix.splice.apply(suffix, [suffix.length, 0].concat(slice.call(prefix_copy)));
              return send([glyph, [sortcode, infix, suffix, prefix]]);
            } else {
              return send(event);
            }
          });
        };
        $count_glyphs_etc = function() {
          var glyphs, lineup_count;
          glyphs = new Set();
          lineup_count = 0;
          return D.$observe(function(event, has_ended) {
            var _, glyph;
            if (event != null) {
              if (CND.isa_list(event)) {
                glyph = event[0], _ = event[1];
                glyphs.add(glyph);
                lineup_count += +1;
              } else {
                send(event);
              }
            }
            if (has_ended) {
              help("built KWIC for " + (ƒ(glyphs.size)) + " glyphs");
              return help("containing " + (ƒ(lineup_count)) + " lineups");
            }
          });
        };
        $show = function() {
          var last_glyph;
          last_glyph = null;
          return D.$observe(function(event) {
            var _, glyph, infix, lineup, prefix, sortcode, suffix;
            if (CND.isa_list(event)) {
              glyph = event[0], sortcode = event[1];
              _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
              prefix = prefix.join('');
              suffix = suffix.join('');
              lineup = prefix + '|' + infix + '|' + suffix;
              if (glyph !== last_glyph) {
                echo('');
                last_glyph = glyph;
              }
              return echo(lineup + glyph);
            } else {
              return echo(event);
            }
          });
        };
        $transform_v3 = function() {
          return D.combine([$reorder_phrase(), $exclude_gaiji(), $include_sample(), $count_lineup_lengths(), $_XXX_sort(), $align_affixes(), $count_glyphs_etc(), $show()]);
        };
        query_v3 = {
          prefix: ['pos', 'guide/kwic/v3/sortcode']
        };
        input_v3 = (HOLLERITH.create_phrasestream(db, query_v3)).pipe($transform_v3());
        return null;
      };
    })(this));
  };

  if (module.parent == null) {
    options = {
      'route': njs_path.resolve(__dirname, '../../jizura-datasources/data/leveldb-v2')
    };
    this.show_kwic_v3();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/show-kwic-v3.js.map
