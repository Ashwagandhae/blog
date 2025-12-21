import type { Component } from "svelte";

export const embedComponents: Record<string, Component<any>> = getComponents();

function getComponents() {
  let res = {};
  const modules = import.meta.glob("$lib/embed/*.svelte", { eager: true });
  for (const path in modules) {
    const fileName = path.split("/").pop()?.replace(".svelte", "") || "";

    const kebabName = fileName
      .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
      .toLowerCase();

    // @ts-ignore
    res[kebabName] = modules[path].default;
  }
  return res;
}
