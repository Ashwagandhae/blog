import {
  extractContent,
  extractMeta,
  getSortedArticleMetas,
  type ArticleContent,
  type ArticleMeta,
} from "$lib/article";
import { error } from "@sveltejs/kit";

type Article = {
  meta: ArticleMeta;
  content: ArticleContent;
  next: { meta: ArticleMeta; path: string };
  previous: { meta: ArticleMeta; path: string };
  path: string;
};

export async function load({ params }): Promise<Article> {
  const path = params.slug;

  let rawHtml;
  try {
    const module = await import(`../../../writing/target/${path}.html?raw`);
    rawHtml = module.default;
  } catch (e) {
    throw error(404, "Article not found");
  }

  let metas = await getSortedArticleMetas();
  let index = metas.findIndex((m) => m.path == path);
  let next = metas[(index + 1) % metas.length];
  let previous = metas[(index - 1 + metas.length) % metas.length];

  return {
    content: await extractContent(rawHtml),
    meta: extractMeta(rawHtml),
    next,
    previous,
    path,
  };
}
