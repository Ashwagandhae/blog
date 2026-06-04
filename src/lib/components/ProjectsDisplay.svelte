<script lang="ts">
  import ProjectDisplay from "./ProjectDisplay.svelte";
  import { projects, type Project } from "$lib/projects";
  let { filter }: { filter: (project: Project) => boolean } = $props();

  const images = import.meta.glob("$lib/assets/*", {
    eager: true,
    import: "default",
  }) as Record<string, string>;
</script>

<ul>
  {#each projects.filter(filter) as project (project.name)}
    <li>
      <ProjectDisplay
        name={project.name}
        links={project.links}
        tags={project.tags}
        image={project.image
          ? {
              src: images[`/src/lib/assets/${project.image.src}`],
              alt: project.image.alt,
            }
          : undefined}
      >
        {@html project.description}
      </ProjectDisplay>
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
  li {
    margin: 0;
  }
</style>
