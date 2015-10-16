

front #1 #,2<<(:foo1>>FOO<<:)>>. <<!foo1>>, <\<!foo1>>, \<<!foo1>>, back.

front #1 #,2<<(:foo2>>#FOO#<<:)>>. <<!foo2>>, <\<!foo2>>, \<<!foo2>>, back.

A <<(:x1>> <\<(raw>>\TeX{} <\<raw)>> <<:)>>: (<<!x1>>) Z

A <<(:x2>> <<(raw>>\TeX{} <<raw)>> <<:)>>: (<<!x2>>) Z

<<(:redefined>>[first value]<<:)>><<!redefined>>

<<(:redefined>>[second value]<<:)>><<!redefined>>

&lt;&lt;!redefined>>!!!

a <\<b>> \c
<<!end>>

<<(:thequestion>>*What is the meaning of life,
the universe, and everything?*<<:)>>
<<(:theanswer>>**42**<<:)>>
<<(:TEX>><<(raw>>\TeX{}<<raw)>><<:)>>
<<(:LATEX>><<(raw>>\LaTeX{}<<raw)>><<:)>>
<<(:MKTS>>**MKTS**<<:)>>
<<(:two-pars>>first first first first first first
first first first first first first first first first
first first first first first first first first first

second second second second second second second second second
second second second second second second second second second
second second second second second second second second second
second second second second second second second second second
<<:)>>

<<{multi-column>>

<<!two-pars>>

Use of definition: The question is "<<!thequestion>>"; the
answer is "<<!theanswer>>".

<<multi-column}>>
<!-- <<!end>> -->

Use of the logo: <<!LATEX>>.

## Generalized Command Syntax

foo <\<bar>> baz

Here we inserted '<<!LATEX>>' using `<<!LATEX>>`.

<<!end>>

<<{multi-column>>

## Math Mode

It's perfectly possible to take advantage of
<<!TEX>>'s famous Math Mode; for example,
you can now effortlessly have formulas like

<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>

in your documents (and of course, inline math *à la*
<<(raw>>$\lim_{x \to \infty}$<<raw)>> works as well).

<<multi-column}>>


Some math: `<<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>`

Some math: <<(raw>>$\lim_{x \to \infty} \exp(-x) = 0$<<raw)>>

xxx

## Quotes, Character Entities, <<!TEX>> Special Characters

foo 'bar' baz. &jzr#xe170; beautiful!

<<{multi-column>>
You can use `<<{raw>> ... <<raw}>>` or `<<(raw>> ... <<raw)>>` to directly insert <<!LATEX>>
code into your script; for example, you could
use `<<(raw>>\LaTeX{}<<raw)>>`
to obtain the <<(raw>>\LaTeX{}<<raw)>> logogram.
Observe that we had to write `\LaTeX{}` here instead of `\LaTeX` to preserve the space between the logogram itself and
the word 'logogram'—<<!MKTS>> will not intervene to make that happen
automatically, as a careful, scientific study has demonstrated
that this problem—preserving spaces following commands in a
general way that does not rely on parsing <<(raw>>\LaTeX{}<<raw)>>
source and is not going to muck with very deep
<<!TEX>>
internals—is NP-complete.

Another potential use of  is to <<(raw>>{\color{red}<<raw)>>COLORIZE!<<(raw>>}<<raw)>> your text, here done by inserting
```latex
<<(raw>>{\color{red}<<raw)>>
COLORIZE!
<<(raw>>}<<raw)>>
```
(with or without the line breaks) into the script.
<<multi-column}>>

xxx


`<<<document>>...<<document>>>`


<<{raw>>
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA AAAAAA
AAAAAA AAAAAA AAAAAA AAAAAA\begin{multicols}{2}\end{multicols}BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB BBBBB
BBBBB\begin{multicols}{2}XXXXXXXXXX\end{multicols}CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC CCCCCC
<<raw}>>

<<{raw>>to insert <<!LATEX>> commands
<<raw}>>
<<{multi-column>>
<<multi-column}>>

Helo <<(code>>world<<code)>>! = Helo `world`!

<!-- <<!end>> -->

@@@multi-column

^[h2^<<!MKTS>> Regions 中國皇帝^]h2^

## Footnotes

ere is a footnote reference,[^1] and another.[^longnote]

[^1]: Here is the footnote.

[^longnote]: Here's one with multiple blocks.

    Subsequent paragraphs are indented to show that they
belong to the previous footnote.

## MKTS Regions 中國皇帝

To indicate the start of an <<!MKTS>>/MD Region, place a triple at-sign `@@@`
at the start of a line, immediately followed by a command name such as
`keep-lines` or `single-column`. The end of a region is indicated by a
triple at-sign without a command name. Nested regions are possible; for example,
you can put a `@@@keep-lines` region inside a `@@@single-column` region as
done here:

## Code Regions

x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
```
this is
a code block &jzr#xe202;
with three lines & an XNCR
```
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

