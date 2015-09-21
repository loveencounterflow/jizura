
# This is a Demonstration

## Regions

To indicate the start of an MKTS-MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
∆∆∆new-page
you can put a `@@@keep-lines` region inside a `@@@single-column` region as
done here:


@@@single-column
Here are some formulas:
@@@keep-lines
`u-cjk/4e36`  丶   ●
`u-cjk/4e37`  丷   ⿰丶丿
`u-cjk/4e38`  丸   ⿻九丶
`u-cjk/4e39`  丹   ⿻⺆⿱丶一
`u-cjk/4e3a`  为   ⿻丶⿵力丶
`u-cjk/4e3b`  主   ⿱丶王
`u-cjk/4e3b`  主   ⿱亠土
`u-cjk/4e3c`  丼   ⿴井丶

`u-cjk-xb/250b7`  𥂷   ⿱⿰告巨皿
`u-cjk-xb/250b8`  𥂸   ⿱楊皿

@@@

At this point, a line consisting of a triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, *this
paragraph runs across the entire width* of the document's text
area.

@@@

Rules:

--------------------------------------------------------------

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

**************************************************************

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda


# Regions

## Keep-Lines

--------------------------------------------------------------

A-before
@@@keep-lines
A-within
A-within
A-within
@@@
A-after


--------------------------------------------------------------

B-before

@@@keep-lines
B-within
B-within
B-within
@@@

B-after


--------------------------------------------------------------

C-before
@@@keep-lines

C-within
C-within
C-within

@@@
C-after

--------------------------------------------------------------


D-before

@@@keep-lines

D-within
D-within
D-within

@@@

D-after


