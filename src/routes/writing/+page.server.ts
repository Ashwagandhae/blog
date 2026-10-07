import { getSortedArticleMetas } from "#lib/article.js";

export async function load() {
  return {
    articles: await getSortedArticleMetas(),
  };
}
