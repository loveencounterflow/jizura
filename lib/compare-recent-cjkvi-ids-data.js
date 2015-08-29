(function() {
  var $, $async, CHR, CND, D, HOLLERITH, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_fs, njs_path, options, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  join = njs_path.join;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'HOLLERITH/copy';

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

  CHR = require('coffeenode-chr');

  ƒ = CND.format_number.bind(CND);

  options = this.$show_progress = function(size) {
    var glyph_count, last_glyph, phrase_count;
    if (size == null) {
      size = 1e3;
    }
    phrase_count = 0;
    glyph_count = 0;
    last_glyph = null;
    return D.$observe((function(_this) {
      return function(_, has_ended) {
        if (!has_ended) {
          phrase_count += 1;
          if (phrase_count % size === 0) {
            return echo(ƒ(phrase_count));
          }
        } else {
          return help("read " + (ƒ(phrase_count)) + " records");
        }
      };
    })(this));
  };

  options = {
    'comment-marks': ['#', ';'],
    'cjkvi-ncr-kernel-pattern': /^(?:(U)\+|(CDP)-)([0-9A-F]{4,5})$/,
    'cjkvi-ncr-pattern': /&([^;]+);/g,
    'blank-line-tester': /^\s*$/,
    'known-ref-mismatches': {
      '鿉鿈': '鿉'
    }
  };

  this.read_glyph_categories = function(db, handler) {
    var Z, count, input, query;
    Z = {};
    count = 0;
    query = {
      prefix: ['pos', 'cp/'],
      star: '*'
    };
    input = HOLLERITH.create_phrasestream(db, query);
    return input.pipe($((function(_this) {
      return function(phrase, send) {
        var _, glyph, prd;
        _ = phrase[0], prd = phrase[1], _ = phrase[2], glyph = phrase[3];
        if (prd === 'cp/inner/original' || prd === 'cp/inner/mapped' || prd === 'cp/outer/original' || prd === 'cp/outer/mapped') {
          Z[glyph] = prd;
          count += +1;
          return send(glyph);
        }
      };
    })(this))).pipe(this.$show_progress(1e4)).pipe(D.$on_end((function(_this) {
      return function() {
        help("read categories for " + (ƒ(count)) + " glyphs");
        njs_fs.writeFileSync('/tmp/glyph-categories.json', JSON.stringify(Z, null, '  '));
        return handler(null, Z);
      };
    })(this)));
  };

  this.$filter_comments_and_empty_lines = function() {
    return $((function(_this) {
      return function(line, send) {
        var ref;
        if ((options['blank-line-tester'].test(line)) || (ref = line[0], indexOf.call(options['comment-marks'], ref) >= 0)) {
          return null;
        } else {
          return send(line);
        }
      };
    })(this));
  };

  this.chr_from_cjkvi_ncr_kernel = function(cjkvi_ncr_kernel) {
    var cid, csg, match, ref;
    match = cjkvi_ncr_kernel.match(options['cjkvi-ncr-kernel-pattern']);
    if (match == null) {
      throw new Error("unexpected CJVKI NCR kernel: " + (rpr(cjkvi_ncr_kernel)));
    } else {
      csg = ((ref = match[1]) != null ? ref : match[2]).toLowerCase();
      cid = parseInt(match[3], 16);
      return CHR._as_chr(csg, cid);
    }
  };

  this.$resolve_cjkvi_kernel = function() {
    return $((function(_this) {
      return function(fields, send) {
        var cjkvi_formulas, cjkvi_ncr_kernel, glyph, glyph_reference;
        if (fields.length === 0) {
          return;
        }
        cjkvi_ncr_kernel = fields[0], glyph = fields[1], cjkvi_formulas = 3 <= fields.length ? slice.call(fields, 2) : [];
        glyph_reference = _this.chr_from_cjkvi_ncr_kernel(cjkvi_ncr_kernel);
        return send([glyph_reference, glyph].concat(slice.call(cjkvi_formulas)));
      };
    })(this));
  };

  this.$normalize_cjkvi_ncrs = function() {
    var pattern;
    pattern = options['cjkvi-ncr-pattern'];
    return $((function(_this) {
      return function(fields, send) {
        var field_idx, i, ref;
        for (field_idx = i = 1, ref = fields.length; 1 <= ref ? i < ref : i > ref; field_idx = 1 <= ref ? ++i : --i) {
          fields[field_idx] = fields[field_idx].replace(pattern, function($0, $1) {
            return _this.chr_from_cjkvi_ncr_kernel($1);
          });
        }
        return send(fields);
      };
    })(this));
  };

  this.$check_glyph_reference = function() {
    return $((function(_this) {
      return function(fields, send) {
        var cjkvi_formulas, glyph, glyph_reference, key, replacement;
        glyph_reference = fields[0], glyph = fields[1], cjkvi_formulas = 3 <= fields.length ? slice.call(fields, 2) : [];
        if (glyph_reference !== glyph) {
          key = glyph_reference + glyph;
          replacement = options['known-ref-mismatches'][key];
          if (replacement == null) {
            warn("unknown glyph reference mismatch: " + (rpr(glyph_reference)) + ", " + (rpr(glyph)));
          }
          glyph = replacement;
        }
        return send([glyph, cjkvi_formulas]);
      };
    })(this));
  };

  this.$filter_outer_mapped_and_unknown_glyphs = function(glyph_categories) {
    var counts, unknown_non_cjk_xe;
    counts = {
      'unknown': 0,
      'cp/inner/original': 0,
      'cp/inner/mapped': 0,
      'cp/outer/original': 0,
      'cp/outer/mapped': 0
    };
    unknown_non_cjk_xe = [];
    return $((function(_this) {
      return function(fields, send, end) {
        var category, cjkvi_formulas, fncr, glyph, ref, rsg;
        if (fields != null) {
          glyph = fields[0], cjkvi_formulas = fields[1];
          category = (ref = glyph_categories[glyph]) != null ? ref : 'unknown';
          counts[category] += +1;
          rsg = CHR.as_rsg(glyph, {
            input: 'xncr'
          });
          if (category === 'unknown' && !(rsg === 'cdp' || rsg === 'u-cjk-xe')) {
            fncr = CHR.as_fncr(glyph, {
              input: 'xncr'
            });
            unknown_non_cjk_xe.push("glyph " + fncr + " " + glyph);
          }
          if (category === 'cp/inner/original') {
            send([glyph, cjkvi_formulas]);
          }
        }
        if (end != null) {
          help("filtering counts:");
          help('\n' + rpr(counts));
          help();
          help("of the " + (ƒ(counts['unknown'])) + " unknown codepoints,");
          help((ƒ(unknown_non_cjk_xe.length)) + " are *not* from Unicode V8 CJK Ext. E:");
          help('\n' + rpr(unknown_non_cjk_xe));
          return end();
        }
      };
    })(this));
  };

  this.$remove_region_annotations = function() {
    return $((function(_this) {
      return function(fields, send) {
        var cjkvi_formulas, formula, glyph, i, idx, len;
        glyph = fields[0], cjkvi_formulas = fields[1];
        for (idx = i = 0, len = cjkvi_formulas.length; i < len; idx = ++i) {
          formula = cjkvi_formulas[idx];
          cjkvi_formulas[idx] = formula.replace(/\[[^\]]+\]/g, '');
        }
        return send([glyph, cjkvi_formulas]);
      };
    })(this));
    return R;
  };

  this.$retrieve_jzr_formulas = function(db) {
    return $async((function(_this) {
      return function(fields, done) {
        return step(function*(resume) {
          var _, cjkvi_formulas, glyph, jzr_formulas, phrase, prefix, query;
          glyph = fields[0], cjkvi_formulas = fields[1];
          prefix = ['spo', glyph, 'formula'];
          query = {
            prefix: prefix,
            fallback: [null, null, null, []]
          };
          phrase = (yield HOLLERITH.read_one_phrase(db, query, resume));
          _ = phrase[0], _ = phrase[1], _ = phrase[2], jzr_formulas = phrase[3];
          return done([glyph, cjkvi_formulas, jzr_formulas]);
        });
      };
    })(this));
    return R;
  };

  this.$compare_formulas = function() {
    var diff_count, glyph_count, missing_count;
    glyph_count = 0;
    diff_count = 0;
    missing_count = 0;
    return $((function(_this) {
      return function(fields, send, end) {
        var cjkvi_formula, cjkvi_formulas, fncr, glyph, i, jzr_formulas, len;
        if (fields != null) {
          glyph = fields[0], cjkvi_formulas = fields[1], jzr_formulas = fields[2];
          glyph_count += +1;
          if (jzr_formulas.length === 0) {
            fncr = CHR.as_fncr(glyph, {
              input: 'xncr'
            });
            warn("no formulas found for glyph " + fncr + " " + glyph);
            missing_count += +1;
          } else {
            for (i = 0, len = cjkvi_formulas.length; i < len; i++) {
              cjkvi_formula = cjkvi_formulas[i];

              /* Skip identity formulas like `X = X` which we express as `X = ●` */
              if (cjkvi_formula === glyph) {
                continue;
              }
              if (!(indexOf.call(jzr_formulas, cjkvi_formula) >= 0)) {
                fncr = CHR.as_fncr(glyph, {
                  input: 'xncr'
                });
                diff_count += +1;
                echo('difference:', fncr + " " + glyph + " " + cjkvi_formula + " " + (rpr(jzr_formulas)));
              }
            }
          }
        }
        if (end != null) {
          help("differences in formulas:");
          help("glyphs:             " + (ƒ(glyph_count)));
          help("missing formulas:   " + (ƒ(missing_count)));
          help("different formulas: " + (ƒ(diff_count)));
          return end();
        }
      };
    })(this));
  };

  this.compare = function() {
    var cjkvi_route, db, db_route, home, input;
    home = join(__dirname, '../../jizura-datasources');
    cjkvi_route = join(home, 'data/flat-files/shape/github.com´cjkvi´cjkvi-ids/ids.txt');
    input = njs_fs.createReadStream(cjkvi_route);
    db_route = join(home, 'data/leveldb-v2');
    db = HOLLERITH.new_db(db_route);
    return step((function(_this) {
      return function*(resume) {
        var glyph_categories;
        glyph_categories = (yield _this.read_glyph_categories(db, resume));
        return input.pipe(D.$split()).pipe(_this.$filter_comments_and_empty_lines()).pipe(D.$parse_csv({
          headers: false,
          delimiter: '\t'
        })).pipe(_this.$resolve_cjkvi_kernel()).pipe(_this.$normalize_cjkvi_ncrs()).pipe(_this.$check_glyph_reference()).pipe(_this.$show_progress(1e4)).pipe(_this.$filter_outer_mapped_and_unknown_glyphs(glyph_categories)).pipe(_this.$remove_region_annotations()).pipe(_this.$retrieve_jzr_formulas(db)).pipe(_this.$compare_formulas());
      };
    })(this));
  };

  if (module.parent == null) {
    this.compare();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/compare-recent-cjkvi-ids-data.js.map