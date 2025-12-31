import { parseHTML } from "linkedom";

export type ArticleMeta = {
  title: string;
  description: string;
  date: string;
  wordCount: number;
  tags: string[];
};

export type TocHeading = {
  nodes: ContentNode[];
  id: string;
  level: 2 | 3 | 4 | 5 | 6;
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

function slugify(text: string): string {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^\w\-]+/g, "")
    .replace(/\-\-+/g, "-");
}
export async function extractContent(html: string): Promise<ArticleContent> {
  const { document } = parseHTML(html);

  await modifyHtml(document.body);

  const slugCounts = new Map<string, number>();
  const headings = document.querySelectorAll("h2, h3, h4, h5, h6");
  let toc: TocHeading[] = [];
  for (const heading of headings) {
    const text = heading.textContent || "";
    const baseSlug = slugify(text);

    let finalSlug = baseSlug;
    if (slugCounts.has(baseSlug)) {
      const count = slugCounts.get(baseSlug)! + 1;
      slugCounts.set(baseSlug, count);
      finalSlug = `${baseSlug}-${count}`;
    } else {
      slugCounts.set(baseSlug, 0);
    }

    const headingNodes = nodesToContentNodes(Array.from(heading.childNodes));
    let headingLevel: TocHeading["level"];
    switch (heading.tagName) {
      case "H2":
        headingLevel = 2;
        break;
      case "H3":
        headingLevel = 3;
        break;
      case "H4":
        headingLevel = 4;
        break;
      case "H5":
        headingLevel = 5;
        break;
      case "H6":
        headingLevel = 6;
        break;
      default:
        headingLevel = 2;
    }

    toc.push({
      level: headingLevel,
      nodes: headingNodes,
      id: finalSlug,
    });

    const anchor = document.createElement("a");
    anchor.setAttribute("href", `#${finalSlug}`);
    heading.setAttribute("id", finalSlug);
    anchor.className = "anchor-link";

    heading.parentNode?.insertBefore(anchor, heading);
    anchor.appendChild(heading);
  }

  let nodes = nodesToContentNodes(Array.from(document.body.childNodes));
  return {
    nodes,
    toc,
  };
}

async function modifyHtml(root: HTMLElement) {
  const targetFills = root.querySelectorAll(
    '.math [fill="#ffffff"], figure [fill="#ffffff"]'
  );
  targetFills.forEach((el) => el.setAttribute("fill", "currentColor"));

  const targetStrokes = root.querySelectorAll(
    '.math [stroke="#ffffff"], figure [stroke="#ffffff"]'
  );
  targetStrokes.forEach((el) => el.setAttribute("stroke", "currentColor"));
  await addShikiHighlighting(root);
}

import { embedComponents } from "$lib/embed";
import { addShikiHighlighting } from "./articleHighlight";

const customTags = new Set(Object.keys(embedComponents));

export type ContentNode =
  | {
      type: "element";
      tag: string;
      attributes: Record<string, string>;
      children: ContentNode[];
    }
  | { type: "raw"; html: string };

export function nodesToContentNodes(nodes: Node[]): ContentNode[] {
  const result: ContentNode[] = [];

  function pushRaw(html: string) {
    if (result.length > 0 && result[result.length - 1].type === "raw") {
      (result[result.length - 1] as { type: "raw"; html: string }).html += html;
    } else {
      result.push({ type: "raw", html });
    }
  }

  for (const node of nodes) {
    if (node.nodeType === 3) {
      const text = node.textContent || "";
      pushRaw(escapeHtml(text));
      continue;
    }

    if (node.nodeType === 1) {
      const element = node as Element;
      const tagName = element.tagName.toLowerCase();

      if (tagName === "svg") {
        pushRaw(element.outerHTML);
        continue;
      }

      if (customTags.has(tagName)) {
        result.push({
          type: "element",
          tag: tagName,
          attributes: getAttributes(element),
          children: nodesToContentNodes(Array.from(element.childNodes)),
        });
        continue;
      }

      if (!containsCustomTag(element)) {
        pushRaw(element.outerHTML);
        continue;
      }

      result.push({
        type: "element",
        tag: tagName,
        attributes: getAttributes(element),
        children: nodesToContentNodes(Array.from(element.childNodes)),
      });
    }
  }

  return result;
}

function getAttributes(element: Element): Record<string, string> {
  const attributes: Record<string, string> = {};
  if (element.attributes) {
    Array.from(element.attributes).forEach((attr) => {
      attributes[attr.name] = attr.value;
    });
  }
  return attributes;
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function containsCustomTag(element: Element): boolean {
  const selector = Array.from(customTags).join(",");
  if (!selector) return false;
  return element.querySelector(selector) !== null;
}

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
