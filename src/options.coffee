


############################################################################################################
njs_path                  = require 'path'


#-----------------------------------------------------------------------------------------------------------
module.exports = options =
  'pdf-command':          "bin/pdf-from-tex.sh"


  #.........................................................................................................
  'tex':
    'ignore-latin':             yes
    #.......................................................................................................
    'tex-command-by-rsgs':
      'u-latn':                 'latin'
      'u-latn-1':               'latin'
      'u-punct':                'latin'
      'u-cjk':                  'cn'
      'u-halfull':              'cn'
      'u-dingb':                'cn'
      'u-cjk-xa':               'cnxa'
      'u-cjk-xb':               'cnxb'
      'u-cjk-xc':               'cnxc'
      'u-cjk-xd':               'cnxd'
      'u-cjk-cmpi1':            'cncone'
      'u-cjk-cmpi2':            'cnctwo'
      'u-cjk-rad1':             'cnrone'
      'u-cjk-rad2':             'cnrtwo'
      'u-cjk-sym':              'cnsym'
      'u-cjk-strk':             'cnstrk'
      'u-pua':                  'cnjzr'
      'jzr-fig':                'cnjzr'
      'u-cjk-kata':             'ka'
      'u-cjk-hira':             'hi'
      'u-hang-syl':             'hg'
    #.......................................................................................................
    'glyph-styles':
      ### Ideographic description characters: ###
      '↻':          '\\cnxJzr{}'
      '↔':          '\\cnxJzr{}'
      '↕':          '\\cnxJzr{}'
      '●':          '\\cnxJzr{}'
      '◰':          '\\cnxJzr{}'
      '≈':          '\\cnxJzr{}'
      '⿰':          '\\cnxJzr{}'
      '⿱':          '\\cnxJzr{}'
      '⿺':          '\\cnxJzr{}'
      '⿸':          '\\cnxJzr{}'
      '⿹':          '\\cnxJzr{}'
      '⿶':          '\\cnxJzr{}'
      '⿷':          '\\cnxJzr{}'
      '⿵':          '\\cnxJzr{}'
      '⿴':          '\\cnxJzr{}'
      '⿻':          '\\cnxJzr{}'
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 
      # 

      ### 'Late Additions' in upper part of CJK unified ideographs (Unicode v5.2); glyphs are missing
        from Sun-ExtA but are included in BabelstoneHan: ###
      '龺':            "\\cnxBabel{龺}"
      '龻':            "\\cnxBabel{龻}"
      '龼':            "\\cnxBabel{龼}"
      '龽':            "\\cnxBabel{龽}"
      '龾':            "\\cnxBabel{龾}"
      '龿':            "\\cnxBabel{龿}"
      '鿀':            "\\cnxBabel{鿀}"
      '鿁':            "\\cnxBabel{鿁}"
      '鿂':            "\\cnxBabel{鿂}"
      '鿃':            "\\cnxBabel{鿃}"
      '鿄':            "\\cnxBabel{鿄}"
      '鿅':            "\\cnxBabel{鿅}"
      '鿆':            "\\cnxBabel{鿆}"
      '鿇':            "\\cnxBabel{鿇}"
      '鿈':            "\\cnxBabel{鿈}"
      '鿉':            "\\cnxBabel{鿉}"
      '鿊':            "\\cnxBabel{鿊}"
      '鿋':            "\\cnxBabel{鿋}"
      '鿌':            "\\cnxBabel{鿌}"
      #.....................................................................................................
      ### This glyph is damaged in Sun-ExtA; it happens to be included in HanaMinA: ###
      '䗍':            "\\cnxHanaA{䗍}"
      #.....................................................................................................
      ### Shifted glyphs: ###
      '&#x3000;':      "\\cnjzr{}"
      '《':            "\\prPushRaise{0}{-0.2}{\\jzrFontSunXA{《}}"
      '》':            "\\prPushRaise{0}{-0.2}{\\jzrFontSunXA{》}}"
      # '':   "\\cnjzr{}"
      # '&jzr#xe352;':   "\\cnjzr{}"
      '囗':            "\\cnjzr{}"
      '。':            "\\prPushRaise{0.5}{0.25}{\\cn{。}}"
      '亻':            "\\prPush{0.4}{\\cn{亻}}"
      '冫':            "\\prPush{0.5}{\\cn{冫}}"
      '灬':            "\\prRaise{0.25}{\\cn{灬}}"
      '爫':            "\\prRaise{-0.125}{\\cn{爫}}"
      '牜':            "\\prPush{0.4}{\\cn{牜}}"
      '飠':            "\\prPush{0.4}{\\cn{飠}}"
      '扌':            "\\prPush{0.05}{\\cn{扌}}"
      '犭':            "\\prPush{0.3}{\\cn{犭}}"
      '忄':            "\\prPush{0.4}{\\cn{忄}}"
      '礻':            "\\prPush{0.2}{\\cn{礻}}"
      '衤':            "\\prPush{0.1}{\\cn{衤}}"
      '覀':            "\\prRaise{-0.125}{\\cn{覀}}"
      '讠':            "\\prPush{0.4}{\\cn{讠}}"
      '𧾷':            "\\prPush{0.4}{\\cnxb{𧾷}}"
      '卩':            "\\prPush{-0.4}{\\cn{卩}}"
      '癶':            "\\prRaise{-0.2}{\\cnxBabel{癶}}"
      '':            "\\prRaise{0.1}{\\cnxJzr{}}"
      '':            "\\prPushRaise{0.5}{-0.2}{\\cnxJzr{}}"
      '乛':            "\\prRaise{-0.2}{\\cn{乛}}"
      '糹':            "\\prPush{0.4}{\\cn{糹}}"
      '纟':            "\\prPush{0.4}{\\cn{纟}}"
      '𥫗':            "\\prRaise{-0.2}{\\cnxb{𥫗}}"
      '罓':            "\\prRaise{-0.2}{\\cn{罓}}"
      '钅':            "\\prPush{0.3}{\\cn{钅}}"
      '阝':            "\\prPush{0.4}{\\cn{阝}}"
      '龵':            "\\prRaise{-0.1}{\\cnxBabel{龵}}"
      '𩰊':            "\\prPush{-0.15}{\\cnxb{𩰊}}"
      '𩰋':            "\\prPush{0.15}{\\cnxb{𩰋}}"
      '彳':            "\\prPush{0.15}{\\cn{彳}}"
      '龹':            "\\prRaise{-0.12}{\\cn{龹}}"
      '龸':            "\\prRaise{-0.15}{\\cn{龸}}"
      '䒑':            "\\prRaise{-0.15}{\\cnxa{䒑}}"
      '宀':            "\\prRaise{-0.15}{\\cn{宀}}"
      '〇':            "\\prRaise{-0.05}{\\cnxBabel{〇}}"
      #.....................................................................................................
      ### Glyphs represented by other codepoints and/or with other than the standard fonts: ###
      # '⺊':            "\\cnxHanaA{⺊}"
      # '⺑':            "\\cnxHanaA{⺑}"
      # '⺕':            "\\cnxHanaA{⺕}"
      # '⺴':            "\\cnxHanaA{⺴}"
      # '⺿':            "\\cnxHanaA{⺿}"
      # '〆':            "\\cnxHanaA{〆}"
      # '〻':            "\\cnxHanaA{〻}"
      # '㇀':            "\\cnxHanaA{㇀}"
      # '㇊':            "\\cnxHanaA{㇊}"
      # '㇎':            "\\cnxHanaA{㇎}"
      # '㇏':            "\\cnxHanaA{㇏}"
      # '丷':            "\\cnxHanaA{丷}"
      # '饣':            "\\cnxHanaA{饣}"
      '⺀':            "\\cnxHanaA{⺀}"
      '⺀':            "\\cnxHanaA{⺀}"
      '⺄':            "\\cnxHanaA{⺄}"
      '⺆':            "\\cnxBabel{⺆}"
      '⺌':            "\\cnxHanaA{⺌}"
      '⺍':            "\\cnxHanaA{⺍}"
      '⺍':            "\\cnxHanaA{⺍}"
      '⺗':            "\\cnxHanaA{⺗}"
      '⺝':            "\\cnxBabel{⺝}"
      '⺝':            "\\cnxHanaA{⺝}"
      '⺥':            "\\cnxHanaA{⺥}"
      '⺳':            "\\cnxHanaA{⺳}"
      '⺶':            "\\cnxBabel{⺶}"
      '⺻':            "\\cnxHanaA{⺻}"
      '⺼':            "\\cnxBabel{⺼}"
      '覀':            "\\cnxJzr{}"
      '⻗':            "\\cnxJzr{}"
      '𡗗':            "\\cnxJzr{}"
      '〓':            "\\cnxBabel{〓}"
      '〓':            "\\cnxBabel{〓}"
      '〢':            "\\cnxSunXA{〢}"
      '〣':            "\\cnxSunXA{〣}"
      '〥':            "\\cnxBabel{〥}"
      '〥':            "\\cnxSunXA{〥}"
      '〧':            "\\cnxBabel{〧}"
      '〨':            "\\cnxBabel{〨}"
      '〽':            "\\cnxSunXA{〽}"
      '丿':            "\\cnxJzr{}"
      '㇁':            "\\cnxBabel{㇁}"
      '㇂':            "\\cnxHanaA{㇂}"
      '㇃':            "\\cnxBabel{㇃}"
      '㇄':            "\\cnxBabel{㇄}"
      '㇅':            "\\cnxBabel{㇅}"
      '㇈':            "\\cnxBabel{㇈}"
      '㇉':            "\\cnxHanaA{㇉}"
      '㇋':            "\\cnxBabel{㇋}"
      '㇌':            "\\cnxHanaA{㇌}"
      '㇢':            "\\cnxHanaA{㇢}"
      '㓁':            "\\cnxBabel{㓁}"
      '冖':            "\\cnxHanaA{冖}"
      '刂':            "\\cnxHanaA{刂}"
      '氵':            "\\cnxHanaA{氵}"
      '罒':            "\\cnxHanaA{罒}"
      '龴':            "\\cnxHanaA{龴}"
      '𠂉':            "\\cnxHanaA{𠂉}"
      '帯':            "\\cnxHanaA{帯}"
      '齒':            "\\cnxBabel{齒}"
      '龰':            "\\cnxBabel{龰}"
      '𤴔':            "\\cnxBabel{𤴔}"
      '㐃':            "\\cnxBabel{㐃}"
      '𠥓':            "\\cnxJzr{}"
      '𠚜':            "\\cnxHanaB{𠚜}"
      '𠚡':            "\\cnxHanaB{𠚡}"
      '𠥧':            "\\cnxHanaB{𠥧}"
      '𠥩':            "\\cnxHanaB{𠥩}"
      '𠥪':            "\\cnxHanaB{𠥪}"
      '𠥫':            "\\cnxHanaB{𠥫}"
      '𠥬':            "\\cnxHanaB{𠥬}"
      '𧀍':            "\\cnxHanaB{𧀍}"
      '龷':            "\\cnxJzr{}"
      '龶':            "\\cnxJzr{}"




#...........................................................................................................
do ->
  home                      = njs_path.join __dirname, '..'
  options[ 'home' ]         = home
  options[ 'tmp-home' ]     = njs_path.join home, 'tmp'
  options[ 'pdf-command' ]  = njs_path.resolve home, options[ 'pdf-command' ]



