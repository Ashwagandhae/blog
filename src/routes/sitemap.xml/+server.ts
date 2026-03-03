import { loadArticlesHtml } from "$lib/article";

export const GET = async () => {
  const articles = await loadArticlesHtml();

  const pages: { path: string; priority: number }[] = [
    { path: "", priority: 1.0 },
    { path: "/about", priority: 0.7 },
    { path: "/about/contact", priority: 0.5 },
    { path: "/writing", priority: 0.7 },
    ...articles
      .filter(({ path }) => path != "test")
      .map(({ path }) => {
        return { path: "/writing/" + path, priority: 0.7 };
      }),
  ];

  const siteUrl = "https://julianlbauer.com";

  const sitemap = `<?xml version="1.0" encoding="UTF-8" ?>
    <urlset
      xmlns="https://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xhtml="https://www.w3.org/1999/xhtml"
    >
      ${pages
        .map(
          (page) => `
        <url>
          <loc>${siteUrl}${page.path}</loc>
          <priority>${page.priority}</priority>
        </url>
      `,
        )
        .join("")}
    </urlset>`.trim();

  return new Response(sitemap, {
    headers: {
      "Content-Type": "application/xml",
      "Cache-Control": "max-age=0, s-maxage=3600",
    },
  });
};

export const prerender = true;
