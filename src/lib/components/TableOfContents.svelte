<script lang="ts">
  import type { ArticleContent } from "$lib/article";
  import { onDestroy, onMount } from "svelte";
  import ContentRenderer from "./ContentRenderer.svelte";
  import { SvelteSet } from "svelte/reactivity";

  let {
    toc,
  }: {
    toc: ArticleContent["toc"];
  } = $props();

  let activeIds: SvelteSet<string> = $state(new SvelteSet());
  let topActiveId: string | undefined = $derived(
    toc.map((h) => h.id).find((id) => activeIds.has(id)),
  );

  let element: HTMLElement | null = $state(null);
  let sentinelElement: HTMLElement | null = $state(null);
  let isStuck: boolean = $state(false);
  let noTransition: boolean = $state(true);

  onMount(() => {
    if (element == null || sentinelElement == null) return;

    const sections = Array.from(
      element.parentElement!.querySelectorAll(".headerSection"),
    );

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          const id = entry.target.getAttribute("data-toc-id");
          if (id == null) continue;
          if (entry.isIntersecting) {
            activeIds.add(id);
          } else {
            activeIds.delete(id);
          }
          activeIds = activeIds;
        }
      },
      {
        rootMargin: "-58px 0px 0px 0px",
      },
    );

    sections.forEach((s) => observer.observe(s));
    isStuck = false;

    const tocStickyObserver = new IntersectionObserver(
      (entries) => {
        if (!entries[0].isIntersecting) {
          isStuck = true;
        } else {
          isStuck = false;
        }
      },
      {
        rootMargin: "0px 0px 0px 0px",
        threshold: [0],
      },
    );
    tocStickyObserver.observe(sentinelElement);

    requestAnimationFrame(() => {
      setTimeout(() => {
        noTransition = false;
      }, 100);
    });

    return () => observer.disconnect();
  });

  $effect(() => {
    console.log(activeIds);
  });
</script>

<aside class="tocWrapper" bind:this={element}>
  <div class="stickySentinel" bind:this={sentinelElement}></div>
  <nav class="toc" class:isStuck class:noTransition>
    <ul>
      {#each toc as heading}
        <li
          class="tocItem"
          style="--heading-level: {heading.level}"
          class:active={heading.id == topActiveId}
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
    top: 0;
    width: calc((100vw - var(--content-width)) / 2);
    overflow-y: auto;
    max-width: 12rem;
    box-sizing: border-box;
    padding: 0 var(--pad-big);
    padding-top: var(--pad-big);
    overflow: scroll;
    max-height: calc(100vh);
  }

  .stickySentinel {
    height: 0;
    width: 0;
    visibility: hidden;
  }
  /* @supports (container-type: scroll-state) {
    .toc {
      container-type: scroll-state;
    }
    .toc ul {
      opacity: 0;
      transition: opacity var(--transition-duration-slow);
    }
    @container scroll-state(stuck: top) {
      .toc ul {
        opacity: 1;
      }
    }
  } */

  .toc ul {
    opacity: 0;
    transition: opacity var(--transition-duration-slow);
  }
  .toc.noTransition ul {
    transition: opacity 0s;
  }
  .toc.isStuck ul {
    opacity: 1;
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
    /* font-weight: bold; */
    text-decoration: underline;
  }

  .tocItem a {
    color: inherit;
    text-decoration: none;
    display: block;
    width: 100%;
    line-height: 1.6;
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
