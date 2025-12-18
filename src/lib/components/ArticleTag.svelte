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
    color: inherit;
    text-decoration: none;
    --tag-back: oklch(var(--article-tag-lightness) 0.08 var(--hue));
  }
  a:hover {
    text-decoration: underline;
  }
</style>
