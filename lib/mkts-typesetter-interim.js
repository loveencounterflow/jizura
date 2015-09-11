(function() {
  var $, $async, ASYNC, CND, D, HELPERS, TYPO, alert, badge, debug, echo, help, info, log, njs_fs, njs_path, options, rpr, step, suspend, urge, warn, whisper, ƒ,
    slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'JIZURA/MKTS-interim';

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

  D = require('pipedreams');

  $ = D.remit.bind(D);

  $async = D.remit_async.bind(D);

  ASYNC = require('async');

  ƒ = CND.format_number.bind(CND);

  HELPERS = require('./HELPERS');

  TYPO = HELPERS['TYPO'];

  options = require('./options');

  this.pdf_from_md = function(source_route, handler) {

    /*
    FI = require 'coffeenode-fillin'
    text                    = FI.fill_in template, kwic_details
     */
    var input, layout_info, source_locator, state, tex_locator, tex_output, text;
    HELPERS.provide_tmp_folder();
    if (handler == null) {
      handler = function() {};
    }
    layout_info = HELPERS.new_layout_info(source_route);
    source_locator = layout_info['source-locator'];
    tex_locator = layout_info['tex-locator'];
    tex_output = njs_fs.createWriteStream(tex_locator);

    /* TAINT should read MD source stream */
    text = njs_fs.readFileSync(source_locator, {
      encoding: 'utf-8'
    });
    state = {
      within_multicol: false,
      within_keeplines: false,
      within_pre: false,
      within_single_column: false,
      layout_info: layout_info
    };
    tex_output.on('close', (function(_this) {
      return function() {
        var tasks;
        tasks = [];
        tasks.push(function(done) {
          return HELPERS.write_pdf(layout_info, done);
        });
        return ASYNC.parallel(tasks, handler);
      };
    })(this));
    input = TYPO.create_mdreadstream(text);
    input.pipe(TYPO.$fix_typography_for_tex()).pipe(TYPO.$show_mktsmd_events()).pipe(this.MKTX.COMMAND.$new_page(state)).pipe(this.MKTX.REGION.$keep_lines(state)).pipe(this.MKTX.BLOCK.$heading(state)).pipe(this.MKTX.BLOCK.$paragraph(state)).pipe(this.MKTX.BLOCK.$hr(state)).pipe(this.MKTX.INLINE.$code(state)).pipe(this.MKTX.INLINE.$em_and_strong(state)).pipe(this.$filter_tex()).pipe(this.$insert_preamble(state)).pipe(this.$insert_postscript()).pipe(tex_output);
    return input.resume();
  };

  this.MKTX = {
    COMMAND: {},
    REGION: {},
    BLOCK: {},
    INLINE: {}
  };

  this.MKTX.COMMAND.$new_page = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        if (!TYPO.isa(event, '∆', 'new-page')) {
          return send(event);
        }
        return send(['tex', "\\null\\newpage{}"]);
      });
    };
  })(this);


  /* Pending */

  this.MKTX.REGION.$keep_lines = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (TYPO.isa(event, '.', 'text')) {

          /* TAINT differences between pre and keep-lines? */
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (S.within_pre) {
            text = text.replace(/\u0020/g, '\u00a0');
          }
          return send([type, name, text, meta]);
        } else if (TYPO.isa(event, ['{', '}'], 'keep-lines')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '{') {
            S.within_pre = true;
            S.within_keeplines = true;
            return send(['tex', "\\begingroup\\obeyalllines{}"]);
          } else {
            send(['tex', "\\endgroup{}"]);
            S.within_keeplines = false;
            return S.within_pre = false;
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$heading = (function(_this) {
    return function(S) {
      var restart_multicols;
      restart_multicols = false;
      return $(function(event, send) {
        var meta, name, text, type;
        if (TYPO.isa(event, ['[', ']'], ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '[') {

            /* TAINT Pending
            if S.within_multicol and name in [ 'h1', 'h2', ]
              send [ 'tex', '\\end{multicols}' ]
              S.within_multicol = no
              restart_multicols = yes
             */
            send(['tex', "\n"]);
            switch (name) {
              case 'h1':
                return send(['tex', "\\jzrChapter{"]);
              case 'h2':
                return send(['tex', "\\jzrSection{"]);
              default:
                return send(['tex', "\\subsection{"]);
            }
          } else {

            /* Placing the closing brace on a new line seems to improve line breaking */
            send(['tex', "\n"]);
            send(['tex', "}"]);
            return send(['tex', "\n"]);

            /* TAINT Pending
            if restart_multicols
              send [ 'tex', '\\begin{multicols}{2}\n' ]
              S.within_multicol = yes
             */
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$paragraph = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (TYPO.isa(event, ['[', ']'], 'p')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '[') {
            return send(['text', '\n\n']);
          } else {
            return send(['tex', '\\par']);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.BLOCK.$hr = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var chr, meta, name, text, type;
        if (TYPO.isa(event, '.', 'hr')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          switch (chr = text[0]) {
            case '-':
              return send(['text', '\n--------------\n']);
            case '*':
              return send(['text', '\n**************\n']);
            default:
              return warn("ignored hr markup " + (rpr(text)));
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$code = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (TYPO.isa(event, ['(', ')'], 'code')) {
          type = event[0], name = event[1], text = event[2], meta = event[3];

          /* TAINT should use proper command */
          if (type === '(') {
            return send(['tex', "{\\jzrFontSourceCodePro{}"]);
          } else {
            return send(['tex', "}"]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.MKTX.INLINE.$em_and_strong = (function(_this) {
    return function(S) {
      return $(function(event, send) {
        var meta, name, text, type;
        if (TYPO.isa(event, ['(', ')'], ['em', 'strong'])) {
          type = event[0], name = event[1], text = event[2], meta = event[3];
          if (type === '(') {
            if (name === 'em') {
              return send(['tex', '\\textit{']);
            } else {
              return send(['tex', '\\bold{']);
            }
          } else {
            return send(['tex', "}"]);
          }
        } else {
          return send(event);
        }
      });
    };
  })(this);

  this.$assemble_tex_events_v1 = function() {
    var add_newline_before_end, list_level, start_multicol_after, tag_stack, within_keeplines, within_multicol, within_pre, within_single_column;
    tag_stack = [];
    within_multicol = false;
    start_multicol_after = null;
    add_newline_before_end = null;
    list_level = 0;
    within_keeplines = false;
    within_pre = false;
    within_single_column = false;
    return $((function(_this) {
      return function(event, send, end) {
        var attributes, command, document_name, i, len, line, name, ref, tail, text, type, values;
        if (event != null) {
          type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
          switch (type) {
            case 'command':
              command = tail[0], values = tail[1];
              switch (command) {
                case 'new-document':
                  send(['tex', '% ### MKTS ∆∆∆new-document ###\n']);
                  document_name = values;
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%‡" + command + " " + document_name + "‡\n"]);
                  break;
                case 'new-page':
                  send(['tex', '% ### MKTS ∆∆∆new-page ###\n']);
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%1\n"]);
                  break;
                default:
                  warn("ignored command " + (rpr(event)));
              }
              break;
            case 'comment':
              ref = tail[0].split('\n');
              for (i = 0, len = ref.length; i < len; i++) {
                line = ref[i];
                send(['tex', "% " + line + "\n"]);
              }
              break;
            case 'text':
              text = tail[0];
              if (within_pre) {
                text = text.replace(/\u0020/g, '\u00a0');
              }
              send(['text', text]);
              break;
            case 'start-region':
              name = tail[0];
              switch (name) {
                case 'single-column':
                  send(['tex', '% ### MKTS @@@single-column ###\n']);
                  debug('©x1ESw', '---------------------------single-column(');
                  within_single_column = true;
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', '\n\n']);
                  break;
                case 'keep-lines':
                  send(['tex', '% ### MKTS @@@keep-lines ###\n']);

                  /* TAINT differences between pre and keep-lines? */
                  debug('©x1ESw', '---------------------------keep-lines(');
                  within_pre = true;
                  within_keeplines = true;
                  send(['tex', "\\begingroup\\obeyalllines{}"]);
                  break;
                default:
                  warn("ignored start-region " + (rpr(name)));
              }
              break;
            case 'end-region':
              send(['tex', '% ### MKTS @@@ ###\n']);
              name = tail[0];
              switch (name) {
                case 'single-column':
                  debug('©x1ESw', ')single-column---------------------------');
                  send(['tex', '\\begin{multicols}{2}\n']);
                  within_multicol = true;
                  within_single_column = false;
                  break;
                case 'keep-lines':
                  debug('©x1ESw', ')keep-lines---------------------------');
                  send(['tex', "\\endgroup{}\n"]);
                  within_keeplines = false;
                  within_pre = false;
                  break;
                default:
                  warn("ignored start-region " + (rpr(name)));
              }
              break;
            case 'open-tag':
              name = tail[0], attributes = tail[1];
              tag_stack.push(name);
              switch (name) {
                case 'newpage':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%2\n"]);
                  break;
                case 'fullwidth':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  break;
                case 'h1':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', "\\jzrChapter{"]);
                  add_newline_before_end = name;
                  start_multicol_after = name;
                  break;
                case 'h2':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}']);
                    within_multicol = false;
                  }
                  send(['tex', "\\jzrSection{"]);
                  start_multicol_after = name;
                  break;
                case 'h3':
                  send(['tex', "\\subsection{"]);
                  break;
                case 'h4':

                  /* TAINT subsection or deeper? */
                  send(['tex', "\\subsection{"]);
                  break;
                case 'h5':
                case 'h6':
                  send(['tex', "\\subsection{"]);
                  break;
                case 'p':
                  if ((!within_single_column) && (!within_multicol)) {
                    send(['tex', '\\begin{multicols}{2}\n']);
                    within_multicol = true;
                  }
                  send(['tex', '\n']);
                  break;
                case 'br':
                  send(['tex', '\\\\']);
                  break;
                case 'blockquote':
                  send(['tex', '\\begin{blockquote}\n']);
                  break;
                case 'strong':
                  send(['tex', '\\bold{']);
                  break;
                case 'em':
                  send(['tex', '\\textit{']);
                  break;
                case 'ul':
                  send(['tex', "\\begin{description}[leftmargin=0mm,itemsep=\\parskip,topsep=0mm]"]);
                  list_level += 1;
                  break;
                case 'ol':

                  /* TAINT doing an unordered list here */
                  send(['tex', "\\begin{enumerate}\n"]);
                  list_level += 1;
                  break;
                case 'li':
                  send(['tex', "\\item[—] "]);
                  break;
                case 'pre':
                  send(['tex', "\\begingroup\\obeyalllines\n"]);
                  within_pre = true;
                  within_keeplines = true;
                  break;
                case 'code':
                  send(['tex', "\\begingroup\\jzrFontSourceCodePro{}"]);
                  break;
                default:
                  warn("ignored opening HTML tag " + (rpr(name)));
              }
              break;
            case 'close-tag':
              if (tag_stack.length < 1) {
                warn("empty tag stack");
              } else {

                /* TAINT wrongly pops tags that got omitted */
                name = tag_stack.pop();
                if (add_newline_before_end === name) {
                  send(['tex', '\\\\']);
                  add_newline_before_end = null;
                }
                switch (name) {
                  case 'h1':
                  case 'h2':
                  case 'h3':
                  case 'h4':
                  case 'h5':
                  case 'h6':
                    send(['tex', "}"]);
                    send(['tex', "\n\n"]);
                    break;
                  case 'strong':
                  case 'em':
                    send(['tex', "}"]);
                    break;
                  case 'blockquote':
                    send(['tex', "\\end{blockquote}\n\n"]);
                    break;
                  case 'p':
                  case 'li':
                  case 'br':
                  case 'newpage':
                  case 'fullwidth':
                    null;
                    break;
                  case 'pre':
                    send(['tex', "\\endgroup\n"]);
                    within_keeplines = false;
                    within_pre = false;
                    break;
                  case 'code':
                    send(['tex', "\\endgroup{}"]);
                    break;
                  case 'ul':
                  case 'ol':
                    send(['tex', "\\end{enumerate}"]);
                    list_level += -1;
                    break;
                  default:
                    warn("ignored closing HTML tag " + (rpr(name)));
                }

                /* TAINT places multicols between h1, h2 etc */
                if (start_multicol_after === name) {
                  send(['tex', '\\begin{multicols}{2}\n']);
                  start_multicol_after = null;
                  within_multicol = true;
                }
              }
              break;
            case 'end':
              if (within_multicol) {
                send(['tex', '\\end{multicols}']);
              }
              break;
            default:
              warn("ignored event " + (rpr(event)));
          }
        }
        if (end != null) {
          return end();
        }
      };
    })(this));
  };

  this.$filter_tex = function() {
    return $((function(_this) {
      return function(event, send) {
        var ref;
        if ((ref = event[0]) === 'tex' || ref === 'text') {
          return send(event[1]);
        } else if (TYPO.isa(event, '.', 'text')) {
          return send(event[2]);
        } else {
          return warn("unhandled event: " + (JSON.stringify(event)));
        }
      };
    })(this));
  };

  this.$insert_preamble = function(state) {
    var layout_info;
    layout_info = state.layout_info;
    return D.$on_start((function(_this) {
      return function(send) {
        var tex_inputs_home;
        tex_inputs_home = layout_info['tex-inputs-home'];

        /* TAINT should escape locators to prevent clashes with LaTeX syntax */

        /* TAINT should be located in style / document folder / file */
        return send("\\documentclass[a4paper,twoside]{book}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-main')) + "}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-fonts')) + "}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-article')) + "}\n\\begin{document}\n\n");
      };
    })(this));
  };

  this.$insert_postscript = function() {
    return D.$on_end((function(_this) {
      return function(send, end) {
        send("\\end{document}\n");
        return end();
      };
    })(this));
  };

  if (module.parent == null) {
    this.pdf_from_md('texts/demo/demo.md');
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/mkts-typesetter-interim.js.map