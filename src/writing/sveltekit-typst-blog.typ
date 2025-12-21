#import "lib/lib.typ": *

#show: article.with(
  title: "SvelteKit blog with Typst as markup language",
  date: datetime(year: 2025, month: 12, day: 19),
  description: "Guide to making a SvelteKit blog with Typst as the markup language.",
  tags: ("typst", "javascript", "svelte"),
)

As of December 2025, Typst's #link("https://typst.app/docs/reference/html/")[documentation for HTML export] states:

#quote(block: true)[
  Typst's HTML export is currently under active development. The feature is still very incomplete and only available for experimentation behind a feature flag. Do not use this feature for production use cases.
]

Seems like a great time to create a blog that relies on Typst HTML export!

= Introduction

This article acts as a guide to building a bare-bones blog website with SvelteKit and Typst, based on my experience making the website you're currently looking at, with support for code blocks, math, footnotes, and other rich content. I focus on getting the website to function, omitting the styling that makes it look nice.

Because of the experimental nature of Typst's HTML export, much of this article consists of code that patches unsupported elements into Typst and SvelteKit. If you have a popular blog with billions of important serious users, I probably can't safely recommend this setup. However, if you really like Typst, really like Svelte, and don't really mind an unstable setup for your website, this guide is for you.

= Why

Because SvelteKit and Typst are both very good.

*SvelteKit* is built on Svelte, a JavaScript framework that's extremely simple and focused on developer experience. It also supports static site generation with `adapter-static`, prerendering each page at compile time for blazingly fast loading speeds on any static website hosting service, such as GitHub pages.

*Typst* has beautiful markdown-inspired syntax that makes reading the source almost as easy as reading the output. The biggest reason Typst is better than Markdown for a blog is that it is also a fully-featured programming language, allowing you to run arbitrary code to generate your markup.#footnote[
  #let block = ```typ
  #let fibs(n) = {
    let ret = (0, 1)
    for _ in range(n - 2) {
      ret = (..ret, ret.at(-1) + ret.at(-2))
    }
    ret
  }
  For example, if I wanted to list out the first 40 fibonacci numbers,
  which are #fibs(40).map(str).join(", ", last: ", and "), I can do it by
  writing code like this:
  ```
  #eval(block.text, mode: "markup")
  #block
]

= Setup
To generate a SvelteKit project named `sveltekit-typst-blog`, open your terminal and run
```bash
npx sv create sveltekit-typst-blog
```
Then, when prompted, choose `SvelteKit minimal` as your template, add TypeScript type checking, and don't add anything else to your project.#footnote[
  You can also just run
  ```bash
  npx sv create --template minimal --types ts --install npm sveltkit-typst-blog
  ```
  to skip manually selecting settings.] Now, run
```bash
cd sveltkit-typst-blog
npm run dev -- --open
```

You should see your website running in your browser!
#image("sveltekit-typst-blog/svelkit-starter.png")

= Strategy

I'll discuss the strategy we'll use to render Typst in our website. We will
+ Write our blog posts in Typst.
+ Use the Typst compiler to convert all Typst files into HTML files.
+ Parse the HTML files server-side to extract metadata, like the post title and publish date.
+ Render the HTML on the frontend with the Svelte #link("https://svelte.dev/docs/svelte/@html")[`@html` template syntax].

= Posts folder

We'll start by creating a folder to hold our blog posts. Create a folder `src/posts`. Inside this folder, create
+ a folder named `lib` with a file `lib.typ`, which we will use to create shared code for all articles
+ a folder named `target` which will contain the generated HTML
+ a file `test.typ` that we'll use to test different content types

== `lib.typ` article function

In our `lib.typ` file, we'll create a function called `article` that we'll wrap all future articles in using show rules:

```typ
// src/posts/lib/lib.typ
#let article(
  content,
  title: "Article title",
  date: datetime(year: 2025, month: 12, day: 14),
) = {
  html.elem("html")[
    #html.elem("head")[
      #html.elem("title")[#title]
      #html.elem("meta", attrs: (property: "article:published_time", content: date.display()))
    ]
    #html.elem("body")[
      #content
    ]
  ]
}
```

Here, we allow users to specify we use Typst's HTML `elem` function to generate the basic structure of our document, including metadata in the `head` element.#footnote[Typst automatically generates the basic `html`, `head` and `body` if you don't create your own `html` element. However, we're manually specifying the structure to give us more control over metadata.]

== `test.typ` content types

Now, we can use our newly-created `article` function in our test article:

```typ
// src/posts/test.typ
#import "lib/lib.typ": *

#show: article.with(
  title: "Test article",
  date: datetime(year: 2025, month: 12, day: 14),
)
```

We'll also include examples of different types content we want to support in our blog.

#collapsible[````typ
// src/posts/test.typ
// ...
= Paragraph
#lorem(67)

= Marks

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
    + nestings

= Code

```python
import math

