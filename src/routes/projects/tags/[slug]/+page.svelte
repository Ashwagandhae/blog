<script lang="ts">
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import ProjectsDisplay from "$lib/components/ProjectsDisplay.svelte";
  import WithTagHeading from "$lib/components/WithTagHeading.svelte";
  import { getTagPalette, type Palette } from "$lib/palette.js";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();

  let palette: Palette | null = $derived(getTagPalette(data.tag));
</script>

<svelte:head>
  <title>Projects with tag {data.tag}{titleSuffix}</title>
  <meta
    name="description"
    content="Projects tagged with '{data.tag}' strewn across the garage floor of Julian Bauer's home on the internet."
  />
</svelte:head>

<PaletteDisplay {palette}></PaletteDisplay>
<h1>
  Projects with tag
  <WithTagHeading tag={data.tag} backLink="/projects" />
</h1>
{#key data.tag}
  <ProjectsDisplay filter={(project) => project.tags.includes(data.tag)} />
{/key}
