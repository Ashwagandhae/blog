import {
  createHighlighter,
  type BundledLanguage,
  type Highlighter,
  type SpecialLanguage,
} from "shiki";
import typstGrammar from "../typstGrammar.json";
import {
  transformerNotationDiff,
  transformerNotationErrorLevel,
  transformerNotationFocus,
  transformerNotationHighlight,
  transformerNotationWordHighlight,
} from "@shikijs/transformers";

let highlighter: Highlighter | null = null;

async function getHighlighter(): Promise<Highlighter> {
  if (highlighter == null) {
    const newHighlighter = await createHighlighter({
      themes: ["one-dark-pro"],
      langs: [],
    });
    await newHighlighter.loadLanguage({
      ...(typstGrammar as any),
      name: "typst",
      aliases: ["typ"],
    });
    highlighter = newHighlighter;
    return newHighlighter;
  }
  return highlighter;
}

export async function addShikiHighlighting(root: HTMLElement) {
  const codes = Array.from(root.querySelectorAll("code"));

  for (const code of codes) {
    let rawLang = code.getAttribute("data-lang");
    if (!rawLang) {
      rawLang = "text";
    }

    const lang = rawLang as BundledLanguage | SpecialLanguage;
    let text = code.textContent || "";

    if (lang == "ansi") {
      // replace \u{241b} with \x1b to get shiki to render correctly if in ansi language
      text = text.replace(/\u241b/g, "\x1b");
      // get rid of the OSC codes because shiki can only render SGR codes
      text = text.replace(/\x1b][0-9]+;.*?\x1b\\/g, "");
    }

    const isBlock = code.parentElement && code.parentElement.tagName === "PRE";

    const highlighter = await getHighlighter();

    if (!highlighter.getLoadedLanguages().includes(lang)) {
      await highlighter.loadLanguage(lang);
    }

    const codeHtml = highlighter.codeToHtml(text, {
      lang,
      theme: "one-dark-pro",
      structure: isBlock ? "classic" : "inline",
      transformers: [
        transformerRemoveBackground,
        transformerNotationDiff(),
        transformerNotationHighlight(),
        transformerNotationFocus(),
        transformerNotationErrorLevel(),
        transformerNotationWordHighlight(),
      ],
    });

    if (isBlock) {
      code.parentElement!.outerHTML = codeHtml;
    } else {
      code.outerHTML = `<code class="shiki-inline">${codeHtml}</code>`;
    }
  }
}

const transformerRemoveBackground = {
  name: "remove-bg",
  pre(node: any) {
    if (node.properties && typeof node.properties.style === "string") {
      node.properties.style = node.properties.style.replace(
        /background-color\s*:\s*[^;]+;?/gi,
        ""
      );
    }
  },
  span(node: any) {
    if (node.properties && typeof node.properties.style === "string") {
      node.properties.style = node.properties.style.replace(
        /background-color\s*:\s*[^;]+;?/gi,
        ""
      );
    }
  },
};