def code_block(with_syntax_highlight):
print("hello world")
x = {"hello": (1, 2), "goodbye": (3, 4)}
return f"hello {1}"
```

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
````]

== Compile to HTML

Now, we can compile our file to HTML! Install the #link("https://typst.app/open-source/")[Typst compiler] if you haven't already, then open your terminal and run
```bash
typst compile src/posts/test.typ src/posts/target/test.html --format html --features html
```

You should see a newly created `test.html` in `src/posts/target/test.html`! Ignore any warnings you get for now, we will fix them later.

= Post rendering

Now, let's display our posts in SvelteKit!

== Extraction functions
First, we'll create some utility functions to extract the metadata and content out of our generated HTML files. To parse our HTML on the server, which doesn't have access to the browser's DOM API, we need to install #link("https://github.com/WebReflection/linkedom")[linkedom]. To do that, run
```bash
npm i linkedom
```

Now, create a new file `posts.ts` in `src/lib` for our extraction functions. We'll first create a `PostMeta` type to group each post's metadata:

```ts
export type PostMeta = {
  title: string;
  date: string;
};
```

Then, we'll create a function to extract that metadata, using the `parseHTML` function from `linkedom`.

```ts
export function extractMeta(html: string): PostMeta {
  const { document } = parseHTML(html);

  const title = document.title ?? "no title";

  const dateMeta = document.querySelector(
    'meta[property="article:published_time"]'
  );
  const date = dateMeta?.getAttribute("content") ?? "2000-1-1";

  return {
    title,
    date,
  };
}
```

Finally, we'll create a symmetrical function to extract the article's content.

```ts
export function extractContent(html: string): string {
  const { document } = parseHTML(html);
  return document.body.innerHTML;
}
```

== Post listing
We'll make the website's homepage display a list of links to all blog posts. In `src/routes`, create a new file `+page.server.ts`. This file will load all HTML files in our target directory and extract the metadata from each one.
```ts
// src/routes/+page.server.ts
import { extractMeta } from "$lib/posts";

export async function load() {
  const allPostFiles = import.meta.glob("/src/posts/target/*.html", {
    query: "?raw",
    import: "default",
  });
  const posts = await Promise.all(
    Object.entries(allPostFiles).map(async ([path, resolver]) => {
      const html = (await resolver()) as string;

      const slug = path.split("/").pop()?.replace(".html", "") ?? "unknown";

      return {
        meta: extractMeta(html),
        path: slug,
      };
    })
  );

  return { posts };
}
```

Then, we'll edit the existing `src/routes/+page.svelte` to display a list of links to all posts.
```svelte
<!-- src/routes/+page.svelte -->
<script lang="ts">
  let { data } = $props();
</script>

<h1>Posts</h1>
<ul>
  {#each data.posts as post}
    <li>
      <a href="./{post.path}">
        {post.meta.title} - {post.meta.date}
      </a>
    </li>
  {/each}
</ul>
```

== Post display
In `src/routes`, create a folder called `[slug]`. Inside that folder, first create a file `+page.server.ts`. This file will get our HTML file, extract the metadata, and send both the metadata and the article contents to the frontend.

We'll define a function called `load`, whose return value SvelteKit will automatically pass to the frontend.
```ts
// src/routes/[slug]/+page.server.ts
import { extractContent, extractMeta } from "$lib/posts";
import { error } from "@sveltejs/kit";

export async function load({ params }) {
  const slug = params.slug;

  const module = await import(`../../posts/target/${slug}.html?raw`);
  const html = module.default;

  if (!html) {
    throw error(404, "Post not found");
  }

  return {
    content: extractContent(html),
    meta: extractMeta(html),
  };
}
```

Here, we first load the HTML by `import`ing it from the target directory based on the URL's slug (the slug is the part after the last `/` in the URL, which should match the name of our file, see the #link("https://svelte.dev/docs/kit/routing")[SvelteKit routing docs] for more information). Then, we use our extraction functions to return the post's content and metadata.

With all the data we need extracted, rendering it becomes quite easy. Create another file `+page.svelte` in our `[slug]` folder. In that file, we'll write some simple rendering code:
```svelte
<!-- src/routes/[slug]/+page.svelte -->

<script lang="ts">
  let { data } = $props();
</script>

<h1>Title: {data.meta.title}</h1>
<p>Published on {data.meta.date}</p>
<article>
  {@html data.content}
</article>
```

Now, all the pieces are in place! Run `npm run dev`, and go to `localhost:????/test` to view the rendered `test.typ` blog post!

#image("sveltekit-typst-blog/first-post-render.png")

= Developer experience

Although the current setup works, the developer experience is not good. Currently, to see changes in your blog post, you have to manually rerun `typst compile` and reload the website. We'll fix this by automatically recompiling Typst files when they change, and automatically reloading the website when the source HTML files change in `dev` mode.

== File watcher

First, to install the libraries we need for our file watcher, run
```bash
npm install --save @types/node
npm i -D chokidar
npm i -D concurrently
```

Then, create a new file `scripts/typst-manager.ts`. This script has two modes, `dev` and `build`, corresponding to `vite dev` and `vite build`.
- in `build` mode, it just runs `typst compile` for all `.typ` files in `src/posts`
- in `dev` mode, it builds all `.typ` files _and_ checks for updates to `.typ` files
  - if a `.typ` file is modified, then the script runs `typst watch` for that file, which will instantly update the HTML whenever the Typst content changes. The approach prevents spawning hundreds of `typst watch` processes if you have hundreds of `.typ` files (assuming that you will likely only edit one blog post at a time).
I won't go into much more detail about the script. Here's the code:

#collapsible[```ts
// scripts/typst-manager.ts
import { spawn, execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import chokidar from "chokidar";

const ROOT = process.cwd();
const SOURCE_DIR = "src/posts";
const TARGET_DIR = "src/posts/target";
const EXCLUDE = ["lib.typ"];
const ABS_TARGET = path.resolve(ROOT, TARGET_DIR);

if (!fs.existsSync(path.join(ROOT, TARGET_DIR))) {
  fs.mkdirSync(path.join(ROOT, TARGET_DIR), { recursive: true });
}

const activeWatchers = new Map();

const mode = process.argv[2] || "build";

if (mode === "build") {
  buildAll();
} else if (mode === "dev") {
  buildAll();
  startDevMode();
}

function getTypstFiles() {
  const dir = path.join(ROOT, SOURCE_DIR);
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".typ") && !EXCLUDE.includes(f));
}

