(function() {
  var $, $async, CND, D, HOLLERITH, KWIC, after, alert, badge, debug, echo, eventually, every, help, immediately, info, join, log, njs_path, repeat_immediately, rpr, step, suspend, urge, warn, whisper, ƒ;

  njs_path = require('path');

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

  this.main = function() {
    var db, db_route;
    db_route = join(__dirname, '../../jizura-datasources/data/leveldb-v2');
    db = HOLLERITH.new_db(db_route, {
      create: false
    });
    help("using DB at " + db['%self']['location']);
    return step((function(_this) {
      return function*(resume) {
        var include, input, prefix, query, ranks, sample;
        ranks = {};
        include = Infinity;
        include = 100;
        sample = (yield _this.read_sample(db, include, resume));
        debug('©u2o8L', (Object.keys(sample)).join(' '));
        prefix = ['pos', 'guide/has/uchr'];
        query = {
          prefix: prefix
        };
        input = HOLLERITH.create_phrasestream(db, query);
        input.on('end', function() {
          return help("ok");
        });
        input.pipe(D.$show());
        return null;
      };
    })(this));
  };

  if (module.parent == null) {
    this.main();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/show-factor-usages.js.map