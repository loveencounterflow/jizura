(function() {
  var $, $async, CND, D, HOLLERITH, IDLX, KWIC, XNCHR, alert, badge, debug, echo, help, info, join, log, njs_fs, njs_path, options, rpr, step, suspend, urge, warn, whisper, ƒ,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

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

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  HOLLERITH = require('hollerith');

  KWIC = require('kwic');

  IDLX = require('idlx');

  XNCHR = require('./XNCHR');

  ƒ = CND.format_number.bind(CND);

  options = {
    sample: null
  };

  this.$show_progress = function(size) {
    var glyph_count, last_glyph, phrase_count;
    if (size == null) {
      size = 1e3;
    }
    phrase_count = 0;
    glyph_count = 0;
    last_glyph = null;
    return D.$observe((function(_this) {
      return function(phrase, has_ended) {
        var glyph;
        if (!has_ended) {
          phrase_count += 1;
          if (phrase_count % size === 0) {
            echo(ƒ(phrase_count));
          }
          if ((glyph = phrase[0]) !== last_glyph) {
            glyph_count += +1;
          }
          return last_glyph = glyph;
        } else {
          help("read " + (ƒ(phrase_count)) + " phrases for " + (ƒ(glyph_count)) + " glyphs");
          return help("(" + ((phrase_count / glyph_count).toFixed(2)) + " phrases per glyph)");
        }
      };
    })(this));
  };

  this.$keep_small_sample = function() {
    return $((function(_this) {
      return function(key, send) {
        var glyph, idx, obj, prd;
        if (options['sample'] == null) {
          return send(key);
        }
        glyph = key[0], prd = key[1], obj = key[2], idx = key[3];
        if (indexOf.call(options['sample'], glyph) >= 0) {
          return send(key);
        }
      };
    })(this));
  };

  this.$throw_out_pods = function() {
    return $((function(_this) {
      return function(key, send) {
        var glyph, idx, obj, prd;
        glyph = key[0], prd = key[1], obj = key[2], idx = key[3];
        if (prd !== 'pod') {
          return send(key);
        }
      };
    })(this));
  };

  this.$remove_duplicate_kana_readings = function() {
    var readings_by_glyph;
    readings_by_glyph = {};
    return $((function(_this) {
      return function(key, send) {
        var glyph, idx, obj, prd, target;
        glyph = key[0], prd = key[1], obj = key[2], idx = key[3];
        if (prd === 'reading/hi') {
          target = readings_by_glyph[glyph] != null ? readings_by_glyph[glyph] : readings_by_glyph[glyph] = [];
          if (indexOf.call(target, obj) >= 0) {
            return warn("skipping duplicate reading " + glyph + " " + obj);
          }
          target.push(obj);
        }
        return send(key);
      };
    })(this));
  };

  this.$cast_types = function(ds_options) {
    return $((function(_this) {
      return function(arg, send) {
        var idx, obj, prd, sbj, type, type_description;
        sbj = arg[0], prd = arg[1], obj = arg[2], idx = arg[3];
        type_description = ds_options['schema'][prd];
        if (type_description == null) {
          warn("no type description for predicate " + (rpr(prd)));
        } else {
          switch (type = type_description['type']) {
            case 'int':
              obj = parseInt(obj, 10);
              break;
            case 'text':

              /* TAINT we have no booleans configured */
              if (obj === 'true') {
                obj = true;
              } else if (obj === 'false') {
                obj = false;
              }
          }
        }
        return send(idx != null ? [sbj, prd, obj, idx] : [sbj, prd, obj]);
      };
    })(this));
  };

  this.$collect_lists = function() {
    var context_keys, has_errors, last_digest, objs, sbj_prd;
    objs = null;
    sbj_prd = null;
    last_digest = null;
    context_keys = [];
    has_errors = false;
    return $((function(_this) {
      return function(key, send, end) {
        var digest, idx, obj, prd, sbj;
        if (key != null) {
          context_keys.push(key);
          if (context_keys.length > 10) {
            context_keys.shift();
          }
          sbj = key[0], prd = key[1], obj = key[2], idx = key[3];
          digest = JSON.stringify([sbj, prd]);
          if (digest === last_digest) {
            if (idx != null) {
              objs[idx] = obj;
            } else {

              /* A certain subject/predicate combination can only ever be repeated if an index is
              present in the key
               */
              alert();
              alert("erroneous repeated entry; context:");
              alert(context_keys);
              has_errors = true;
            }
          } else {
            if (objs != null) {
              send(slice.call(sbj_prd).concat([objs]));
            }
            objs = null;
            last_digest = digest;
            if (idx != null) {
              objs = [];
              objs[idx] = obj;
              sbj_prd = [sbj, prd];
            } else {
              send(key);
            }
          }
        }
        if (end != null) {
          if (objs != null) {
            send(slice.call(sbj_prd).concat([objs]));
          }
          if (has_errors) {
            return send.error(new Error("there were errors; see alerts above"));
          }
          end();
        }
        return null;
      };
    })(this));
  };

  this.$compact_lists = function() {
    return $((function(_this) {
      return function(arg, send) {
        var element, new_obj, obj, prd, sbj;
        sbj = arg[0], prd = arg[1], obj = arg[2];

        /* Compactify sparse lists so all `undefined` elements are removed; warn about this */
        if ((CND.type_of(obj)) === 'list') {
          new_obj = (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = obj.length; k < len; k++) {
              element = obj[k];
              if (element !== void 0) {
                results.push(element);
              }
            }
            return results;
          })();
          if (obj.length !== new_obj.length) {
            warn("phrase " + (rpr([sbj, prd, obj])) + " contained undefined elements; compactified");
          }
          obj = new_obj;
        }
        return send([sbj, prd, obj]);
      };
    })(this));
  };

  this.$add_version_to_kwic_v1 = function() {

    /* mark up all predicates `guide/kwic/*` as `guide/kwic/v1/*` */
    return $((function(_this) {
      return function(arg, send) {
        var obj, prd, sbj;
        sbj = arg[0], prd = arg[1], obj = arg[2];
        if (prd.startsWith('guide/kwic/')) {
          prd = prd.replace(/^guide\/kwic\//, 'guide/kwic/v1/');
        }
        return send([sbj, prd, obj]);
      };
    })(this));
  };

  this._long_wrapped_lineups_from_guides = function(guides) {

    /* Extending lineups to accommodate for glyphs with 'overlong' factorials (those with more than 6
    factors; these were previously excluded from the gamut in `feed-db.coffee`, line 2135,
    `@KWIC.$compose_lineup_facets`).
     */

    /* TAINT here be magic numbers */
    var R, idx, infix, k, last_idx, lineup, prefix, ref, suffix;
    lineup = guides.slice(0);
    last_idx = lineup.length - 1 + 6;
    while (lineup.length < 19) {
      lineup.push('\u3000');
    }
    while (lineup.length < 25) {
      lineup.unshift('\u3000');
    }
    R = [];
    for (idx = k = 6, ref = last_idx; 6 <= ref ? k <= ref : k >= ref; idx = 6 <= ref ? ++k : --k) {
      infix = lineup[idx];
      suffix = lineup.slice(idx + 1, +(idx + 6) + 1 || 9e9).join('');
      prefix = lineup.slice(idx - 6, +(idx - 1) + 1 || 9e9).join('');
      R.push([infix, suffix, prefix].join(','));
    }
    return R;
  };

  this.$add_kwic_v3 = function(factor_infos) {

    /* see `demo/show_kwic_v2_and_v3_sample` */
    return $((function(_this) {
      return function(arg, send) {
        var _, factor, factors, glyph, obj, permutations, prd, ref, ref1, sbj, sortcode, sortcode_v1, sortrow_v1, weights, x;
        sbj = arg[0], prd = arg[1], obj = arg[2];
        if (prd.startsWith('guide/kwic/v2/')) {
          return;
        }
        if (!prd.startsWith('guide/kwic/v1/')) {
          return send([sbj, prd, obj]);
        }
        if (prd !== 'guide/kwic/v1/sortcode') {
          return;
        }
        ref = [sbj, prd, obj], glyph = ref[0], _ = ref[1], (ref1 = ref[2], sortcode_v1 = ref1[0]);
        sortrow_v1 = (function() {
          var k, len, ref2, results;
          ref2 = sortcode_v1.split(/(........,..),/);
          results = [];
          for (k = 0, len = ref2.length; k < len; k++) {
            x = ref2[k];
            if (x.length > 0) {
              results.push(x);
            }
          }
          return results;
        })();
        weights = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = sortrow_v1.length; k < len; k++) {
            x = sortrow_v1[k];
            results.push(x.split(','));
          }
          return results;
        })();
        weights.pop();
        weights = (function() {
          var k, len, ref2, results;
          results = [];
          for (k = 0, len = weights.length; k < len; k++) {
            ref2 = weights[k], sortcode = ref2[0], _ = ref2[1];
            results.push(sortcode);
          }
          return results;
        })();
        weights = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = weights.length; k < len; k++) {
            sortcode = weights[k];
            if (sortcode !== '--------') {
              results.push(sortcode);
            }
          }
          return results;
        })();
        weights = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = weights.length; k < len; k++) {
            sortcode = weights[k];
            results.push(sortcode.replace(/~/g, '-'));
          }
          return results;
        })();
        weights = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = weights.length; k < len; k++) {
            sortcode = weights[k];
            results.push(sortcode.replace(/----/g, 'f---'));
          }
          return results;
        })();
        factors = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = weights.length; k < len; k++) {
            sortcode = weights[k];
            results.push(factor_infos[sortcode]);
          }
          return results;
        })();
        factors = (function() {
          var k, len, results;
          results = [];
          for (k = 0, len = factors.length; k < len; k++) {
            factor = factors[k];
            results.push(factor != null ? factor : '〓');
          }
          return results;
        })();
        if (weights.length !== factors.length) {
          warn(glyph, weights, factors, weights.length, factors.length);
          return;
        }
        permutations = KWIC.get_permutations(factors, weights);
        return send([glyph, 'guide/kwic/v3/sortcode', permutations]);
      };
    })(this));
  };

  this.$add_kwic_v3_wrapped_lineups = function(factor_infos) {
    var prefix_max_length, suffix_max_length;
    prefix_max_length = 3;
    suffix_max_length = 3;
    return $((function(_this) {
      return function(arg, send) {
        var _, glyph, idx, infix, k, len, lineups, obj, permutation, permutations, prd, prefix, prefix_delta, prefix_excess, prefix_excess_max_length, prefix_length, prefix_padding, ref, sbj, sortcode, suffix, suffix_delta, suffix_excess, suffix_excess_max_length, suffix_length, suffix_padding;
        sbj = arg[0], prd = arg[1], obj = arg[2];
        send([sbj, prd, obj]);
        if (prd !== 'guide/kwic/v3/sortcode') {
          return;
        }
        ref = [sbj, prd, obj], glyph = ref[0], _ = ref[1], permutations = ref[2];
        lineups = [];
        for (idx = k = 0, len = permutations.length; k < len; idx = ++k) {
          permutation = permutations[idx];
          sortcode = permutation[0], infix = permutation[1], suffix = permutation[2], prefix = permutation[3];
          suffix = Object.assign([], suffix);
          prefix = Object.assign([], prefix);
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
          prefix = prefix.join('');
          suffix = suffix.join('');
          lineups.push([sortcode, infix, suffix, prefix]);
        }
        return send([glyph, 'guide/kwic/v3/sortcode/wrapped-lineups', lineups]);
      };
    })(this));
  };

  this.$add_factor_membership = function(factor_infos) {
    var glyphs_by_factors;
    glyphs_by_factors = {};
    return $((function(_this) {
      return function(phrase, send, end) {
        var factor, glyph, glyphs, k, len, obj, prd;
        if (phrase != null) {
          send(phrase);
          glyph = phrase[0], prd = phrase[1], obj = phrase[2];
          if (prd !== 'guide/has/uchr') {
            return;
          }
          for (k = 0, len = obj.length; k < len; k++) {
            factor = obj[k];
            if (factor === glyph) {
              continue;
            }
            (glyphs_by_factors[factor] != null ? glyphs_by_factors[factor] : glyphs_by_factors[factor] = new Set()).add(glyph);
          }
        }
        if (end != null) {
          for (factor in glyphs_by_factors) {
            glyphs = glyphs_by_factors[factor];
            send([factor, 'factor/has/glyph/uchr', Array.from(glyphs.keys())]);
          }
          return end();
        }
      };
    })(this));
  };


  /* TAINT code duplication */

  this.$add_components = function() {

    /* The field `component/uchr` lists all the components that appear as part of a given glyph,
    collected from all its formulas and down through all recursive steps of component resolution. The
    resulting lists can, therefore, be quite long and potentially include parts that are present in
    virtually all glyphs, such as `丿` or `一`. The components listed are unique and appear in no
    particular order. As an example, the DB contains the folloqing entry:
    
    ```
    spo|䱴|component/uchr: [ '魚', '恒', '', '灬', '𠂊', '田', '丿', '㇇', '囗', '十', '日',
    '丨', '冂', '一', '𠃌', '彐', '', '', '丶', '', '忄', '亘', '旦', ]
    ```
     */

    /* Immediate Constituents (ICs) */
    var glyph_count, ics_by_glyph, resolve_ics, seen_glyphs;
    ics_by_glyph = {};
    seen_glyphs = new Set();
    glyph_count = 0;
    resolve_ics = (function(_this) {
      return function(glyph) {
        var entry, ic, k, len, ref, results, sub_entry, sub_ic;
        if (seen_glyphs.has(glyph)) {
          return;
        }
        seen_glyphs.add(glyph);
        if ((entry = ics_by_glyph[glyph]) != null) {
          ref = Array.from(entry.keys());
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            ic = ref[k];
            resolve_ics(ic);
            if ((sub_entry = ics_by_glyph[ic]) != null) {
              results.push((function() {
                var l, len1, ref1, results1;
                ref1 = Array.from(sub_entry);
                results1 = [];
                for (l = 0, len1 = ref1.length; l < len1; l++) {
                  sub_ic = ref1[l];
                  results1.push(entry.add(sub_ic));
                }
                return results1;
              })());
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      };
    })(this);
    return $((function(_this) {
      return function(phrase, send, end) {
        var entry, formula, formula_idx, glyph, ic, ics, k, l, len, len1, obj, prd, target;
        if (phrase != null) {
          send(phrase);
          glyph = phrase[0], prd = phrase[1], obj = phrase[2];
          if (prd !== 'formula') {
            return;
          }

          /* TAINT collecting ICs from outer glyphs might aid in resolving more inner glyphs */
          if (!XNCHR.is_inner_glyph(glyph)) {
            return;
          }
          glyph = XNCHR.as_uchr(glyph);
          glyph_count += +1;
          for (formula_idx = k = 0, len = obj.length; k < len; formula_idx = ++k) {
            formula = obj[formula_idx];
            ics = IDLX.find_all_non_operators(formula);
            target = ics_by_glyph[glyph] != null ? ics_by_glyph[glyph] : ics_by_glyph[glyph] = new Set();
            for (l = 0, len1 = ics.length; l < len1; l++) {
              ic = ics[l];
              target.add(XNCHR.as_uchr(ic));
            }
          }
        }
        if (end != null) {
          for (glyph in ics_by_glyph) {
            resolve_ics(glyph);
          }
          for (glyph in ics_by_glyph) {
            entry = ics_by_glyph[glyph];
            ics_by_glyph[glyph] = Array.from(entry);
          }
          for (glyph in ics_by_glyph) {
            ics = ics_by_glyph[glyph];
            send([glyph, 'component/uchr', ics]);
          }
          end();
        }
        return null;
      };
    })(this));
  };


  /* TAINT code duplication */

  this.$add_factorial_factors = function(factor_infos) {

    /* Factorial Factors: the factors of factors; used for cross-referencing. E.g. the formula of
    鬲 is ⿱𠮛⿵冂&jzr#xe152;; all the components of 鬲 are factors except for 𠮛, which must again be
    analyzed into 𠮛:⿱一口, leading to the entry 鬲:一口冂&jzr#xe152;.
     */
    var _, factor, factor_count, factors, factors_by_factor, seen_glyphs;
    factors = new Set();
    for (_ in factor_infos) {
      factor = factor_infos[_];
      factors.add(XNCHR.as_uchr(factor));
    }

    /* Immediate Constituents (ICs) */
    factors_by_factor = {};
    seen_glyphs = new Set();
    factor_count = 0;
    return $((function(_this) {
      return function(phrase, send, end) {
        var entry, factors_by_factor_json, factors_json, factors_route, formula, formula_idx, glyph, ic, ics, ics_route, k, len, obj, prd;
        if (phrase != null) {
          send(phrase);
          glyph = phrase[0], prd = phrase[1], obj = phrase[2];
          if (prd !== 'formula') {
            return;
          }

          /* TAINT collecting ICs from outer glyphs might aid in resolving more inner glyphs */
          if (!XNCHR.is_inner_glyph(glyph)) {
            return;
          }
          glyph = XNCHR.as_uchr(glyph);
          if (factors.has(glyph)) {
            factor_count += +1;
          }
          entry = factors_by_factor[glyph] != null ? factors_by_factor[glyph] : factors_by_factor[glyph] = [];
          for (formula_idx = k = 0, len = obj.length; k < len; formula_idx = ++k) {
            formula = obj[formula_idx];
            ics = IDLX.find_all_non_operators(formula);
            entry.push((function() {
              var l, len1, results;
              results = [];
              for (l = 0, len1 = ics.length; l < len1; l++) {
                ic = ics[l];
                results.push(XNCHR.as_uchr(ic));
              }
              return results;
            })());
          }
        }
        if (end != null) {
          factors_by_factor_json = JSON.stringify(factors_by_factor, null, '  ');
          factors_json = JSON.stringify(Array.from(factors), null, '  ');
          ics_route = njs_path.resolve(__dirname, '../../jizura-datasources/data/5-derivatives/ics-by-glyphs.json');
          factors_route = njs_path.resolve(__dirname, '../../jizura-datasources/data/5-derivatives/factors.json');
          warn("write to " + ics_route);
          njs_fs.writeFileSync(ics_route, factors_by_factor_json);
          warn("write to " + factors_route);
          njs_fs.writeFileSync(factors_route, factors_json);
          end();
        }
        return null;
      };
    })(this));
  };


  /* TAINT code duplication */

  this.$add_lineup_back_and_forwards = function() {
    return $((function(_this) {
      return function(phrase, send) {
        var backwards_lineups, forwards_lineups, glyph, idx, infix, k, len, obj, permutation, prd, prefix, sortcode, suffix;
        send(phrase);
        glyph = phrase[0], prd = phrase[1], obj = phrase[2];
        if (prd !== 'guide/kwic/v3/sortcode') {
          return;
        }
        if (!XNCHR.is_inner_glyph(glyph)) {
          return;
        }
        forwards_lineups = [];
        backwards_lineups = [];
        for (idx = k = 0, len = obj.length; k < len; idx = ++k) {
          permutation = obj[idx];
          sortcode = permutation[0], infix = permutation[1], suffix = permutation[2], prefix = permutation[3];
          forwards_lineups.push(infix + suffix.join(''));
          backwards_lineups.push(infix + (Object.assign([], prefix)).reverse().join(''));
        }
        send([glyph, 'guide/kwic/lineup/forwards', forwards_lineups]);
        send([glyph, 'guide/kwic/lineup/backwards', backwards_lineups]);
        return null;
      };
    })(this));
  };

  this.$add_sims = function() {
    var sims_by_glyph;
    sims_by_glyph = {};
    return $((function(_this) {
      return function(phrase, send, end) {
        var _, prd, ref, sims, source_glyph, tag, target, target_glyph;
        if (phrase != null) {
          send(phrase);
          source_glyph = phrase[0], prd = phrase[1], target_glyph = phrase[2];
          if (!prd.startsWith('sim/')) {
            return;
          }
          if (!XNCHR.is_inner_glyph(source_glyph)) {
            return;
          }
          ref = prd.match(/\/(.+)$/), _ = ref[0], tag = ref[1];
          target = sims_by_glyph[target_glyph] != null ? sims_by_glyph[target_glyph] : sims_by_glyph[target_glyph] = {};
          (target[tag] != null ? target[tag] : target[tag] = []).push(source_glyph);
        }
        if (end != null) {
          for (target_glyph in sims_by_glyph) {
            sims = sims_by_glyph[target_glyph];
            send([target_glyph, "sims/from", sims]);
          }
          return end();
        }
      };
    })(this));
  };

  this.$add_guide_pairs = function(factor_infos) {
    var collector, derivatives, derivatives_home, derivatives_route, excludes, get_pairs, guide_uchr, home, sortcode, sortcode_by_factors;
    sortcode_by_factors = {};
    for (sortcode in factor_infos) {
      guide_uchr = factor_infos[sortcode];
      sortcode_by_factors[guide_uchr] = sortcode;
    }

    /* TAINT code duplication */

    /* TAIN make configurable / store in options */
    home = njs_path.resolve(__dirname, '../../jizura-datasources');
    derivatives_home = njs_path.resolve(home, 'data/5-derivatives');
    derivatives_route = njs_path.resolve(derivatives_home, 'guide-pairs.txt');
    derivatives = njs_fs.createWriteStream(derivatives_route, {
      encoding: 'utf-8'
    });
    collector = [];
    excludes = ['一'];
    help("writing results of `add_guide_pairs` to " + derivatives_route);
    derivatives.write("# generated on " + (new Date()) + "\n# by " + __filename + "\n\n\n");
    get_pairs = function(glyph, guides) {

      /* TAINT allow or eliminate duplicates? use pairs and reversed pairs? */
      var R, chrs, entries, guide_0, guide_1, i, j, k, key, l, length, ref, ref1, ref2, seen, sortcode_0, sortcode_1, sortcodes;
      length = guides.length;
      chrs = [];
      sortcodes = [];
      entries = [];
      seen = {};
      R = {
        chrs: chrs,
        entries: entries
      };
      if (length < 2) {
        return R;
      }
      for (i = k = 0, ref = length - 1; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        for (j = l = ref1 = i + 1, ref2 = length; ref1 <= ref2 ? l < ref2 : l > ref2; j = ref1 <= ref2 ? ++l : --l) {
          guide_0 = guides[i];
          guide_1 = guides[j];
          if (indexOf.call(excludes, guide_0) >= 0 || indexOf.call(excludes, guide_1) >= 0) {
            continue;
          }
          sortcode_0 = sortcode_by_factors[guide_0];
          sortcode_1 = sortcode_by_factors[guide_1];
          if (sortcode_0 == null) {
            sortcode_0 = 'zzzzzzzz';
          }
          if (sortcode_1 == null) {
            sortcode_1 = 'zzzzzzzz';
          }
          key = guide_0 + guide_1;
          if (!(key in seen)) {
            chrs.push(key);
            entries.push(sortcode_0 + " " + sortcode_1 + "\t" + key + "\t" + glyph);
            seen[key] = 1;
          }
          key = guide_1 + guide_0;
          if (!(key in seen)) {
            chrs.push(key);
            entries.push(sortcode_1 + " " + sortcode_0 + "\t" + key + "\t" + glyph);
            seen[key] = 1;
          }
        }
      }
      return R;
    };
    return $((function(_this) {
      return function(phrase, send, end) {
        var _, chrs, entries, entry, glyph, guides, k, l, len, len1, obj, prd, ref, ref1, sbj;
        if (phrase != null) {
          send(phrase);
          sbj = phrase[0], prd = phrase[1], obj = phrase[2];
          if (prd === 'guide/has/uchr') {
            ref = [sbj, prd, obj], glyph = ref[0], _ = ref[1], guides = ref[2];
            if (XNCHR.is_inner_glyph(glyph)) {
              ref1 = get_pairs(glyph, guides), chrs = ref1.chrs, entries = ref1.entries;
              for (k = 0, len = entries.length; k < len; k++) {
                entry = entries[k];
                collector.push(entry);
              }
              send([glyph, 'guide/pair/uchr', chrs]);
              send([glyph, 'guide/pair/entry', entries]);
            }
          }
        }
        if (end != null) {
          debug('©70RRX', new Date());
          whisper("sorting guide pairs...");
          collector.sort();
          whisper("done");
          debug('©70RRX', new Date());
          whisper("writing guide pairs...");
          for (l = 0, len1 = collector.length; l < len1; l++) {
            entry = collector[l];
            derivatives.write(entry + '\n');
          }
          derivatives.end();
          whisper("done");
          debug('©70RRX', new Date());
          return end();
        }
      };
    })(this));
  };

  this.v1_split_so_bkey = function(bkey) {
    var R, idx, idx_txt, k, len, r;
    R = bkey.toString('utf-8');
    R = R.split('|');
    idx_txt = R[3];
    R = [(R[1].split(':'))[1]].concat(slice.call(R[2].split(':')));
    if ((idx_txt != null) && idx_txt.length > 0) {
      R.push(parseInt(idx_txt, 10));
    }
    for (idx = k = 0, len = R.length; k < len; idx = ++k) {
      r = R[idx];
      if (!CND.isa_text(r)) {
        continue;
      }
      if (indexOf.call(r, 'µ') < 0) {
        continue;
      }
      R[idx] = this.v1_unescape(r);
    }
    return R;
  };

  this.v1_$split_so_bkey = function() {
    return $((function(_this) {
      return function(bkey, send) {
        return send(_this.v1_split_so_bkey(bkey));
      };
    })(this));
  };

  this.v1_lte_from_gte = function(gte) {
    var R, last_idx;
    R = new Buffer((last_idx = Buffer.byteLength(gte)) + 1);
    R.write(gte);
    R[last_idx] = 0xff;
    return R;
  };

  this.v1_unescape = function(text_esc) {
    var matcher;
    matcher = /µ([0-9a-f]{2})/g;
    return text_esc.replace(matcher, function(_, cid_hex) {
      return String.fromCharCode(parseInt(cid_hex, 16));
    });
  };

  this.read_factors = function(db, handler) {
    var Z, gte, input, lte;
    Z = {};
    gte = 'os|factor/sortcode';
    lte = this.v1_lte_from_gte(gte);
    input = db['%self'].createKeyStream({
      gte: gte,
      lte: lte
    });
    return input.pipe(this.v1_$split_so_bkey()).pipe(D.$observe((function(_this) {
      return function(arg) {
        var _, factor, sortcode;
        sortcode = arg[0], _ = arg[1], factor = arg[2];
        return Z[sortcode] = XNCHR.as_uchr(factor);
      };
    })(this))).pipe(D.$on_end(function() {
      return handler(null, Z);
    }));
  };

  this.copy_jizura_db = function() {
    var ds_options, home, solids, source_db, source_route, target_db, target_db_size, target_route;
    home = njs_path.resolve(__dirname, '../../jizura-datasources');
    source_route = njs_path.resolve(home, 'data/leveldb');
    target_route = njs_path.resolve(home, 'data/leveldb-v2');
    target_db_size = 1e6;
    ds_options = require(njs_path.resolve(home, 'options'));
    source_db = HOLLERITH.new_db(source_route);
    target_db = HOLLERITH.new_db(target_route, {
      size: target_db_size,
      create: true

      /* TAINT this setting should come from Jizura DB options */
    });
    solids = [];
    help("using DB at " + source_db['%self']['location']);
    help("using DB at " + target_db['%self']['location']);
    return step((function(_this) {
      return function*(resume) {
        var batch_size, factor_infos, gte, input, lte, output, sample;
        (yield HOLLERITH.clear(target_db, resume));
        factor_infos = (yield _this.read_factors(source_db, resume));
        help("read " + (Object.keys(factor_infos)).length + " entries for factor_infos");
        if ((CND.isa_list(sample = options['sample'])) && (sample.length === 1)) {
          gte = "so|glyph:" + sample[0];
        } else {
          gte = 'so|';
        }
        lte = _this.v1_lte_from_gte(gte);
        input = source_db['%self'].createKeyStream({
          gte: gte,
          lte: lte
        });
        batch_size = 1e4;
        output = HOLLERITH.$write(target_db, {
          batch: batch_size,
          solids: solids
        });
        help("copying from  " + source_route);
        help("to            " + target_route);
        help("reading records with prefix " + (rpr(gte)));
        help("writing with batch size " + (ƒ(batch_size)));
        return input.pipe(_this.v1_$split_so_bkey()).pipe(_this.$show_progress(1e4)).pipe(_this.$keep_small_sample()).pipe(_this.$throw_out_pods()).pipe(_this.$remove_duplicate_kana_readings()).pipe(_this.$cast_types(ds_options)).pipe(_this.$collect_lists()).pipe(_this.$compact_lists()).pipe(_this.$add_version_to_kwic_v1()).pipe(_this.$add_kwic_v3(factor_infos)).pipe(_this.$add_kwic_v3_wrapped_lineups(factor_infos)).pipe(_this.$add_factor_membership(factor_infos)).pipe(_this.$add_components()).pipe(_this.$add_lineup_back_and_forwards()).pipe(_this.$add_factorial_factors(factor_infos)).pipe(_this.$add_sims()).pipe(D.$count(function(count) {
          return help("kept " + (ƒ(count)) + " phrases");
        })).pipe(D.$stop_time("copy Jizura DB")).pipe(output);
      };
    })(this));
  };

  if (module.parent == null) {
    this.copy_jizura_db();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/copy-jizuradb-to-Hollerith2-format.js.map
