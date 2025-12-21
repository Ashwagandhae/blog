import { getSortedArticleMetas } from "$lib/article";

export async function load() {
  return {
    articles: await getSortedArticleMetas(),
  };
}
