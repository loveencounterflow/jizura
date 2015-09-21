

### Hint: do not use `require` statements in this file unless they refer to built in modules. ###


module.exports = options =

  #.........................................................................................................
  defs:
    foobar:   "this variable has been set in `options`"

  #.........................................................................................................
  newcommands:
    ### TAINT use relative routes ###
    mktsPathsMktsHome:    '/Volumes/Storage/io/jizura/tex-inputs'
    mktsPathsFontsHome:   '/Volumes/Storage/io/jizura-fonts/fonts'

  #.........................................................................................................
  main:
    filename:       'main.md'
  #.........................................................................................................
  master:
    filename:       '.master.tex'

  #.........................................................................................................
  fonts:
    # route:      './.mkts-fonts.sty'
    declarations: [
      #   texname:    'mktsFontDejavuserifregular'
      #   home:       '\\mktsPathsFontsHome'
      #   filename:   'DejaVuSerif.ttf'
      # ,
      #   texname:    'mktsFontUbunturegular'
      #   home:       '\\mktsPathsFontsHome'
      #   filename:   'Ubuntu-R.ttf'
      # ,
      #   texname:    'mktsFontSunexta'
      #   home:       '\\mktsPathsFontsHome'
      #   filename:   'sun-exta.ttf'
      # ,
      #   texname:    'mktsFontCwtexqkaimedium'
      #   home:       '\\mktsPathsFontsHome'
      #   filename:   'cwTeXQKai-Medium.ttf'
      # ,
        texname:    'mktsFontBabelstonehan'
        home:       '\\mktsPathsFontsHome'
        filename:   'BabelStoneHan.ttf'
      ,
        texname:    'mktsFontCwtexqfangsongmedium'
        home:       '\\mktsPathsFontsHome'
        filename:   'cwTeXQFangsong-Medium.ttf'
      ,
        texname:    'mktsFontCwtexqheibold'
        home:       '\\mktsPathsFontsHome'
        filename:   'cwTeXQHei-Bold.ttf'
      ,
        texname:    'mktsFontCwtexqkaimedium'
        home:       '\\mktsPathsFontsHome'
        filename:   'cwTeXQKai-Medium.ttf'
      ,
        texname:    'mktsFontCwtexqmingmedium'
        home:       '\\mktsPathsFontsHome'
        filename:   'cwTeXQMing-Medium.ttf'
      ,
        texname:    'mktsFontCwtexqyuanmedium'
        home:       '\\mktsPathsFontsHome'
        filename:   'cwTeXQYuan-Medium.ttf'
      ,
        texname:    'mktsFontDejavusansbold'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSans-Bold.ttf'
      ,
        texname:    'mktsFontDejavusansboldoblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSans-BoldOblique.ttf'
      ,
        texname:    'mktsFontDejavusansoblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSans-Oblique.ttf'
      ,
        texname:    'mktsFontDejavusans'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSans.ttf'
      ,
        texname:    'mktsFontDejavusanscondensedbold'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansCondensed-Bold.ttf'
      ,
        texname:    'mktsFontDejavusanscondensedboldoblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansCondensed-BoldOblique.ttf'
      ,
        texname:    'mktsFontDejavusanscondensedoblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansCondensed-Oblique.ttf'
      ,
        texname:    'mktsFontDejavusanscondensed'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansCondensed.ttf'
      ,
        texname:    'mktsFontDejavusansmonobold'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansMono-Bold.ttf'
      ,
        texname:    'mktsFontDejavusansmonoboldoblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansMono-BoldOblique.ttf'
      ,
        texname:    'mktsFontDejavusansmonooblique'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansMono-Oblique.ttf'
      ,
        texname:    'mktsFontDejavusansmono'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSansMono.ttf'
      ,
        texname:    'mktsFontDejavuserifbold'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerif-Bold.ttf'
      ,
        texname:    'mktsFontDejavuserifbolditalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerif-BoldItalic.ttf'
      ,
        texname:    'mktsFontDejavuserifitalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerif-Italic.ttf'
      ,
        texname:    'mktsFontDejavuserif'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerif.ttf'
      ,
        texname:    'mktsFontDejavuserifcondensedbold'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerifCondensed-Bold.ttf'
      ,
        texname:    'mktsFontDejavuserifcondensedbolditalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerifCondensed-BoldItalic.ttf'
      ,
        texname:    'mktsFontDejavuserifcondenseditalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerifCondensed-Italic.ttf'
      ,
        texname:    'mktsFontDejavuserifcondensed'
        home:       '\\mktsPathsFontsHome'
        filename:   'DejaVuSerifCondensed.ttf'
      ,
        texname:    'mktsFontEbgaramondinitials'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond-Initials.otf'
      ,
        texname:    'mktsFontEbgaramondinitialsfone'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond-InitialsF1.otf'
      ,
        texname:    'mktsFontEbgaramondinitialsftwo'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond-InitialsF2.otf'
      ,
        texname:    'mktsFontEbgaramondeightitalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond08-Italic.otf'
      ,
        texname:    'mktsFontEbgaramondeightregular'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond08-Regular.otf'
      ,
        texname:    'mktsFontEbgaramondeightsc'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond08-SC.otf'
      ,
        texname:    'mktsFontEbgaramondtwelveallsc'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond12-AllSC.otf'
      ,
        texname:    'mktsFontEbgaramondtwelveitalic'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond12-Italic.otf'
      ,
        texname:    'mktsFontEbgaramondtwelveregular'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond12-Regular.otf'
      ,
        texname:    'mktsFontEbgaramondtwelvesc'
        home:       '\\mktsPathsFontsHome'
        filename:   'EBGaramond12-SC.otf'
      ,
        texname:    'mktsFontFlowdejavusansmono'
        home:       '\\mktsPathsFontsHome'
        filename:   'FlowDejaVuSansMono.ttf'
      ,
        texname:    'mktsFontHanamina'
        home:       '\\mktsPathsFontsHome'
        filename:   'HanaMinA.ttf'
      ,
        texname:    'mktsFontHanaminb'
        home:       '\\mktsPathsFontsHome'
        filename:   'HanaMinB.ttf'
      ,
        texname:    'mktsFontSunexta'
        home:       '\\mktsPathsFontsHome'
        filename:   'sun-exta.ttf'
      ,
        texname:    'mktsFontSunextb'
        home:       '\\mktsPathsFontsHome'
        filename:   'Sun-ExtB.ttf'
      # ,
      #   texname:    'mktsFontSunflower-u-cjk-xa-centered'
        home:       '\\mktsPathsFontsHome'
      #   filename:   'sunflower-u-cjk-xa-centered.ttf'
      ,
        texname:    'mktsFontSunflowerucjkxb'
        home:       '\\mktsPathsFontsHome'
        filename:   'sunflower-u-cjk-xb.ttf'
      ,
        texname:    'mktsFontUbuntub'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-B.ttf'
      ,
        texname:    'mktsFontUbuntubi'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-BI.ttf'
      ,
        texname:    'mktsFontUbuntuc'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-C.ttf'
      ,
        texname:    'mktsFontUbuntul'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-L.ttf'
      ,
        texname:    'mktsFontUbuntuli'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-LI.ttf'
      ,
        texname:    'mktsFontUbuntur'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-R.ttf'
      ,
        texname:    'mktsFontUbunturi'
        home:       '\\mktsPathsFontsHome'
        filename:   'Ubuntu-RI.ttf'
      ,
        texname:    'mktsFontUbuntumonob'
        home:       '\\mktsPathsFontsHome'
        filename:   'UbuntuMono-B.ttf'
      ,
        texname:    'mktsFontUbuntumonobi'
        home:       '\\mktsPathsFontsHome'
        filename:   'UbuntuMono-BI.ttf'
      ,
        texname:    'mktsFontUbuntumonor'
        home:       '\\mktsPathsFontsHome'
        filename:   'UbuntuMono-R.ttf'
      ,
        texname:    'mktsFontUbuntumonori'
        home:       '\\mktsPathsFontsHome'
        filename:   'UbuntuMono-RI.ttf'
      ,
      ]

  #.........................................................................................................
  cache:
    # route:          './tmp/.cache.json'
    route:          './.cache.json'

  #.........................................................................................................
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












