import { loadArticlesHtml } from "$lib/article";
import { extractMeta, type ArticleMeta, type ContentNode } from "$lib/article";

type Article = {
  meta: ArticleMeta;
  content: ContentNode[];
};

export async function load({ params }) {
  const tag = params.slug;

  return {
    tag,
    articles: (await loadArticlesHtml())
      .map(({ html, path }) => ({
        path,
        meta: extractMeta(html),
      }))
      .filter(({ meta }) => meta.tags.includes(tag)),
  };
}
