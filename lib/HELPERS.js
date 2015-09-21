(function() {
  var $, $async, ASYNC, CND, D, Html_parser, Markdown_parser, XNCHR, alert, badge, debug, echo, help, info, log, new_md_inline_plugin, njs_fs, njs_path, rpr, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  this.provide_tmp_folder = function(options) {
    if (!njs_fs.existsSync(options['tmp-home'])) {
      njs_fs.mkdirSync(options['tmp-home']);
    }
    return null;
  };

  this.new_layout_info = function(options, source_route) {
    var R, aux_locator, job_name, master_ext, master_locator, master_locator_bare, master_name, master_name_bare, pdf_locator, source_home, source_locator, source_name, tex_inputs_home, xelatex_command;
    xelatex_command = options['xelatex-command'];
    source_home = njs_path.resolve(process.cwd(), source_route);
    source_name = options['main']['filename'];
    source_locator = njs_path.join(source_home, source_name);
    if (!njs_fs.existsSync(source_home)) {
      throw new Error("unable to locate " + source_home);
    }
    if (!(njs_fs.statSync(source_home)).isDirectory()) {
      throw new Error("not a directory: " + source_home);
    }
    if (!njs_fs.existsSync(source_locator)) {
      throw new Error("unable to locate " + source_locator);
    }
    if (!(njs_fs.statSync(source_locator)).isFile()) {
      throw new Error("not a file: " + source_locator);
    }
    job_name = njs_path.basename(source_home);
    aux_locator = njs_path.join(source_home, job_name + ".aux");
    pdf_locator = njs_path.join(source_home, job_name + ".pdf");
    tex_inputs_home = njs_path.resolve(__dirname, '..', 'tex-inputs');
    master_name = options['master']['filename'];
    master_ext = njs_path.extname(master_name);
    master_name_bare = njs_path.basename(master_name, master_ext);
    master_locator = njs_path.join(source_home, master_name);
    master_locator_bare = njs_path.join(source_home, master_name_bare);
    R = {
      'job-name': job_name,
      'aux-locator': aux_locator,
      'xelatex-run-count': 0,
      'master-locator': master_locator,
      'master-locator.bare': master_locator_bare,
      'master-name': master_name,
      'xelatex-command': xelatex_command,
      'pdf-locator': pdf_locator,
      'source-home': source_home,
      'source-locator': source_locator,
      'source-name': source_name,
      'source-route': source_route,
      'tex-inputs-home': tex_inputs_home,
      'tex-locator': tex_locator
    };
    return R;
  };

  this.write_pdf = function(layout_info, handler) {
    var aux_locator, count, digest, job_name, last_digest, parameters, pdf_from_tex, pdf_locator, source_home, tex_locator, xelatex_command;
    job_name = layout_info['job-name'];
    source_home = layout_info['source-home'];
    xelatex_command = layout_info['xelatex-command'];
    tex_locator = layout_info['tex-locator'];
    aux_locator = layout_info['aux-locator'];
    pdf_locator = layout_info['pdf-locator'];
    last_digest = null;
    if (njs_fs.existsSync(aux_locator)) {
      last_digest = CND.id_from_route(aux_locator);
    }
    digest = null;
    count = 0;
    parameters = [source_home, job_name, tex_locator];
    urge("" + xelatex_command);
    whisper("$1: " + parameters[0]);
    whisper("$2: " + parameters[1]);
    whisper("$2: " + parameters[2]);
    pdf_from_tex = (function(_this) {
      return function(next) {
        count += 1;
        urge("run #" + count);
        return CND.spawn(xelatex_command, parameters, function(error, data) {
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
            layout_info['xelatex-run-count'] = count;

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

  this.TYPO.$fix_typography_for_tex = function() {
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.isa(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          text = _this.fix_typography_for_tex(text);
          return send([type, name, text, meta]);
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


  /*
   */

  this.TYPO.$flatten_tokens = function() {
    return $(function(token, send) {
      var i, len, ref, results, sub_token, type;
      switch ((type = token['type'])) {
        case 'inline':
          ref = token['children'];
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            sub_token = ref[i];
            results.push(send(sub_token));
          }
          return results;
          break;
        default:
          return send(token);
      }
    });
  };

  this.TYPO.$rewrite_markdownit_tokens = function() {
    var unknown_tokens;
    unknown_tokens = [];
    return $((function(_this) {
      return function(token, send, end) {
        var meta, type;
        if (token != null) {
          meta = {
            within_text_literal: false
          };
          switch ((type = token['type'])) {
            case 'heading_open':
              send(['[', token['tag'], null, meta]);
              break;
            case 'heading_close':
              send([']', token['tag'], null, meta]);
              break;
            case 'paragraph_open':
              send(['[', 'p', null, meta]);
              break;
            case 'paragraph_close':
              send([']', 'p', null, meta]);
              break;
            case 'list_item_open':
              send(['[', 'li', null, meta]);
              break;
            case 'list_item_close':
              send([']', 'li', null, meta]);
              break;
            case 'strong_open':
              send(['(', 'strong', null, meta]);
              break;
            case 'strong_close':
              send([')', 'strong', null, meta]);
              break;
            case 'em_open':
              send(['(', 'em', null, meta]);
              break;
            case 'em_close':
              send([')', 'em', null, meta]);
              break;
            case 'text':
              send(['.', 'text', token['content'], meta]);
              break;
            case 'hr':
              send(['.', 'hr', token['markup'], meta]);
              break;
            case 'code_inline':
              send(['(', 'code', null, _this._copy(meta)]);
              send([
                '.', 'text', token['content'], _this._copy(meta, {
                  within_text_literal: true
                })
              ]);
              send([')', 'code', null, _this._copy(meta)]);
              break;
            default:
              send(['?', token['tag'], token['content'], meta]);
              if (indexOf.call(unknown_tokens, type) < 0) {
                unknown_tokens.push(type);
              }
          }
        }
        if (end != null) {
          if (unknown_tokens.length > 0) {
            warn("unknown tokens: " + (unknown_tokens.sort().join(', ')));
          }
          end();
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$preprocess_regions = function() {
    var closing_pattern, collector, opening_pattern, region_stack;
    opening_pattern = /^@@@(\S.+)(\n|$)/;
    closing_pattern = /^@@@\s*(\n|$)/;
    collector = [];
    region_stack = [];
    return $((function(_this) {
      return function(event, send, end) {
        var i, len, line, lines, match, meta, name, region_name, text, type;
        if (event != null) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if ((!meta.within_text_literal) && (_this.isa(event, '.', 'text'))) {
            lines = _this._split_lines_with_nl(text);
            for (i = 0, len = lines.length; i < len; i++) {
              line = lines[i];
              if ((match = line.match(opening_pattern)) != null) {
                _this._flush_text_collector(send, collector, _this._copy(meta));
                region_name = match[1];
                region_stack.push(region_name);
                send(['{', region_name, null, _this._copy(meta)]);
              } else if ((match = line.match(closing_pattern)) != null) {
                _this._flush_text_collector(send, collector, _this._copy(meta));
                if (region_stack.length > 0) {
                  send(['}', region_stack.pop(), null, _this._copy(meta)]);
                } else {
                  warn("ignoring end-region");
                }
              } else {
                collector.push(line);
              }
            }
            _this._flush_text_collector(send, collector, _this._copy(meta));
          } else {
            send(event);
          }
        }
        if (end != null) {
          if (region_stack.length > 0) {
            warn("auto-closing regions: " + (rpr(region_stack.join(', '))));
            while (region_stack.length > 0) {
              send([
                '}', region_stack.pop(), null, _this._copy(meta, {
                  block: true
                })
              ]);
            }
          }
          end();
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$preprocess_commands = function() {
    var collector, pattern;
    pattern = /^∆∆∆(\S.+)(\n|$)/;
    collector = [];
    return $((function(_this) {
      return function(event, send) {
        var i, len, line, lines, match, meta, name, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (!((type === '.') && (name === 'text'))) {
          return send(event);
        }
        lines = _this._split_lines_with_nl(text);
        for (i = 0, len = lines.length; i < len; i++) {
          line = lines[i];
          if ((match = line.match(pattern)) != null) {
            _this._flush_text_collector(send, collector, _this._copy(meta));
            send(['∆', match[1], null, _this._copy(meta)]);
          } else {
            collector.push(line);
          }
        }
        _this._flush_text_collector(send, collector, _this._copy(meta));
        return null;
      };
    })(this));
  };

  this.TYPO.isa = function(event, type, name) {
    var ref, ref1, type_of_name, type_of_type;
    switch (type_of_type = CND.type_of(type)) {
      case 'text':
        if (event[0] !== type) {
          return false;
        }
        break;
      case 'list':
        if (ref = event[0], indexOf.call(type, ref) < 0) {
          return false;
        }
        break;
      default:
        throw new Error("expected text or list, got a " + type_of_type);
    }
    switch (type_of_name = CND.type_of(name)) {
      case 'text':
        if (event[1] !== name) {
          return false;
        }
        break;
      case 'list':
        if (ref1 = event[1], indexOf.call(name, ref1) < 0) {
          return false;
        }
        break;
      default:
        throw new Error("expected text or list, got a " + type_of_name);
    }
    return true;
  };

  this.TYPO._copy = function(meta, overwrites) {
    var R, name, value;
    R = {};
    for (name in meta) {
      value = meta[name];
      R[name] = value;
    }
    if (overwrites != null) {
      for (name in overwrites) {
        value = overwrites[name];
        R[name] = value;
      }
    }
    return R;
  };

  this.TYPO._split_lines_with_nl = function(text) {
    var i, len, line, ref, results;
    ref = text.split(/(.*\n)/);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      if (line.length > 0) {
        results.push(line);
      }
    }
    return results;
  };

  this.TYPO._flush_text_collector = function(send, collector, meta) {
    if (collector.length > 0) {
      send(['.', 'text', collector.join(''), meta]);
      collector.length = 0;
    }
    return null;
  };

  this.TYPO.$add_lookahead = function() {
    var previous_event;
    previous_event = null;
    return $(function(event, send, end) {
      if (event != null) {
        if (previous_event != null) {
          previous_event[3]['ends-block'] = event[3]['block'];
          send(previous_event);
        }
        previous_event = event;
      }
      if (end != null) {
        previous_event[3]['ends-block'] = false;
        send(previous_event);
        end();
      }
      return null;
    });
  };

  this.TYPO.$show_mktsmd_events = function() {
    var indentation, level, next_indentation, unknown_events;
    unknown_events = [];
    level = 0;
    indentation = '';
    next_indentation = indentation;
    return D.$observe(function(event, has_ended) {
      var color, meta, name, text, type;
      if (event != null) {
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (type === '?') {
          if (indexOf.call(unknown_events, name) < 0) {
            unknown_events.push(name);
          }
          warn(JSON.stringify(event));
        } else {
          color = CND.blue;
          switch (type) {
            case '{':
            case '[':
            case '(':
              level += +1;
              next_indentation = (new Array(level)).join('  ');
              break;
            case ')':
            case ']':
            case '}':
              level += -1;
              next_indentation = (new Array(level)).join('  ');
              break;
            case '.':
              switch (name) {
                case 'text':
                  color = CND.green;
                  break;
                case 'code':
                  color = CND.orange;
              }
          }
          switch (type) {
            case '{':
              color = CND.red;
              break;
            case '∆':
              color = CND.red;
              break;
            case ')':
            case ']':
            case '}':
              color = CND.grey;
          }
          text = text != null ? color(rpr(text)) : '';
          log(indentation + (CND.grey(type)) + (color(name)) + ' ' + text);
          indentation = next_indentation;
        }
      }
      if (has_ended) {
        if (unknown_events.length > 0) {
          warn("unknown events: " + (unknown_events.sort().join(', ')));
        }
      }
      return null;
    });
  };

  this.TYPO.create_mdreadstream = function(md_source, settings) {
    var R, confluence;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }
    confluence = D.create_throughstream();
    R = D.create_throughstream();
    R.pause();
    confluence.pipe(this.$flatten_tokens()).pipe(this.$rewrite_markdownit_tokens()).pipe(this.$preprocess_regions()).pipe(this.$preprocess_commands()).pipe(R);
    R.on('resume', (function(_this) {
      return function() {
        var environment, i, len, md_parser, token, tokens;
        md_parser = _this._new_markdown_parser();
        environment = {};
        tokens = md_parser.parse(md_source, environment);
        _this.set_meta(R, 'environment', environment);
        for (i = 0, len = tokens.length; i < len; i++) {
          token = tokens[i];
          confluence.write(token);
        }
        return confluence.end();
      };
    })(this));
    return R;
  };

}).call(this);

//# sourceMappingURL=../sourcemaps/HELPERS.js.map