It's possible to switch on `inline code`. It's also possible
to have a region of code with lines rendered as in the source:
@@@single-column
```
#-------------------------------------------------------------------------------------
@_shuffle = ( list, ratio, rnd, random_integer ) ->
  #...................................................................................
  return list if ( this_idx = list.length ) < 2
  #...................................................................................
  loop
    this_idx += -1
    return list if this_idx < 1
    if ratio >= 1 or rnd() <= ratio
      # return list if this_idx < 1
      that_idx = random_integer 0, this_idx
      [ list[ that_idx ], list[ this_idx ] ] = [ list[ this_idx ], list[ that_idx ] ]
  #...................................................................................
  return list
```
@@@
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

Code sample, keeping indentations:

```
x
  x
    x
```
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x
x x x x x x x x x x x x x x x x x x x x x x x x x x

## MKTS Regions 中國皇帝

To indicate the start of an <<!MKTS>>/MD Region, place a triple at-sign `@@@`
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
At this point, a line consisting of a triple at-sign `@@@`
indicates the end of the `keep-lines` region; since the
`single-column` region is still active, however, *this
paragraph runs across the entire width* of the documents text
area.
@@@
Now a `}single-column` <<!MKTS>>/MD event has been encountered
that was triggered by a triple-at command in the manuscript;
accordingly, typesetting is reverted back to multi-column mode,
which is why you can see this paragraph set in two columns.


## Using HTML

This section tests HTML that occurs as 'blocks' (i.e. as typographical blocks
that start with an HTML tag) and 'inline' (i.e. inside of MD blocks).

<p>helo <i>world</i> and **everyone**</p>

A paragraph with <i foo=bar><b>some</b></i> HTML in it.

Here's MD with *single* and **double** stars.

Testing *italics with Chinese: 義大利體* and **bold with Chinese: 黑體, ゴシック体**

# Regions

Regions are started and ended using `@@@` (triple at-signs); the opener
must be followed by a key word indicating the region's type.


## Code

Here's `some code` within a fenced block:
```
This is a code region;
lines are kept as they appear
in the MD manuscript,
but in addition,
the font is monospaced
```
And this is the text following the fence.

## Keep-Lines Regions: Formulas Example

To preserve line breaks in the PDF the way they were entered in
the MD manuscript, use `@@@keep-lines` regions. Currently, the
best idea is to position the sentinels in a 'tight' way, without
intervening blank lines between the sentinels and the surrounding
paragraph.

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
These formulas may be recursively resolved by way of substitution to their
ultimate constituent parts—strokes. Somewhere along that process of
deconstruction, we meet with fairly recurrent figures or shapes.


## Keep-Lines Regions: All in One Paragraph

@@@single-column
A-before
@@@keep-lines
A-within
A-within
A-within
@@@
A-after
@@@

## Keep-Lines Regions: With separate Before, After Paragraphs

@@@single-column
B-before

@@@keep-lines
B-within
B-within
B-within
@@@

B-after

@@@

## Keep-Lines Regions: Region Starts, Ends within Paragraph

@@@single-column
C-before
@@@keep-lines

C-within
C-within
C-within

@@@
C-after
@@@

## Keep-Lines Regions: Region Starts, Ends with separate Paragraph

@@@single-column
D-before

@@@keep-lines

D-within
D-within
D-within

@@@

D-after
@@@


# This is a Demonstration 中國皇帝

## A Section Title 1 中國皇帝



