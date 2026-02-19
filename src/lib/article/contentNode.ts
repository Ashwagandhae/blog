import { embedComponents } from "$lib/embed";

const customTags = new Set(Object.keys(embedComponents));

export type ContentNode =
  | {
      type: "element";
      tag: string;
      attributes: Record<string, string>;
      children: ContentNode[];
    }
  | { type: "raw"; html: string };

function getAttributes(element: Element): Record<string, string> {
  const attributes: Record<string, string> = {};
  if (element.attributes) {
    Array.from(element.attributes).forEach((attr) => {
      attributes[attr.name] = attr.value;
    });
  }
  return attributes;
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function containsCustomTag(element: Element): boolean {
  const selector = Array.from(customTags).join(",");
  if (!selector) return false;
  return element.querySelector(selector) !== null;
}

export function nodesToContentNodes(nodes: Node[]): ContentNode[] {
  const result: ContentNode[] = [];

  function pushRaw(html: string) {
    if (result.length > 0 && result[result.length - 1].type === "raw") {
      (result[result.length - 1] as { type: "raw"; html: string }).html += html;
    } else {
      result.push({ type: "raw", html });
    }
  }

  for (const node of nodes) {
    if (node.nodeType === 3) {
      const text = node.textContent || "";
      pushRaw(escapeHtml(text));
      continue;
    }

    if (node.nodeType === 1) {
      const element = node as Element;
      const tagName = element.tagName.toLowerCase();

      if (tagName === "svg") {
        pushRaw(element.outerHTML);
        continue;
      }

      if (customTags.has(tagName)) {
        result.push({
          type: "element",
          tag: tagName,
          attributes: getAttributes(element),
          children: nodesToContentNodes(Array.from(element.childNodes)),
        });
        continue;
      }

      if (!containsCustomTag(element)) {
        pushRaw(element.outerHTML);
        continue;
      }

      result.push({
        type: "element",
        tag: tagName,
        attributes: getAttributes(element),
        children: nodesToContentNodes(Array.from(element.childNodes)),
      });
    }
  }

  return result;
}
