#import "lib/lib.typ": *


#show: article.with(
  title: "Configuring Helix for convenient Typst previewing",
  date: datetime(year: 2026, month: 9, day: 22),
  description: "Guide to configure Helix to open Typst preview in a dedicated window on-demand.",
  tags: ("typst", "helix"),
)



While switching from #link("https://code.visualstudio.com/")[VSCode] to #link("https://helix-editor.com/")[Helix] this summer provided much perceived efficiency and fun, it also degraded my #link("https://typst.app/")[Typst] editing workflow by making previewing less ergonomic. After much finnicking, I've found a satisfactory Helix configuration on par with VSCode's functionality.


= What you get
