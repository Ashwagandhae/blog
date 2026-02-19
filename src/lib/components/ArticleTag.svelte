<script lang="ts">
  import InfoTag from "./InfoTag.svelte";
  import { getTagHue } from "$lib/tag";

  let { name }: { name: string } = $props();

  let hue = $derived(getTagHue(name) ?? 0);
</script>

<a href="/writing/tags/{name}" style="--hue: {hue}">
  <InfoTag>{name}</InfoTag>
</a>

<style>
  a {
    display: inline-block;
    color: oklch(var(--text-lightness) var(--text-color-chroma) var(--hue));
    text-decoration: none;
    /* --tag-back: oklch(var(--article-tag-lightness) 0.08 var(--hue)); */
    --tag-back: none;
  }
  a:hover {
    text-decoration: underline;
    --tag-back: oklch(var(--article-tag-lightness-hover) 0.08 var(--hue));
    --tag-transition: background var(--transition-duration);
    --tag-back: none;
  }
  a:active {
    text-decoration: underline;
    --tag-back: oklch(var(--article-tag-lightness-active) 0.08 var(--hue));
    --tag-transition: background var(--transition-duration);
    --tag-back: none;
  }
</style>
