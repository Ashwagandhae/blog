#import "lib/lib.typ": *

#show: article.with(
  title: "Test article",
  date: datetime(year: 2025, month: 12, day: 14),
  description: "An article to test different content types, such as headings, equations, and code blocks.",
  tags: ("typst", "svelte"),
  hue: 340,
)



= Paragraph and marks

#lorem(67)

Footnote that shows up#footnote[wow what an interesting footnote with some *formatting*], and then after that, another interesting#footnote[wow how interesting so good and interesting https://typst.app] group#footnote[$6 + 7$ wow good footnote] of footnotes#footnote[what if i attach a post-it to my feet].

Marks:

- *bold text*
- _italic text_
- #underline[underline text]
- `code text`
- #link("https://www.google.com/")[link to google]

= Headings

== Heading 2

=== Heading 3

==== Heading 4

===== Heading 5

== Duplicate heading
== Duplicate heading

= Lists

== Unordered
- unordered list
  - that goes
    - like this
- and also has item
- hello

== Ordered
+ ordered list
+ that goes
+ like this
  + and has
    + nesings

= Code

```python
import math

def code_block(with_syntax_highlight):
	print("hello world")
	x = {"hello": (1, 2), "goodbye": (3, 4)}
	return f"hello {1}"
```

= Table

#table(
  columns: 3,
  table.header([hello], [hi], [*hello*]),
  [this], [table], [is cool],
  [this], [table], [is cool],
)

= Blockquote

#quote(block: true)[
  Blockquote that is pretty long and contains *rich content*.

  And can be multiline.
]

= Math

Inline math $(1 + 3 + 3^4 / 1) / 2 x y z$ wow that was cool math.

Block math:

$
  cases(1 + 1, hat(2 + 2), 3 + 3/2)
$

= Embedded components

#embed("click-counter", attrs: (count: 67, celebrations: ("wow", "yay", "yippee")))

= Images

#image("san-francisco.png", alt: "San Francisco road with trees in the background")

= Figure
#import "@preview/lilaq:0.5.0" as lq

#let xs = range(0, 5)

#show: lq.theme.moon
#figure(caption: [Cool data])[
  #lq.diagram(
    title: [Precious data],
    xlabel: $x$,
    ylabel: $y$,
    width: 350pt,
    height: 200pt,

    lq.plot(range(0, 5), (3, 5, 4, 2, 3), mark: "s", label: [A]),
    lq.plot(
      xs,
      x => 2 * calc.cos(x) + 3,
      mark: "o",
      label: [B],
    ),
  )
]

= Ending paragraph

#lorem(57)
