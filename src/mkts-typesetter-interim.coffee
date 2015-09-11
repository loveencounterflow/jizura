




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
ASYNC                     = require 'async'
#...........................................................................................................
ƒ                         = CND.format_number.bind CND
HELPERS                   = require './HELPERS'
TYPO                      = HELPERS[ 'TYPO' ]
options                   = require './options'


#-----------------------------------------------------------------------------------------------------------
@pdf_from_md = ( source_route, handler ) ->
  ###
  FI = require 'coffeenode-fillin'
  text                    = FI.fill_in template, kwic_details
  ###
  HELPERS.provide_tmp_folder()
  handler                ?= ->
  layout_info             = HELPERS.new_layout_info source_route
  source_locator          = layout_info[ 'source-locator']
  tex_locator             = layout_info[ 'tex-locator']
  tex_output              = njs_fs.createWriteStream tex_locator
  ### TAINT should read MD source stream ###
  text                    = njs_fs.readFileSync source_locator, encoding: 'utf-8'
  #---------------------------------------------------------------------------------------------------------
  state =
    within_multicol:      no
    within_keeplines:     no
    within_pre:           no
    within_single_column: no
    layout_info:          layout_info
  #---------------------------------------------------------------------------------------------------------
  tex_output.on 'close', =>
    tasks = []
    tasks.push ( done ) -> HELPERS.write_pdf layout_info, done
    # ### TAINT put into HELPERS ###
    # tasks.push ( done ) ->
    #   html          = TYPO.get_meta input, 'html'
    #   html_locator  = HELPERS.tmp_locator_for_extension layout_info, 'html'
    #   help "writing HTML to #{html_locator}"
    #   njs_fs.writeFile html_locator, html, done
    ASYNC.parallel tasks, handler
  #---------------------------------------------------------------------------------------------------------
  input = TYPO.create_mdreadstream text
  input
    # .pipe TYPO.$resolve_html_entities()
    .pipe TYPO.$fix_typography_for_tex()
    .pipe TYPO.$show_mktsmd_events()
    .pipe @MKTX.COMMAND.$new_page       state
    # .pipe @MKTX.REGION.$single_column   state
    .pipe @MKTX.REGION.$keep_lines      state
    .pipe @MKTX.BLOCK.$heading          state
    .pipe @MKTX.BLOCK.$paragraph        state
    .pipe @MKTX.BLOCK.$hr               state
    # .pipe D.$show()
    .pipe @MKTX.INLINE.$code            state
    .pipe @MKTX.INLINE.$em_and_strong   state
    .pipe @$filter_tex()
    .pipe @$insert_preamble state
    .pipe @$insert_postscript()
    .pipe tex_output
  #---------------------------------------------------------------------------------------------------------
  # D.resume input
  input.resume()
  # debug '©Fad1u', TYPO.get_meta input

#-----------------------------------------------------------------------------------------------------------
@MKTX =
  COMMAND:    {}
  REGION:     {}
  BLOCK:      {}
  INLINE:     {}

#-----------------------------------------------------------------------------------------------------------
@MKTX.COMMAND.$new_page = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    return send event unless TYPO.isa event, '∆', 'new-page'
    # [ type, name, text, meta, ] = event
    send [ 'tex', "\\null\\newpage{}", ]

# #-----------------------------------------------------------------------------------------------------------
# @MKTX.change_column_count = ( S, send, end ) =>

