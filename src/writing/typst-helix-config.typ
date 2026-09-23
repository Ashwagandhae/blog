#import "lib/lib.typ": *


#show: article.with(
  title: "Configuring Helix for convenient Typst previewing",
  date: datetime(year: 2026, month: 9, day: 22),
  description: "Using the dependently-typed programming language Idris to verify insertion sort.",
  tags: ("typst", "helix"),
)



While switching from #link("https://code.visualstudio.com/")[VSCode] to #link("https://helix-editor.com/")[Helix] this summer provided much perceived efficiency and fun, it also degraded my #link("https://typst.app/")[Typst] editing workflow by making previewing less ergonomic. After much finnicking, I've found a satisfactory Helix configuration on par with VSCode's functionality.


= What you get

#image(
  "typst-helix-config/screenshot.png",
  alt: "Screenshot of working Typst preview, with two terminals with Typst files open in Helix next to their preview windows.",
)

This configuration creates two new keyboard shortcuts you can use when editing Typst files:
#table(
  columns: 2,
  table.header([Keybinding], [Action]),
  [`ctrl+shift+p` ], [Open a previewing window],
  [`ctrl+p` ],
  [Set the file the preview window previews to the currently open buffer],
) <keyboard-shortcuts>

The previewing window
- Has all the #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist] preview features, including instant previewing as you type, click-to-jump, and dark theme
- Spawns as a seperate window without distracting browser elements like tabs and search bars
- Works without conflicting with other preview windows spawned from other Helix instances

= Configuration steps <configuration-steps>
+ Make sure you've installed the #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist LSP]
+ Open your global #link("https://docs.helix-editor.com/languages.html")[Helix languages file], and append:
  #file-display("~/.config/helix/languages.toml")[
    ```toml
    [language-server.tinymist]
    command = "tinymist"
    config.preview.background.enabled = true
    config.preview.background.args = ["--data-plane-host=127.0.0.1:0"]
    ```
  ]

  These lines configure Tinymist to start a preview server at a random port once you've opened your first Typst file, as specified by setting the `data-plane-host` port to `0`.
+ Make sure you've installed #link("https://www.nushell.sh/")[Nushell].#footnote[
    If you don't like installing things, you can also rewrite the script in Bash and update the Helix command to run the Bash script.
  ]
+ Create a file `typst-preview.nu` somewhere, perhaps in your #link("https://docs.helix-editor.com/configuration.html")[Helix config directory], with the contents:
  #file-display("~/.config/helix/typst-preview.nu")[
    ```nu
    let helix_pid = (ps | where pid == $nu.pid | first).ppid
    let tinymist_proc = ps |
      where ppid == $helix_pid |
      where name =~ tinymist |
      first
    if $tinymist_proc == null {
      print "tinymist proc is null"
      return
    } else {
      let tinymist_entry = lsof -i -P -n |
        from ssv --minimum-spaces 1 |
        where PID == ($tinymist_proc.pid | into string) |
        first
      ^open -na "Google Chrome" --args --app=("http://" + $tinymist_entry.NAME)
      # should be `google-chrome --app=("http://" + $tinymist_entry.NAME)` on Linux
    }
    ```
  ]
  This script finds your Helix instance's process ID, finds the child Tinymist process that the Helix instance spawned, and looks up the address of the previewing server based on the child's process ID.

  The final ```nu open``` command opens the address in Chrome, using the `--app` flag of Chromium browsers to hide tabs and other superfluous UI elements.#footnote[You can also open the url in other browsers like Firefox or Safari, but to my knowledge those browsers don't have a similar UI-hiding feature.]
+ Open your #link("https://docs.helix-editor.com/configuration.html")[Helix config file], and append:
  #file-display("~/.config/helix/config.toml")[
    ```toml
    [keys.normal]
    "C-S-p" = ':sh nu ~/.config/helix/typst-preview.nu'
    "C-p" = ':lsp-workspace-command tinymist.pinMain "%sh{realpath %{buffer_name}}"'
    ```
  ]
  These lines create the keyboard shortcuts #link(<keyboard-shortcuts>)[described above].

= Credits

Most of the config comes from #link("https://forum.typst.app/t/what-is-the-best-setup-for-using-typst-in-helix-editor/5867/3")[sijo's reply in the Typst forums], without which I wouldn't have understood how to make Tinymist preview at a random port. Thank you!

My improvements consist of
- Letting you open the preview server intentionally with a shortcut instead of having Tinymist open your browser automatically on startup and annoyingly steal your focus
- Opening the preview in a dedicated UI-less window instead of cluttering your browser's tabs#footnote[Additionally, because I use Zen as my actual browser, opening the preview in the seperate app Chrome allow any shortcuts I use to switch to the Zen app to better match my intent, focusing my actual browser window instead of a random Typst preview.]

I hope this helps!
