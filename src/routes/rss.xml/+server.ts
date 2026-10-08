import { render } from "svelte/server";
import ContentRenderer from "#lib/components/ContentRenderer.svelte";
import {
	getSortedArticles,
	type ArticleContent,
	type ArticleMeta,
} from "#lib/article.ts";

export const prerender = true;

const SITE_URL = "https://julianlbauer.com";
const SITE_TITLE = "Julian Bauer";
const SITE_DESC = "Julian Bauer's home on the internet. ";

function generateRssItem(
	content: ArticleContent,
	meta: ArticleMeta,
	path: string,
): string {
	const context: Map<any, any> = new Map([["isRss", true]]);
	const { body } = render(ContentRenderer, {
		props: { nodes: content.nodes },
		context,
	});
	const cleanHtml = body.replace(/<!--.*?-->/g, "");

	return `
    <item>
      <title><![CDATA[${meta.title}]]></title>
      <link>${SITE_URL}/writing/${path}</link>
      <guid isPermaLink="true">${SITE_URL}/writing/${path}</guid>
      <pubDate>${new Date(meta.date).toUTCString()}</pubDate>
      <description>${meta.description}</description>
			<content:encoded><![CDATA[${cleanHtml}]]></content:encoded>
    </item>
  `;
}

export async function GET() {
	const posts = await getSortedArticles();
	const recentPosts = posts.slice(0, 15);
	const itemsXml = recentPosts
		.map(({ content, meta, path }) => generateRssItem(content, meta, path))
		.join("");

	const xml = `<?xml version="1.0" encoding="UTF-8" ?>
	<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/">
    <channel>
      <title>${SITE_TITLE}</title>
      <link>${SITE_URL}</link>
      <description>${SITE_DESC}</description>
      <atom:link href="${SITE_URL}/rss.xml" rel="self" type="application/rss+xml" />
      ${itemsXml}
    </channel>
  </rss>`.trim();

	return new Response(xml, {
		headers: {
			"Content-Type": "application/xml",
			"Cache-Control": "max-age=0, s-maxage=3600",
		},
	});
}