### Pending ###
# #-----------------------------------------------------------------------------------------------------------
# @MKTX.REGION.$single_column = ( S ) =>
#   ### TAINT consider to implement command `change_column_count = ( send, n )` ###
#   #.........................................................................................................
#   return $ ( event, send, end ) =>
#     if event?
#       if TYPO.isa event, [ '{', '}', ], 'single-column'
#         [ type, name, text, meta, ] = event
#         #...................................................................................................
#         if type is '{'
#           send [ 'tex', '% ### MKTS @@@single-column ###\n', ]
#           debug '©x1ESw', '---------------------------single-column('
#           S.within_single_column = yes
#           if S.within_multicol
#             send [ 'tex', '\\end{multicols}' ]
#             S.within_multicol = no
#           send [ 'tex', '\n\n', ]
#         #...................................................................................................
#         else
#           debug '©x1ESw', ')single-column---------------------------'
#           send [ 'tex', '\\begin{multicols}{2}\n' ]
#           S.within_multicol       = yes
#           S.within_single_column  = no
#       #.....................................................................................................
#       else
#         send event
#     #.......................................................................................................
#     if end?
#       if S.within_multicol
#         send [ 'tex', '\\end{multicols}' ]
#         S.within_multicol = no
#       end()
#     #.......................................................................................................
#     return null

#-----------------------------------------------------------------------------------------------------------
@MKTX.REGION.$keep_lines = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '.', 'text'
      ### TAINT differences between pre and keep-lines? ###
      [ type, name, text, meta, ] = event
      # if S.within_keeplines
      #   text = text.replace /\n\n/g, '~\\\\\n'
      if S.within_pre
        text = text.replace /\u0020/g, '\u00a0'
      send [ type, name, text, meta, ]
    #.......................................................................................................
    else if TYPO.isa event, [ '{', '}', ], 'keep-lines'
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      if type is '{'
        # send [ 'tex', '% ### MKTS @@@keep-lines ###\n', ]
        S.within_pre        = yes
        S.within_keeplines  = yes
        send [ 'tex', "\\begingroup\\obeyalllines{}", ]
      else
        send [ 'tex', "\\endgroup{}", ]
        S.within_keeplines    = no
        S.within_pre          = no
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$heading = ( S ) =>
  restart_multicols = no
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '[', ']', ], [ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', ]
      [ type, name, text, meta, ] = event
      #.....................................................................................................
      # OPEN
      #.....................................................................................................
      if type is '['
        #...................................................................................................
        ### TAINT Pending
        if S.within_multicol and name in [ 'h1', 'h2', ]
          send [ 'tex', '\\end{multicols}' ]
          S.within_multicol = no
          restart_multicols = yes
        ###
        #...................................................................................................
        send [ 'tex', "\n", ]
        #...................................................................................................
        switch name
          when 'h1' then  send [ 'tex', "\\jzrChapter{", ]
          when 'h2' then  send [ 'tex', "\\jzrSection{", ]
          else            send [ 'tex', "\\subsection{", ]
      #.....................................................................................................
      # CLOSE
      #.....................................................................................................
      else
        ### Placing the closing brace on a new line seems to improve line breaking ###
        send [ 'tex', "\n", ]
        send [ 'tex', "}", ]
        send [ 'tex', "\n", ]
        ### TAINT Pending
        if restart_multicols
          send [ 'tex', '\\begin{multicols}{2}\n' ]
          S.within_multicol = yes
        ###
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$paragraph = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '[', ']', ], 'p'
      [ type, name, text, meta, ] = event
      if type is '['
        send [ 'text', '\n\n' ]
      else
        send [ 'tex', '\\par' ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.BLOCK.$hr = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, '.', 'hr'
      [ type, name, text, meta, ] = event
      switch chr = text[ 0 ]
        when '-' then send [ 'text', '\n--------------\n' ]
        when '*' then send [ 'text', '\n**************\n' ]
        else warn "ignored hr markup #{rpr text}"
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$code = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '(', ')', ], 'code'
      [ type, name, text, meta, ] = event
      ### TAINT should use proper command ###
      if type is '(' then send [ 'tex', "{\\jzrFontSourceCodePro{}", ]
      else                send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@MKTX.INLINE.$em_and_strong = ( S ) =>
  #.........................................................................................................
  return $ ( event, send ) =>
    #.......................................................................................................
    if TYPO.isa event, [ '(', ')', ], [ 'em', 'strong', ]
      [ type, name, text, meta, ] = event
      if type is '('
        if name is 'em'
          send [ 'tex', '\\textit{', ]
        else
          send [ 'tex', '\\bold{', ]
      else
        send [ 'tex', "}", ]
    #.......................................................................................................
    else
      send event

