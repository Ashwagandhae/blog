<script lang="ts">
  import ProjectTag from "$lib/components/ProjectTag.svelte";
  import { projects } from "$lib/projects";
  import { titleSuffix } from "$lib/title.js";

  const tags = Array.from(
    new Set(projects.flatMap((project) => project.tags)),
  ).toSorted();
</script>

<svelte:head>
  <title>Tags{titleSuffix}</title>
  <meta
    name="description"
    content="List of all tags for projects strewn across the garage floor of Julian Bauer's home on the internet."
  />
</svelte:head>

<h1>Project tags</h1>
<ul>
  {#each tags as tag}
    <li>
      <ProjectTag name={tag}></ProjectTag>
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
  li {
    margin: 0;
  }
</style>
