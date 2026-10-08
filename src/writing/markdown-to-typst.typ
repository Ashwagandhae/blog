#import "lib/lib.typ": *


#show: article.with(
  title: "Converting all my Markdown notes to Typst",
  date: datetime(year: 2026, month: 10, day: 7),
  description: "Using Pandoc to upgrade more than 400 notes.",
  tags: ("pandoc", "typst", "markdown"),
)



After the vim-inspired modal editor #link("https://helix-editor.com/")[Helix] conquered my code writing habits this summer, it demanded complete loyalty. That meant that my homemade note-taking app, #link("https://github.com/Ashwagandhae/brot")[brot], built with the #link("https://tiptap.dev/")[Tiptap] what-you-see-is-what-you-get Markdown editor, needed surgical alteration to meet my new standards.

I initially tried making a modal Markdown editor to allow myself to edit my notes without changing their representation. However, looking at the strange corners of Markdown syntax I had to handle, with millions#footnote[Ok, there exist only 3 ways: ```md - Item```, ```md + Item```, and ```md * Item```, but it still feels like too many.] of redundant ways to make bullet points and strange alternative heading types#footnote[Did you know about #link("https://spec.commonmark.org/0.20/#setext-header")[setext headings]? The ones that let you use the following syntax?
  ```md
  Wow, h1 heading
  ====================

  Wow, h2 heading
  ---------

  Uh oh, there's no way to make an h3...
  ```

  Neither did I.
]
, convinced me to search for #link("https://karl-voit.at/2025/08/17/Markdown-disaster/")[articles to confirm my growing Markdown disapproval].

With my dislike of Markdown now supported by credible sources, I decided to convert all my 400 notes to #link("https://typst.app/")[Typst], the LaTeX replacement with Markdown-like syntax. I will describe that conversion process in this post to help anyone else converting many Markdown documents.

= Setup

I used the universal document converter #link("https://pandoc.org/")[Pandoc] to automate the conversion. To minimize the cost of mistakes, I wrote a Python script that would run each command-line tool, and save the output in a folder separate from my actual notes folder. This separation protected my actual notes from modification before I became certain about my conversion process.


The main part of my Python script initially looked like this:
#file-display("main.py")[```py
old_dir = Path("./old")
new_dir = Path("./new")

if new_dir.exists():
    shutil.rmtree(new_dir)
    print("cleared new_dir")

new_dir.mkdir(parents=True, exist_ok=True)

md_names = [
    "md_to_typ_test.md",
    "-hackerman--brot_rich_content_test.md",
]

for md_name in md_names:
    print("converting", md_name)

    md_file = old_dir / md_name
    content = md_file.read_text(encoding="utf-8")
    modified_content = process_content(content)

    typ_file = new_dir / md_file.with_suffix(".typ").name
    typ_file.write_text(modified_content, encoding="utf-8")

    print("compiling with typst")
    path = str(typ_file)
    call_typst(path)
    call_typstyle(path)
```]
I started by only converting two test Markdown files containing examples of richly formatted content. For each of those files, I first used Pandoc to convert the content to Typst, ensured that the results compiled by calling Typst, and finally fixed formatting with the formatter #link("https://github.com/typstyle-rs/typstyle")[typstyle].

This infrastructure allowed me to quickly iterate on my conversion process, giving me the ability to easily change arguments for all command-line tools and quickly see the conversion results.
= Results

After much iteration, I created a process that worked correctly for almost all my notes.

== Preprocessing <preprocessing>

Tiptap denotes underlines with the nonstandard `++` syntax, for example ```md ++I am underlined++```. I used an evil RegEx to solve this problem, using python to replace these markers with the _bracketed spans_ notation that Pandoc understands.

The below regex replaces text like ```md ++hello world++``` with ```md [hello world]{.underline}```.


#file-display("main.py")[```py
def preprocess_markdown(md_text: str) -> str:
    md_text = re.sub(r"(?<!\\)\+\+(.+?)(?<!\\)\+\+", r"[\1]{.underline}", md_text)
    return md_text
```]


== Pandoc command


My final Pandoc command looked like this:

```sh
pandoc
  -f gfm-gfm_auto_identifiers+bracketed_spans+smart-autolink_bare_uris
  -t typst
  --lua-filter=filter.lua
```
I converted from Github-Flavored Markdown (specified by setting `-f` to `gfm`), because it better fit Tiptap's Markdown export. I also configured some Pandoc extensions on GFM, and added a Lua filter to fix edge cases.

=== Pandoc extensions

- I disabled the `gfm_auto_identifiers` #link("https://pandoc.org/MANUAL.html#extensions")[Pandoc extension] by appending #raw("\u{2011}gfm_auto_identifiers") (you can read this syntax as "subtract `gfm_auto_identifiers`") so that each heading wouldn't have an associated #link("https://typst.app/docs/reference/foundations/label/")[Typst label].
- I enabled the `bracketed_spans` extension to handle the underlines I created in #link(<preprocessing>)[preprocessing].
- I enabled the `smart` extension so that Pandoc would correctly interpret quotes matching curly quotes, and not escape them when converting to Typst, preventing the problem of ```md "hello world"``` turning into ```typ \"hello world\"```.
- I disabled the `autolink_bare_uris` extension to pass plain links to Typst as plain text.


=== Lua filter

I also used a Pandoc #link("https://pandoc.org/lua-filters.html")[Lua filter] by specifying the `--lua-filter` option, allowing me to make precise adjustments by writing arbitrary Lua code with access to Pandoc's internal representation of elements.


