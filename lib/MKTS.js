(function() {
  var $, CND, D, Markdown_parser, XNCHR, alert, badge, debug, echo, fences_rxcc, get_parse_html_methods, help, info, log, misfit, name_rx, new_md_inline_plugin, njs_fs, parse_methods, rpr, tracker_pattern, urge, warn, whisper,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/MKTS';

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

  D = require('pipedreams');

  $ = D.remit.bind(D);

  Markdown_parser = require('markdown-it');

  new_md_inline_plugin = require('markdown-it-regexp');

  misfit = Symbol('misfit');

  this._tex_escape_replacements = [[/\x01/g, '\x01\x02'], [/\x5c/g, '\x01\x01'], [/\{/g, '\\{'], [/\}/g, '\\}'], [/\$/g, '\\$'], [/\#/g, '\\#'], [/%/g, '\\%'], [/_/g, '\\_'], [/\^/g, '\\textasciicircum{}'], [/~/g, '\\textasciitilde{}'], [/&/g, '\\&'], [/\x01\x01/g, '\\textbackslash{}'], [/\x01\x02/g, '\x01']];

  this.escape_for_tex = function(text) {
    var R, i, idx, len, pattern, ref, ref1, replacement;
    R = text;
    ref = this._tex_escape_replacements;
    for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
      ref1 = ref[idx], pattern = ref1[0], replacement = ref1[1];
      R = R.replace(pattern, replacement);
    }
    return R;
  };

  this.$fix_typography_for_tex = function(options) {
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          meta['raw'] = text;
          text = _this.fix_typography_for_tex(text, options);
          return send([type, name, text, meta]);
        } else {
          return send(event);
        }
      };
    })(this));
  };

  this.fix_typography_for_tex = function(text, options) {

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

  this._new_markdown_parser = function() {

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

  this.$_flatten_tokens = function(S) {
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

  this.$_reinject_html_blocks = function(S) {

    /* re-inject HTML blocks */
    var md_parser;
    md_parser = this._new_markdown_parser();
    return $((function(_this) {
      return function(token, send) {
        var XXX_source, environment, i, len, map, ref, ref1, ref2, removed, results, tokens, type;
        type = token.type, map = token.map;
        if (type === 'html_block') {

          /* TAINT `map` location data is borked with this method */

          /* add extraneous text content; this causes the parser to parse the HTML block as a paragraph
          with some inline HTML:
           */
          XXX_source = "XXX" + token['content'];

          /* for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse */

          /* TAINT what to do with useful data appearing environment? */
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
            results.push(S.confluence.write(token));
          }
          return results;
        } else {
          return send(token);
        }
      };
    })(this));
  };

  get_parse_html_methods = function() {
    var Parser, R, get_message, parser;
    Parser = (require('parse5')).Parser;
    parser = new Parser();
    get_message = function(source) {
      return "expected single opening node, got " + (rpr(source));
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

  this._parse_html_open_tag = parse_methods['_parse_html_open_tag'];

  this._parse_html_block = parse_methods['_parse_html_block'];

  this._parse_html_tag = function(source) {
    var match;
    if ((match = source.match(this._parse_html_tag.close_tag_pattern)) != null) {
      return ['end', match[1]];
    }
    if ((match = source.match(this._parse_html_tag.comment_pattern)) != null) {
      return ['comment', 'comment', match[1]];
    }
    return this._parse_html_open_tag(source);
  };

  this._parse_html_tag.close_tag_pattern = /^<\/([^>]+)>$/;

  this._parse_html_tag.comment_pattern = /^<!--([\s\S]*)-->$/;

  this.FENCES = {};

  this.FENCES.xleft = ['<', '{', '[', '('];

  this.FENCES.xright = ['>', '}', ']', ')'];

  this.FENCES.left = ['{', '[', '('];

  this.FENCES.right = ['}', ']', ')'];

  this.FENCES.xpairs = {
    '<': '>',
    '{': '}',
    '[': ']',
    '(': ')',
    '>': '<',
    '}': '{',
    ']': '[',
    ')': '('
  };

  this.FENCES._get_opposite = (function(_this) {
    return function(fence, fallback) {
      var R;
      if ((R = _this.FENCES.xpairs[fence]) == null) {
        if (fallback !== void 0) {
          return fallback;
        }
        throw new Error("unknown fence: " + (rpr(fence)));
      }
      return R;
    };
  })(this);

  this.TRACKER = {};


  /* TAINT shouldn't be defined at module level */

  fences_rxcc = /<\.\{\[\(\)\]\}>/;

  name_rx = RegExp("[^\\s" + fences_rxcc.source + "]*");

  tracker_pattern = RegExp("^([" + fences_rxcc.source + "]?)(" + name_rx.source + ")([" + fences_rxcc.source + "]?)$");

  this.FENCES.parse = (function(_this) {
    return function(pattern, settings) {
      var _, left_fence, match, name, ref, right_fence, symmetric;
      left_fence = null;
      name = null;
      right_fence = null;
      symmetric = (ref = settings != null ? settings['symmetric'] : void 0) != null ? ref : true;
      if ((pattern == null) || pattern.length === 0) {
        throw new Error("pattern must be non-empty, got " + (rpr(pattern)));
      }
      match = pattern.match(_this.TRACKER._tracker_pattern);
      if (match == null) {
        throw new Error("not a valid pattern: " + (rpr(pattern)));
      }
      _ = match[0], left_fence = match[1], name = match[2], right_fence = match[3];
      if (left_fence.length === 0) {
        left_fence = null;
      }
      if (name.length === 0) {
        name = null;
      }
      if (right_fence.length === 0) {
        right_fence = null;
      }
      if (left_fence === '.') {

        /* Can not have a right fence if left fence is a dot */
        if (right_fence != null) {
          throw new Error("fence '.' can not have right fence, got " + (rpr(pattern)));
        }
      } else {

        /* Except for dot fence, must always have no fence or both fences in case `symmetric` is set */
        if (symmetric) {
          if (((left_fence != null) && (right_fence == null)) || ((right_fence != null) && (left_fence == null))) {
            throw new Error("unmatched fence in " + (rpr(pattern)));
          }
        }
      }
      if ((left_fence != null) && left_fence !== '.') {

        /* Complain about unknown left fences */
        if (indexOf.call(_this.FENCES.xleft, left_fence) < 0) {
          throw new Error("illegal left_fence in pattern " + (rpr(pattern)));
        }
        if (right_fence != null) {

          /* Complain about non-matching fences */
          if ((_this.FENCES._get_opposite(left_fence, null)) !== right_fence) {
            throw new Error("fences don't match in pattern " + (rpr(pattern)));
          }
        }
      }
      if (right_fence != null) {

        /* Complain about unknown right fences */
        if (indexOf.call(_this.FENCES.xright, right_fence) < 0) {
          throw new Error("illegal right_fence in pattern " + (rpr(pattern)));
        }
      }
      return [left_fence, name, right_fence];
    };
  })(this);

  this.TRACKER._tracker_pattern = tracker_pattern;

  this.TRACKER.new_tracker = (function(_this) {
    return function() {
      var _MKTS, patterns, self;
      patterns = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      _MKTS = _this;
      self = function(event) {
        var event_name, left_fence, parts, pattern, pattern_name, ref, ref1, right_fence, state, type;
        ref = self._states;
        for (pattern in ref) {
          state = ref[pattern];
          parts = state.parts;
          if (!_MKTS.select.apply(_MKTS, [event].concat(slice.call(parts)))) {
            continue;
          }
          (ref1 = parts[0], left_fence = ref1[0], right_fence = ref1[1]), pattern_name = parts[1];
          type = event[0], event_name = event[1];
          if (type === left_fence) {
            self._enter(state);
          } else {
            self._leave(state);
            if (state['count'] < 0) {
              throw new Error("too many right fences: " + (rpr(event)));
            }
          }
        }
        return event;
      };
      self._states = {};
      self._get_state = function(pattern) {
        var R;
        if ((R = self._states[pattern]) == null) {
          throw new Error("untracked pattern " + (rpr(pattern)));
        }
        return R;
      };
      self.within = function() {
        var i, len, pattern, patterns;
        patterns = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        for (i = 0, len = patterns.length; i < len; i++) {
          pattern = patterns[i];
          if (self._within(pattern)) {
            return true;
          }
        }
        return false;
      };
      self._within = function(pattern) {
        return (self._get_state(pattern))['count'] > 0;
      };
      self.enter = function(pattern) {
        return self._enter(self._get_state(pattern));
      };
      self.leave = function(pattern) {
        return self._leave(self._get_state(pattern));
      };
      self._enter = function(state) {
        return state['count'] += +1;
      };

      /* TAINT should validate count when leaving */
      self._leave = function(state) {
        return state['count'] += -1;
      };
      (function() {
        var i, left_fence, len, pattern, pattern_name, ref, results, right_fence, state;
        results = [];
        for (i = 0, len = patterns.length; i < len; i++) {
          pattern = patterns[i];
          ref = _MKTS.FENCES.parse(pattern), left_fence = ref[0], pattern_name = ref[1], right_fence = ref[2];
          state = {
            parts: [[left_fence, right_fence], pattern_name],
            count: 0
          };
          results.push(self._states[pattern] = state);
        }
        return results;
      })();
      return self;
    };
  })(this);

  this.$_rewrite_markdownit_tokens = function(S) {
    var _send, is_first, last_map, send_unknown, unknown_tokens;
    unknown_tokens = [];
    is_first = true;
    last_map = [0, 0];
    _send = null;
    send_unknown = (function(_this) {
      return function(token, meta) {
        var type;
        type = token.type;
        _send(['?', type, token['content'], meta]);
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
                send(['(', 'code', null, meta]);
                send(['.', 'text', token['content'], _this.copy(meta)]);
                send([')', 'code', null, _this.copy(meta)]);
                break;
              case 'html_block':
                debug('@8873', _this._parse_html_tag(token['content']));
                throw new Error("should never happen");
                break;
              case 'fence':
                switch (token['tag']) {
                  case 'code':
                    language_name = token['info'];
                    if (language_name.length === 0) {
                      language_name = 'text';
                    }
                    send(['{', 'code', language_name, meta]);
                    send(['.', 'text', token['content'], _this.copy(meta)]);
                    send(['}', 'code', language_name, _this.copy(meta)]);
                    break;
                  default:
                    send_unknown(token, meta);
                }
                break;
              case 'html_inline':
                ref2 = _this._parse_html_tag(token['content']), position = ref2[0], name = ref2[1], extra = ref2[2];
                switch (position) {
                  case 'comment':
                    send(['.', 'comment', extra.trim(), meta]);
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
                send_unknown(token, meta);
            }
            last_map = map;
          }
        }
        if (end != null) {
          if (unknown_tokens.length > 0) {
            warn("unknown tokens: " + (unknown_tokens.sort().join(', ')));
          }
          send(['>', 'document', null, {}]);
          end();
        }
        return null;
      };
    })(this));
  };

  this.$_preprocess_commands = function(S) {

    /* TAINT `<xxx>` translates as `(xxx`, which is generally correct, but it should translate
    to `(xxx)` when `xxx` is a known HTML5 'lone' tag.
     */
    var collector, fence_pattern, left_meta_fence, prefix_pattern, repetitions, right_meta_fence, track;
    left_meta_fence = '<';
    right_meta_fence = '>';
    repetitions = 2;
    fence_pattern = RegExp(left_meta_fence + "{" + repetitions + "}((?:\\\\" + right_meta_fence + "|[^" + right_meta_fence + "]|" + right_meta_fence + "{" + (repetitions - 1) + "}(?!" + right_meta_fence + "))*)" + right_meta_fence + "{" + repetitions + "}");
    prefix_pattern = /^([!:])(.*)/;
    collector = [];
    track = this.TRACKER.new_tracker('{code}', '(code)', '(latex)', '(latex)');
    return $((function(_this) {
      return function(event, send) {
        var _, command_name, i, is_command, last_idx, left_fence, len, match, meta, name, part, prefix, ref, ref1, ref2, right_fence, suffix, text, type, within_literal;
        within_literal = track.within('{code}', '(code)', '(latex)', '(latex)');
        track(event);
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if ((!within_literal) && _this.select(event, '.', 'text')) {
          is_command = true;
          ref = text.split(fence_pattern);
          for (i = 0, len = ref.length; i < len; i++) {
            part = ref[i];
            is_command = !is_command;
            left_fence = null;
            right_fence = null;
            if (is_command) {
              last_idx = part.length - 1;
              if (ref1 = part[0], indexOf.call(_this.FENCES.xleft, ref1) >= 0) {
                left_fence = part[0];
              }
              if (ref2 = part[last_idx], indexOf.call(_this.FENCES.xright, ref2) >= 0) {
                right_fence = part[last_idx];
              }
              if ((left_fence != null) && (right_fence != null)) {
                command_name = part.slice(1, last_idx);
                if (prefix_pattern.test(command_name)) {
                  warn("prefix not supported in " + (rpr(part)));
                  send(['?', part, null, _this.copy(meta)]);
                } else {
                  send([left_fence, command_name, null, _this.copy(meta)]);
                  send([right_fence, command_name, null, _this.copy(meta)]);
                }
              } else if (left_fence != null) {
                command_name = part.slice(1);
                if ((match = command_name.match(prefix_pattern)) != null) {
                  _ = match[0], prefix = match[1], suffix = match[2];
                  switch (prefix) {
                    case ':':
                      send([left_fence, prefix, suffix, _this.copy(meta)]);
                      break;
                    default:
                      warn("prefix " + (rpr(prefix)) + " not supported in " + (rpr(part)));
                      send(['?', part, null, _this.copy(meta)]);
                  }
                } else {
                  send([left_fence, command_name, null, _this.copy(meta)]);
                }
              } else if (right_fence != null) {

                /* TAINT code duplication */
                command_name = part.slice(0, last_idx);
                if ((match = command_name.match(prefix_pattern)) != null) {
                  _ = match[0], prefix = match[1], suffix = match[2];
                  switch (prefix) {
                    case ':':
                      send([right_fence, prefix, suffix, _this.copy(meta)]);
                      break;
                    default:
                      warn("prefix " + (rpr(prefix)) + " not supported in " + (rpr(part)));
                      send(['?', part, null, _this.copy(meta)]);
                  }
                } else {
                  send([right_fence, command_name, null, _this.copy(meta)]);
                }
              } else {
                match = part.match(prefix_pattern);
                if (match == null) {
                  warn("not a legal command: " + (rpr(part)));
                  send(['?', part, null, _this.copy(meta)]);
                } else {
                  _ = match[0], prefix = match[1], suffix = match[2];
                  switch (prefix) {
                    case '!':
                      send(['!', suffix, null, _this.copy(meta)]);
                      break;
                    default:
                      warn("prefix " + (rpr(prefix)) + " not supported in " + (rpr(part)));
                      send(['?', part, null, _this.copy(meta)]);
                  }
                }
              }
            } else {
              send([type, name, part, _this.copy(meta)]);
            }
          }
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.$_process_end_command = function(S) {
    S.has_ended = false;
    return $((function(_this) {
      return function(event, send) {
        var _, line_nr, meta;
        if (_this.select(event, '!', 'end')) {
          _ = event[0], _ = event[1], _ = event[2], meta = event[3];
          line_nr = meta.line_nr;
          warn("encountered `<<!end>>` on line #" + line_nr + ", ignoring further material");
          S.has_ended = true;
        } else if (_this.select(event, '>', 'document')) {
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

  this.$close_dangling_open_tags = function(S) {
    var tag_stack;
    tag_stack = [];
    return $((function(_this) {
      return function(event, send) {
        var meta, name, sub_event, sub_meta, sub_name, sub_text, sub_type, text, type;
        type = event[0], name = event[1], text = event[2], meta = event[3];
        if (_this.select(event, '>', 'document')) {
          while (tag_stack.length > 0) {
            sub_event = tag_stack.pop();
            sub_type = sub_event[0], sub_name = sub_event[1], sub_text = sub_event[2], sub_meta = sub_event[3];
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
            S.resend([sub_type, sub_name, sub_text, _this.copy(sub_meta)]);
          }
          send(event);
        } else if (_this.select(event, ['{', '[', '('])) {
          tag_stack.push([type, name, null, meta]);
          send(event);
        } else if (_this.select(event, ['}', ']', ')'])) {

          /* TAINT should check matching pairs */
          tag_stack.pop();
          send(event);
        } else {
          send(event);
        }
        return null;
      };
    })(this));
  };

  this.select = function(event, type, name) {

    /* TAINT should use the same syntax as accepted by `FENCES.parse` */

    /* check for arity as it's easy to write `select event, '(', ')', 'latex'` when what you meant
    was `select event, [ '(', ')', ], 'latex'`
     */
    var arity, ref, ref1, type_of_name, type_of_type;
    if (this.is_hidden(event)) {
      return false;
    }
    if ((arity = arguments.length) > 3) {
      throw new Error("expected at most 3 arguments, got " + arity);
    }
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

  this.stamp = function(event) {

    /* 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
    ignore events that have already been marked upstream, or, inversely choose to look out for events
    that have not yet found a representation in the target document.
     */
    event[3]['stamped'] = true;
    return event;
  };

  this.is_stamped = function(event) {
    var ref;
    return ((ref = event[3]) != null ? ref['stamped'] : void 0) === true;
  };

  this.is_unstamped = function(event) {
    return !this.is_stamped(event);
  };

  this.hide = function(event) {

    /* 'Stamping' an event means to mark it as 'processed'; hence, downstream transformers can choose to
    ignore events that have already been marked upstream, or, inversely choose to look out for events
    that have not yet found a representation in the target document.
     */
    event[3]['hidden'] = true;
    return event;
  };

  this.is_hidden = function(event) {
    var ref;
    return ((ref = event[3]) != null ? ref['hidden'] : void 0) === true;
  };

  this.copy = function() {
    var R, isa_list, meta, updates, x;
    x = arguments[0], updates = 2 <= arguments.length ? slice.call(arguments, 1) : [];

    /* (Hopefully) fast semi-deep copying for events (i.e. lists with a possible `meta` object on
    index 3) and plain objects. The value returned will be a shallow copy in the case of objects and
    lists, but if a list has a value at index 3, that object will also be copied. Not guaranteed to
    work for general values.
     */
    if ((isa_list = CND.isa_list(x))) {
      R = [];
    } else if (CND.isa_pod(x)) {
      R = {};
    } else {
      throw new Error("unable to copy a " + (CND.type_of(x)));
    }
    R = Object.assign.apply(Object, [R, x].concat(slice.call(updates)));
    if (isa_list && ((meta = R[3]) != null)) {
      R[3] = Object.assign({}, meta);
    }
    return R;
  };

  this._split_lines_with_nl = function(text) {
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

  this._flush_text_collector = function(send, collector, meta) {
    if (collector.length > 0) {
      send(['.', 'text', collector.join(''), meta]);
      collector.length = 0;
    }
    return null;
  };

  this.$show_mktsmd_events = function(S) {
    var indentation, tag_stack, unknown_events;
    unknown_events = [];
    indentation = '';
    tag_stack = [];
    return D.$observe((function(_this) {
      return function(event, has_ended) {
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
            if (_this.is_hidden(event)) {
              color = CND.brown;
            } else {
              switch (type) {
                case '<':
                case '>':
                  color = CND.yellow;
                  break;
                case '{':
                case '[':
                case '(':
                  color = CND.lime;
                  break;
                case ')':
                case ']':
                case '}':
                  color = CND.olive;
                  break;
                case '!':
                  color = CND.indigo;
                  break;
                case '.':
                  switch (name) {
                    case 'text':
                      color = CND.BLUE;
                  }
              }
            }
            text = text != null ? color(rpr(text)) : '';
            switch (type) {
              case 'text':
                log(indentation + (color(type)) + ' ' + rpr(name));
                break;
              case 'tex':
                if ((ref = S.show_tex_events) != null ? ref : false) {
                  log(indentation + (color(type)) + (color(name)) + ' ' + text);
                }
                break;
              default:
                log(indentation + (color(type)) + (color(name)) + ' ' + text);
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
      };
    })(this));
  };

  this.$write_mktscript = function(S) {
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
            case '!':
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

  this._escape_command_fences = function(text) {
    var R;
    R = text;
    R = R.replace(/♎/g, '♎0');
    R = R.replace(/\\<\\</g, '♎1');
    R = R.replace(/\\<</g, '♎2');
    R = R.replace(/<\\</g, '♎3');
    R = R.replace(/<</g, '♎4');
    return R;
  };

  this._unescape_command_fences_A = function(text) {
    var R;
    R = text;
    R = R.replace(/♎4/g, '<<');
    return R;
  };

  this._unescape_command_fences_B = function(text) {
    var R;
    R = text;
    R = R.replace(/♎3/g, '<<');
    R = R.replace(/♎2/g, '<<');
    R = R.replace(/♎1/g, '<<');
    R = R.replace(/♎0/g, '♎');
    return R;
  };

  this.$_replace_text = function(S, method) {
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.select(event, '.', ['text', 'code', 'comment'])) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          event[2] = method(text);
        }
        return send(event);
      };
    })(this));
  };

  this.$_remove_empty_texts = function(S) {
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.select(event, '.', 'text')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (text !== '') {
            return send(event);
          }
        } else {
          return send(event);
        }
      };
    })(this));
  };

  this.$_remove_postdef_dispensables = function(S) {
    var last_was_definition;
    last_was_definition = false;
    return $((function(_this) {
      return function(event, send) {
        var meta, name, text, type;
        if (_this.select(event, ')', ':')) {
          debug('>>> 1');
          last_was_definition = true;
          return send(event);
        } else if (last_was_definition && _this.select(event, '.', ['text', 'p'])) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (name === 'text') {
            debug('>>> 2');
            if (/^\n*$/.test(text)) {
              debug('>>> 3');
              return whisper("ignoring blank text after command definition");
            } else {
              debug('>>> 4');
              return send(event);
            }
          } else {
            debug('>>> 5');
            whisper("ignoring `p` after command definition");
            return last_was_definition = false;
          }
        } else {
          debug('>>> 6');
          last_was_definition = false;
          return send(event);
        }
      };
    })(this));
  };

  this.create_mdreadstream = function(md_source, settings) {
    var R, confluence, state;
    if (settings != null) {
      throw new Error("settings currently unsupported");
    }
    confluence = D.create_throughstream();
    R = D.create_throughstream();
    R.pause();
    state = {
      confluence: confluence
    };
    confluence.pipe(this.$_flatten_tokens(state)).pipe(this.$_reinject_html_blocks(state)).pipe(this.$_rewrite_markdownit_tokens(state)).pipe(this.$_replace_text(state, this._unescape_command_fences_A)).pipe(this.$_preprocess_commands(state)).pipe(this.$_replace_text(state, this._unescape_command_fences_B)).pipe(this.$_remove_empty_texts(state)).pipe(this.$_remove_postdef_dispensables(state)).pipe(this.$_process_end_command(state)).pipe(R);
    R.on('resume', (function(_this) {
      return function() {
        var environment, i, len, md_parser, token, tokens;
        md_parser = _this._new_markdown_parser();

        /* for `environment` see https://markdown-it.github.io/markdown-it/#MarkdownIt.parse */

        /* TAINT what to do with useful data appearing environment? */

        /* TAINT environment becomes important for footnotes */
        environment = {};
        md_source = _this._escape_command_fences(md_source);
        tokens = md_parser.parse(md_source, environment);
        for (i = 0, len = tokens.length; i < len; i++) {
          token = tokens[i];
          confluence.write(token);
        }
        return confluence.end();
      };
    })(this));
    return R;
  };


  /* TAINT currently not used, but 'potentially useful'
  #-----------------------------------------------------------------------------------------------------------
  @_meta  = Symbol 'meta'
  
  #-----------------------------------------------------------------------------------------------------------
  @set_meta = ( x, name, value = true ) ->
    target          = x[ @_meta ]?= {}
    target[ name ]  = value
    return x
  
  #-----------------------------------------------------------------------------------------------------------
  @get_meta = ( x, name = null ) ->
    R = x[ @_meta ]
    R = R[ name ] if name
    return R
   */

}).call(this);

//# sourceMappingURL=../sourcemaps/MKTS.js.map