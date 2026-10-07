#import "lib/lib.typ": *


#show: article.with(
  title: "Converting all my Markdown notes to Typst",
  date: datetime(year: 2026, month: 10, day: 7),
  description: "Using Pandoc to upgrade more than 400 notes.",
  tags: ("pandoc", "typst", "markdown"),
)



After #link("https://helix-editor.com/")[Helix] conquered my text editing habits this summer, it demanded complete loyalty. That meant that my note-taking app, #link("https://github.com/Ashwagandhae/brot")[brot], built with a #link("https://tiptap.dev/")[Tiptap] WYSIWYG editor, needed surgerical alteration to meet the new standards.

I initially tried making an #link("https://obsidian.md/")[Obsidian]-like modal markdown editor to allow myself to edit my notes without changing their representation. However, looking at the strange corners of syntax I had to handle, with useless Setext headings and millions of ways to make bullet points, convinced me to search for #link("https://karl-voit.at/2025/08/17/Markdown-disaster/")[articles that confirmed my disapproval of markdown]. With my dislike of markdown now supported by credible sources, I decided to convert all my 400 notes to #link("https://typst.app/")[Typst].

= Setup

To minimize the cost of mistakes, I decided to write a Python script that would run each command-line tool