function compileFile(fileName: string) {
  const source = path.join(SOURCE_DIR, fileName);
  const target = path.join(TARGET_DIR, fileName.replace(".typ", ".html"));

  try {
    execSync(
      `typst compile "${source}" "${target}" --format html --features html`,
      { stdio: "inherit" }
    );
    console.log(`built ${fileName}`);
  } catch (e) {
    console.error(`failed to build ${fileName}`);
  }
}

function buildAll() {
  console.log("\nstarting full typst build...");
  const files = getTypstFiles();
  files.forEach(compileFile);
  console.log("build complete.\n");
}

function startDevMode() {
  console.log("watching for changes...");

  const watcher = chokidar.watch(SOURCE_DIR, {
    persistent: true,
    ignoreInitial: true,
    ignored: [ABS_TARGET],
  });

  watcher.on("all", (event, filePath) => {
    const fileName = path.basename(filePath);
    const ext = path.extname(filePath).toLowerCase();

    if (!filePath.endsWith(".typ") || EXCLUDE.includes(fileName)) {
      return;
    }

    if (activeWatchers.has(fileName)) {
      return;
    }

    if (event === "change" || event === "add") {
      spawnDedicatedWatcher(fileName);
    }
  });

  process.on("SIGINT", () => {
    console.log("\nstopping all typst watchers...");
    activeWatchers.forEach((child, name) => {
      child.kill();
    });
    process.exit();
  });
}

