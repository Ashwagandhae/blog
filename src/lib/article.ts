import { parseHTML } from "linkedom";

export type ArticleMeta = {
  title: string;
  description: string;
  date: string;
  wordCount: number;
  tags: string[];
  hue: number | null;
};

function parseNum(str: string | null) {
  if (str == null) return null;
  const num = parseFloat(str);
  return isNaN(num) ? null : num;
}
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

  const hueMeta = document.querySelector('meta[name="theme:hue"]');
  const hueString = hueMeta?.getAttribute("content") ?? null;
  const hue = parseNum(hueString);

  return {
    title,
    description,
    date,
    wordCount,
    tags,
    hue,
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
export function extractContent(html: string): ContentNode[] {
  const { document } = parseHTML(html);

  const targetFills = document.querySelectorAll(
    '.math [fill="#ffffff"], figure [fill="#ffffff"]'
  );
  targetFills.forEach((el) => el.setAttribute("fill", "currentColor"));

  const targetStrokes = document.querySelectorAll(
    '.math [stroke="#ffffff"], figure [stroke="#ffffff"]'
  );
  targetStrokes.forEach((el) => el.setAttribute("stroke", "currentColor"));

  const slugCounts = new Map<string, number>();
  const headings = document.querySelectorAll("h2, h3, h4, h5, h6");
  headings.forEach((heading) => {
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

    const anchor = document.createElement("a");
    anchor.setAttribute("id", finalSlug);
    anchor.setAttribute("href", `#${finalSlug}`);
    anchor.className = "anchor-link";

    heading.parentNode?.insertBefore(anchor, heading);
    anchor.appendChild(heading);
  });

  return Array.from(document.body.childNodes)
    .map(nodeToContentNode)
    .filter((n) => n !== null);
}

//
export type ContentNode =
  | {
      type: "text";
      content: string;
    }
  | {
      type: "element";
      tag: string;
      attributes: Record<string, string>;
      children: ContentNode[];
    }
  | { type: "raw"; html: string };

export function nodeToContentNode(node: Node): ContentNode | null {
  if (node.nodeType === 3) {
    return { type: "text", content: node.textContent || "" };
  }

  if (node.nodeType === 1) {
    const element = node as Element;
    const tagName = element.tagName.toLowerCase();

    if (tagName === "svg") {
      return {
        type: "raw",

        html: element.outerHTML,
      };
    }

    const attributes: Record<string, string> = {};
    if (element.attributes) {
      Array.from(element.attributes).forEach((attr) => {
        attributes[attr.name] = attr.value;
      });
    }

    return {
      type: "element",
      tag: tagName,
      attributes,
      children: Array.from(element.childNodes)
        .map(nodeToContentNode)
        .filter((n): n is ContentNode => n !== null),
    };
  }

  return null;
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
