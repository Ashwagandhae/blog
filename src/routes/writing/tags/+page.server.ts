import { extractMeta, loadArticlesHtml } from "$lib/article";

export async function load() {
  let allTags = (await loadArticlesHtml()).flatMap(
    ({ html }) => extractMeta(html).tags
  );

  let tags = Array.from(new Set(allTags));
  return {
    tags,
  };
}
