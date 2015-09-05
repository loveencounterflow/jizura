(function() {
  var CND, TEX, XNCHR, alert, badge, debug, echo, help, info, log, rpr, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'XLTX';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  echo = CND.echo.bind(CND);

  XNCHR = require('./XNCHR');

  TEX = require('coffeenode-tex');

  this.glyph_tag_by_rsg = {
    'u-latn': TEX.make_command('latin'),
    'u-latn-1': TEX.make_command('latin'),
    'u-cjk': TEX.make_command('cn'),
    'u-halfull': TEX.make_command('cn'),
    'u-dingb': TEX.make_command('cn'),
    'u-cjk-xa': TEX.make_command('cnxa'),
    'u-cjk-xb': TEX.make_command('cnxb'),
    'u-cjk-xc': TEX.make_command('cnxc'),
    'u-cjk-xd': TEX.make_command('cnxd'),
    'u-cjk-cmpi1': TEX.make_command('cncone'),
    'u-cjk-cmpi2': TEX.make_command('cnctwo'),
    'u-cjk-rad1': TEX.make_command('cnrone'),
    'u-cjk-rad2': TEX.make_command('cnrtwo'),
    'u-cjk-sym': TEX.make_command('cnsym'),
    'u-cjk-strk': TEX.make_command('cnstrk'),
    'u-pua': TEX.make_command('cnjzr'),
    'jzr-fig': TEX.make_command('cnjzr'),
    'u-cjk-kata': TEX.make_command('ka'),
    'u-cjk-hira': TEX.make_command('hi'),
    'u-hang-syl': TEX.make_command('hg')
  };

  this.stacked_fncr = TEX.make_multicommand('fncr', 2);

  this._py = TEX.make_command('py');

  this.ka = TEX.make_command('ka');

  this.hi = TEX.make_command('hi');

  this.hg = TEX.make_command('hg');

  this.gloss = TEX.make_command('gloss');

  this.mainentry = TEX.make_command('mainentry');

  this.missing = TEX.make_command('missing');

  this.hbox = TEX.make_command('hbox');

  this.jzrplain = TEX.make_environment('jzrplain');

  this.tabular = TEX.make_environment('tabular');

  this.par = TEX.raw(' \\\\\n');

  this.hirabar = (TEX.make_loner('hirabar'))();

  this.next_cell = TEX.raw(' & ');

  this.new_page = (TEX.make_loner('clearpage'))();

  this.as_tex_text = function(text, settings) {

    /* An improved version of `tag_from_chr`, below */
    var R, advance, chr, chr_info, command, fncr, glyph_styles, i, ignore_latin, last_command, last_tag_name, len, ref, ref1, ref2, replacement, rsg, stretch, tex_command_by_rsgs, uchr;
    glyph_styles = (ref = settings != null ? settings['glyph-styles'] : void 0) != null ? ref : {};
    ignore_latin = (ref1 = settings != null ? settings['ignore-latin'] : void 0) != null ? ref1 : true;
    tex_command_by_rsgs = settings != null ? settings['tex-command-by-rsgs'] : void 0;
    last_command = null;
    if (tex_command_by_rsgs == null) {
      throw new Error("need setting 'tex-command-by-rsgs'");
    }
    R = [];
    stretch = [];
    last_tag_name = null;
    advance = (function(_this) {
      return function() {
        if (stretch.length > 0) {
          R.push(stretch.join(''));
          if (!(ignore_latin && last_command === 'latin')) {
            R.push('}');
          }
        }
        stretch.length = 0;
        return null;
      };
    })(this);
    ref2 = XNCHR.chrs_from_text(text);
    for (i = 0, len = ref2.length; i < len; i++) {
      chr = ref2[i];
      chr_info = XNCHR.analyze(chr);
      chr = chr_info.chr, uchr = chr_info.uchr, fncr = chr_info.fncr, rsg = chr_info.rsg;
      switch (rsg) {
        case 'jzr-fig':
          chr = uchr;
          break;
        case 'u-pua':
          rsg = 'jzr-fig';
      }
      if ((replacement = glyph_styles[chr]) != null) {
        advance();
        R.push(replacement);
        continue;
      }
      if ((command = tex_command_by_rsgs[rsg]) == null) {
        warn("unknown RSG " + (rpr(rsg)) + ": " + fncr + " " + chr);
        advance();
        stretch.push(chr);
        continue;
      }
      if (last_command !== command) {
        advance();
        last_command = command;
        if (!(ignore_latin && command === 'latin')) {
          stretch.push("\\" + command + "{");
        }
      }
      stretch.push(chr);
    }
    advance();
    return R.join('');
  };

  this.tag_from_chr = function(glyph_styles, chr) {

    /* TAINT not well written */
    var R, chr_info, fncr, rsg, tag;
    chr_info = XNCHR.analyze(chr);
    chr = chr_info.chr, fncr = chr_info.fncr, rsg = chr_info.rsg;
    if ((R = glyph_styles[chr]) != null) {
      return TEX.raw(R);
    }
    if (rsg === 'jzr-fig') {
      return TEX.raw("\\cnjzr{" + chr_info['uchr'] + "}");
    }
    if ((tag = this.glyph_tag_by_rsg[rsg]) == null) {
      warn("unknown RSG " + (rpr(rsg)) + ": " + fncr + " " + chr);
      return chr_info['chr'];
    }
    return tag(chr_info['chr']);
  };

  this.tag_rpr_from_chr = function(glyph_styles, chr) {
    return TEX.rpr(this.tag_from_chr(glyph_styles, chr));
  };

  this.py = function(text) {
    return this._py(this.raw(this._rewrite_pinyin(text)));
  };

  this._rewrite_pinyin = function(text) {
    var R;
    R = text;
    R = R.replace(/ǖ/, "\\upaccent{\\aboxshift{ˉ}}{ü}");
    R = R.replace(/ǘ/, "\\upaccent{\\aboxshift{´}}{ü}");
    R = R.replace(/ǚ/, "\\upaccent{\\aboxshift{ˇ}}{ü}");
    R = R.replace(/ǜ/, "\\upaccent{\\aboxshift{`}}{ü}");
    R = R.replace(/ê1/, "\\upaccent{\\aboxshift{ˉ}}{ê}");
    R = R.replace(/ê2/, "\\upaccent{\\aboxshift{´}}{ê}");
    R = R.replace(/ê3/, "\\upaccent{\\aboxshift{ˇ}}{ê}");
    R = R.replace(/ê4/, "\\upaccent{\\aboxshift{`}}{ê}");
    return R;
  };

  this.rpr = TEX.rpr.bind(TEX);

}).call(this);

//# sourceMappingURL=../sourcemaps/XELATEX.js.map