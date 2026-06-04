<script lang="ts">
  import InfoTag from "./InfoTag.svelte";
  import { getTagHue } from "$lib/tag";

  let { name, route }: { name: string; route: string } = $props();

  let hue = $derived(getTagHue(name) ?? 0);
</script>

<a href="{route}/{name}" style="--hue: {hue}">
  <InfoTag>{name}</InfoTag>
</a>

<style>
  a {
    display: inline-block;
    color: oklch(var(--text-lightness) var(--text-color-chroma) var(--hue));
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
  a:active {
    text-decoration: underline;
  }
</style>
