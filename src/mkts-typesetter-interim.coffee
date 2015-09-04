




############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
join                      = njs_path.join
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'JIZURA/MKTS-interim'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
D                         = require 'pipedreams'
$                         = D.remit.bind D
$async                    = D.remit_async.bind D
#...........................................................................................................
ƒ                         = CND.format_number.bind CND
TYPESETTER                = require 'mingkwai-typesetter'


#-----------------------------------------------------------------------------------------------------------
@write = ( index_name, handler ) ->
  ###
  FI = require 'coffeenode-fillin'
  ###
  # help "compiling and typesetting #{rpr index_name}"
  # unless handler?
  #   handler     = index_name
  #   index_name  = 'kwic-intro'
  # #.........................................................................................................
  # # cli                     = options[ 'cli' ]
  # content_layout_info     = options[ 'tex-generated' ][ index_name ]
  # tex_output_route        = content_layout_info[ 'route' ]
  # tex_output              = njs_fs.createWriteStream tex_output_route
  # pdf_routes              = H1.get_pdf_routes options[ 'tex-generated' ][ 'kwic' ]
  # aux_route               = pdf_routes[ 'aux-route' ]
  # template_route          = content_layout_info[ 'text-route' ]
  # text                    = njs_fs.readFileSync template_route, encoding: 'utf-8'
  tex_output_route        = '/tmp/mkts-typesetter-interim-output.tex'
  tex_output              = njs_fs.createWriteStream tex_output_route
  text                    = """
    # Helo World

    Just a test.

    ‡new-document 'preface'
    This is the preface.
    """
  debug '©H9UrZ', text
  ###
  details_route           = CND.swap_extension aux_route, '.json'
  template                = njs_fs.readFileSync template_route, encoding: 'utf-8'
  #.........................................................................................................
  kwic_details                  = require details_route
  kwic_details[ 'glyph-count' ] = ( ƒ kwic_details[ 'glyph-count' ] ).replace "'", '.'
  kwic_details[ 'kwic-count'  ] = ( ƒ kwic_details[ 'kwic-count'  ] ).replace "'", '.'
  #.........................................................................................................
  text                    = FI.fill_in template, kwic_details
  ###
  #---------------------------------------------------------------------------------------------------------
  # tex_output.on 'close', =>
  #   H1.write_pdf content_layout_info, handler
  #---------------------------------------------------------------------------------------------------------
  input = TYPESETTER.create_html_readstream_from_mdx_text text
  input
    # .pipe @$transform_commands()
    .pipe @$assemble_tex_events index_name
    .pipe @$filter_tex()
    # .pipe @$supply_cjk_markup index_name
    .pipe @$insert_preamble()
    .pipe @$insert_postscript()
    .pipe D.$show()
    .pipe tex_output
  #---------------------------------------------------------------------------------------------------------
  # D.resume input
  input.resume()

###
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
###

