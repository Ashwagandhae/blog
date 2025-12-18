<script lang="ts">
  import type { Component } from "svelte";
  import type { ContentNode } from "$lib/article";
  import Self from "./ContentRenderer.svelte";

  const modules = import.meta.glob("$lib/embed/*.svelte", { eager: true });

  const COMPONENTS: Record<string, Component<any>> = {};

  for (const path in modules) {
    const fileName = path.split("/").pop()?.replace(".svelte", "") || "";

    const kebabName = fileName
      .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
      .toLowerCase();

    // @ts-ignore
    COMPONENTS[kebabName] = modules[path].default;
  }

  const imageModules = import.meta.glob(
    "/src/writing/*.{png,jpg,jpeg,webp,gif}",
    {
      eager: true,
      query: { enhanced: true },
    }
  );

  function getImageModule(filename: string) {
    for (const path in imageModules) {
      if (path.endsWith(filename)) {
        // @ts-ignore
        return imageModules[path].default;
      }
    }
    return null;
  }

  let { nodes }: { nodes: ContentNode[] } = $props();

  const VOID_ELEMENTS = new Set([
    "area",
    "base",
    "br",
    "col",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
  ]);

  function deserializeAttributes(
    attributes: Record<string, string>
  ): Record<string, any> {
    let res: Record<string, any> = {};
    for (let key of Object.keys(attributes)) {
      res[key] = JSON.parse(attributes[key]);
    }
    return res;
  }
</script>

{#each nodes as node}
  {#if node.type === "text"}
    {node.content}
  {:else if node.type === "raw"}
    {@html node.html}
  {:else if node.type === "element"}
    {@const CustomComponent = COMPONENTS[node.tag]}

    {#if CustomComponent}
      <CustomComponent {...deserializeAttributes(node.attributes)}>
        {#if node.children.length > 0}
          <Self nodes={node.children} />
        {/if}
      </CustomComponent>
    {:else if node.tag == "img"}
      {@const src = node.attributes.src}
      {@const imgModule = getImageModule(src)}
      {#if imgModule}
        <enhanced:img {...node.attributes} src={imgModule} />
      {:else}
        <img {...node.attributes} />
      {/if}
    {:else if VOID_ELEMENTS.has(node.tag)}
      <svelte:element this={node.tag} {...node.attributes} />
    {:else}
      <svelte:element this={node.tag} {...node.attributes}>
        {#if node.children.length > 0}
          <Self nodes={node.children} />
        {/if}
      </svelte:element>
    {/if}
  {/if}
{/each}
