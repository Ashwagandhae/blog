<script lang="ts">
  import type { ComponentProps } from "svelte";
  import ArticlePreview from "./ArticlePreview.svelte";
  import type { ArticleMeta } from "$lib/article";

  let {
    articles,
  }: {
    articles: { path: string; meta: ArticleMeta }[];
  } = $props();
</script>

<ul>
  {#each articles as article}
    <li>
      <ArticlePreview {...article}></ArticlePreview>
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
    gap: 2em;
  }
</style>
