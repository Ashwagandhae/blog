<script lang="ts">
  import { titleSuffix } from "$lib/title";
  import ProjectsDisplay from "$lib/components/ProjectsDisplay.svelte";
  import InfoTag from "$lib/components/InfoTag.svelte";
</script>

<svelte:head>
  <title>Projects{titleSuffix}</title>
  <meta
    name="description"
    content="Projects strewn across the garage floor of Julian Bauer's home on the internet."
  />
</svelte:head>
<div class="title">
  <h1>Projects</h1>
  <a href="/projects/tags"><InfoTag icon="tag">all tags</InfoTag></a>
</div>
<ProjectsDisplay filter={() => true}></ProjectsDisplay>

<style>
  .title {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
  }

  .title a {
    text-decoration: none;
  }

  .title a:hover,
  .title a:active {
    text-decoration: underline;
  }
</style>
