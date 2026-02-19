<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import Icon from "$lib/components/Icon.svelte";
  import InlineIcon from "$lib/components/InlineIcon.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import { getTagPalette, type Palette } from "$lib/palette.js";
  import { getTagHue } from "$lib/tag";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();

  let palette: Palette | null = $derived(getTagPalette(data.tag));

  let hue = $derived(getTagHue(data.tag) ?? 0);
</script>

<svelte:head>
  <title>Writing with tag {data.tag}{titleSuffix}</title>
</svelte:head>

<PaletteDisplay {palette}></PaletteDisplay>
<h1>
  Writing with tag
  <div class="tag" style="--hue: {hue}">
    <span class="text">{data.tag}</span><a href="/writing" class="close">
      <InlineIcon name="x" />
    </a>
  </div>
</h1>
{#key data.tag}
  <ArticleList articles={data.articles}></ArticleList>
{/key}

<style>
  .tag {
    display: inline-block;

    /* background: oklch(var(--level-2) 0.08 var(--hue)); */
    border-radius: var(--radius);
    /* padding: var(--pad); */
    white-space: nowrap;
    line-height: 1;
    color: oklch(var(--text-lightness) var(--text-color-chroma) var(--hue));
  }

  .text {
    display: inline;
  }

  .close {
    display: inline-block;
    text-decoration: none;
    color: inherit;
    margin-left: var(--pad);

    vertical-align: middle;
  }
</style>
