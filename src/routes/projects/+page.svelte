<script lang="ts">
  import { titleSuffix } from "$lib/title";
  import ProjectsDisplay from "$lib/components/ProjectsDisplay.svelte";
</script>

<svelte:head>
  <title>Projects{titleSuffix}</title>
  <meta
    name="description"
    content="Projects strewn across the garage floor of Julian Bauer's home on the internet."
  />
</svelte:head>

<h1>Projects</h1>
<ProjectsDisplay filter={() => true}></ProjectsDisplay>
