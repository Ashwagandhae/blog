import {
  extractContent,
  extractMeta,
  getSortedArticleMetas,
  type ArticleMeta,
  type ContentNode,
} from "$lib/article";
import { error } from "@sveltejs/kit";

type Article = {
  meta: ArticleMeta;
  content: ContentNode[];
  next: { meta: ArticleMeta; path: string };
  previous: { meta: ArticleMeta; path: string };
};

export async function load({ params }): Promise<Article> {
  const slug = params.slug;

  let rawHtml;
  try {
    const module = await import(`../../../writing/target/${slug}.html?raw`);
    rawHtml = module.default;
  } catch (e) {
    throw error(404, "Article not found");
  }

  let metas = await getSortedArticleMetas();
  let index = metas.findIndex((m) => m.path == slug);
  let next = metas[(index + 1) % metas.length];
  let previous = metas[(index - 1 + metas.length) % metas.length];

  return {
    content: extractContent(rawHtml),
    meta: extractMeta(rawHtml),
    next,
    previous,
  };
}
