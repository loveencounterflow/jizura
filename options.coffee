

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
  routes:
    settings:       './.mkts-settings.sty'

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








