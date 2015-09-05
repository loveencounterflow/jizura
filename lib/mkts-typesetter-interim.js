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

  options = {
    'pdf-command': "xelatex\n  -8bit\n  -halt-on-error\n  --enable-write18\n  --recorder\n  -output-directory=$1\n  $2".replace(/\s+/g, ' ')
  };

  (function() {
    var home;
    home = njs_path.join(__dirname, '..');
    options['home'] = home;
    return options['tmp-home'] = njs_path.join(home, 'tmp');
  })();

  HELPERS = {};

  HELPERS.provide_tmp_folder = function() {
    if (!njs_fs.existsSync(options['tmp-home'])) {
      njs_fs.mkdirSync(options['tmp-home']);
    }
    return null;
  };

  HELPERS.new_layout_info = function(source_route) {
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

  HELPERS.write_pdf = function(layout_info, handler) {
    var aux_locator, count, digest, last_digest, pdf_command, pdf_from_tex, pdf_source_locator, pdf_target_locator, tex_locator, tmp_home;
    pdf_command = layout_info['pdf-command'];
    tmp_home = layout_info['tmp-home'];
    tex_locator = layout_info['tex-locator'];
    aux_locator = layout_info['aux-locator'];
    pdf_source_locator = layout_info['pdf-source-locator'];
    pdf_target_locator = layout_info['pdf-target-locator'];
    last_digest = njs_fs.existsSync(aux_locator) ? BNP.id_from_route(aux_locator) : null;
    digest = null;
    count = 0;
    pdf_from_tex = (function(_this) {
      return function(next) {
        count += 1;
        urge("run #" + count + " " + pdf_command + " " + pdf_output_home + " " + tex_locator);
        return TRM.spawn(pdf_command, [tmp_home, tex_locator], function(error, data) {
          if (error === 0) {
            error = void 0;
          }
          if (error != null) {
            return handler(error);
          }
          digest = BNP.id_from_route(aux_locator);
          if (digest === last_digest) {
            echo(TRM.grey(badge), TRM.lime("done."));
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

  this.write = function(handler) {

    /*
    FI = require 'coffeenode-fillin'
     */
    var input, layout_info, source_route, tex_locator, tex_output, text;
    HELPERS.provide_tmp_folder();
    source_route = '/tmp/mkts-typesetter-interim-output.md';
    layout_info = HELPERS.new_layout_info(source_route);
    tex_locator = layout_info['tex-locator'];
    tex_output = njs_fs.createWriteStream(tex_locator);
    text = "# Helo World\n\nJust a test.\n\n‡new-document 'preface'\nThis is the preface.";

    /*
    details_route           = CND.swap_extension aux_route, '.json'
    template                = njs_fs.readFileSync template_route, encoding: 'utf-8'
    #.........................................................................................................
    kwic_details                  = require details_route
    kwic_details[ 'glyph-count' ] = ( ƒ kwic_details[ 'glyph-count' ] ).replace "'", '.'
    kwic_details[ 'kwic-count'  ] = ( ƒ kwic_details[ 'kwic-count'  ] ).replace "'", '.'
    #.........................................................................................................
    text                    = FI.fill_in template, kwic_details
     */
    tex_output.on('close', (function(_this) {
      return function() {
        return H1.write_pdf(content_layout_info, handler);
      };
    })(this));
    input = TYPESETTER.create_html_readstream_from_mdx_text(text);
    input.pipe(this.$assemble_tex_events(index_name)).pipe(this.$filter_tex()).pipe(this.$insert_preamble()).pipe(this.$insert_postscript()).pipe(D.$show()).pipe(tex_output);
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

  this.$assemble_tex_events = function(index_name) {
    var add_newline_before_end, list_level, start_multicol_after, tag_stack, within_multicol;
    tag_stack = [];
    within_multicol = false;
    start_multicol_after = null;
    add_newline_before_end = null;
    list_level = 0;
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
              text = _this.fix_quotes(text);
              text = _this.escape_text(text);
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
                  send(['tex', "\\item[¶] "]);
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

  this.fix_quotes = function(text) {
    var R;
    R = text;
    R = R.replace(/'([^\s]+)’/g, '‘$1’');
    return R;
  };

  this.escape_text = function(text) {
    var R;
    R = text;
    R = R.replace(/‰/g, '\\permille{}');
    R = R.replace(/&amp;/g, '\\&');
    return R;
  };

  this.$supply_cjk_markup = function(index_name) {
    var tag_stack;
    tag_stack = [];
    return H1.remit_with_messages(index_name, (function(_this) {
      return function(LMSG) {
        return function(event, send) {
          var tail, tex, text, type;
          type = event[0], tail = 2 <= event.length ? slice.call(event, 1) : [];
          if (type !== 'text') {
            return send(event);
          }
          text = tail[0];
          tex = H1.cjk_as_tex_text(text);
          return send(['tex', tex]);
        };
      };
    })(this));
  };

  if (module.parent == null) {
    this.write();
  }

}).call(this);

//# sourceMappingURL=../sourcemaps/mkts-typesetter-interim.js.map