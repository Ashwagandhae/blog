<script lang="ts">
  import { getTagHue } from "$lib/tag";
  import InlineIcon from "$lib/components/InlineIcon.svelte";
  let { tag, backLink }: { tag: string; backLink: string } = $props();
  let hue = $derived(getTagHue(tag) ?? 0);
</script>

<div class="tag" style="--hue: {hue}">
  <span class="text">{tag}</span><a href={backLink} class="close">
    <InlineIcon name="x" />
  </a>
</div>

<style>
  .tag {
    display: inline-block;
    border-radius: var(--radius);
    white-space: nowrap;
    line-height: 1;
    color: oklch(var(--text-lightness) var(--text-color-chroma) var(--hue));
  }

  .text {
    display: inline;
  }

  .close {
    display: inline-block;
    text-decoration: none;
    color: inherit;
    margin-left: var(--pad);

    vertical-align: middle;
  }
</style>