14‰, A, able, about, account, acid, across, act, addition as done in mathematics, adjustment,
advertisement, after, again, against, agreement, air, all, almost a full sentence here
to show the effects of microtypography, among,
amount, amusement, and, angle, angry, animal, answer, ant, any, apparatus,
apple, approval, arch, argument, arm, army, art, as, at, attack, attempt,
attention, attraction, authority, automatic, awake, baby, back, bad, bag,
balance, ball, band, base, basin, basket, bath, be, beautiful, because, bed,
bee, before, behaviour, belief, bell, bent, berry, between, bird, birth, bit,
bite, bitter, black, blade, blood, blow, blue, board, boat, body, boiling,
bone, book, boot, bottle, box, boy, brain, brake, branch, brass, bread,
breath, brick, a bridge to span the chasm, bright, broken, brother, brown, brush, bucket,
building, bulb, burn, burst, business, but, butter, button, by, cake, camera,
canvas, card, care, carriage, cart, cat, cause, certain, chain, chalk, chance,
change, cheap, cheese, chemical, chest, chief, chin, church, circle, clean,
clear, clock, cloth, cloud, coal, coat, cold, collar, colour, comb, come,
comfort, committee, common, company, comparison, competition, complete,
complex, condition, connection, conscious, control, cook, copper, copy, cord,
cork, cotton, cough, country, cover, cow, crack, credit, crime, cruel, crush,
cry, cup, cup, current, curtain, curve, cushion, damage, danger, dark,
daughter, day, dead, dear, death, debt, decision, deep, degree, delicate,
dependent, design, desire, destruction, detail, development, different,
digestion, direction, dirty, discovery, discussion, disease, disgust,
distance, distribution, division, do, dog, door, doubt, down, drain, drawer,
dress, drink, driving, drop, dry, dust, ear, early, earth, east, edge,
education, effect, egg, elastic, electric, end, engine, enough, equal, error,
even, event, ever, every, example, exchange, existence, expansion, experience,
expert, eye, face, fact, fall, false, family, far, farm, fat, father, fear,
feather, feeble, feeling, female, fertile, fiction, field, fight, finger,
fire, first, fish, fixed, flag, flame, flat, flight, floor, flower, fly, fold,
food, foolish, foot, for, force, fork, form, forward, fowl, frame, free,
frequent, friend, from, front, fruit, full, future, garden, general, get,
girl, give, glass, glove, go, goat, gold, good, government, grain, grass,
great, green, grey, grip, group, growth, guide, gun, hair, hammer, hand,
hanging, happy, harbour, hard, harmony, hat, hate, have, he, head, healthy,
hear, hearing, heart, heat, help, high, history, hole, hollow, hook, hope,
horn, horse, hospital, hour, house, how, humour, I, ice, idea, if, ill,
important, impulse, in, increase, industry, ink, insect, instrument,
insurance, interest, invention, iron, island, jelly, jewel, join, journey,
judge, jump, keep, kettle, key, kick, kind, kiss, knee, knife, knot,
knowledge, land, language, last, late, laugh, law, lead, leaf, learning,
leather, left, leg, let, letter, level, library, lift, light, like, limit,
line, linen, lip, liquid, list, little, living, lock, long, look, loose, loss,
loud, love, low, machine, make, male, man, manager, map, mark, market,
married, mass, match, material, may, meal, measure, meat, medical, meeting,
memory, metal, middle, military, milk, mind, mine, minute, mist, mixed, money,
monkey, month, moon, morning, mother, motion, mountain, mouth, move, much,
muscle, music, nail, name, narrow, nation, natural, near, necessary, neck,
need, needle, nerve, net, new, news, night, no, noise, normal, north, nose,
not, note, now, number, nut, observation, of, off, offer, office, oil, old,
on, only, open, operation, opinion, opposite, or, orange, order, organization,
ornament, other, out, oven, over, owner, page, pain, paint, paper, parallel,
parcel, part, past, paste, payment, peace, pen, pencil, person, physical,
picture, pig, pin, pipe, place, plane, plant, plate, play, please, pleasure,
plough, pocket, point, poison, polish, political, poor, porter, position,
possible, pot, potato, powder, power, present, price, print, prison, private,
probable, process, produce, profit, property, prose, protest, public, pull,
pump, punishment, purpose, push, put, quality, question, quick, quiet, quite,
rail, rain, range, rat, rate, ray, reaction, reading, ready, reason, receipt,
record, red, regret, regular, relation, religion, representative, request,
respect, responsible, rest, reward, rhythm, rice, right, ring, river, road,
rod, roll, roof, room, root, rough, round, rub, rule, run, sad, safe, sail,
salt, same, sand, say, scale, school, science, scissors, screw, sea, seat,
second, secret, secretary, see, seed, seem, selection, self, send, sense,
separate, serious, servant, sex, shade, shake, shame, sharp, sheep, shelf,
ship, shirt, shock, shoe, short, shut, side, sign, silk, silver, simple,
sister, size, skin, skirt, sky, sleep, slip, slope, slow, small, smash, smell,
smile, smoke, smooth, snake, sneeze, snow, so, soap, society, sock, soft,
solid, some, son, song, sort, sound, soup, south, space, spade, special,
sponge, spoon, spring, square, stage, stamp, star, start, statement, station,
steam, steel, stem, step, stick, sticky, stiff, still, stitch, stocking,
stomach, stone, stop, store, story, straight, strange, street, stretch,
strong, structure, substance, such, sudden, sugar, suggestion, summer, sun,
support, surprise, sweet, swim, system, table, tail, take, talk, tall, taste,
tax, teaching, tendency, test, than, that, the, then, theory, there, thick,
thin, thing, this, thought, thread, throat, through, through, thumb, thunder,
ticket, tight, till, time, tin, tired, to, toe, together, tomorrow, tongue,
tooth, top, touch, town, trade, train, transport, tray, tree, trick, trouble,
trousers, true, turn, twist, umbrella, under, unit, up, use, value, verse,
very, vessel, view, violent, voice, waiting, walk, wall, war, warm, wash,
waste, watch, water, wave, wax, way, weather, week, weight, well, west, wet,
wheel, when, where, while, whip, whistle, white, who, why, wide, will, wind,
window, wine, wing, winter, wire, wise, with, woman, wood, wool, word, work,
worm, wound, writing, wrong, year, yellow, yes, yesterday, you, young.


yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 2 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

## A Section Title 3 中國皇帝

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

# Another Demonstration

yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda
yadda yadda yadda yadda yadda yadda yadda yadda yadda yadda

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
