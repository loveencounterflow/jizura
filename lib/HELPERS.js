(function() {
  var $, $async, ASYNC, CND, D, Html_parser, Markdown_parser, XNCHR, alert, badge, debug, echo, help, info, log, new_md_inline_plugin, njs_fs, njs_path, options, rpr, urge, warn, whisper,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/HELPERS';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  XNCHR = require('./XNCHR');

  ASYNC = require('async');

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  Markdown_parser = require('markdown-it');

  Html_parser = (require('htmlparser2')).Parser;

  new_md_inline_plugin = require('markdown-it-regexp');

  options = require('./options');

  this.provide_tmp_folder = function() {
    if (!njs_fs.existsSync(options['tmp-home'])) {
      njs_fs.mkdirSync(options['tmp-home']);
    }
    return null;
  };

  this.new_layout_info = function(source_route) {
    var R, aux_locator, pdf_command, pdf_source_locator, pdf_target_locator, source_home, source_locator, source_name, tex_locator, tmp_home;
    pdf_command = options['pdf-command'];
    tmp_home = options['tmp-home'];
    source_locator = njs_path.resolve(process.cwd(), source_route);
    source_home = njs_path.dirname(source_locator);
    source_name = njs_path.basename(source_locator);
    tex_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.tex'));
    aux_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.aux'));
    pdf_source_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.pdf'));
    pdf_target_locator = njs_path.join(source_home, CND.swap_extension(source_name, '.pdf'));
    R = {
      'pdf-command': pdf_command,
      'tmp-home': tmp_home,
      'source-route': source_route,
      'source-locator': source_locator,
      'source-home': source_home,
      'source-name': source_name,
      'tex-locator': tex_locator,
      'aux-locator': aux_locator,
      'pdf-source-locator': pdf_source_locator,
      'pdf-target-locator': pdf_target_locator,
      'latex-run-count': 0
    };
    return R;
  };

  this.write_pdf = function(layout_info, handler) {
    var aux_locator, count, digest, last_digest, pdf_command, pdf_from_tex, pdf_source_locator, pdf_target_locator, tex_locator, tmp_home;
    pdf_command = layout_info['pdf-command'];
    tmp_home = layout_info['tmp-home'];
    tex_locator = layout_info['tex-locator'];
    aux_locator = layout_info['aux-locator'];
    pdf_source_locator = layout_info['pdf-source-locator'];
    pdf_target_locator = layout_info['pdf-target-locator'];
    last_digest = null;
    if (njs_fs.existsSync(aux_locator)) {
      last_digest = CND.id_from_route(aux_locator);
    }
    digest = null;
    count = 0;
    pdf_from_tex = (function(_this) {
      return function(next) {
        count += 1;
        urge("run #" + count + " " + pdf_command);
        whisper("$1: " + tmp_home);
        whisper("$2: " + tex_locator);
        return CND.spawn(pdf_command, [tmp_home, tex_locator], function(error, data) {
          if (error === 0) {
            error = void 0;
          }
          if (error != null) {
            alert(error);
            return handler(error);
          }
          digest = CND.id_from_route(aux_locator);
          if (digest === last_digest) {
            echo(CND.grey(badge), CND.lime("done."));
            layout_info['latex-run-count'] = count;

            /* TAINT move pdf to layout_info[ 'source-home' ] */
            return handler(null);
          } else {
            last_digest = digest;
            return next();
          }
        });
      };
    })(this);
    return ASYNC.forever(pdf_from_tex);
  };

  this.TYPO = {};

  this.TYPO._escape_replacements = [[/\\/g, '\\textbackslash{}'], [/\{/g, '\\{'], [/\}/g, '\\}'], [/\$/g, '\\$'], [/\#/g, '\\#'], [/%/g, '\\%'], [/_/g, '\\_'], [/\^/g, '\\textasciicircum{}'], [/~/g, '\\textasciitilde{}'], [/‰/g, '\\permille{}'], [/&amp;/g, '\\&'], [/&quot;/g, '"'], [/'([^\s]+)’/g, '‘$1’'], [/(^|[^\\])&/g, '\\&']];

  this.TYPO.escape_for_tex = (function(_this) {
    return function(text) {
      var R, i, len, matcher, ref, ref1, replacement;
      R = text;
      ref = _this.TYPO._escape_replacements;
      for (i = 0, len = ref.length; i < len; i++) {
        ref1 = ref[i], matcher = ref1[0], replacement = ref1[1];
        R = R.replace(matcher, replacement);
      }
      return R;
    };
  })(this);

  this.TYPO.$fix_typography_for_tex = (function(_this) {
    return function() {
      return $(function(event, send) {
        var tail, type;
        type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
        if (type === 'text') {
          return send(['text', _this.TYPO.as_tex_text(tail[0])]);
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.TYPO.as_tex_text = (function(_this) {
    return function(text, settings) {

      /* An improved version of `XELATEX.tag_from_chr` */
      var R, advance, chr, chr_info, command, fncr, glyph_styles, i, last_command, last_tag_name, len, ref, ref1, ref2, ref3, replacement, rsg, stretch, tex_command_by_rsgs, uchr;
      if (settings == null) {
        settings = options;
      }
      glyph_styles = (ref = (ref1 = settings['tex']) != null ? ref1['glyph-styles'] : void 0) != null ? ref : {};
      tex_command_by_rsgs = (ref2 = settings['tex']) != null ? ref2['tex-command-by-rsgs'] : void 0;
      last_command = null;
      R = [];
      stretch = [];
      last_tag_name = null;
      if (tex_command_by_rsgs == null) {
        throw new Error("need setting 'tex-command-by-rsgs'");
      }
      advance = function() {
        if (stretch.length > 0) {
          debug('©zDJqU', last_command, JSON.stringify(stretch.join('.')));
          if (last_command === null || last_command === 'latin') {
            R.push(_this.TYPO.escape_for_tex(stretch.join('')));
          } else {
            R.push(stretch.join(''));
            R.push('}');
          }
        }
        stretch.length = 0;
        return null;
      };
      ref3 = XNCHR.chrs_from_text(text);
      for (i = 0, len = ref3.length; i < len; i++) {
        chr = ref3[i];
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
          last_command = null;
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
          if (command !== 'latin') {
            stretch.push("\\" + command + "{");
          }
        }
        stretch.push(chr);
      }
      advance();
      return R.join('');
    };
  })(this);


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */


  /*  * # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # */

  this._new_markdown_parser = function() {

    /* https://markdown-it.github.io/markdown-it/#MarkdownIt.new */
    var R, settings, user_handler, user_pattern, user_plugin;
    settings = {
      html: true,
      xhtmlOut: false,
      breaks: false,
      langPrefix: 'language-',
      linkify: true,
      typographer: true,
      quotes: ['«\xA0', '\xA0»', '‹\xA0', '\xA0›']
    };
    R = new Markdown_parser(settings);

    /* sample plugin */
    user_pattern = /@(\w+)/;
    user_handler = function(match, utils) {
      var url;
      url = 'http://example.org/u/' + match[1];
      return '<a href="' + utils.escape(url) + '">' + utils.escape(match[1]) + '</a>';
    };
    user_plugin = new_md_inline_plugin(user_pattern, user_handler);
    R.use(user_plugin);
    return R;
  };

  this._new_html_parser = function(stream) {

    /* https://github.com/fb55/htmlparser2/wiki/Parser-options */
    var handlers, settings;
    settings = {
      xmlMode: false,
      decodeEntities: false,
      lowerCaseTags: false,
      lowerCaseAttributeNames: false,
      recognizeCDATA: true,
      recognizeSelfClosing: true
    };
    handlers = {
      onopentag: function(name, attributes) {
        return stream.write(['open-tag', name, attributes]);
      },
      ontext: function(text) {
        return stream.write(['text', text]);
      },
      onclosetag: function(name) {
        return stream.write(['close-tag', name]);
      },
      onerror: function(error) {
        return stream.error(error);
      },
      oncomment: function(text) {
        return stream.write(['comment', text]);
      },
      onend: function() {
        stream.write(['end']);
        return stream.end();
      }
    };
    return new Html_parser(handlers, settings);
  };

  this.create_html_readstream_from_md_text = function(text, settings) {
    var R, html, html_parser, md_parser;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }
    R = D.create_throughstream();
    R.pause();
    md_parser = this._new_markdown_parser();
    html_parser = this._new_html_parser(R);
    html = md_parser.render(text);
    html_parser.write(html);
    html_parser.end();
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/HELPERS.js.map