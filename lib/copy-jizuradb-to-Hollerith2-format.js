(function() {
  var $, $async, CND, D, HOLLERITH, KWIC, XNCHR, after, alert, badge, debug, echo, eventually, every, find_duplicated_guides, help, immediately, info, join, log, njs_fs, njs_path, options, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ,
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

  XNCHR = require('./XNCHR');

  ƒ = CND.format_number.bind(CND);

  options = {
    sample: ['國']
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

  this.$add_kwic_v2 = function() {

    /* see `demo/show_kwic_v2_and_v3_sample` */
    var last_glyph, long_wrapped_lineups;
    last_glyph = null;
    long_wrapped_lineups = null;
    return $((function(_this) {
      return function(arg, send) {
        var _, glyph, idx, k, l, len, len1, len2, len3, len4, lineup, m, n, o, obj, position, prd, ref, ref1, ref2, sbj, sortcode, sortcode_v1, sortcodes_v1, sortcodes_v2, sortrow_v1, sortrow_v2, x;
        sbj = arg[0], prd = arg[1], obj = arg[2];
        if (prd === 'guide/has/uchr') {
          last_glyph = sbj;
          long_wrapped_lineups = _this._long_wrapped_lineups_from_guides(obj);
        }
        if (!prd.startsWith('guide/kwic/v1/')) {
          return send([sbj, prd, obj]);
        }
        switch (prd.replace(/^guide\/kwic\/v1\//, '')) {
          case 'lineup/wrapped/infix':
          case 'lineup/wrapped/prefix':
          case 'lineup/wrapped/suffix':
          case 'lineup/wrapped/single':

            /* copy to target */
            return send([sbj, prd, obj]);
          case 'sortcode':
            ref = [sbj, prd, obj], glyph = ref[0], _ = ref[1], sortcodes_v1 = ref[2];
            sortcodes_v2 = [];

            /* The difference between KWIC sortcodes of version 1 and version 2 lies in the re-arrangement
            of the factor codes and the index codes. In v1, the index codes appeared interspersed with
            the factor codes; in v2, the index codes come up front and the index codes come in the latter half
            of the sortcode strings. The effect of this rearrangement is that now that all of the indexes
            (which indicate the position of each factor in the lineup) are weaker than any of the factor codes,
            like sequences of factor codes (and, therefore, factors) will always be grouped together (whereas
            in v1, only like factors with like positions appeared together, and often like sequences appeared
            with other sequences interspersed where their indexes demanded it so).
             */
            for (k = 0, len = sortcodes_v1.length; k < len; k++) {
              sortcode_v1 = sortcodes_v1[k];
              sortrow_v1 = (function() {
                var l, len1, ref1, results;
                ref1 = sortcode_v1.split(/(........,..),/);
                results = [];
                for (l = 0, len1 = ref1.length; l < len1; l++) {
                  x = ref1[l];
                  if (x.length > 0) {
                    results.push(x);
                  }
                }
                return results;
              })();
              sortrow_v1 = (function() {
                var l, len1, results;
                results = [];
                for (l = 0, len1 = sortrow_v1.length; l < len1; l++) {
                  x = sortrow_v1[l];
                  results.push(x.split(','));
                }
                return results;
              })();
              sortrow_v2 = [];
              for (l = 0, len1 = sortrow_v1.length; l < len1; l++) {
                ref1 = sortrow_v1[l], sortcode = ref1[0], _ = ref1[1];
                sortrow_v2.push(sortcode);
              }
              for (m = 0, len2 = sortrow_v1.length; m < len2; m++) {
                ref2 = sortrow_v1[m], _ = ref2[0], position = ref2[1];
                sortrow_v2.push(position);
              }
              sortcodes_v2.push(sortrow_v2.join(','));
            }
            if (glyph !== last_glyph) {
              return send.error(new Error("unexpected mismatch: " + (rpr(glyph)) + ", " + (rpr(last_glyph))));
            }
            if (long_wrapped_lineups == null) {
              return send.error(new Error("missing long wrapped lineups for glyph " + (rpr(glyph))));
            }
            if (sortcodes_v2.length !== long_wrapped_lineups.length) {
              warn('sortcodes_v2:         ', sortcodes_v2);
              warn('long_wrapped_lineups: ', long_wrapped_lineups);
              return send.error(new Error("length mismatch for glyph " + (rpr(glyph))));
            }
            for (idx = n = 0, len3 = long_wrapped_lineups.length; n < len3; idx = ++n) {
              lineup = long_wrapped_lineups[idx];
              sortcodes_v1[idx] += ";" + lineup;
            }
            for (idx = o = 0, len4 = long_wrapped_lineups.length; o < len4; idx = ++o) {
              lineup = long_wrapped_lineups[idx];
              sortcodes_v2[idx] += ";" + lineup;
            }
            send([glyph, 'guide/kwic/v2/lineup/wrapped/single', long_wrapped_lineups]);
            long_wrapped_lineups = null;
            send([glyph, prd, sortcodes_v1]);
            return send([glyph, 'guide/kwic/v2/sortcode', sortcodes_v2]);
          default:
            return send.error(new Error("unhandled predicate " + (rpr(prd))));
        }
      };
    })(this));
  };

  this.$add_kwic_v3 = function(factor_infos) {

    /* see `demo/show_kwic_v2_and_v3_sample` */
    return $((function(_this) {
      return function(arg, send) {
        var _, factor, factors, glyph, obj, permutations, prd, ref, ref1, sbj, sortcode, sortcode_v1, sortrow_v1, weights, x;
        sbj = arg[0], prd = arg[1], obj = arg[2];
        send([sbj, prd, obj]);
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

  find_duplicated_guides = function() {
    var derivatives_home, home, input, output;
    D = require('pipedreams');
    $ = D.remit.bind(D);

    /* TAINT code duplication */

    /* TAIN make configurable / store in options */
    home = njs_path.resolve(__dirname, '../../jizura-datasources');
    derivatives_home = njs_path.resolve(home, 'data/5-derivatives');
    input = njs_fs.createReadStream(njs_path.resolve(derivatives_home, 'guide-pairs.txt'));
    output = njs_fs.createWriteStream(njs_path.resolve(derivatives_home, 'guide-pairs-duplicated.txt'));
    return input.pipe(D.$split()).pipe($((function(_this) {
      return function(line, send) {
        if (line.length !== 0) {
          return send(line);
        }
      };
    })(this))).pipe($((function(_this) {
      return function(line, send) {
        if (!line.startsWith('#')) {
          return send(line);
        }
      };
    })(this))).pipe($((function(_this) {
      return function(line, send) {
        return send([line].concat(slice.call(line.split('\t'))));
      };
    })(this))).pipe($((function(_this) {
      return function(arg, send) {
        var _, glyph, guides, line;
        line = arg[0], _ = arg[1], guides = arg[2], glyph = arg[3];
        return send([line, glyph, guides]);
      };
    })(this))).pipe($((function(_this) {
      return function(fields, send) {
        var glyph, guides, line;
        line = fields[0], glyph = fields[1], guides = fields[2];
        if (!CND.isa_text(guides)) {
          warn(line, fields);
        }
        return send(fields);
      };
    })(this))).pipe($((function(_this) {
      return function(arg, send) {
        var glyph, guides, line;
        line = arg[0], glyph = arg[1], guides = arg[2];
        return send([line, glyph].concat(slice.call(Array.from(guides))));
      };
    })(this))).pipe($((function(_this) {
      return function(fields, send) {
        var glyph, guide_0, guide_1, line;
        line = fields[0], glyph = fields[1], guide_0 = fields[2], guide_1 = fields[3];
        if (!(guide_0 === '一' || guide_1 === '一')) {
          return send(fields);
        }
      };
    })(this))).pipe($((function(_this) {
      return function(fields, send) {
        var glyph, guide_0, guide_1, line;
        line = fields[0], glyph = fields[1], guide_0 = fields[2], guide_1 = fields[3];
        if (guide_0 === guide_1) {
          return send(fields);
        }
      };
    })(this))).pipe($((function(_this) {
      return function(arg, send) {
        var glyph, guide_0, guide_1, line;
        line = arg[0], glyph = arg[1], guide_0 = arg[2], guide_1 = arg[3];
        return send(line + '\n');
      };
    })(this))).pipe(output);
  };

  find_duplicated_guides();

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

    /*  * # # # # # # # # # # # # # # # # # # # # */
    target_route = '/tmp/leveldb-v2';
    alert("using temp DB");

    /*  * # # # # # # # # # # # # # # # # # # # # */
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
        var batch_size, factor_infos, gte, input, lte, output;
        (yield HOLLERITH.clear(target_db, resume));
        factor_infos = (yield _this.read_factors(source_db, resume));
        help("read " + (Object.keys(factor_infos)).length + " entries for factor_infos");
        gte = 'so|glyph:國';
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
        return input.pipe(_this.v1_$split_so_bkey()).pipe(_this.$show_progress(1e4)).pipe(_this.$keep_small_sample()).pipe(_this.$throw_out_pods()).pipe(_this.$cast_types(ds_options)).pipe(_this.$collect_lists()).pipe(_this.$compact_lists()).pipe(_this.$add_version_to_kwic_v1()).pipe(_this.$add_kwic_v2()).pipe(_this.$add_kwic_v3(factor_infos)).pipe(_this.$add_guide_pairs(factor_infos)).pipe(D.$count(function(count) {
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
