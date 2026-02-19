import { parseHTML } from "linkedom";

export type ArticleMeta = {
  title: string;
  description: string;
  date: string;
  wordCount: number;
  tags: string[];
};

export type ArticleContent = {
  nodes: ContentNode[];
  toc: TocHeading[];
};

export function extractMeta(html: string): ArticleMeta {
  const { document } = parseHTML(html);

  const title = document.title ?? "no title";

  const descMeta = document.querySelector('meta[name="description"]');
  const description = descMeta?.getAttribute("content") ?? "no description";

  const dateMeta = document.querySelector(
    'meta[property="article:published_time"]'
  );
  const date = dateMeta?.getAttribute("content") ?? "2000-1-1";

  const text = document.body.textContent;
  const wordCount = text.trim().split(/\s+/).length;

  const tags = Array.from(
    document.querySelectorAll('meta[property="article:tag"]')
  ).map((x) => x.getAttribute("content") ?? "tag");

  return {
    title,
    description,
    date,
    wordCount,
    tags,
  };
}

export async function extractContent(html: string): Promise<ArticleContent> {
  const { document } = parseHTML(html);

  await modifyHtml(document);

  let toc = processHeaders(document);

  let nodes = nodesToContentNodes(Array.from(document.body.childNodes));
  return {
    nodes,
    toc,
  };
}

async function modifyHtml(document: Document) {
  const targetFills = document.body.querySelectorAll(
    '.math [fill="#ffffff"], figure [fill="#ffffff"]'
  );
  targetFills.forEach((el) => el.setAttribute("fill", "currentColor"));

  const targetStrokes = document.body.querySelectorAll(
    '.math [stroke="#ffffff"], figure [stroke="#ffffff"]'
  );
  targetStrokes.forEach((el) => el.setAttribute("stroke", "currentColor"));
  await addShikiHighlighting(document.body);
}

import { addShikiHighlighting } from "./article/highlight";
import { nodesToContentNodes, type ContentNode } from "./article/contentNode";
import { processHeaders, type TocHeading } from "./article/header";

export async function loadArticlesHtml(): Promise<
  { html: string; path: string }[]
> {
  const allArticleFiles = import.meta.glob("/src/writing/target/*.html", {
    query: "?raw",
    import: "default",
  });
  const iterableArticleFiles = Object.entries(allArticleFiles);

  const articles = await Promise.all(
    iterableArticleFiles.map(async ([path, resolver]) => {
      const rawHtml = (await resolver()) as string;

      const slug = path.split("/").pop()?.replace(".html", "") ?? "unknown";

      return {
        html: rawHtml,
        path: slug,
      };
    })
  );

  return articles;
}

export async function getSortedArticleMetas(): Promise<
  { meta: ArticleMeta; path: string }[]
> {
  return (await loadArticlesHtml())
    .map(({ html, path }) => ({
      path,
      meta: extractMeta(html),
    }))
    .sort((a, b) => {
      return new Date(b.meta.date).getTime() - new Date(a.meta.date).getTime();
    });
}
