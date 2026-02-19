import { nodesToContentNodes, type ContentNode } from "./contentNode";

export type TocHeading = {
  nodes: ContentNode[];
  id: string;
  level: 2 | 3 | 4 | 5 | 6;
};

export function processHeaders(document: Document): TocHeading[] {
  const slugCounts = new Map<string, number>();
  const headings = document.querySelectorAll("h2, h3, h4, h5, h6");
  let toc: TocHeading[] = [];
  for (const heading of headings) {
    const text = heading.textContent || "";
    const id = uniqueSlug(slugify(text), slugCounts);
    toc.push({
      nodes: nodesToContentNodes(Array.from(heading.childNodes)),
      level: getHeadingLevel(heading.tagName),
      id,
    });

    const anchor = document.createElement("a");
    anchor.setAttribute("href", `#${id}`);
    heading.setAttribute("id", id);
    anchor.className = "anchorLink";

    heading.parentNode?.insertBefore(anchor, heading);
    anchor.appendChild(heading);
  }

  const children = Array.from(document.body.childNodes);

  let currentWrapper: HTMLElement | null = null;

  for (const node of children) {
    const isElement = node.nodeType === 1;
    const element = node as HTMLElement;

    // assumes headers are <a class="anchorLink"><h{n} id=id></h{n}></a>
    const isHeaderAnchorLink =
      isElement &&
      element.tagName == "A" &&
      element.classList.contains("anchorLink");

    const isFooter = isElement && element.tagName === "FOOTER";

    if (isFooter) {
      currentWrapper = null;
    }

    if (isHeaderAnchorLink) {
      currentWrapper = document.createElement("div");
      currentWrapper.className = "headerSection";

      let headerId = element.firstElementChild?.id;
      currentWrapper.setAttribute("data-toc-id", headerId!);

      document.body.insertBefore(currentWrapper, node);
      currentWrapper.appendChild(node);
    } else if (currentWrapper) {
      currentWrapper.appendChild(node);
    } else {
      // preamble or footer
    }
  }

  return toc;
}

function slugify(text: string): string {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^\w\-]+/g, "")
    .replace(/\-\-+/g, "-");
}

function getHeadingLevel(tagName: string): TocHeading["level"] {
  switch (tagName) {
    case "H2":
      return 2;
    case "H3":
      return 3;
    case "H4":
      return 4;
    case "H5":
      return 5;
    case "H6":
      return 6;
    default:
      return 2;
  }
}

function uniqueSlug(baseSlug: string, slugCounts: Map<string, number>): string {
  let finalSlug = baseSlug;
  if (slugCounts.has(baseSlug)) {
    const count = slugCounts.get(baseSlug)! + 1;
    slugCounts.set(baseSlug, count);
    finalSlug = `${baseSlug}-${count}`;
  } else {
    slugCounts.set(baseSlug, 0);
  }
  return finalSlug;
}
