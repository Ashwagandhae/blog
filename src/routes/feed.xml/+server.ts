import { render } from "svelte/server";
import ContentRenderer from "#lib/components/ContentRenderer.svelte";
import { getSortedArticlesRss, type ArticleMeta } from "#lib/article.ts";
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
		svg.removeAttribute("style");
		const bg = document.createElement("rect");
		bg.setAttribute("width", "100%");
		bg.setAttribute("height", "100%");
		bg.setAttribute("fill", "#1a1a1a");
		svg.insertBefore(bg, svg.firstChild);

		svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");
		if (!svg.hasAttribute("xmlns:xlink")) {
			svg.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
		}

		const dataUri = `data:image/svg+xml,${encodeURIComponent(svg.outerHTML)}`;
		const img = document.createElement("img");
		img.setAttribute("src", dataUri);

		if (svg.getAttribute("aria-label")) {
			img.setAttribute("alt", svg.getAttribute("aria-label") || "Data Plot");
		}

		svg.parentNode?.insertBefore(img, svg);
		svg.remove();
	});

	root.querySelectorAll("a[href], img[src]").forEach((node) => {
		const attr = node.tagName === "A" ? "href" : "src";
		const val = node.getAttribute(attr);

		// Keep hash links intact
		if (val && val.startsWith("#")) return;

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

function generateAtomEntry(
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
	const permalink = `${SITE_URL}/writing/${path}`;

	// Atom strictly requires ISO 8601 formatting
	const isoDate = new Date(meta.date).toISOString();

	return `
    <entry>
      <title><![CDATA[${meta.title}]]></title>
      <link href="${permalink}" />
      <id>${permalink}</id>
      <published>${isoDate}</published>
      <updated>${isoDate}</updated>
      <summary><![CDATA[${meta.description}]]></summary>
      <content type="html"><![CDATA[${cleanHtml}]]></content>
    </entry>
  `;
}

export async function GET() {
	const posts = await getSortedArticlesRss();
	const recentPosts = posts.slice(0, 15);
	const entriesXml = recentPosts
		.map(({ nodes, meta, path }) => generateAtomEntry(nodes, meta, path))
		.join("");

	const lastUpdated =
		recentPosts.length > 0
			? new Date(recentPosts[0].meta.date).toISOString()
			: new Date().toISOString();

	const xml = `<?xml version="1.0" encoding="UTF-8" ?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>${SITE_TITLE}</title>
      <subtitle>${SITE_DESC}</subtitle>
      <link href="${SITE_URL}/atom.xml" rel="self" />
      <link href="${SITE_URL}" />
      <id>${SITE_URL}/</id>
      <updated>${lastUpdated}</updated>
      <author>
        <name>Julian Bauer</name>
      </author>
      ${entriesXml}
    </feed>`.trim();

	return new Response(xml, {
		headers: {
			"Content-Type": "application/atom+xml",
			"Cache-Control": "max-age=0, s-maxage=3600",
		},
	});
}
