(function() {
  var CND, alert, app, app_name, badge, debug, echo, get_do_stats, get_factor_sample, get_glyph_sample, get_two_stats, get_width, get_with_prefixes, help, info, isa_folder, log, njs_fs, njs_path, ref, rpr, urge, warn, whisper;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/cli';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);


  /*
  
  app       = require 'commander'
  app_name  = process.argv[ 1 ]
  
  app
    .version ( require '../package.json' )[ 'version' ]
    .command 'mkts <filename>'
    .action ( filename ) ->
      help ( CND.grey "#{app_name}" ), ( CND.gold 'mkts' ), ( CND.lime filename )
      MKTS = require './mkts-typesetter-interim'
      CND.dir MKTS
      MKTS.pdf_from_md filename
  
  app.parse process.argv
   * debug '©nES6R', process.argv
   */

  app = require('commander');

  app_name = process.argv[1];

  app.version((require('../package.json'))['version']);

  get_do_stats = get_with_prefixes = get_two_stats = function(input, fallback) {
    if (fallback == null) {
      fallback = false;
    }
    if (input == null) {
      return fallback;
    }
    return input;
  };

  get_width = function(input, fallback) {
    var R;
    if (fallback == null) {
      fallback = null;
    }
    if (input == null) {
      return fallback;
    }
    if (input === Infinity || input === 'full' || input === 'infinity' || input === 'Infinity') {
      return null;
    }
    R = parseInt(input, 10);
    if (!((R === parseFloat(input)) && (CND.isa_number(R)) && (R >= 0))) {
      throw new Error("expected non-negative integer number for width, got " + (rpr(input)));
    }
    return R;
  };

  get_glyph_sample = function(input, fallback) {
    var R;
    if (fallback == null) {
      fallback = Infinity;
    }
    if (input == null) {
      return fallback;
    }
    if (input === Infinity || input === 'all' || input === 'infinity' || input === 'Infinity') {
      return Infinity;
    }
    if (CND.isa_number((R = parseInt(input, 10)))) {
      return R;
    }
    return Array.from(input);
  };

  get_factor_sample = function(input, fallback) {
    if (fallback == null) {
      fallback = null;
    }
    if (input == null) {
      return fallback;
    }
    return Array.from(input);
  };

  isa_folder = function(route) {
    var error, error1, fstats;
    try {
      fstats = njs_fs.statSync(route);
    } catch (error1) {
      error = error1;
      if (error.code === 'ENOENT') {
        return false;
      }
      throw error;
    }
    return fstats.isDirectory();
  };

  app.command("repetitions").description("find repeated components in formulas or lineups").option("--lineups", "look in lineups").option("--formulas", "look in formulas").action(function(options) {
    var S, SRF, command, formulas, lineups, ref, ref1;
    command = options['command'];
    lineups = (ref = options['lineups']) != null ? ref : false;
    formulas = (ref1 = options['formulas']) != null ? ref1 : false;
    if ((!lineups) && (!formulas)) {
      throw new Error("must indicate source (--lineups, --formulas, or both)");
    }
    S = {
      command: command,
      lineups: lineups,
      formulas: formulas
    };
    help(CND.grey("" + app_name), CND.gold('repetitions'));
    SRF = require('./show-repeated-factors');
    return SRF.show_repeated_factors(S);
  });

  app.command("formulas <glyphs>").description("dump formulas for glyphs").action(function(glyphs) {
    var DFFG, S, XNCHR;
    XNCHR = require('./XNCHR');
    DFFG = require('./dump-formulas-for-glyphs');
    glyphs = XNCHR.chrs_from_text(glyphs);
    S = {
      glyphs: glyphs
    };
    help(CND.grey("" + app_name), CND.gold(glyphs.join('')));
    return DFFG.dump_formulas(S);
  });

  app.command("kwic [output_route]").description("render (excerpt of) KWIC index (to output_route where given; must be a folder)").option("-s, --stats", "show KWIC infix statistics [false]").option("-p, --prefixes", "infix statistics to include prefixes (only with -s) [false]").option("-2, --two", "separate prefix and suffix stats (only with -sp) [false]").option("-w, --width [count]", "maximum number of glyphs in infix statistics [full]").option("-g, --glyphs [glyphs]", "which glyphs to include").option("-f, --factors [factors]", "which factors to include").action(function(output_route, options) {
    var S, SHOW_KWIC_V3, do_stats, factor_sample, glyph_sample, glyph_sample_key, glyphs_description_route, glyphs_route, key, stats_description_route, stats_route, two_stats, width, with_prefixes;
    help(CND.white("" + app_name), CND.gold('kwic'));
    do_stats = get_do_stats(options['stats']);
    with_prefixes = get_with_prefixes(options['prefixes']);
    two_stats = get_two_stats(options['two']);
    width = get_width(options['width']);
    glyph_sample = get_glyph_sample(options['glyphs']);
    factor_sample = get_factor_sample(options['factors']);
    if (output_route == null) {
      output_route = null;
    }
    glyphs_route = null;
    glyphs_description_route = null;
    stats_route = null;
    stats_description_route = null;
    if (with_prefixes && !do_stats) {
      throw new Error("switch -p (--prefixes) only valid with -s (--stats)");
    }
    if (two_stats && !(do_stats && with_prefixes)) {
      throw new Error("switch -2 only valid with -sp (--prefixes and --stats)");
    }
    if (glyph_sample === Infinity) {
      glyph_sample_key = 'all';
    } else if (CND.isa_number(glyph_sample)) {
      glyph_sample_key = rpr(glyph_sample);
    } else {
      glyph_sample_key = glyph_sample.join('');
    }
    key = ["g." + glyph_sample_key];
    if (factor_sample != null) {
      key.push("f." + (factor_sample.join('')));
    }
    if (do_stats && with_prefixes && two_stats) {
      key.push("sp2");
    } else if (do_stats && with_prefixes) {
      key.push("sp");
    } else if (do_stats) {
      key.push("s");
    }
    if (width != null) {
      key.push("w." + width);
    }
    key = key.join('-');
    key = "kwic-" + (CND.id_from_text(key, 4)) + "-" + key;
    if (output_route != null) {
      output_route = njs_path.resolve(process.cwd(), output_route);
      if (!isa_folder(output_route)) {
        throw new Error(output_route + ":\nnot a folder");
      }
      glyphs_route = njs_path.join(output_route, key + "-glyphs.md");
      glyphs_description_route = njs_path.join(output_route, key + "-glyphs-description.md");
      if (do_stats) {
        stats_route = njs_path.join(output_route, key + "-stats.md");
        stats_description_route = njs_path.join(output_route, key + "-stats-description.md");
      }
    }
    help("key for this collection is " + key);
    if (output_route != null) {
      help("KWIC index will be written to " + glyphs_route);
    }
    if (stats_route != null) {
      help("statistics will be written to " + stats_route);
    }
    help("glyph_sample is " + (rpr(glyph_sample)));
    if (factor_sample != null) {
      help("factors: " + (factor_sample.join('')));
    } else {
      help("all factors will be included");
    }
    S = {
      command: 'kwic',
      glyph_sample: glyph_sample,
      factor_sample: factor_sample,
      output_route: output_route,
      glyphs_route: glyphs_route,
      stats_route: stats_route,
      glyphs_description_route: glyphs_description_route,
      stats_description_route: stats_description_route,
      do_stats: do_stats,
      with_prefixes: with_prefixes,
      two_stats: two_stats,
      width: width,
      key: key
    };
    SHOW_KWIC_V3 = require('./show-kwic-v3');
    return SHOW_KWIC_V3.show_kwic_v3(S);
  });

  app.parse(process.argv);

  if (!(((ref = app.args) != null ? ref.length : void 0) > 0)) {
    warn("missing arguments");
    app.help();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/cli.js.map
