<script lang="ts">
  import type { ContentNode } from "$lib/article/contentNode";
  import { embedComponents } from "$lib/embed";
  import Self from "./ContentRenderer.svelte";

  let { nodes }: { nodes: ContentNode[] } = $props();

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
  {#if node.type === "raw"}
    {@html node.html}
  {:else if node.type === "element"}
    {@const CustomComponent = embedComponents[node.tag]}
    {#if CustomComponent}
      <CustomComponent {...deserializeAttributes(node.attributes)}>
        {#if node.children.length > 0}
          <Self nodes={node.children} />
        {/if}
      </CustomComponent>
    {:else}
      <svelte:element this={node.tag} {...node.attributes}>
        {#if node.children.length > 0}
          <Self nodes={node.children} />
        {/if}
      </svelte:element>
    {/if}
  {/if}
{/each}
