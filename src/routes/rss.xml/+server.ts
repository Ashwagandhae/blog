import { render } from "svelte/server";
import ContentRenderer from "#lib/components/ContentRenderer.svelte";
import {
	getSortedArticlesRss,
	type ArticleContent,
	type ArticleMeta,
} from "#lib/article.ts";
import type { ContentNode } from "#lib/article/contentNode.ts";
import { parseHTML } from "linkedom";

export const prerender = true;

const SITE_URL = "https://julianlbauer.com";
const SITE_TITLE = "Julian Bauer";
const SITE_DESC = "Julian Bauer's home on the internet. ";

function cleanRssHtml(html: string): string {
	const { document } = parseHTML(`<div>${html}</div>`);
	const root = document.firstElementChild as HTMLElement;

	root.querySelectorAll("svg").forEach((svg) => {
		svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");

		const svgString = svg.outerHTML;

		const dataUri = `data:image/svg+xml,${encodeURIComponent(svgString)}`;

		const img = document.createElement("img");
		img.setAttribute("src", dataUri);

		if (svg.getAttribute("aria-label")) {
			img.setAttribute("alt", svg.getAttribute("aria-label") || "");
		}

		svg.parentNode?.insertBefore(img, svg);
		svg.remove();
	});
	root.querySelectorAll("a[href], img[src]").forEach((node) => {
		const attr = node.tagName === "A" ? "href" : "src";
		const val = node.getAttribute(attr);

		if (val && (val.startsWith("/") || val.startsWith("."))) {
			node.setAttribute(attr, new URL(val, SITE_URL).href);
		}
	});
	const walker = document.createTreeWalker(root, 128);
	const comments: Node[] = [];
	while (walker.nextNode()) {
		comments.push(walker.currentNode);
	}

	comments.forEach((comment) => {
		if (comment.parentNode) {
			comment.parentNode.removeChild(comment);
		}
	});

	return root.innerHTML;
}

function generateRssItem(
	nodes: ContentNode[],
	meta: ArticleMeta,
	path: string,
): string {
	const context: Map<any, any> = new Map([["isRss", true]]);
	const { body } = render(ContentRenderer, {
		props: { nodes },
		context,
	});
	const cleanHtml = cleanRssHtml(body);

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
	const posts = await getSortedArticlesRss();
	const recentPosts = posts.slice(0, 15);
	const itemsXml = recentPosts
		.map(({ nodes, meta, path }) => generateRssItem(nodes, meta, path))
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
