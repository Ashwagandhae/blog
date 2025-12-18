import { extractMeta, loadArticlesHtml } from "$lib/article";

export async function load() {
  return {
    articles: (await loadArticlesHtml()).map(({ html, path }) => ({
      path,
      meta: extractMeta(html),
    })),
  };
}
