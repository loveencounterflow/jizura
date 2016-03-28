
/*


`@$align_affixes_with_braces`

```keep-lines squish: yes
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
```


`align_affixes_with_spaces`

```keep-lines squish: yes
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
```
 */

(function() {
  var $, $async, $count_lineup_lengths, $exclude_gaiji, $include_sample, $reorder_phrase, $transform_v3, $write_glyphs, $write_glyphs_description, $write_stats, $write_stats_description, ASYNC, CHR, CND, D, HOLLERITH, KWIC, TEXT, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, new_db, njs_fs, njs_path, options, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

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

  this._describe_glyph_sample = function(S) {
    if (S.glyph_sample === Infinity) {

      /* TAINT font substitution should be configured in options or other appropriate place */
      return "gamut of *N* <<<{\\mktsFontfileOptima{}≈}>>> " + (CND.format_number(75000, ',')) + " glyphs";
    } else if (CND.isa_number(S.glyph_sample)) {
      return "gamut of *N* = " + (CND.format_number(S.glyph_sample, ',')) + " glyphs";
    } else {
      return "selected glyphs: " + (S.glyph_sample.join(''));
    }
  };

  this.describe_glyphs = function(S) {
    var R, factors, plural;
    factors = Object.keys(S.factor_sample);
    R = [];
    R.push("<<(em>> ___KWIC___ Index for ");

    /* TAINT type-dependent code */
    if (factors.length > 0) {
      plural = factors.length > 1 ? 's' : '';
      R.push("factor" + plural + " " + (factors.join('')) + "; ");
    }
    R.push((this._describe_glyph_sample(S)) + ':<<)>>');
    return R.join('\n');
  };

  this.describe_stats = function(S) {
    var R, factors, plural, pronoun;
    if (!S.do_stats) {
      return "(no stats)";
    }
    factors = Object.keys(S.factor_sample);
    if (factors.length === 1) {
      plural = "";
      pronoun = "its";
    } else {
      plural = "s";
      pronoun = "their";
    }
    R = [];
    R.push("<<(em>>Statistics for factor" + plural + " " + (factors.join('')));
    if (S.two_stats) {
      R.push("and " + pronoun + " immediate suffix and prefix factors");
    } else {
      R.push("and " + pronoun + " immediate suffix factors");
    }
    R.push(" (\ue045 indicates first/last position);");
    R.push((this._describe_glyph_sample(S)) + ':<<)>>');
    return R.join('\n');
  };

  this.show_kwic_v3 = function(S) {

    /* TAINT temporary; going to use sets */
    var _fs, factor, i, len, ref;
    if (S.factor_sample != null) {
      _fs = {};
      ref = S.factor_sample;
      for (i = 0, len = ref.length; i < len; i++) {
        factor = ref[i];
        _fs[factor] = 1;
      }
      S.factor_sample = _fs;
    }
    S.glyphs_description = this.describe_glyphs(S);
    S.stats_description = this.describe_stats(S);
    urge(S.glyphs_description);
    urge(S.stats_description);
    S.query = {
      prefix: ['pos', 'guide/kwic/v3/sortcode/wrapped-lineups']
    };
    S.db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    S.db = HOLLERITH.new_db(S.db_route, {
      create: false
    });
    help("using DB at " + S.db['%self']['location']);
    step((function(_this) {
      return function*(resume) {
        var input;
        S.glyph_sample = (yield _this.read_sample(S.db, S.glyph_sample, resume));
        input = (HOLLERITH.create_phrasestream(S.db, S.query)).pipe($transform_v3(S));
        return null;
      };
    })(this));
    return null;
  };

  $reorder_phrase = (function(_this) {
    return function(S) {
      return $(function(phrase, send) {

        /* extract sortcode */
        var _, glyph, infix, prefix, sortrow, suffix;
        _ = phrase[0], _ = phrase[1], sortrow = phrase[2], glyph = phrase[3], _ = phrase[4];
        _ = sortrow[0], infix = sortrow[1], suffix = sortrow[2], prefix = sortrow[3];
        return send([glyph, prefix, infix, suffix]);
      });
    };
  })(this);

  $exclude_gaiji = (function(_this) {
    return function(S) {
      return D.$filter(function(event) {
        var glyph;
        glyph = event[0];
        return (!glyph.startsWith('&')) || (glyph.startsWith('&jzr#'));
      });
    };
  })(this);

  $include_sample = (function(_this) {
    return function(S) {
      return D.$filter(function(event) {
        var glyph, in_factor_sample, in_glyph_sample, infix, prefix, suffix;
        if ((S.glyph_sample == null) && (S.factor_sample == null)) {
          return true;
        }
        glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
        in_glyph_sample = (S.glyph_sample == null) || (glyph in S.glyph_sample);
        in_factor_sample = (S.factor_sample == null) || (infix in S.factor_sample);
        return in_glyph_sample && in_factor_sample;
      });
    };
  })(this);

  $count_lineup_lengths = (function(_this) {
    return function(S) {
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
  })(this);

  $write_stats = (function(_this) {
    return function(S) {
      var factor_pairs, glyphs, in_suffix_part, infixes, line_count, lineup_count, output;
      if (!S.do_stats) {
        return D.$pass_through();
      }
      glyphs = new Set();

      /* NB that we use a JS `Set` to record unique infixes; it has the convenient property of keeping the
      insertion order of its elements, so afterwards we can use it to determine the infix ordering.
       */
      infixes = new Set();
      factor_pairs = new Map();
      lineup_count = 0;
      output = njs_fs.createWriteStream(S.stats_route);
      line_count = 0;
      in_suffix_part = false;
      return D.$observe(function(event, has_ended) {
        var entry, factor_pair, glyph, glyph_count, glyph_count_txt, i, infix, j, key, last_infix, last_series, len, len1, line, prefix, ref, ref1, separator, series, suffix, target;
        if (event != null) {
          if (CND.isa_list(event)) {
            glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
            if (suffix.startsWith('\u3000')) {
              suffix = '\ue045';
            } else {
              suffix = suffix.trim();
            }
            suffix = Array.from(suffix);
            key = infix + "," + infix + suffix[0] + ",1";
            if ((target = factor_pairs.get(key)) == null) {
              factor_pairs.set(key, target = new Set());
            }
            target.add(glyph);
            if (S.with_prefixes) {
              if (prefix.endsWith('\u3000')) {
                prefix = '\ue045';
              } else {
                prefix = prefix.trim();
              }
              prefix = Array.from(prefix);
              key = infix + "," + prefix[prefix.length - 1] + infix + ",2";
              if ((target = factor_pairs.get(key)) == null) {
                factor_pairs.set(key, target = new Set());
              }
              target.add(glyph);
            }
            infixes.add(infix);
            glyphs.add(glyph);
            lineup_count += +1;
          }
        }
        if (has_ended) {
          help("built KWIC for " + (ƒ(glyphs.size)) + " glyphs");
          help("containing " + (ƒ(lineup_count)) + " lineups");
          infixes = Array.from(infixes);
          factor_pairs = Array.from(factor_pairs);
          for (i = 0, len = factor_pairs.length; i < len; i++) {
            entry = factor_pairs[i];
            entry[0] = entry[0].split(',');
            entry[0][2] = parseInt(entry[0][2], 10);
            entry[1] = Array.from(entry[1]);
          }
          factor_pairs.sort(function(a, b) {
            var a_glyphs, a_infix, a_infix_idx, a_pair, a_series, b_glyphs, b_infix, b_infix_idx, b_pair, b_series, ref, ref1;
            (ref = a[0], a_infix = ref[0], a_pair = ref[1], a_series = ref[2]), a_glyphs = a[1];
            (ref1 = b[0], b_infix = ref1[0], b_pair = ref1[1], b_series = ref1[2]), b_glyphs = b[1];
            a_infix_idx = infixes.indexOf(a_infix);
            b_infix_idx = infixes.indexOf(b_infix);
            if (S.two_stats) {
              if (a_series > b_series) {
                return +1;
              }
              if (a_series < b_series) {
                return -1;
              }
            }
            if (a_infix_idx > b_infix_idx) {
              return +1;
            }
            if (a_infix_idx < b_infix_idx) {
              return -1;
            }
            if (a_glyphs.length < b_glyphs.length) {
              return +1;
            }
            if (a_glyphs.length > b_glyphs.length) {
              return -1;
            }
            if (a_pair > b_pair) {
              return +1;
            }
            if (a_pair < b_pair) {
              return -1;
            }
            return 0;
          });

          /* TAINT column count should be accessible through CLI and otherwise be calculated according to
          paper size and lineup lengths
           */
          output.write("<<(columns 4>><<(JZR.vertical-bar>>\n");
          output.write("```keep-lines squish: yes\n");
          last_infix = null;
          last_series = null;
          separator = '】';
          for (j = 0, len1 = factor_pairs.length; j < len1; j++) {
            ref = factor_pairs[j], (ref1 = ref[0], infix = ref1[0], factor_pair = ref1[1], series = ref1[2]), glyphs = ref[1];
            if (S.two_stats && (last_series != null) && last_series !== series) {
              in_suffix_part = true;
              output.write("```\n");
              output.write("<<)>><<)>>\n");
              output.write("\n:::::::::::::::::::::::::::::::::::::\n\n");
              output.write("<<(columns 4>><<(JZR.vertical-bar>>\n");
              output.write("```keep-lines squish: yes\n");
              output.write("——.4\ue023" + infix + ".——\n");
            } else if (last_infix !== infix) {
              if (S.two_stats) {
                if (!in_suffix_part) {
                  output.write("——.1" + infix + "\ue023.——\n");
                } else {
                  output.write("——.2\ue023" + infix + ".——\n");
                }
              } else {
                output.write("——.3\ue023" + infix + "\ue023.——\n");
              }
            }
            last_infix = infix;
            last_series = series;
            glyph_count = glyphs.length;
            glyph_count_txt = "" + glyph_count;
            if (S.width != null) {
              while (glyphs.length < S.width) {
                glyphs.push('\u3000');
              }
              while (glyphs.length > S.width) {
                glyphs.pop();
              }
            }
            line = [factor_pair, separator, glyphs.join(''), '==>', glyph_count_txt, '\n'].join('');
            output.write(line);
            line_count += +1;
          }
          output.write("```\n");
          output.write("<<)>><<)>>\n");
          output.end();
          help("found " + infixes.length + " infixes");
          help("wrote " + line_count + " lines to " + S.stats_route);
          if (S.handler != null) {
            return S.handler(null);
          }
        }
      });
      return null;
    };
  })(this);

  $write_glyphs = (function(_this) {
    return function(S) {
      var is_first, last_infix, line_count, output;
      output = njs_fs.createWriteStream(S.glyphs_route);
      line_count = 0;
      is_first = true;
      last_infix = null;
      return D.$observe(function(event, has_ended) {
        var glyph, infix, lineup, prefix, suffix;
        if (event != null) {
          if (CND.isa_list(event)) {
            if (is_first) {

              /* TAINT column count should be accessible through CLI and otherwise be calculated according to
              paper size and lineup lengths
               */
              output.write("<<(columns 4>><<(JZR.vertical-bar>>\n");
              output.write("```keep-lines squish: yes\n");
              is_first = false;
            }
            glyph = event[0], prefix = event[1], infix = event[2], suffix = event[3];
            if (infix !== last_infix) {
              last_infix = infix;
              output.write(prefix + '【' + infix + '】' + suffix + '\n');
            } else {
              lineup = prefix + '【' + infix + '】' + suffix;
              output.write(lineup + '==>' + glyph + '\n');
            }
          } else {
            output.write(event + '\n');
          }
          line_count += +1;
        }
        if (has_ended) {
          output.write("```\n");
          output.write("<<)>><<)>>\n");
          help("wrote " + line_count + " lines to " + S.glyphs_route);
          return output.end();
        }
      });
    };
  })(this);

  $write_glyphs_description = (function(_this) {
    return function(S) {
      var output;
      output = njs_fs.createWriteStream(S.glyphs_description_route);
      return D.$observe(function(event, has_ended) {
        if (has_ended) {
          output.write(S.glyphs_description);
          help("wrote glyphs description to " + S.glyphs_description_route);
          return output.end();
        }
      });
    };
  })(this);

  $write_stats_description = (function(_this) {
    return function(S) {
      var output;
      if (!S.do_stats) {
        return D.$pass_through();
      }
      output = njs_fs.createWriteStream(S.stats_description_route);
      return D.$observe(function(event, has_ended) {
        if (has_ended) {
          output.write(S.stats_description);
          help("wrote stats description to " + S.stats_description_route);
          return output.end();
        }
      });
    };
  })(this);

  this.$align_affixes_with_braces = (function(_this) {
    return function(S) {
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
    return function(S) {

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

  $transform_v3 = (function(_this) {
    return function(S) {
      return D.combine([
        $reorder_phrase(S), $exclude_gaiji(S), $include_sample(S), $write_stats(S), $write_glyphs(S), $write_glyphs_description(S), $write_stats_description(S), D.$on_end(function() {
          if (S.handler != null) {
            return S.handler(null);
          }
        })
      ]);
    };
  })(this);

}).call(this);

//# sourceMappingURL=../sourcemaps/show-kwic-v3.js.map
