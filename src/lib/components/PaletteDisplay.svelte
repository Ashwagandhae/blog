<script lang="ts">
  import type { Palette } from "$lib/palette";

  let { palette }: { palette: Palette | null } = $props();

  let bodyStyle: string | null = $derived.by(() => {
    if (palette == null) return null;

    let front = palette[0];
    let back = palette[palette.length - 1];

    // let gradientColors = palette.map(
    //   (hue) => `oklch(var(--level-1) var(--back-chroma) ${hue})`
    // );
    // let backGradient = `radial-gradient(at 0% 0%, ${gradientColors.join(", ")})`;

    return `body {
      --hue-back: ${back};
      --hue-front: ${front};
    }`;
  });
</script>

{#if bodyStyle != null}
  <svelte:element this={"style"}>{bodyStyle}</svelte:element>
{/if}
