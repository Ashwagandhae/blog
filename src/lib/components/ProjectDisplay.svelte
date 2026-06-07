<script lang="ts">
  import type { Snippet } from "svelte";
  import InfoTag from "./InfoTag.svelte";
  import TagsContainer from "./TagsContainer.svelte";
  import ProjectTag from "./ProjectTag.svelte";
  import type { Picture } from "@sveltejs/enhanced-img";

  let {
    name,
    links,
    children,
    image,
    tags,
  }: {
    name: string;
    links: Record<string, string>;
    children: Snippet;
    image?: { src: string | Picture; alt: string };
    tags: string[];
  } = $props();
  function getIcon(name: string) {
    if (name == "github") {
      return "code";
    }
    if (name == "writing") {
      return "page";
    }
    if (name == "release") {
      return "tag";
    }
    return "link";
  }
</script>

<div class="projectTitle">
  <h2>{name}</h2>
  <div class="links">
    {#each Object.entries(links) as [content, url]}
      <a href={url}>
        <InfoTag icon={getIcon(content)}>
          {content}
        </InfoTag>
      </a>
    {/each}
  </div>
</div>

{@render children()}

<div class="tagsWrapper">
  <TagsContainer>
    {#each tags as tag}
      <ProjectTag name={tag}></ProjectTag>
    {/each}
  </TagsContainer>
</div>

{#if image != null}
  <enhanced:img src={image.src} alt={image.alt}></enhanced:img>
{/if}

<style>
  .projectTitle {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
  }
  .links {
    display: flex;
    flex-direction: row;
    gap: var(--pad-big);
    align-items: center;
    width: min-content;
  }

  .links a {
    text-decoration: none;
  }

  .links a:hover,
  .links a:active {
    text-decoration: underline;
  }
  h2 {
    margin: 0;
  }
  .tagsWrapper {
    margin: var(--margin) 0;
  }
</style>
