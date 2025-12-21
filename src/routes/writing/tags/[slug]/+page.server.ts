import { getSortedArticleMetas, loadArticlesHtml } from "$lib/article";
import { extractMeta } from "$lib/article";

export async function load({ params }) {
  const tag = params.slug;

  return {
    tag,
    articles: (await getSortedArticleMetas()).filter(({ meta }) =>
      meta.tags.includes(tag)
    ),
  };
}