#-----------------------------------------------------------------------------------------------------------
@$assemble_tex_events_v1 = ->
  tag_stack               = []
  within_multicol         = no
  start_multicol_after    = null
  add_newline_before_end  = null
  list_level              = 0
  within_keeplines        = no
  within_pre              = no
  within_single_column    = no
  #.........................................................................................................
  return $ ( event, send, end ) =>
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
              send [ 'tex', '% ### MKTS ∆∆∆new-document ###\n', ]
              document_name = values
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%‡#{command} #{document_name}‡\n" ]
            when 'new-page'
              send [ 'tex', '% ### MKTS ∆∆∆new-page ###\n', ]
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%1\n" ]
            else
              warn "ignored command #{rpr event}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'comment'
          for line in tail[ 0 ].split '\n'
            send [ 'tex', "% #{line}\n", ]
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'text'
          text = tail[ 0 ]
          # if within_keeplines
          #   text = text.replace /\n\n/g, '~\\\\\n'
          if within_pre
            text = text.replace /\u0020/g, '\u00a0'
          send [ 'text', text, ]
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'start-region'
          [ name, ] = tail
          switch name
            #...............................................................................................
            when 'single-column'
              send [ 'tex', '% ### MKTS @@@single-column ###\n', ]
              debug '©x1ESw', '---------------------------single-column('
              within_single_column = yes
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
              send [ 'tex', '\n\n', ]
            #...............................................................................................
            when 'keep-lines'
              send [ 'tex', '% ### MKTS @@@keep-lines ###\n', ]
              ### TAINT differences between pre and keep-lines? ###
              debug '©x1ESw', '---------------------------keep-lines('
              within_pre        = yes
              within_keeplines  = yes
              send [ 'tex', "\\begingroup\\obeyalllines{}", ]
              # ignore_next_nl          = yes
            #...............................................................................................
            else
              warn "ignored start-region #{rpr name}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'end-region'
          send [ 'tex', '% ### MKTS @@@ ###\n', ]
          [ name, ] = tail
          switch name
            #...............................................................................................
            when 'single-column'
              debug '©x1ESw', ')single-column---------------------------'
              send [ 'tex', '\\begin{multicols}{2}\n' ]
              within_multicol       = yes
              within_single_column  = no
            #...............................................................................................
            when 'keep-lines'
              debug '©x1ESw', ')keep-lines---------------------------'
              send [ 'tex', "\\endgroup{}\n", ]
              # send [ 'tex', "\n\n", ]
              within_keeplines  = no
              within_pre        = no
            #...............................................................................................
            else
              warn "ignored start-region #{rpr name}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'open-tag'
          [ name, attributes, ] = tail
          tag_stack.push name
          #.................................................................................................
          switch name
            #...............................................................................................
            # when 'div'
            #   ### modify tag stack so we know which tag was popped: ###
            #   clasz                             = attributes[ 'class' ]
            #   tag_stack[ tag_stack.length - 1 ] = clasz
            #   switch clasz
            #     when 'keep-lines'
            #       within_keeplines        = yes
            #       ignore_next_nl          = yes
            #     else
            #       warn "ignored unknown div class #{rpr clasz}"
            #...............................................................................................
            when 'newpage'
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
              send [ 'tex', "\\null\\newpage%2\n" ]
            #...............................................................................................
            when 'fullwidth'
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
            #...............................................................................................
            when 'h1'
              if within_multicol
                send [ 'tex', '\\end{multicols}' ]
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
                send [ 'tex', '\\end{multicols}' ]
                within_multicol = no
              send [ 'tex', "\\jzrSection{", ]
              start_multicol_after = name
            #...............................................................................................
            when 'h3'
              send [ 'tex', "\\subsection{", ]
            #...............................................................................................
            when 'h4'
              ### TAINT subsection or deeper? ###
              send [ 'tex', "\\subsection{", ]
            #...............................................................................................
            when 'h5', 'h6'
              send [ 'tex', "\\subsection{", ]
            #...............................................................................................
            when 'p'
              if ( not within_single_column ) and ( not within_multicol )
                send [ 'tex', '\\begin{multicols}{2}\n' ]
                within_multicol = yes
              send [ 'tex', '\n', ]
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
            when 'ol'
              ### TAINT doing an unordered list here ###
              send [ 'tex', "\\begin{enumerate}\n", ]
              list_level += 1
            #...............................................................................................
            when 'li'
              # send [ 'tex', "\\item ", ]
              # send [ 'tex', "\\item[¶] ", ]
              send [ 'tex', "\\item[—] ", ]
            #...............................................................................................
            when 'pre'
              # send [ 'tex', "\n\n", ]
              send [ 'tex', "\\begingroup\\obeyalllines\n", ]
              within_pre        = yes
              within_keeplines  = yes
            #...............................................................................................
            when 'code'
              # send [ 'tex', "\\begingroup\\setCodeLatin\n", ]
              # send [ 'tex', "\\begingroup\\jzrFontSunXA\n", ]
              send [ 'tex', "\\begingroup\\jzrFontSourceCodePro{}", ]
            #...............................................................................................
            else
              warn "ignored opening HTML tag #{rpr name}"
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        when 'close-tag'
          if tag_stack.length < 1
            warn "empty tag stack"
          else
            ### TAINT wrongly pops tags that got omitted ###
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
              when 'pre'
                send [ 'tex', "\\endgroup\n", ]
                within_keeplines  = no
                within_pre        = no
              when 'code'
                send [ 'tex', "\\endgroup{}", ]
              when 'ul', 'ol'
                send [ 'tex', "\\end{enumerate}", ]
                # send [ 'tex', "\\end{description}", ]
                list_level += -1
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
    if event[ 0 ] in [ 'tex', 'text', ]
      send event[ 1 ]
    else if TYPO.isa event, '.', 'text'
      send event[ 2 ]
    else
      warn "unhandled event: #{JSON.stringify event}"

