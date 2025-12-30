import { createHighlighter, type BundledLanguage } from "shiki";
import typstGrammar from "./typstGrammar.json";
import {
  transformerNotationDiff,
  transformerNotationErrorLevel,
  transformerNotationFocus,
  transformerNotationHighlight,
  transformerNotationMap,
  transformerNotationWordHighlight,
} from "@shikijs/transformers";

export async function addShikiHighlighting(document: Document) {
  const highlighter = await createHighlighter({
    themes: ["one-dark-pro"],
    langs: [],
  });

  await highlighter.loadLanguage({
    ...(typstGrammar as any),
    name: "typst",
    aliases: ["typ"],
  });

  const codes = Array.from(document.querySelectorAll("code"));

  for (const code of codes) {
    let rawLang = code.getAttribute("data-lang");
    if (!rawLang) {
      rawLang = "text";
    }

    const lang = rawLang as BundledLanguage;
    const text = code.textContent || "";

    const isBlock = code.parentElement && code.parentElement.tagName === "PRE";

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
