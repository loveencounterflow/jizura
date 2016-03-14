(function() {
  var CND, alert, app, app_name, badge, debug, echo, get_do_stats, get_factor_sample, get_glyph_sample, help, info, isa_folder, log, njs_fs, njs_path, ref, rpr, urge, warn, whisper;

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

  get_do_stats = function(input, fallback) {
    if (fallback == null) {
      fallback = false;
    }
    if (input == null) {
      return fallback;
    }
    return input;
  };

  get_glyph_sample = function(input, fallback) {
    var R;
    if (fallback == null) {
      fallback = 1000;
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

  app.command("mkts <filename>").description("typeset MD source in <filename>, output PDF").action(function(filename) {
    var MKTS;
    help(CND.grey("" + app_name), CND.gold('mkts'), CND.lime(filename));
    MKTS = require('./mkts-typesetter-interim');
    CND.dir(MKTS);
    return MKTS.pdf_from_md(filename);
  });

  app.command("kwic [output_route]").description("render (excerpt of) KWIC index (to output_route where given; must be a folder)").option("-s, --stats", "show KWIC infix statistics [false]").option("-g, --glyphs [glyphs]", "which glyphs to include").option("-f, --factors [factors]", "which factors to include").action(function(output_route, options) {
    var S, SHOW_KWIC_V3, do_stats, factor_sample, glyph_sample, key, kwic_route, stats_route;
    help(CND.white("" + app_name), CND.gold('kwic'));
    do_stats = get_do_stats(options['stats']);
    glyph_sample = get_glyph_sample(options['glyphs']);
    factor_sample = get_factor_sample(options['factors']);
    if (output_route == null) {
      output_route = null;
    }
    kwic_route = null;
    stats_route = null;
    if (factor_sample != null) {
      key = "kwic_g." + glyph_sample + "_f." + (factor_sample.join(''));
    } else {
      key = "kwic_g." + glyph_sample;
    }
    if (output_route != null) {
      if (!isa_folder(output_route)) {
        throw new Error(output_route + ":\nnot a folder");
      }
      output_route = njs_path.resolve(__dirname, output_route);
      kwic_route = njs_path.join(output_route, key + "-kwic.md");
      if (do_stats != null) {
        stats_route = njs_path.join(output_route, key + "-stats.md");
      }
    }
    help("key for this collection is " + key);
    if (output_route != null) {
      help("KWIC index will be written to " + kwic_route);
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
      glyph_sample: glyph_sample,
      factor_sample: factor_sample,
      output_route: output_route,
      kwic_route: kwic_route,
      stats_route: stats_route,
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
