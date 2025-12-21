<script lang="ts">
  import ArticleMeta from "$lib/components/ArticleMetaDisplay.svelte";
  import ContentRenderer from "$lib/components/ContentRenderer.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import {
    findMatchingFrontHue,
    getArticlePalette,
    type Palette,
  } from "$lib/palette.js";
  import { titleSuffix } from "$lib/title.js";
  let { data } = $props();

  let palette: Palette | null = $derived(getArticlePalette(data.meta));
</script>

<svelte:head>
  <title>{data.meta.title}{titleSuffix}</title>
  <meta name="description" content={data.meta.description} />
  <meta property="article:published_time" content={data.meta.date} />
  {#each data.meta.tags as tag}
    <meta property="article:tag" content={tag} />
  {/each}
</svelte:head>

<PaletteDisplay {palette}></PaletteDisplay>

<article>
  <h1>{data.meta.title}</h1>
  <ArticleMeta meta={data.meta}></ArticleMeta>
  <ContentRenderer nodes={data.content}></ContentRenderer>
</article>

<style>
</style>
