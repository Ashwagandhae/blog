<script lang="ts">
  import type { ArticleMeta } from "$lib/article";
  import {
    getArticlePalette,
    getPaletteContext,
    type Palette,
  } from "$lib/palette";
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

  <ArticleMetaDisplay {meta} />

  <p>{meta.description}</p>
</div>

<style>
  .articlePreview {
    position: relative;

    display: flex;
    flex-direction: column;
    color: inherit;
    width: 100%;
    /* padding: var(--pad); */
    box-sizing: border-box;
    border-radius: var(--radius);
    flex: 1;
    flex-basis: 0;
    min-width: 0;
    gap: var(--pad);

    --tag-back: var(--transparent-back);
    --article-tag-lightness: var(--level-2);
    --article-tag-lightness-hover: var(--level-3);
    --article-tag-lightness-active: var(--level-4);
    --tag-transition: background var(--transition-duration-slow);
    transition: background var(--transition-duration-slow);
  }

  h2,
  p {
    margin: 0;
  }

  .mainLink {
    text-decoration: none;
    color: inherit;
    display: block;
    width: 100%;
  }

  .mainLink:hover {
    text-decoration: underline;
  }
</style>
