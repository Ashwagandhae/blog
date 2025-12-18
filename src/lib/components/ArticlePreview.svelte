<script lang="ts">
  import type { ArticleMeta } from "$lib/article";
  import {
    findMatchingFrontHue,
    getPaletteContext,
    type Palette,
  } from "$lib/palette";
  import { getTagHue } from "$lib/tag";
  import ArticleMetaDisplay from "./ArticleMetaDisplay.svelte";

  let { path, meta }: { path: string; meta: ArticleMeta } = $props();

  let paletteUpdater = getPaletteContext();
  let palette: Palette | null = $derived.by(() => {
    let hue = meta.hue;
    if (hue == null) return null;
    return {
      back: hue,
      front: findMatchingFrontHue(hue),
    };
  });

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
<a
  href="/writing/{path}"
  class="articlePreview"
  onmouseover={handleHover}
  onmouseleave={handleBlur}
>
  <h2>
    {meta.title}
  </h2>
  <ArticleMetaDisplay {meta}></ArticleMetaDisplay>
  {meta.description}
</a>

<style>
  .articlePreview {
    display: flex;
    flex-direction: column;
    color: inherit;
    text-decoration: none;
    width: 100%;
    padding: var(--pad);
    background: var(--back);
    box-sizing: border-box;
    border-radius: var(--radius);
    --tag-back: var(--back-1);
    --tag-transition: opacity var(--transition-duration),
      background var(--transition-duration-slow);
    --article-tag-lightness: var(--level-2);
    transition:
      opacity var(--transition-duration),
      background var(--transition-duration-slow);
  }
  .articlePreview:hover {
    background: var(--back-1);
    --tag-back: var(--back-2);
    --article-tag-lightness: var(--level-3);

    --tag-transition: opacity var(--transition-duration),
      background var(--transition-duration);
    transition:
      opacity var(--transition-duration),
      background var(--transition-duration);
  }
  h2 {
    margin: 0;
    font-size: 1.25em;
  }
</style>
