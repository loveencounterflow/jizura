(function() {
  var $, $async, CND, D, HELPERS, TYPESETTER, alert, badge, debug, echo, help, info, log, njs_fs, njs_path, options, rpr, step, suspend, urge, warn, whisper, ƒ,
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

  ƒ = CND.format_number.bind(CND);

  TYPESETTER = require('mingkwai-typesetter');

  HELPERS = require('./HELPERS');

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
        return HELPERS.write_pdf(layout_info, handler);
      };
    })(this));
    input = TYPESETTER.create_html_readstream_from_mdx_text(text);
    input.pipe(HELPERS.TYPO.$fix_typography_for_tex()).pipe(D.$show()).pipe(this.$assemble_tex_events()).pipe(this.$filter_tex()).pipe(this.$insert_preamble()).pipe(this.$insert_postscript()).pipe(tex_output);
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
    var add_newline_before_end, keep_lines, list_level, start_multicol_after, tag_stack, within_multicol;
    tag_stack = [];
    within_multicol = false;
    start_multicol_after = null;
    add_newline_before_end = null;
    list_level = 0;
    keep_lines = false;
    return $((function(_this) {
      return function(event, send, end) {
        var attributes, command, document_name, name, tail, text, type, values;
        if (event != null) {
          type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
          switch (type) {
            case 'command':
              command = tail[0], values = tail[1];
              switch (command) {
                case 'new-document':
                  document_name = values;
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%‡" + command + " " + document_name + "‡\n"]);
                  break;
                case 'newpage':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%1\n"]);
                  break;
                default:
                  warn("ignored command " + (rpr(event)));
              }
              break;
            case 'text':
              text = tail[0];
              if (keep_lines) {
                text = text.replace(/\n/g, '\\\\\n');
              }
              send(['text', text]);
              break;
            case 'open-tag':
              name = tail[0], attributes = tail[1];
              tag_stack.push(name);
              switch (name) {
                case 'newpage':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
                    within_multicol = false;
                  }
                  send(['tex', "\\null\\newpage%2\n"]);
                  break;
                case 'fullwidth':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
                    within_multicol = false;
                  }
                  break;
                case 'h1':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
                    within_multicol = false;
                  }
                  send(['tex', "\\jzrChapter{"]);
                  add_newline_before_end = name;
                  start_multicol_after = name;
                  break;
                case 'h2':
                  if (within_multicol) {
                    send(['tex', '\\end{multicols}\n\n']);
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
                  if (!within_multicol) {
                    send(['tex', '\\begin{multicols}{2}\n']);
                    within_multicol = true;
                  }
                  send(['tex', '\n\n']);
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
                case 'li':
                  send(['tex', "\\item[—] "]);
                  break;
                case 'code':
                  send(['tex', "\\begingroup\\jzrFontSourceCodePro\n"]);
                  keep_lines = true;
                  break;
                default:
                  warn("ignored opening HTML tag " + (rpr(name)));
              }
              break;
            case 'close-tag':
              if (tag_stack.length < 1) {
                warn("empty tag stack");
              } else {
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
                  case 'code':
                    send(['tex', "\n\\endgroup\n"]);
                    keep_lines = false;
                    break;
                  case 'ul':
                    send(['tex', "\\end{description}"]);
                    list_level -= 1;
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

  this.$insert_preamble = function() {
    return D.$on_start((function(_this) {
      return function(send) {
        return send("\\documentclass[a4paper,twoside]{book}\n\\usepackage{jzr2014}\n\\usepackage{jzr2015-article}\n\\begin{document}");
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