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
    var input, layout_info, source_locator, tex_locator, tex_output, text;
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
    tex_output.on('close', (function(_this) {
      return function() {
        var tasks;
        tasks = [];
        tasks.push(function(done) {
          return HELPERS.write_pdf(layout_info, done);
        });

        /* TAINT put into HELPERS */
        tasks.push(function(done) {
          var html, html_locator;
          html = TYPO.get_meta(input, 'html');
          html_locator = HELPERS.tmp_locator_for_extension(layout_info, 'html');
          help("writing HTML to " + html_locator);
          return njs_fs.writeFile(html_locator, html, done);
        });
        return ASYNC.parallel(tasks, handler);
      };
    })(this));
    input = TYPO.create_html_readstream_from_md(text);
    input.pipe(TYPO.$resolve_html_entities()).pipe(TYPO.$fix_typography_for_tex()).pipe(this.$assemble_tex_events()).pipe(D.$show()).pipe(this.$filter_tex()).pipe(this.$insert_preamble(layout_info)).pipe(this.$insert_postscript()).pipe(tex_output);
    return input.resume();
  };


  /*
  #-----------------------------------------------------------------------------------------------------------
  @$transform_commands = ->
    command_pattern = /^\n?‡([^\s][^\n]*)\n$/
    return $ ( event, send ) =>
      [ type, tail..., ]  = event
      if ( type is 'text' ) and ( match = tail[ 0 ].match command_pattern )?
        command = match[ 1 ]
        match   = command.match /^(\S+)\s+(.+)$/
        if match?
          [ _, command, values, ] = match
          send [ 'command', command, values, ]
        else
          send [ 'command', command, ]
      else
        send event
   */

  this.$assemble_tex_events = function() {
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

                  /* TAINT differences between pre and keeplines? */
                  debug('©x1ESw', '---------------------------keeplines(');
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
                  debug('©x1ESw', ')keeplines---------------------------');
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
                  send(['tex', "\n\n"]);
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
                    send(['tex', "\n\n"]);
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
        var tail, type;
        type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
        switch (type) {
          case 'text':
          case 'tex':
            return send(tail[0]);
          default:
            return send.error("unknown event type " + (rpr(type)));
        }
      };
    })(this));
  };

  this.$insert_preamble = function(layout_info) {
    return D.$on_start((function(_this) {
      return function(send) {
        var tex_inputs_home;
        tex_inputs_home = layout_info['tex-inputs-home'];

        /* TAINT should escape locators to prevent clashes with LaTeX syntax */
        return send("\\documentclass[a4paper,twoside]{book}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-main')) + "}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-fonts')) + "}\n\\usepackage{" + (njs_path.join(tex_inputs_home, 'mkts2015-article')) + "}\n\\begin{document}");
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