The Lua filter I wrote grew into complexity to shoulder the heap of edge cases in the large number of notes I'd written. It consists of two passes, `convert_html` and `modify_elements`. Pandoc knows the order to run the filters because Lua tables are ordered by insertion.
#file-display("filter.lua")[```lua
local convert_html = {
  -- ...
}

local modify_elements = {
  -- ...
}

return { convert_html, modify_elements }
```]


The `convert_html` filter consists of only one selector which finds HTML tables and forces Pandoc to parse them as actual tables.

#file-display("filter.lua")[```lua
local convert_html = {
  RawBlock = function(raw)
    if raw.format:match 'html' and raw.text:match '%<table' then
      return pandoc.read(raw.text, raw.format).blocks
    end
  end
}
```]

The `modify_elements` filter has many more selectors.

- The first selectors force Pandoc to render strong and emphasized elements using the dedicated syntax, turning ```typ #strong(hello) #emph(world)``` into ```typ *hello* _world_```.

  #file-display("filter.lua")[```lua
  local modify_elements = {
    Strong = function(el)
      local inlines = { pandoc.RawInline('typst', '*') }
      for _, item in ipairs(el.content) do
        table.insert(inlines, item)
      end
      table.insert(inlines, pandoc.RawInline('typst', '*'))
      return inlines
    end,

    Emph = function(el)
      local inlines = { pandoc.RawInline('typst', '_') }
      for _, item in ipairs(el.content) do
        table.insert(inlines, item)
      end
      table.insert(inlines, pandoc.RawInline('typst', '_'))
      return inlines
    end,
    -- ...
  }
  ```]
- The `Link` filter turns links without bodies and links with bodies identical to their sources into plaintext links that Typst recognizes, allowing ```md [https://julianlbauer.com](https://julianlbauer.com)``` to become ```typ https://julianlbauer.com``` instead of ```typ #link("https://julianlbauer.com")[https://julianlbauer.com]```.

  #file-display("filter.lua")[```lua
  local modify_elements = {
    -- ...
    Link = function(el)
      local content_text = pandoc.utils.stringify(el.content)

      if content_text == el.target or content_text == "" then
        return pandoc.RawInline('typst', el.target)
      else
        return el
      end
    end,
    -- ...
  }
  ```]
- The `Math` filter passes the content inside math elements directly to Typst, because I had already created a custom Tiptap plugin that used Typst math syntax inside Typst using #link("https://github.com/qwinsi/tex2typst")[tex2typst]. I also included some evil find-and-replace lines to fix tex2typst's inconsistencies with Typst.
  #file-display("filter.lua")[```lua
  local modify_elements = {
    -- ...
    Math = function(el)
      local modified_text = string.gsub(el.text, "cdot", "dot ")
      modified_text = string.gsub(modified_text, "int ", "integral ")
      modified_text = string.gsub(modified_text, "int%%^", "integral^")
      modified_text = string.gsub(modified_text, "int_", "integral_")
      modified_text = string.gsub(modified_text, "empty", "emptyset")
      modified_text = string.gsub(modified_text, " sub ", " subset ")
      if el.mathtype == 'InlineMath' then
        return pandoc.RawInline('typst', '$' .. modified_text .. '$')
      else
        return pandoc.RawInline('typst', '$ ' .. modified_text .. ' $')
      end
    end,
    -- ...
  }
  ```]
- The `Span` filter adds underlines to the spans created in #link(<preprocessing>)[preprocessing].
  #file-display("filter.lua")[```lua
  local modify_elements = {
    -- ...
    Span = function(el)
      if el.classes:includes('underline') then
        return pandoc.Underline(el.content)
      end
    end,
    -- ...
  }
  ```]
- The `Table` filter removes the ```typ #figure()``` wrapping around tables, and uses evil RegExes to remove some table boilerplate I found unecessary.
  #file-display("filter.lua")[```lua
  local modify_elements = {
    -- ...
    Table = function(elem)
      elem.attr.classes:insert('typst:no-figure')
      elem.attr.attributes['typst:figure:kind'] = 'none'
      local typst_code = pandoc.write(pandoc.Pandoc({elem}), 'typst')
      typst_code = typst_code:gsub("%s*align:%s*%([^%)]+%),?\n", "\n")
      typst_code = typst_code:gsub("%s*table%.hline%(%),?\n", "\n")
      return pandoc.RawBlock('typst', typst_code)
    end
  }
  ```]

== Postprocessing
I discovered that Pandoc overcautiously escaped the second slash in the `https://` of links to prevent creating a ```typ // typst comment```, an unnecessary and uglifying change that made all bare links in the resulting Typst look like ```typ http:/\/julianlbauer.com// [!code word:http\:/\\/]``` instead of ```typ http://julianlbauer.com // [!code word:http\://]```.

As a final evil hack, I used find-and-replace on the resulting source code to remove that extra backslash.


#file-display("main.py")[```py
def postprocess_typst(text: str) -> str:
    text = text.replace("https:/\\/", "https://")
    return text
```]

== Manual adjustments
Tragically, there were a few unavoidable manual adjustments I had to make. Before switching my math to Typst, I had written a quarter dozen notes with LaTeX math. I converted those equations to Typst by hand.

= Conclusion

I had to write much more code than I expected, due to the verbosity of Pandoc's default Typst output and the nonstandard Markdown output of my Tiptap editor. Luckily, my process was still much faster than manually converting each note.


You can see my #link("https://github.com/Ashwagandhae/brot-md-to-typ")[conversion code on Github]. I hope this article can act as an example for new Pandoc users facing big document conversion projects!