#-----------------------------------------------------------------------------------------------------------
@$assemble_tex_events = ( index_name ) ->
  tag_stack               = []
  within_multicol         = no
  start_multicol_after    = null
  add_newline_before_end  = null
  list_level              = 0
  #.........................................................................................................
  return $ ( event, send, end ) =>
    # if is_first_event
    #   start_size 1
    #   send [ 'doc', me, ]
    #   is_first_event = no
    #.......................................................................................................
    if event?
      [ type, tail..., ]  = event
    #   ok                  = no
      #.....................................................................................................
      switch type
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'command'
          [ command, values, ] = tail
          switch command
            when 'new-document'
              document_name = values
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%‡#{command} #{document_name}‡\n" ]
              # send [ 'tex', "\\null\\newpage\n" ]
              # send [ 'tex', "\n%‡#{command} #{document_name}\n\n" ]
            when 'newpage'
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%1\n" ]
            else
              warn "ignored command #{rpr event}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'text'
          text = tail[ 0 ]
          text = @fix_quotes  text
          text = @escape_text text
          send [ 'text', text, ]
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'open-tag'
          [ name, attributes, ] = tail
          tag_stack.push name
          #.................................................................................................
          switch name
    #         #...............................................................................................
    #         when 'span'
    #           if attributes[ 'class' ]? and ( match = attributes[ 'class' ].match /^size-([0-9]+)$/ )?
    #             size = parseInt match[ 1 ], 10
    #           else
    #             size = get_size()
    #           start_size size
    #           ok = yes
            #...............................................................................................
            when 'newpage'
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%2\n" ]
            #...............................................................................................
            when 'fullwidth'
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
            #...............................................................................................
            when 'h1'
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
              # img_route = '/Volumes/Storage/temp/french-rule-swell-dash-englische-line/swell-dash.pdf'
              # send [ 'tex', "\\includegraphics[width=0.75\\linewidth]{#{img_route}}", ]
              # send [ 'tex', "\\\\[3\\baselineskip]%", ]
              # send [ 'tex', '\\eline\n', ]
              # send [ 'tex', '\n\n', ]
              send [ 'tex', "\\jzrChapter{", ]
              # send [ 'tex', "\\chapter{", ]
              add_newline_before_end  = name
              start_multicol_after    = name
            #...............................................................................................
            when 'h2'
              if within_multicol
                send [ 'tex', '\\end{multicols}\n\n' ]
                within_multicol = no
              send [ 'tex', "\\jzrSection{", ]
              start_multicol_after = name
            #...............................................................................................
            when 'h3'
              send [ 'tex', "\\subsection{", ]
            #...............................................................................................
            when 'p'
              unless within_multicol
                send [ 'tex', '\\begin{multicols}{2}\n' ]
                within_multicol = yes
              send [ 'tex', '\n\n', ]
            #...............................................................................................
            when 'br'
              send [ 'tex', '\\\\', ]
            #...............................................................................................
            when 'blockquote'
              send [ 'tex', '\\begin{blockquote}\n', ]
              # send [ 'tex', '\\begingroup\n', ]
              # send [ 'tex', '\\itshape\n', ]
            #...............................................................................................
            when 'strong'
              send [ 'tex', '\\bold{', ]
            #...............................................................................................
            when 'em'
              send [ 'tex', '\\textit{', ]
            #...............................................................................................
            when 'ul'
              # send [ 'tex', "\\begin{itemize}\n", ]
              send [ 'tex', "\\begin{description}[leftmargin=0mm,itemsep=\\parskip,topsep=0mm]" ]
              # send [ 'tex', "\\setlength{\\itemsep}{0mm}\\setlength{\\parskip}{0mm}\\setlength{\\parsep}{0mm}\n", ]
              # send [ 'tex', "\\setlength{\\itemsep}{\\parskip}", ]
              # send [ 'tex', "\\setlength{\\topsep}{\\parskip}\n", ]
              list_level += 1
            #...............................................................................................
            when 'li'
              # send [ 'tex', "\\item ", ]
              send [ 'tex', "\\item[¶] ", ]
            # #...............................................................................................
            # when 'span'
            #   switch clasz = attributes[ 'class' ]
            #     when 'fullwidth'
            #       if within_multicol
            #         send [ 'tex', '\\end{multicols}\n\n' ]
            #         within_multicol                   = no
            #         start_multicol_after              = 'fullwidth'
            #         tag_stack[ tag_stack.length - 1 ] = 'fullwidth'
            #     else
            #       warn "ignored HTML span of class #{rpr clasz}"
            #...............................................................................................
            else
              warn "ignored opening HTML tag #{rpr name}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'close-tag'
          if tag_stack.length < 1
            warn "empty tag stack"
          else
            name = tag_stack.pop()
            #...............................................................................................
            if add_newline_before_end is name
              send [ 'tex', '\\\\', ]
              add_newline_before_end = null
            #...............................................................................................
            switch name
              when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
                send [ 'tex', "}", ]
                send [ 'tex', "\n\n", ]
              when 'strong', 'em'
                send [ 'tex', "}", ]
              when 'blockquote'
                send [ 'tex', "\\end{blockquote}\n\n", ]
                # send [ 'tex', "\\endgroup\n\n", ]
              when 'p', 'li', 'br', 'newpage', 'fullwidth'
                null
              when 'ul'
                # send [ 'tex', "\\end{itemize}", ]
                send [ 'tex', "\\end{description}", ]
                list_level -= 1
              else
                warn "ignored closing HTML tag #{rpr name}"
            #...............................................................................................
            ### TAINT places multicols between h1, h2 etc ###
            if start_multicol_after is name
              send [ 'tex', '\\begin{multicols}{2}\n' ]
              start_multicol_after  = null
              within_multicol       = yes
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'end'
          send [ 'tex', '\\end{multicols}' ] if within_multicol
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        else
          warn "ignored event #{rpr event}"
    #.......................................................................................................
    if end?
      end()

#-----------------------------------------------------------------------------------------------------------
@$filter_tex = ->
  return $ ( event, send ) =>
    [ type, tail..., ] = event
    switch type
      when 'text', 'tex'
        send tail[ 0 ]
      else
        send.error "unknown event type #{rpr type}"

#-----------------------------------------------------------------------------------------------------------
@$insert_preamble = ->
  return D.$on_start ( send ) =>
    send """
      \\documentclass[a4paper,twoside]{book}
      \\usepackage{jzr2014}
      \\usepackage{jzr2015-article}
      \\usepackage{multicol}
      \\setlength{\\columnsep}{3mm}
      \\setlength\\columnseprule{0.155mm}
      \\begin{document}
      """

#-----------------------------------------------------------------------------------------------------------
@$insert_postscript = ->
  return D.$on_end ( send, end ) =>
    send """
      \\end{document}\n
      """
    end()

#-----------------------------------------------------------------------------------------------------------
@fix_quotes = ( text ) ->
  R = text
  R = R.replace /'([^\s]+)’/g, '‘$1’'
  return R

#-----------------------------------------------------------------------------------------------------------
@escape_text = ( text ) ->
  R = text
  R = R.replace /‰/g, '\\permille{}'
  R = R.replace /&amp;/g, '\\&'
  return R

#-----------------------------------------------------------------------------------------------------------
@$supply_cjk_markup = ( index_name ) ->
  tag_stack = []
  #.........................................................................................................
  return H1.remit_with_messages index_name, ( LMSG ) => ( event, send ) =>
    [ type, tail..., ] = event
    return send event unless type is 'text'
    text  = tail[ 0 ]
    tex   = H1.cjk_as_tex_text text
    # tex   = tex.replace /\\latin\{([^]+)\}/g, '$1'
    send [ 'tex', tex, ]



############################################################################################################
unless module.parent?
  @write()