#-----------------------------------------------------------------------------------------------------------
@$insert_preamble = ( state ) ->
  { layout_info } = state
  return D.$on_start ( send ) =>
    tex_inputs_home = layout_info[ 'tex-inputs-home' ]
    ### TAINT should escape locators to prevent clashes with LaTeX syntax ###
    ### TAINT should be located in style / document folder / file ###
    send """
      \\documentclass[a4paper,twoside]{book}
      \\usepackage{#{njs_path.join tex_inputs_home, 'mkts2015-main'}}
      \\usepackage{#{njs_path.join tex_inputs_home, 'mkts2015-fonts'}}
      \\usepackage{#{njs_path.join tex_inputs_home, 'mkts2015-article'}}
      \\begin{document}\n\n
      """

#-----------------------------------------------------------------------------------------------------------
@$insert_postscript = ->
  return D.$on_end ( send, end ) =>
    send """
      \\end{document}\n
      """
    end()



############################################################################################################
unless module.parent?
  # @pdf_from_md 'texts/A-Permuted-Index-of-Chinese-Characters/index.md'
  @pdf_from_md 'texts/demo/demo.md'

  # debug '©nL12s', TYPO.as_tex_text '亻龵helo さしすサシス 臺灣國語Ⓒ, Ⓙ, Ⓣ𠀤𠁥&jzr#e202;'
  # debug '©nL12s', TYPO.as_tex_text 'helo さし'
  # event = [ '{', 'single-column', ]
  # event = [ '}', 'single-column', ]
  # event = [ '{', 'new-page', ]
  # debug '©Gpn1J', TYPO.isa event, [ '{', '}'], [ 'single-column', 'new-page', ]

