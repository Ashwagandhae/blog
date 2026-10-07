import { getSortedArticleMetas, loadArticlesHtml } from "#lib/article.js";
import { extractMeta } from "#lib/article.js";

export async function load({ params }) {
  const tag = params.slug;

  return {
    tag,
    articles: (await getSortedArticleMetas()).filter(({ meta }) =>
      meta.tags.includes(tag)
    ),
  };
}