function spawnDedicatedWatcher(fileName: string) {
  console.log(`spawning dedicated watcher for: ${fileName}`);

  const source = path.join(SOURCE_DIR, fileName);
  const target = path.join(TARGET_DIR, fileName.replace(".typ", ".html"));

  const child = spawn(
    "typst",
    ["watch", source, target, "--format", "html", "--features", "html"],
    {
      stdio: "inherit",
      shell: true,
    }
  );

  activeWatchers.set(fileName, child);

  child.on("close", () => {
    activeWatchers.delete(fileName);
  });
}
```]

Now, we'll modify our `package.json` to run `typst-manager.ts` whenever we run `dev` or `build`. Modify `package.json` so the `scripts` section looks like this:
```json
{
  ...
  "scripts": {
    "typst:dev": "node scripts/typst-manager.ts dev",
    "typst:build": "node scripts/typst-manager.ts build",
    "dev": "concurrently \"npm run typst:dev\" \"vite dev\"",
    "build": "npm run typst:build && vite build",
    ...
  },
  ...
}
```
Now, if you run `npm run dev`, any changes to `test.typ` should be reflected in `test.html` on save.

== Hot reloading

Even though our HTML files change in sync with our Typst files, we have to manually reload our blog in `dev` mode if we want to see how those changes will look on our website. Let's fix that!

In `vite.config.ts`, we'll create a new custom plugin that notifies the frontend whenever HTML files change. Replace
```ts
export default defineConfig({
	plugins: [sveltekit()]
});
```
with
```ts
export default defineConfig({
  plugins: [
    sveltekit(),
    {
      name: "watch-content",
      handleHotUpdate({ file, server }) {
        if (file.endsWith(".html")) {
          server.ws.send({ type: "custom", event: "content-update" });
        }
      },
    },
  ],
});
```
We can listen for these changes on the frontend by modifying `src/routes/+layout.svelte`. Add the following snippet to the `script` section of your `+layout.svelte` file:
```ts
import { invalidateAll } from "$app/navigation";
if (import.meta.hot) {
   import.meta.hot.on("content-update", () => {
     invalidateAll();
   });
}
```
Now, when you're running `npm run dev`, any changes to `test.typ` should be reflected in your browser on save!

= Math

Clever observers might have noticed that Typst has been furiously emitting warnings about our use of math blocks in our `test.typ` file. Even cleverer observers might have noticed that our output HTML currently contains no math—Typst currently removes math elements because it doesn't know how to display them. Let's fix this!

Open `src/writing/lib/lib.typ`. In the article function, we'll create a show rule that changes the way Typst renders math equations by modifying our article function:
```typ
// src/posts/lib/lib.typ
#let article(
  // ...
) = context {
  show math.equation: it => {
    show: if it.block {
      it => html.elem("div", attrs: (class: "math"), it)
    } else {
      it => html.elem("span", attrs: (class: "math"), it)
    }
    html.frame(it)
  }
  // ...
}
```
Our show rule maps block math in `div`s and inline math in `span`s. Most importantly, it wraps the whole element in a `frame`, which makes Typst render the contained content as an SVG. Typst doesn't currently have built-in HTML rendering for math, but it can render any part of the document as SVG, so we just wrap all our math equations with `frame`s to show them as SVGs instead.#footnote[
  There are other approaches to rendering math, like using #link("https://codeberg.org/akida/mathyml")[mathyml] to convert equations to MathML Core or #link("https://github.com/qwinsi/tex2typst")[convert to LaTeX] and render with #link("https://www.mathjax.org/")[MathJax] or #link("https://katex.org/")[KaTeX]. I decided to use SVG rendering because of simplicity and visual accuracy.
]

Now, math displays correctly!

#image("sveltekit-typst-blog/math.png")

= Footnotes

Let's add support for footnotes! First, create another show rule in the `lib.typ` `article` function:
```typ
// src/posts/lib/lib.typ
#let article(
  // ...
) = context {
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
  // ...
}
```

This show rule uses Typst's `counter` function to display numbered footnotes linked to their sources, and also sets up backlink targets so that readers can return to the article after reading the footnote. We use a show rule to add accessible attributes to the generated `a` element.

Then, let's update the `html.body` function to display each footnote, using Typst's `query` function to find each footnote's content.

```typ
#html.elem("body")[
  #content
  #context {
    let footnotes = query(footnote)
    if footnotes.len() != 0 {
      html.elem("footer")[
        #html.elem("ol")[
          #for (i, footnote) in footnotes.enumerate() {
            let count = str(i + 1)
            [#html.elem("li", attrs: (role: "doc-footnote"))[
                #footnote.body #{
                  show html.elem.where(tag: "a"): it => {
                    if it.attrs.at("role", default: none) == none {
                      html.elem(
                        "a",
                        attrs: (
                          ..it.attrs,
                          role: "doc-backlink",
                          aria-label: "Back to content",
                        ),
                        it.body,
                      )
                    } else {
                      it
                    }
                  }
                  link(label("footnote-return-" + count))[↩︎]
                }] #label("footnote-" + count)]
          }
        ]
      ]
    }
  }
]
```

Here, we create the targets for the links we set up in our show rule, and create backlinks with the `↩︎` symbol at the end of each footnote. We also use another show rule to add accessible attributes to our links.

We can our implementation by modifying our `test.typ` file to include some example footnotes:

```typ
// src/posts/test.typ
// ...
= Footnote

Let's make footnotes#footnote[An example footnote]
and more footnotes#footnote[
  Another example footnote with *rich content*
]
```
Now, we have support for footnotes!

#image("sveltekit-typst-blog/footnote.png")

= Conclusion

I hope this article provided a good guide for the basics of setting up a SvelteKit + Typst blog. Other features, like support for arbitrary figures or images that aren't just embedded into the HTML can be implemented pretty easily with more show rules and some extra JavaScript. You can find the code #link("https://github.com/Ashwagandhae/sveltekit-typst-blog")[on Github].

The approach I used has good developer experience but is somewhat fragile; future solutions could use #link("https://github.com/Myriad-Dreamin/typst.ts")[typst.ts] to make a proper Vite plugin.
