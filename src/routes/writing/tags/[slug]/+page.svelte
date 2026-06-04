<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import WithTagHeading from "$lib/components/WithTagHeading.svelte";
  import { getTagPalette, type Palette } from "$lib/palette.js";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();

  let palette: Palette | null = $derived(getTagPalette(data.tag));
</script>

<svelte:head>
  <title>Writing with tag {data.tag}{titleSuffix}</title>
  <meta
    name="description"
    content="Writing tagged with '{data.tag}' in the library of Julian Bauer's home on the internet."
  />
</svelte:head>

<PaletteDisplay {palette}></PaletteDisplay>
<h1>
  Writing with tag
  <WithTagHeading tag={data.tag} backLink="/writing" />
</h1>
{#key data.tag}
  <ArticleList articles={data.articles}></ArticleList>
{/key}
