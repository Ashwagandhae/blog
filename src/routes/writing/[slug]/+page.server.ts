import {
  extractContent,
  extractMeta,
  type ArticleMeta,
  type ContentNode,
} from "$lib/article";
import { error } from "@sveltejs/kit";
import { parseHTML } from "linkedom";

type Article = {
  meta: ArticleMeta;
  content: ContentNode[];
};

export async function load({ params }): Promise<Article> {
  const slug = params.slug;

  const module = await import(`../../../writing/target/${slug}.html?raw`);

  const rawHtml = module.default;

  if (!rawHtml) {
    throw error(404, "Post not found");
  }

  return {
    content: extractContent(rawHtml),
    meta: extractMeta(rawHtml),
  };
}
