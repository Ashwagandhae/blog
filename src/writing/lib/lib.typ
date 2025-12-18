// embedded components
#let embed(tag, body: none, attrs: (:)) = {
  let json-attrs = (:)
  for (key, value) in attrs {
    json-attrs.insert(key, json.encode(value))
  }
  html.elem(tag, body, attrs: json-attrs)
}

#let article(
  content,
  title: "Article title",
  date: datetime(year: 2025, month: 12, day: 14),
  description: "Article description",
  tags: (),
  hue: none,
) = {
  set text(fill: white, font: "Atkinson Hyperlegible")

  show math.equation: it => context {
    if target() == "html" {
      show: if it.block {
        it => html.elem("div", attrs: (class: "math"), it)
      } else {
        it => html.elem("span", attrs: (class: "math"), it)
      }
      html.frame(it)
    } else { it }
  }

  show image: it => context {
    html.img(src: it.source)
  }

  set raw(theme: "one-dark.tmTheme")

  show raw: it => context {
    if it.block {
      html.elem("div", attrs: (class: "raw"))[
        #embed("raw-copy-button", attrs: (text: it.text))
        #it
      ]
    } else {
      it
    }
  }


  show figure: it => {
    html.elem("figure")[
      #html.frame(it.body)
      #if it.caption != none {
        html.elem("figcaption", it.caption)
      }
    ]
  }


  show footnote: it => {
    let count = counter(footnote).display()
    super([#{
        show html.elem.where(tag: "a"): it => {
          if it.attrs.at("role", default: none) == none {
            html.elem("a", attrs: (..it.attrs, role: "doc-noteref", aria-label: "footnote " + count), it.body)
          } else {
            it
          }
        }
        link(label("footnote-" + count), count)
      } #label("footnote-return-" + count)])
  }


  html.elem("html")[
    #html.elem("head")[
      #html.elem("meta", attrs: (charset: "utf-8"))
      #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
      #html.elem("title")[#title]
      #html.elem("meta", attrs: (name: "description", content: description))
      #html.elem("meta", attrs: (property: "article:published_time", content: date.display()))
      #for tag in tags {
        html.elem("meta", attrs: (property: "article:tag", content: tag))
      }
      #if hue != none {
        html.elem("meta", attrs: (name: "theme:hue", content: str(hue)))
      }
    ]
    #html.elem("body")[
      #content

      #context {
        let footnotes = query(footnote)
        if footnotes.len() != 0 {
          html.elem("footer")[
            #html.elem("ol")[
              #for (i, footnote) in footnotes.enumerate() {
                let count = str(i + 1)
                [#html.elem("li", attrs: (role: "doc-footnote"))[#footnote.body #{
                      show html.elem.where(tag: "a"): it => {
                        if it.attrs.at("role", default: none) == none {
                          html.elem(
                            "a",
                            attrs: (..it.attrs, role: "doc-backlink", aria-label: "Back to content"),
                            it.body,
                          )
                        } else {
                          it
                        }
                      }
                      link(
                        label("footnote-return-" + count),
                        [↩︎],
                      )
                    }] #label(
                    "footnote-" + count,
                  )]
              }
            ]
          ]
        }
      }
    ]
  ]
}

