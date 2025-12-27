<script lang="ts">
  import type { ArticleMeta } from "$lib/article";
  import {
    findMatchingFrontHue,
    getArticlePalette,
    getPaletteContext,
    type Palette,
  } from "$lib/palette";
  import { getTagHue } from "$lib/tag";
  import ArticleMetaDisplay from "./ArticleMetaDisplay.svelte";

  let { path, meta }: { path: string; meta: ArticleMeta } = $props();

  let paletteUpdater = getPaletteContext();
  let palette: Palette | null = $derived(getArticlePalette(meta));

  function handleHover() {
    paletteUpdater((layers) => {
      layers.active = palette;
      return layers;
    });
  }

  function handleBlur() {
    paletteUpdater((layers) => {
      layers.active = null;
      return layers;
    });
  }
</script>

<!-- svelte-ignore a11y_mouse_events_have_key_events -->
<div
  class="articlePreview"
  role="group"
  onmouseenter={handleHover}
  onmouseleave={handleBlur}
>
  <h2>
    <a href="/writing/{path}" class="mainLink">
      {meta.title}
    </a>
  </h2>

  <div class="metaWrapper">
    <ArticleMetaDisplay {meta} />
  </div>

  {meta.description}
</div>

<style>
  .articlePreview {
    position: relative;

    display: flex;
    flex-direction: column;
    color: inherit;
    width: 100%;
    padding: var(--pad);
    box-sizing: border-box;
    border-radius: var(--radius);
    flex: 1;
    flex-basis: 0;
    min-width: 0;

    --tag-back: var(--transparent-back);
    --article-tag-lightness: var(--level-2);
    --article-tag-lightness-hover: var(--level-3);
    --article-tag-lightness-active: var(--level-4);
    --tag-transition: background var(--transition-duration-slow);
    transition: background var(--transition-duration-slow);
  }

  .articlePreview:has(.mainLink:hover) {
    background: var(--transparent-back);
    --article-tag-lightness: var(--level-3);
    --article-tag-lightness-hover: var(--level-4);
    --article-tag-lightness-active: var(--level-5);
    --tag-transition: background var(--transition-duration);
    transition: background var(--transition-duration);
  }

  .articlePreview:has(.mainLink:active) {
    background: var(--transparent-back-1);
    --article-tag-lightness: var(--level-4);
    --article-tag-lightness-hover: var(--level-5);
    --article-tag-lightness-active: var(--level-6);
    --tag-transition: background var(--transition-duration);
    transition: background var(--transition-duration);
  }

  h2 {
    margin: 0;
    font-size: 1.25em;
  }

  .mainLink {
    text-decoration: none;
    color: inherit;
  }

  .mainLink::after {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 1;
  }

  .metaWrapper {
    position: relative;
    z-index: 2;
    width: 100%;
    pointer-events: none;
  }
</style>
