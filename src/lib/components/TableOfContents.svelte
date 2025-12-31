<script lang="ts">
  import type { ArticleContent } from "$lib/article";
  import { onDestroy, onMount } from "svelte";
  import ContentRenderer from "./ContentRenderer.svelte";

  let {
    toc,
  }: {
    toc: ArticleContent["toc"];
  } = $props();

  let activeId = $state("");

  let element: HTMLElement | null = $state(null);

  onMount(() => {
    if (element == null) return;
    const headers = Array.from(
      element.parentElement!.querySelectorAll?.("h2, h3, h4, h5, h6")
    );

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            activeId = entry.target.id;
          }
        });
      },
      {
        rootMargin: "58px 0px -80% 0px",
      }
    );

    headers.forEach((h) => observer.observe(h));

    onDestroy(() => observer.disconnect());
  });
</script>

<aside class="tocWrapper" bind:this={element}>
  <nav class="toc">
    <ul>
      {#each toc as heading}
        <li
          class="tocItem"
          style="--heading-level: {heading.level}"
          class:active={activeId == heading.id}
        >
          <a href="#{heading.id}">
            <ContentRenderer nodes={heading.nodes}></ContentRenderer>
          </a>
        </li>
      {/each}
    </ul>
  </nav>
</aside>

<style>
  .tocWrapper {
    position: absolute;
    right: 100%;
    top: 0;

    height: 100%;

    display: none;
  }

  .toc {
    font-size: var(--font-size-small);
    position: sticky;
    top: calc(var(--header-height));
    width: calc((100vw - var(--content-width)) / 2);
    overflow-y: auto;
    max-width: 12rem;
    box-sizing: border-box;
    padding: 0 var(--pad);
    overflow: scroll;
    height: calc(100vh - var(--header-height));
  }

  .toc ul {
    margin: 0;
    list-style: none;
    padding: 0;
  }

  .tocItem {
    color: var(--text);
    opacity: 0.75;
    padding-left: calc((var(--heading-level) - 2) * var(--pad-big));
  }

  .tocItem.active {
    opacity: 1;
    font-weight: bold;
  }

  .tocItem a {
    color: inherit;
    text-decoration: none;
    display: block;
    width: 100%;
  }
  .tocItem a:hover {
    text-decoration: underline;
  }

  @media (min-width: 1000px) {
    .tocWrapper {
      display: block;
    }
  }
</style>
