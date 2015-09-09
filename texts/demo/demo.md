
# This is a Demonstration

## Regions

To indicate the start of an MKTS-MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
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
At this point, a line consisting of a  triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, this
paragraph runs across the entire width of the document's text
area.

@@@

∆∆∆new-page


## Fenced Code Blocks

Fenced code blocks are ended and started by pairs of triple backticks.
Here's a code sample that shows how line breaks and indentations are
kept:

```

if a > 10
  if b < 100
    echo "success!"
```


## Lists
An unordered list:

<!--
* America
* Europe
* Australia

  (includes Oceania) -->


An ordered list:

1) South America
1) Central Asia
1) Polar Regions
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)
1) Djibouti (Republic of Djibouti)
1) Dominica (Commonwealth of Dominica)
1) Dominican Republic
1) East Timor (Democratic Republic of Timor-Leste)
1) Ecuador (Republic of Ecuador)
1) Egypt (Arab Republic of Egypt)
1) El Salvador (Republic of El Salvador)
1) Equatorial Guinea (Republic of Equatorial Guinea)
1) Eritrea (State of Eritrea)
1) Estonia (Republic of Estonia)


## Footnotes

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnotes **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.








