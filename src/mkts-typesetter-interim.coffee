




############################################################################################################
njs_path                  = require 'path'
njs_fs                    = require 'fs'
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
ASYNC                     = require 'async'


#-----------------------------------------------------------------------------------------------------------
options =
  'pdf-command':          "bin/pdf-from-tex.sh"
#...........................................................................................................
do ->
  home                      = njs_path.join __dirname, '..'
  options[ 'home' ]         = home
  options[ 'tmp-home' ]     = njs_path.join home, 'tmp'
  options[ 'pdf-command' ]  = njs_path.resolve home, options[ 'pdf-command' ]

#-----------------------------------------------------------------------------------------------------------
HELPERS = {}

#-----------------------------------------------------------------------------------------------------------
HELPERS.provide_tmp_folder = ->
  njs_fs.mkdirSync options[ 'tmp-home' ] unless njs_fs.existsSync options[ 'tmp-home' ]
  return null

#-----------------------------------------------------------------------------------------------------------
HELPERS.new_layout_info = ( source_route ) ->
  pdf_command         = options[ 'pdf-command' ]
  tmp_home            = options[ 'tmp-home' ]
  source_locator      = njs_path.resolve process.cwd(), source_route
  source_home         = njs_path.dirname source_locator
  source_name         = njs_path.basename source_locator
  tex_locator         = njs_path.join tmp_home, CND.swap_extension source_name, '.tex'
  aux_locator         = njs_path.join tmp_home, CND.swap_extension source_name, '.aux'
  pdf_source_locator  = njs_path.join tmp_home, CND.swap_extension source_name, '.pdf'
  pdf_target_locator  = njs_path.join source_home, CND.swap_extension source_name, '.pdf'
  #.........................................................................................................
  R =
    'pdf-command':          pdf_command
    'tmp-home':             tmp_home
    'source-route':         source_route
    'source-locator':       source_locator
    'source-home':          source_home
    'source-name':          source_name
    'tex-locator':          tex_locator
    'aux-locator':          aux_locator
    'pdf-source-locator':   pdf_source_locator
    'pdf-target-locator':   pdf_target_locator
    'latex-run-count':      0
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
HELPERS.write_pdf = ( layout_info, handler ) ->
  #.........................................................................................................
  pdf_command         = layout_info[ 'pdf-command'          ]
  tmp_home            = layout_info[ 'tmp-home'             ]
  tex_locator         = layout_info[ 'tex-locator'          ]
  aux_locator         = layout_info[ 'aux-locator'          ]
  pdf_source_locator  = layout_info[ 'pdf-source-locator'   ]
  pdf_target_locator  = layout_info[ 'pdf-target-locator'   ]
  last_digest         = null
  last_digest         = CND.id_from_route aux_locator if njs_fs.existsSync aux_locator
  digest              = null
  count               = 0
  #.........................................................................................................
  pdf_from_tex = ( next ) =>
    count += 1
    urge "run ##{count} #{pdf_command}"
    urge "#{pdf_command}"
    urge "$1: #{tmp_home}"
    urge "$2: #{tex_locator}"
    CND.spawn pdf_command, [ tmp_home, tex_locator, ], ( error, data ) =>
      error = undefined if error is 0
      if error?
        alert error
        return handler error
      digest = CND.id_from_route aux_locator
      if digest is last_digest
        echo ( CND.grey badge ), CND.lime "done."
        layout_info[ 'latex-run-count' ] = count
        ### TAINT move pdf to layout_info[ 'source-home' ] ###
        handler null
      else
        last_digest = digest
        next()
  #.........................................................................................................
  ASYNC.forever pdf_from_tex


#-----------------------------------------------------------------------------------------------------------
@write = ( handler ) ->
  ###
  FI = require 'coffeenode-fillin'
  ###
  HELPERS.provide_tmp_folder()
  handler                ?= ->
  source_route            = '/tmp/mkts-typesetter-interim-output.md'
  layout_info             = HELPERS.new_layout_info source_route
  tex_locator             = layout_info[ 'tex-locator']
  tex_output              = njs_fs.createWriteStream tex_locator
  text                    = """
    # Helo World

    Just a test.

    ‡new-document 'preface'
    This is the preface.
    """
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
  tex_output.on 'close', =>
    HELPERS.write_pdf layout_info, handler
  #---------------------------------------------------------------------------------------------------------
  input = TYPESETTER.create_html_readstream_from_mdx_text text
  input
    # .pipe @$transform_commands()
    .pipe @$assemble_tex_events()
    .pipe @$filter_tex()
    # .pipe @$supply_cjk_markup()
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
@$assemble_tex_events = ->
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
@$supply_cjk_markup = ->
  tag_stack = []
  #.........................................................................................................
  return $ ( event, send ) =>
    [ type, tail..., ] = event
    return send event unless type is 'text'
    text  = tail[ 0 ]
    tex   = H1.cjk_as_tex_text text
    # tex   = tex.replace /\\latin\{([^]+)\}/g, '$1'
    send [ 'tex', tex, ]



############################################################################################################
unless module.parent?
  @write()


