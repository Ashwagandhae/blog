<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import {
    findMatchingFrontHue,
    getPaletteContext,
    type Palette,
  } from "$lib/palette.js";
  import { getTagHue } from "$lib/tag.js";

  let { data } = $props();
  let updateLayers = getPaletteContext();

  let palette: Palette | null = $derived.by(() => {
    let tagHue = getTagHue(data.tag);
    if (tagHue == null) return null;
    return {
      back: tagHue,
      front: findMatchingFrontHue(tagHue),
    };
  });
</script>

<PaletteDisplay {palette}></PaletteDisplay>
<h1>Articles with tag <span class="tag">{data.tag}</span></h1>
{#key data.tag}
  <ArticleList articles={data.articles}></ArticleList>
{/key}

<style>
  .tag {
    background: var(--back-1);
    border-radius: var(--radius);
    padding: 0 var(--pad);
  }
</style>
