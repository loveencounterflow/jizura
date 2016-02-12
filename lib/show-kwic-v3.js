
/*


`@$align_affixes_with_braces`

<<(keep-lines>>
　　　「【虫】」　　　　虫

　　「冄【阝】」　　　　𨙻
　　　「【冄】阝」　　　𨙻

　「穴扌【未】」　　　　𥦤
　　「穴【扌】未」　　　𥦤
　　　「【穴】扌未」　　𥦤

「日业䒑【未】」　　　　曗
　「日业【䒑】未」　　　曗
　　「日【业】䒑未」　　曗
　　　「【日】业䒑未」　曗

日𠂇⺝【阝】」　　「禾　𩡏
「禾日𠂇【⺝】阝」　　　𩡏
　「禾日【𠂇】⺝阝」　　𩡏
　　「禾【日】𠂇⺝阝」　𩡏
阝」　　「【禾】日𠂇⺝　𩡏

木冖鬯【彡】」　「木缶　鬱
缶木冖【鬯】彡」　「木　鬱
「木缶木【冖】鬯彡」　　鬱
　「木缶【木】冖鬯彡」　鬱
彡」　「木【缶】木冖鬯　鬱
鬯彡」　「【木】缶木冖　鬱

山一几【夊】」「女山彳　𡤇
彳山一【几】夊」「女山　𡤇
山彳山【一】几夊」「女　𡤇
「女山彳【山】一几夊」　𡤇
夊」「女山【彳】山一几　𡤇
几夊」「女【山】彳山一　𡤇
一几夊」「【女】山彳山　𡤇

目𠃊八【夊】」「二小　𥜹
匕目𠃊【八】夊」「二　𥜹
小匕目【𠃊】八夊」「　𥜹
二小匕【目】𠃊八夊」　𥜹
「二小【匕】目𠃊八　𥜹
夊」「二【小】匕目𠃊　𥜹
八夊」「【二】小匕目　𥜹
𠃊八夊」「【】二小匕　𥜹
<<keep-lines)>>


`align_affixes_with_spaces`

<<(keep-lines>>
　　　【虫】　　　　虫

　　冄【阝】　　　　𨙻
　　　【冄】阝　　　𨙻

　穴扌【未】　　　　𥦤
　　穴【扌】未　　　𥦤
　　　【穴】扌未　　𥦤

日业䒑【未】　　　　曗
　日业【䒑】未　　　曗
　　日【业】䒑未　　曗
　　　【日】业䒑未　曗

日𠂇⺝【阝】　　禾　𩡏
禾日𠂇【⺝】阝　　　𩡏
　禾日【𠂇】⺝阝　　𩡏
　　禾【日】𠂇⺝阝　𩡏
阝　　【禾】日𠂇⺝　𩡏

木冖鬯【彡】　木缶　鬱
缶木冖【鬯】彡　木　鬱
木缶木【冖】鬯彡　　鬱
　木缶【木】冖鬯彡　鬱
彡　木【缶】木冖鬯　鬱
鬯彡　【木】缶木冖　鬱

山一几【夊】　女山　𡤇
彳山一【几】夊　女　𡤇
山彳山【一】几夊　　𡤇
女山彳【山】一几夊　𡤇
　女山【彳】山一几　𡤇
夊　女【山】彳山一　𡤇
几夊　【女】山彳山　𡤇

目𠃊八【夊】　二　𥜹
匕目𠃊【八】夊　　𥜹
小匕目【𠃊】八夊　　𥜹
二小匕【目】𠃊八夊　𥜹
二小【匕】目𠃊八　𥜹
　二【小】匕目𠃊　𥜹
夊　【二】小匕目　𥜹
八夊　【】二小匕　𥜹
<<keep-lines)>>
 */

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
        var $count_glyphs_etc, $count_lineup_lengths, $exclude_gaiji, $include_sample, $insert_hr, $insert_many_keeplines, $insert_single_keepline, $reorder_phrase, $show, $transform_v3, db_route, factor_sample, glyph_sample, include, input_v3, query_v3, ranks;
        db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
        if (db == null) {
          db = HOLLERITH.new_db(db_route, {
            create: false
          });
        }
        help("using DB at " + db['%self']['location']);
        ranks = {};
        include = 20000;
        include = 15000;
        include = 500;
        include = Infinity;
        include = 10000;
        glyph_sample = null;
        factor_sample = null;

        /* TAINT use sets */
        glyph_sample = (yield _this.read_sample(db, include, resume));
        factor_sample = {
          '旧': 1,
          '日': 1,
          '卓': 1,
          '桌': 1,
          '𠦝': 1,
          '昍': 1,
          '昌': 1,
          '晶': 1,
          '𣊭': 1,
          '早': 1,
          '白': 1,
          '㿟': 1,
          '皛': 1
        };
        $reorder_phrase = function() {
          return $(function(phrase, send) {

            /* extract sortcode */
            var _, glyph, infix, prefix, sortrow, suffix;
            _ = phrase[0], _ = phrase[1], sortrow = phrase[2], glyph = phrase[3], _ = phrase[4];
            _ = sortrow[0], infix = sortrow[1], suffix = sortrow[2], prefix = sortrow[3];
            return send([glyph, prefix, infix, suffix]);
          });
        };
        $exclude_gaiji = function() {
          return D.$filter(function(event) {
            var glyph;
            glyph = event[0];
            return (!glyph.startsWith('&')) || (glyph.startsWith('&jzr#'));
          });
        };
        $include_sample = function() {
          return D.$filter(function(event) {
            var glyph, in_factor_sample, in_glyph_sample, infix, prefix, suffix;
            if ((glyph_sample == null) && (factor_sample == null)) {
              return true;
            }
            glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
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
        $insert_many_keeplines = function() {
          var in_keeplines, last_glyph;
          in_keeplines = false;
          last_glyph = null;
          return $(function(event, send, end) {
            var glyph, sortcode;
            if (event != null) {
              if (CND.isa_list(event)) {
                glyph = event[0], sortcode = event[1];
                if ((last_glyph != null) && glyph !== last_glyph) {
                  if (in_keeplines) {
                    send("<<keep-lines)>>");
                  }
                  send('');
                  in_keeplines = false;
                }
                last_glyph = glyph;
                if (!in_keeplines) {
                  send("<<(keep-lines>>");
                }
                in_keeplines = true;
                send(event);
              } else {
                send(event);
              }
            }
            if (end != null) {
              if (in_keeplines) {
                send("<<keep-lines)>>");
              }
              return end();
            }
          });
        };
        $insert_single_keepline = function() {
          var is_first, last_infix;
          is_first = true;
          last_infix = null;
          return $(function(event, send, end) {
            var glyph, infix, prefix, suffix;
            if (event != null) {
              if (is_first) {
                send("<<(keep-lines>>");
                is_first = false;
              }
              if (CND.isa_list(event)) {
                glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
                if ((last_infix != null) && infix !== last_infix) {
                  send('');
                }
                last_infix = infix;
                send(event);
              } else {
                send(event);
              }
            }
            if (end != null) {
              send("<<keep-lines)>>");
              return end();
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
              }
            }
            if (has_ended) {
              help("built KWIC for " + (ƒ(glyphs.size)) + " glyphs");
              return help("containing " + (ƒ(lineup_count)) + " lineups");
            }
          });
        };
        $show = function() {
          return D.$observe(function(event) {
            var glyph, infix, lineup, prefix, suffix;
            if (CND.isa_list(event)) {
              glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
              lineup = prefix + '【' + infix + '】' + suffix;
              return echo(lineup + '|' + glyph);
            } else {
              return echo(event);
            }
          });
        };
        $transform_v3 = function() {
          return D.combine([$reorder_phrase(), $exclude_gaiji(), $include_sample(), D.$show(), $insert_single_keepline(), $count_glyphs_etc(), $show()]);
        };
        query_v3 = {
          prefix: ['pos', 'guide/kwic/v3/sortcode/wrapped-lineups']
        };
        input_v3 = (HOLLERITH.create_phrasestream(db, query_v3)).pipe($transform_v3());
        return null;
      };
    })(this));
  };

  this.$align_affixes_with_braces = (function(_this) {
    return function() {
      var prefix_max_length, suffix_max_length;
      prefix_max_length = 3;
      suffix_max_length = 3;
      return $(function(event, send) {
        var _, glyph, infix, prefix, prefix_delta, prefix_excess, prefix_excess_max_length, prefix_is_shortened, prefix_length, prefix_padding, sortcode, suffix, suffix_delta, suffix_excess, suffix_excess_max_length, suffix_is_shortened, suffix_length, suffix_padding;
        if (CND.isa_list(event)) {
          glyph = event[0], sortcode = event[1];
          _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
          prefix_length = prefix.length;
          suffix_length = suffix.length;
          prefix_delta = prefix_length - prefix_max_length;
          suffix_delta = suffix_length - suffix_max_length;
          prefix_excess_max_length = suffix_max_length - suffix_length;
          suffix_excess_max_length = prefix_max_length - prefix_length;
          prefix_excess = [];
          suffix_excess = [];
          prefix_padding = [];
          suffix_padding = [];
          prefix_is_shortened = false;
          suffix_is_shortened = false;
          if (prefix_delta > 0) {
            prefix_excess = prefix.splice(0, prefix_delta);
          }
          if (suffix_delta > 0) {
            suffix_excess = suffix.splice(suffix.length - suffix_delta, suffix_delta);
          }
          while (prefix_excess.length > 0 && prefix_excess.length > prefix_excess_max_length) {
            prefix_is_shortened = true;
            prefix_excess.pop();
          }
          while (suffix_excess.length > 0 && suffix_excess.length > suffix_excess_max_length) {
            suffix_is_shortened = true;
            suffix_excess.shift();
          }
          while (prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length) {
            prefix_padding.unshift('\u3000');
          }
          while (suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length) {
            suffix_padding.unshift('\u3000');
          }
          if (prefix_excess.length > 0) {
            if (prefix_excess.length !== 0) {
              prefix_excess.unshift('「');
            }
          } else {
            if (!(prefix_delta > 0)) {
              prefix.unshift('「');
            }
          }
          if (suffix_excess.length > 0) {
            if (suffix_excess.length !== 0) {
              suffix_excess.push('」');
            }
          } else {
            if (!(suffix_delta > 0)) {
              suffix.push('」');
            }
          }
          prefix.splice.apply(prefix, [0, 0].concat(slice.call(prefix_padding)));
          prefix.splice.apply(prefix, [0, 0].concat(slice.call(suffix_excess)));
          suffix.splice.apply(suffix, [suffix.length, 0].concat(slice.call(suffix_padding)));
          suffix.splice.apply(suffix, [suffix.length, 0].concat(slice.call(prefix_excess)));
          urge((prefix.join('')) + '【' + infix + '】' + (suffix.join('')));
          return send([glyph, [prefix, infix, suffix]]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$align_affixes_with_spaces = (function(_this) {
    return function() {

      /* This code has been used in `copy-jizuradb-to-Hollerith2-format#add_kwic_v3_wrapped_lineups` */
      var prefix_max_length, suffix_max_length;
      prefix_max_length = 3;
      suffix_max_length = 3;
      return $(function(event, send) {
        var _, glyph, infix, prefix, prefix_delta, prefix_excess, prefix_excess_max_length, prefix_length, prefix_padding, sortcode, suffix, suffix_delta, suffix_excess, suffix_excess_max_length, suffix_length, suffix_padding;
        if (CND.isa_list(event)) {
          glyph = event[0], sortcode = event[1];
          _ = sortcode[0], infix = sortcode[1], suffix = sortcode[2], prefix = sortcode[3];
          prefix_length = prefix.length;
          suffix_length = suffix.length;
          prefix_delta = prefix_length - prefix_max_length;
          suffix_delta = suffix_length - suffix_max_length;
          prefix_excess_max_length = suffix_max_length - suffix_length;
          suffix_excess_max_length = prefix_max_length - prefix_length;
          prefix_excess = [];
          suffix_excess = [];
          prefix_padding = [];
          suffix_padding = [];
          if (prefix_delta > 0) {
            prefix_excess = prefix.splice(0, prefix_delta);
          }
          if (suffix_delta > 0) {
            suffix_excess = suffix.splice(suffix.length - suffix_delta, suffix_delta);
          }
          while (prefix_excess.length > 0 && prefix_excess.length > prefix_excess_max_length - 1) {
            prefix_excess.pop();
          }
          while (suffix_excess.length > 0 && suffix_excess.length > suffix_excess_max_length - 1) {
            suffix_excess.shift();
          }
          while (prefix_padding.length + suffix_excess.length + prefix.length < prefix_max_length) {
            prefix_padding.unshift('\u3000');
          }
          while (suffix_padding.length + prefix_excess.length + suffix.length < suffix_max_length) {
            suffix_padding.unshift('\u3000');
          }
          prefix.splice.apply(prefix, [0, 0].concat(slice.call(prefix_padding)));
          prefix.splice.apply(prefix, [0, 0].concat(slice.call(suffix_excess)));
          suffix.splice.apply(suffix, [suffix.length, 0].concat(slice.call(suffix_padding)));
          suffix.splice.apply(suffix, [suffix.length, 0].concat(slice.call(prefix_excess)));
          urge((prefix.join('')) + '【' + infix + '】' + (suffix.join('')));
          return send([glyph, [prefix, infix, suffix]]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  if (module.parent == null) {
    options = {
      'route': njs_path.resolve(__dirname, '../../jizura-datasources/data/leveldb-v2')
    };
    this.show_kwic_v3();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/show-kwic-v3.js.map
