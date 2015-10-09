(function() {
  var $, $async, ASYNC, CND, D, Markdown_parser, XNCHR, alert, badge, debug, echo, get_parse_html_methods, help, info, log, new_md_inline_plugin, njs_fs, njs_path, parse_methods, rpr, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
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

  new_md_inline_plugin = require('markdown-it-regexp');

  this.new_layout_info = function(options, source_route) {
    var R, aux_locator, content_locator, content_name, job_name, master_ext, master_locator, master_name, mkscript_locator, pdf_locator, source_home, source_locator, source_name, texinputs_value, xelatex_command;
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
    mkscript_locator = njs_path.join(source_home, job_name + ".mkscript");
    master_name = options['master']['filename'];
    master_ext = njs_path.extname(master_name);
    master_locator = njs_path.join(source_home, master_name);
    content_name = options['content']['filename'];
    content_locator = njs_path.join(source_home, content_name);

    /* TAINT duplication: tex_inputs_home, texinputs_value */
    texinputs_value = options['texinputs']['value'];
    R = {
      'aux-locator': aux_locator,
      'content-locator': content_locator,
      'job-name': job_name,
      'master-locator': master_locator,
      'master-name': master_name,
      'pdf-locator': pdf_locator,
      'mkscript-locator': mkscript_locator,
      'source-home': source_home,
      'source-locator': source_locator,
      'source-name': source_name,
      'source-route': source_route,
      'tex-inputs-value': texinputs_value,
      'xelatex-command': xelatex_command,
      'xelatex-run-count': 0
    };
    return R;
  };

  this.write_pdf = function(layout_info, handler) {
    var aux_locator, count, digest, error_lines, i, idx, job_name, last_digest, master_locator, parameters, pdf_from_tex, pdf_locator, ref, source_home, texinputs_value, xelatex_command;
    job_name = layout_info['job-name'];
    source_home = layout_info['source-home'];
    xelatex_command = layout_info['xelatex-command'];
    master_locator = layout_info['master-locator'];
    aux_locator = layout_info['aux-locator'];
    pdf_locator = layout_info['pdf-locator'];
    last_digest = null;
    if (njs_fs.existsSync(aux_locator)) {
      last_digest = CND.id_from_route(aux_locator);
    }
    digest = null;
    count = 0;
    texinputs_value = layout_info['tex-inputs-value'];
    parameters = [texinputs_value, source_home, job_name, master_locator];
    error_lines = [];
    urge("" + xelatex_command);
    for (idx = i = 0, ref = parameters.length; 0 <= ref ? i < ref : i > ref; idx = 0 <= ref ? ++i : --i) {
      whisper("$" + (idx + 1) + ": " + parameters[idx]);
    }
    log(xelatex_command + " " + (parameters.join(' ')));
    pdf_from_tex = (function(_this) {
      return function(next) {
        var cp;
        count += 1;
        urge("run #" + count);
        cp = (require('child_process')).spawn(xelatex_command, parameters);
        cp.stdout.pipe(D.$split()).pipe(D.$observe(function(line) {
          return echo(CND.grey(line));
        }));
        cp.stderr.pipe(D.$split()).pipe(D.$observe(function(line) {
          error_lines.push(line);
          return echo(CND.red(line));
        }));
        return cp.on('close', function(error) {
          var line, message;
          if (error === 0) {
            error = void 0;
          }
          if (error != null) {
            alert(error);
            return handler(error);
          }
          if (error_lines.length > 0) {

            /* TAINT looks like we're getting empty lines on stderr? */
            message = ((function() {
              var j, len, results;
              results = [];
              for (j = 0, len = error_lines.length; j < len; j++) {
                line = error_lines[j];
                if (line.length > 0) {
                  results.push(line);
                }
              }
              return results;
            })()).join('\n');
            if (message.length > 0) {
              alert(message);
              return handler(message);
            }
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

  this.TYPO.$fix_typography_for_tex = function(options) {
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.isa(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          text = _this.fix_typography_for_tex(text, options);
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

  this.TYPO.fix_typography_for_tex = function(text, options) {

    /* An improved version of `XELATEX.tag_from_chr` */

    /* TAINT should accept settings, fall back to `require`d `options.coffee` */
    var R, advance, chr, chr_info, command, fncr, glyph_styles, i, last_command, last_rsg, len, ref, ref1, ref2, ref3, replacement, rsg, stretch, tex_command_by_rsgs, uchr;
    glyph_styles = (ref = (ref1 = options['tex']) != null ? ref1['glyph-styles'] : void 0) != null ? ref : {};
    tex_command_by_rsgs = (ref2 = options['tex']) != null ? ref2['tex-command-by-rsgs'] : void 0;
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

  this.TYPO.$flatten_tokens = function(S) {
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

  get_parse_html_methods = function() {
    var Parser, R, get_message, parser;
    Parser = (require('parse5')).Parser;
    parser = new Parser();
    get_message = function(source) {
      return "expected single openening node, got " + (rpr(source));
    };
    R = {};
    R['_parse_html_open_tag'] = function(source) {
      var cn, cns, ref, ref1, tree;
      tree = parser.parseFragment(source);
      if ((cns = tree['childNodes']).length !== 1) {
        throw new Error(get_message(source));
      }
      cn = cns[0];
      if (((ref = cn['childNodes']) != null ? ref.length : void 0) !== 0) {
        throw new Error(get_message(source));
      }
      return ['begin', cn['tagName'], (ref1 = cn['attrs'][0]) != null ? ref1 : {}];
    };
    R['_parse_html_block'] = function(source) {
      var tree;
      tree = parser.parseFragment(source);
      debug('@88817', tree);
      return null;
    };
    return R;
  };

  parse_methods = get_parse_html_methods();

  this.TYPO._parse_html_open_tag = parse_methods['_parse_html_open_tag'];

  this.TYPO._parse_html_block = parse_methods['_parse_html_block'];

  this.TYPO._parse_html_tag = function(source) {
    var match;
    if ((match = source.match(this._parse_html_tag.close_tag_pattern)) != null) {
      return ['end', match[1]];
    }
    if ((match = source.match(this._parse_html_tag.comment_pattern)) != null) {
      return ['comment', 'comment', match[1]];
    }
    return this._parse_html_open_tag(source);
  };

  this.TYPO._parse_html_tag.close_tag_pattern = /^<\/([^>]+)>$/;

  this.TYPO._parse_html_tag.comment_pattern = /^<!--([\s\S]*)-->$/;

  this.TYPO._fence_pairs = {
    '<': '>',
    '{': '}',
    '[': ']',
    '(': ')',
    '>': '<',
    '}': '{',
    ']': '[',
    ')': '('
  };

  this.TYPO._get_opposite_fence = function(fence, fallback) {
    var R;
    if ((R = this._fence_pairs[fence]) == null) {
      if (fallback !== void 0) {
        return fallback;
      }
      throw new Error("unknown fence: " + (rpr(fence)));
    }
    return R;
  };

  this.TYPO.$rewrite_markdownit_tokens = function(S) {
    var _send, is_first, last_map, send_unknown, unknown_tokens;
    unknown_tokens = [];
    is_first = true;
    last_map = [0, 0];
    _send = null;
    send_unknown = (function(_this) {
      return function(token) {
        debug('@8876', token);
        send(['?', token['tag'], token['content'], meta]);
        if (indexOf.call(unknown_tokens, type) < 0) {
          return unknown_tokens.push(type);
        }
      };
    })(this);
    return $((function(_this) {
      return function(token, send, end) {
        var col_nr, extra, language_name, line_nr, map, meta, name, position, ref, ref1, ref2, type;
        _send = send;
        if (token != null) {
          type = token.type, map = token.map;
          if (map == null) {
            map = last_map;
          }
          line_nr = ((ref = map[0]) != null ? ref : 0) + 1;
          col_nr = ((ref1 = map[1]) != null ? ref1 : 0) + 1;
          meta = {
            line_nr: line_nr,
            col_nr: col_nr
          };
          if (is_first) {
            is_first = false;
            send(['<', 'document', null, meta]);
          }
          if (!S.has_ended) {
            switch (type) {
              case 'heading_open':
                send(['[', token['tag'], null, meta]);
                break;
              case 'heading_close':
                send([']', token['tag'], null, meta]);
                break;
              case 'paragraph_open':
                null;
                break;
              case 'paragraph_close':
                send(['.', 'p', null, meta]);
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
                S.within_text_literal = true;
                send(['(', 'code', null, meta]);
                send(['.', 'text', token['content'], _this._copy(meta)]);
                send([')', 'code', null, _this._copy(meta)]);
                S.within_text_literal = false;
                break;
              case 'html_block':
                debug('@8873', _this._parse_html_tag(token['content']));
                break;
              case 'fence':
                switch (token['tag']) {
                  case 'code':
                    language_name = token['info'];
                    if (language_name.length === 0) {
                      language_name = 'text';
                    }
                    send(['{', 'code', language_name, meta]);
                    send(['.', 'text', token['content'], _this._copy(meta)]);
                    send(['}', 'code', language_name, _this._copy(meta)]);
                    break;
                  default:
                    send_unknown(token);
                }
                break;
              case 'html_inline':
                ref2 = _this._parse_html_tag(token['content']), position = ref2[0], name = ref2[1], extra = ref2[2];
                switch (position) {
                  case 'comment':
                    whisper("ignoring comment: " + (rpr(extra)));
                    break;
                  case 'begin':
                    if (name !== 'p') {
                      send(['(', name, extra, meta]);
                    }
                    break;
                  case 'end':
                    if (name === 'p') {
                      send(['.', name, null, meta]);
                    } else {
                      send([')', name, null, meta]);
                    }
                    break;
                  default:
                    throw new Error("unknown HTML tag position " + (rpr(position)));
                }
                break;
              default:
                send_unknown(token);
            }
            last_map = map;
          }
        }
        if (end != null) {
          if (unknown_tokens.length > 0) {
            warn("unknown tokens: " + (unknown_tokens.sort().join(', ')));
          }

          /* TAINT could send end document earlier in case of `∆∆∆end` */
          send(['>', 'document', null, {}]);
          end();
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$preprocess_regions = function(S) {
    var closing_pattern, collector, opening_pattern, region_stack;
    opening_pattern = /^@@@(\S.+)(\n|$)/;
    closing_pattern = /^@@@\s*(\n|$)/;
    collector = [];
    region_stack = [];
    return $((function(_this) {
      return function(event, send) {
        var i, len, line, lines, match, meta, name, region_name, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if ((!S.within_text_literal) && (_this.isa(event, '.', 'text'))) {
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
        } else if ((region_stack.length > 0) && (_this.isa(event, '>', 'document'))) {
          warn("auto-closing regions: " + (rpr(region_stack.join(', '))));
          while (region_stack.length > 0) {
            send([
              '}', region_stack.pop(), null, _this._copy(meta, {
                block: true
              })
            ]);
          }
          send(event);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$preprocess_commands = function(S) {
    var collector, pattern;
    pattern = /^∆∆∆(\S.+)(\n|$)/;
    collector = [];
    return $((function(_this) {
      return function(event, send) {
        var i, len, line, lines, match, meta, name, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (_this.isa(event, '.', 'text')) {
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
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$process_end_command = function(S) {
    S.has_ended = false;
    return $((function(_this) {
      return function(event, send) {
        var _, line_nr, meta;
        if (_this.isa(event, '∆', 'end')) {
          _ = event[0], _ = event[1], _ = event[2], meta = event[3];
          line_nr = meta.line_nr;
          warn("encountered `∆∆∆end` on line #" + line_nr + ", ignoring further material");
          S.has_ended = true;
        } else if (_this.isa(event, '>', 'document')) {
          send(event);
        } else {
          if (!S.has_ended) {
            send(event);
          }
        }
        return null;
      };
    })(this));
  };

  this.TYPO.$close_dangling_open_tags = function(S) {
    var tag_stack;
    tag_stack = [];
    return $((function(_this) {
      return function(event, send) {
        var meta, name, sub_event, sub_meta, sub_name, sub_type, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (_this.isa(event, ['{', '[', '('])) {
          tag_stack.push([type, name, null, meta]);
          send(event);
        } else if (_this.isa(event, ['}', ']', ')'])) {
          if (_this.isa(event, '>', 'document')) {
            while (tag_stack.length > 0) {
              sub_event = tag_stack.pop();
              sub_type = sub_event[0], sub_name = sub_event[1], sub_meta = sub_event[2];
              switch (sub_type) {
                case '{':
                  sub_type = '}';
                  break;
                case '[':
                  sub_type = ']';
                  break;
                case '(':
                  sub_type = ')';
              }
              send([sub_type, sub_name, null, _this._copy(sub_meta)]);
            }
            send(event);
          } else {
            tag_stack.pop();
            send(event);
          }
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.TYPO.isa = function(event, type, name) {
    var ref, ref1, type_of_name, type_of_type;
    if (type != null) {
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
    }
    if (name != null) {
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
    }
    return true;
  };

  this.TYPO._copy = function(meta, overwrites) {

    /* TAINT use `Object.assign` or similar */
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

  this.TYPO.new_area_observer = function() {
    var area_name, area_names, i, len, state, track, within;
    area_names = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    state = {};
    for (i = 0, len = area_names.length; i < len; i++) {
      area_name = area_names[i];
      if (state[area_name] != null) {
        throw new Error("repeated area_name " + (rpr(area_name)));
      }
      state[area_name] = false;
    }
    track = (function(_this) {
      return function(event) {
        var meta, text, type;
        if (event != null) {
          type = event[0], area_name = event[1], text = event[2], meta = event[3];
          if (area_name in state) {
            if (type === '<' || type === '{' || type === '[' || type === '(') {
              state[area_name] = true;
            } else if (type === '>' || type === '}' || type === ']' || type === ')') {
              state[area_name] = false;
            }
          }
        }
        return event;
      };
    })(this);
    within = (function(_this) {
      return function(pattern) {
        var R;
        if ((R = state[pattern]) == null) {
          throw new Error("untracked pattern " + (rpr(pattern)));
        }
        return R;
      };
    })(this);
    return [track, within];
  };

  this.TYPO.$show_mktsmd_events = function(S) {
    var indentation, tag_stack, unknown_events;
    unknown_events = [];
    indentation = '';
    tag_stack = [];
    return D.$observe(function(event, has_ended) {
      var color, meta, name, ref, ref1, text, topmost_name, topmost_type, type;
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
            case '<':
            case '>':
              color = CND.yellow;
              break;
            case '{':
            case '∆':
              color = CND.red;
              break;
            case ')':
            case ']':
            case '}':
              color = CND.grey;
              break;
            case '.':
              switch (name) {
                case 'text':
                  color = CND.green;
              }
          }
          text = text != null ? color(rpr(text)) : '';
          switch (type) {
            case 'text':
              log(indentation + (color(type)) + ' ' + rpr(name));
              break;
            case 'tex':
              if ((ref = S.show_tex_events) != null ? ref : false) {
                log(indentation + (CND.grey(type)) + (color(name)) + ' ' + text);
              }
              break;
            default:
              log(indentation + (CND.grey(type)) + (color(name)) + ' ' + text);
          }
          switch (type) {
            case '{':
            case '[':
            case '(':
            case ')':
            case ']':
            case '}':
              switch (type) {
                case '{':
                case '[':
                case '(':
                  tag_stack.push([type, name]);
                  break;
                case ')':
                case ']':
                case '}':
                  if (tag_stack.length > 0) {
                    ref1 = tag_stack.pop(), topmost_type = ref1[0], topmost_name = ref1[1];
                    if (topmost_name !== name) {
                      topmost_type = {
                        '{': '}',
                        '[': ']',
                        '(': '(',
                        ')': ')'
                      }[topmost_type];
                      warn("encountered " + type + name + " when " + topmost_type + topmost_name + " was expected");
                    }
                  } else {
                    warn("level below zero");
                  }
              }
              indentation = (new Array(tag_stack.length)).join('  ');
          }
        }
      }
      if (has_ended) {
        if (tag_stack.length > 0) {
          warn("unclosed tags: " + (tag_stack.join(', ')));
        }
        if (unknown_events.length > 0) {
          warn("unknown events: " + (unknown_events.sort().join(', ')));
        }
      }
      return null;
    });
  };

  this.TYPO.$write_mktscript = function(S) {
    var confluence, indentation, mkscript_locator, output, tag_stack, write;
    indentation = '';
    tag_stack = [];
    mkscript_locator = S.layout_info['mkscript-locator'];
    output = njs_fs.createWriteStream(mkscript_locator);
    confluence = D.create_throughstream();
    write = confluence.write.bind(confluence);
    confluence.pipe(output);
    return D.$observe(function(event, has_ended) {
      var anchor, line_nr, meta, name, text, text_rpr, type;
      if (event != null) {
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (type !== 'tex' && type !== 'text') {
          line_nr = meta.line_nr;
          anchor = "█ " + line_nr + " █ ";
          switch (type) {
            case '?':
              write("\n" + anchor + type + name + "\n");
              break;
            case '<':
            case '{':
            case '[':
              write("" + anchor + type + name);
              break;
            case '>':
            case '}':
            case ']':
            case '∆':
              write(type + "\n");
              break;
            case '(':
              write("" + type + name);
              break;
            case ')':
              write("" + type);
              break;
            case '.':
              switch (name) {
                case 'hr':
                  write("\n" + anchor + type + name + "\n");
                  break;
                case 'p':
                  write("¶\n");
                  break;
                case 'text':

                  /* TAINT doesn't recognize escaped backslash */
                  text_rpr = (rpr(text)).replace(/\\n/g, '\n');
                  write(text_rpr);
                  break;
                default:
                  write("\n" + anchor + "IGNORED: " + (rpr(event)));
              }
              break;
            default:
              write("\n" + anchor + "IGNORED: " + (rpr(event)));
          }
        }
      }
      if (has_ended) {
        output.end();
      }
      return null;
    });
  };

  this.TYPO.create_mdreadstream = function(md_source, settings) {
    var R, confluence, state;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }
    state = {
      within_text_literal: false
    };
    confluence = D.create_throughstream();
    R = D.create_throughstream();
    R.pause();
    confluence.pipe(this.$flatten_tokens(state)).pipe((function(_this) {
      return function() {

        /* re-inject HTML blocks */
        var md_parser;
        md_parser = _this._new_markdown_parser();
        return $(function(token, send) {
          var XXX_source, environment, i, len, map, ref, ref1, ref2, removed, results, tokens, type;
          type = token.type, map = token.map;
          if (type === 'html_block') {

            /* TAINT `map` location data is borked with this method */

            /* add extraneous text content; this causes the parser to parse the HTML block as a paragraph
            with some inline HTML:
             */
            XXX_source = "XXX" + token['content'];
            environment = {};
            tokens = md_parser.parse(XXX_source, environment);

            /* remove extraneous text content: */
            removed = (ref = tokens[1]) != null ? (ref1 = ref['children']) != null ? ref1.splice(0, 1) : void 0 : void 0;
            if (((ref2 = removed[0]) != null ? ref2['content'] : void 0) !== "XXX") {
              throw new Error("should never happen");
            }
            results = [];
            for (i = 0, len = tokens.length; i < len; i++) {
              token = tokens[i];
              results.push(confluence.write(token));
            }
            return results;
          } else {
            return send(token);
          }
        });
      };
    })(this)()).pipe(this.$rewrite_markdownit_tokens(state)).pipe(this.$preprocess_commands(state)).pipe(this.$process_end_command(state)).pipe(this.$preprocess_regions(state)).pipe(this.$close_dangling_open_tags(state)).pipe(R);
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