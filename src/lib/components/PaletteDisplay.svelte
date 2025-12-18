<script lang="ts">
  import type { Palette } from "$lib/palette";

  let { palette }: { palette: Palette | null } = $props();

  let bodyStyle: string | null = $derived.by(() => {
    if (palette == null) return null;
    return `body { --hue-back: ${palette.back}; --hue-front: ${palette.front} }`;
  });
</script>

<svelte:head>
  {#if bodyStyle != null}
    <svelte:element this={"style"}>{bodyStyle}</svelte:element>
  {/if}
</svelte:head>
