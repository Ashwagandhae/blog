<script lang="ts">
  import ArticleMeta from "$lib/components/ArticleMetaDisplay.svelte";
  import ContentRenderer from "$lib/components/ContentRenderer.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import { findMatchingFrontHue, type Palette } from "$lib/palette.js";
  let { data } = $props();

  let palette: Palette | null = $derived.by(() => {
    let hue = data.meta.hue;
    if (hue == null) return null;
    return {
      back: hue,
      front: findMatchingFrontHue(hue),
    };
  });
</script>

<PaletteDisplay {palette}></PaletteDisplay>

<svelte:head>
  <title>{data.meta.title}</title>
  <meta name="description" content={data.meta.description} />
  <meta property="article:published_time" content={data.meta.date} />
  {#each data.meta.tags as tag}
    <meta property="article:tag" content={tag} />
  {/each}
</svelte:head>

<article>
  <h1>{data.meta.title}</h1>
  <ArticleMeta meta={data.meta}></ArticleMeta>
  <ContentRenderer nodes={data.content}></ContentRenderer>
</article>

<style>
</style>
