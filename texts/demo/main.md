<<{multi-column>>


<<(:thequestion>>*What is the meaning of life,
the universe, and everything?*<<:)>>
<<(:theanswer>>**42**<<:)>>
<<(:TEX>><<(raw>>\TeX{}<<raw)>><<:)>>
<<(:LATEX>><<(raw>>\LaTeX{}<<raw)>><<:)>>
<<(:MKTS>>**MKTS**<<:)>>

# MKTS/MD

## Regions, Blocks and Spans

### The Fine Print

A fascinating description of a global language, *A Grammar of Mandarin* combines broad perspectives with illuminating depth. Crammed with examples from everyday conversations, it aims to let the language speak for itself. The book opens with an overview of the language situation and a thorough account of Mandarin speech sounds. Nine core chapters explore syntactic, morphological and lexical dimensions. A final chapter traces the Chinese character script from oracle-bone inscriptions to today’s digital pens.

This work will cater to language learners and linguistic specialists alike. Easy reference is provided by more than eighty tables, figures, appendices, and a glossary. The main text is enriched by sections in finer print, offering further analysis and reflection. Example sentences are fully glossed, translated, and explained from diverse angles, with a keen eye for recent linguistic change. This grammar, in short, reveals a Mandarin language in full swing.


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
