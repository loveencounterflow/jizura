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

  this.tmp_locator_for_extension = function(layout_info, extension) {
    var tex_locator, tmp_home;
    tmp_home = layout_info['tmp-home'];
    tex_locator = layout_info['tex-locator'];

    /* TAINT should extension be sanitized? maybe just check for /^\.?[-a-z0-9]$/? */
    if (!(extension.length > 0)) {
      throw new Error("need non-empty extension");
    }
    if (!/^\./.test(extension)) {
      extension = "." + extension;
    }
    return njs_path.join(CND.swap_extension(tex_locator, extension));
  };

  this.new_layout_info = function(source_route) {
    var R, aux_locator, pdf_command, pdf_source_locator, pdf_target_locator, source_home, source_locator, source_name, tex_inputs_home, tex_locator, tmp_home;
    pdf_command = options['pdf-command'];
    tmp_home = options['tmp-home'];
    source_locator = njs_path.resolve(process.cwd(), source_route);
    source_home = njs_path.dirname(source_locator);
    source_name = njs_path.basename(source_locator);

    /* TAINT use `tmp_locator_for_extension` */
    tex_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.tex'));
    aux_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.aux'));
    pdf_source_locator = njs_path.join(tmp_home, CND.swap_extension(source_name, '.pdf'));
    pdf_target_locator = njs_path.join(source_home, CND.swap_extension(source_name, '.pdf'));
    tex_inputs_home = njs_path.resolve(__dirname, '..', 'tex-inputs');
    R = {
      'pdf-command': pdf_command,
      'tmp-home': tmp_home,
      'source-route': source_route,
      'source-locator': source_locator,
      'source-home': source_home,
      'source-name': source_name,
      'tex-locator': tex_locator,
      'tex-inputs-home': tex_inputs_home,
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

  this._meta = Symbol('meta');

  this.TYPO.set_meta = function(x, name, value) {
    var name1, target;
    if (value == null) {
      value = true;
    }
    target = x[name1 = this._meta] != null ? x[name1] : x[name1] = {};
    target[name] = value;
    return x;
  };

  this.TYPO.get_meta = function(x, name) {
    var R;
    if (name == null) {
      name = null;
    }
    R = x[this._meta];
    if (name) {
      R = R[name];
    }
    return R;
  };

  this.TYPO._tex_escape_replacements = [[/\\/g, '\\textbackslash{}'], [/\{/g, '\\{'], [/\}/g, '\\}'], [/\$/g, '\\$'], [/\#/g, '\\#'], [/%/g, '\\%'], [/_/g, '\\_'], [/\^/g, '\\textasciicircum{}'], [/~/g, '\\textasciitilde{}'], [/‰/g, '\\permille{}'], [/&amp;/g, '\\&'], [/&quot;/g, '"'], [/'([^\s]+)’/g, '‘$1’'], [/&/g, '\\&']];

  this.TYPO.escape_for_tex = function(text) {
    var R, i, len, pattern, ref, ref1, replacement;
    R = text;
    ref = this._tex_escape_replacements;
    for (i = 0, len = ref.length; i < len; i++) {
      ref1 = ref[i], pattern = ref1[0], replacement = ref1[1];
      R = R.replace(pattern, replacement);
    }
    return R;
  };

  this.TYPO.$resolve_html_entities = function() {
    return $((function(_this) {
      return function(event, send) {
        var tail, type;
        type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
        if (type === 'text') {
          return send(['text', _this.resolve_html_entities(tail[0])]);
        } else {
          return send(event);
        }
      };
    })(this));
  };

  this.TYPO.$fix_typography_for_tex = function() {
    return $((function(_this) {
      return function(event, send) {
        var tail, type;
        type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
        if (type === 'text') {
          return send(['text', _this.fix_typography_for_tex(tail[0])]);
        } else {
          return send(event);
        }
      };
    })(this));
  };

  this.TYPO.resolve_html_entities = function(text) {
    var R;
    R = text;
    R = R.replace(/&lt;/g, '<');
    R = R.replace(/&gt;/g, '>');
    R = R.replace(/&quot;/g, '"');
    R = R.replace(/&amp;/g, '&');
    R = R.replace(/&[^a-z0-9]+;/g, function(match) {
      warn("unable to resolve HTML entity " + match);
      return match;
    });
    return R;
  };

  this.TYPO.fix_typography_for_tex = function(text, settings) {

    /* An improved version of `XELATEX.tag_from_chr` */
    var R, advance, chr, chr_info, command, fncr, glyph_styles, i, last_command, last_rsg, len, ref, ref1, ref2, ref3, replacement, rsg, stretch, tex_command_by_rsgs, uchr;
    if (settings == null) {
      settings = options;
    }
    glyph_styles = (ref = (ref1 = settings['tex']) != null ? ref1['glyph-styles'] : void 0) != null ? ref : {};
    tex_command_by_rsgs = (ref2 = settings['tex']) != null ? ref2['tex-command-by-rsgs'] : void 0;
    last_command = null;
    R = [];
    stretch = [];
    last_rsg = null;
    if (tex_command_by_rsgs == null) {
      throw new Error("need setting 'tex-command-by-rsgs'");
    }
    advance = (function(_this) {
      return function() {
        if (stretch.length > 0) {
          if (last_command === null || last_command === 'latin') {
            R.push(_this.escape_for_tex(stretch.join('')));
          } else {
            R.push(stretch.join(''));
            R.push('}');
          }
        }
        stretch.length = 0;
        return null;
      };
    })(this);
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

  this.TYPO._new_markdown_parser = function() {

    /* https://markdown-it.github.io/markdown-it/#MarkdownIt.new */
    var R, feature_set, settings;
    feature_set = 'zero';
    settings = {
      html: true,
      xhtmlOut: false,
      breaks: false,
      langPrefix: 'language-',
      linkify: true,
      typographer: true,
      quotes: '“”‘’'
    };
    R = new Markdown_parser(feature_set, settings);
    R.enable('text').enable('escape').enable('backticks').enable('strikethrough').enable('emphasis').enable('link').enable('image').enable('autolink').enable('html_inline').enable('entity').enable('fence').enable('blockquote').enable('hr').enable('list').enable('reference').enable('heading').enable('lheading').enable('html_block').enable('table').enable('paragraph').enable('normalize').enable('block').enable('inline').enable('linkify').enable('replacements').enable('smartquotes');
    R.use(require('markdown-it-footnote'));
    return R;
  };

  this.TYPO._new_html_parser = function(stream) {

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

  this.TYPO._preprocess_regions = function(md_source) {
    var closing_pattern, opening_pattern;
    opening_pattern = /(\n|^)@@@(\S.+)(\n|$)/g;
    closing_pattern = /(\n|^)@@@\s*(\n|$)/g;
    md_source = md_source.replace(opening_pattern, "$1<mkts-mark x-role='start-region' x-name='$2'></mkts-mark>$3");
    md_source = md_source.replace(closing_pattern, "$1<mkts-mark x-role='end-region'></mkts-mark>$2");
    return md_source;
  };

  this.TYPO._preprocess_commands = function(md_source) {
    var pattern;
    pattern = /(\n|^)∆∆∆(\S.+)(\n|$)/g;
    md_source = md_source.replace(pattern, "$1<mkts-mark x-role='command' x-name='$2'></mkts-mark>$3");
    debug('©I74uq', md_source);
    return md_source;
  };

  this.TYPO._$remove_mkts_close_tags = function() {
    return $((function(_this) {
      return function(event, send) {
        var tag_name, type;
        type = event[0], tag_name = event[1];
        if (!((type === 'close-tag') && (tag_name === 'mkts-mark'))) {
          return send(event);
        }
      };
    })(this));
  };

  this.TYPO._$add_regions = function() {
    var region_stack;
    region_stack = [];
    return $((function(_this) {
      return function(event, send, end) {
        var attributes, region_name, tag_name, type;
        if (event != null) {
          type = event[0], tag_name = event[1], attributes = event[2];
          if (type === 'open-tag') {
            if ((tag_name === 'mkts-mark') && (attributes['x-role'] === 'start-region')) {
              region_name = attributes['x-name'];
              region_stack.push(region_name);
              send(['start-region', region_name]);
            } else if ((tag_name === 'mkts-mark') && (attributes['x-role'] === 'end-region')) {
              if (region_stack.length > 0) {
                send(['end-region', region_stack.pop()]);
              } else {
                warn("ignoring end-region");
              }
            } else {
              send(event);
            }
          } else {
            send(event);
          }
        }
        if (end != null) {
          if (region_stack.length > 0) {
            warn("auto-closing regions: " + (rpr(region_stack.join(', '))));
            while (region_stack.length > 0) {
              send(['end-region', region_stack.pop()]);
            }
          }
          return end();
        }
      };
    })(this));
  };

  this.TYPO._$add_commands = function() {
    return $((function(_this) {
      return function(event, send) {
        var attributes, command, tag_name, type;
        type = event[0], tag_name = event[1], attributes = event[2];
        if (type === 'open-tag') {
          if ((tag_name === 'mkts-mark') && (attributes['x-role'] === 'command')) {
            command = attributes['x-name'];
            return send(['command', command]);
          } else {
            return send(event);
          }
        } else {
          return send(event);
        }
      };
    })(this));
  };

  this.TYPO._$remove_block_tags_from_keeplines = (function(_this) {
    return function() {
      var within_keeplines;
      within_keeplines = false;
      return $(function(event, send) {
        var tag, tail, type;
        type = event[0], tag = event[1], tail = 3 <= event.length ? slice.call(event, 2) : [];
        if (type === 'start-region' && tag === 'keeplines') {
          within_keeplines = true;
          return send(event);
        }
        if (type === 'end-region' && tag === 'keeplines') {
          within_keeplines = false;
          return send(event);
        }
        if (within_keeplines) {
          if (type === 'open-tag' || type === 'close-tag') {

            /*TAINT apply to other block-level tags? */
            if (tag !== 'p') {
              return send(event);
            }
          } else {
            return send(event);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.TYPO._$consolidate_texts = (function(_this) {
    return function() {
      var _send, collector, flush;
      collector = [];
      _send = null;
      flush = function() {
        var text;
        if (collector.length > 0) {
          text = collector.join('');
          if (text.length > 0) {
            _send(['text', text]);
          }
          collector.length = 0;
          return null;
        }
      };
      return $(function(event, send, end) {
        var text, type;
        _send = send;
        if (event != null) {
          type = event[0], text = event[1];
          if (type === 'text') {
            collector.push(text);
          } else {
            flush();
            send(event);
          }
        }
        if (end != null) {
          flush();
          return end();
        }
      });
    };
  })(this);

  this.TYPO.create_html_readstream_from_md = function(md_source, settings) {
    var R, html, html_parser, md_parser;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }
    R = D.create_throughstream();
    R.pause();
    md_parser = this._new_markdown_parser();
    md_source = this._preprocess_regions(md_source);
    md_source = this._preprocess_commands(md_source);
    html_parser = this._new_html_parser(R);
    html = md_parser.render(md_source);
    html_parser.write(html);
    html_parser.end();
    R = R.pipe(this._$remove_mkts_close_tags()).pipe(this._$add_regions()).pipe(this._$add_commands()).pipe(this._$remove_block_tags_from_keeplines()).pipe(this._$consolidate_texts());
    this.set_meta(R, 'html', html);
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/HELPERS.js.map