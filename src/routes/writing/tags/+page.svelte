<script lang="ts">
  import ArticleTag from "$lib/components/ArticleTag.svelte";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();
</script>

<svelte:head>
  <title>Tags{titleSuffix}</title>
</svelte:head>

<h1>Tags</h1>
<ul>
  {#each data.tags as tag}
    <li>
      <ArticleTag name={tag}></ArticleTag>
    </li>
  {/each}
</ul>

<style>
  ul {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: var(--pad);
  }
</style>
