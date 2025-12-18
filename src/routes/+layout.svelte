<script lang="ts">
  import "@fontsource-variable/atkinson-hyperlegible-next";
  import "@fontsource-variable/atkinson-hyperlegible-next/wght-italic.css";
  import "@fontsource-variable/jetbrains-mono";
  import "$lib/global.css";
  import "$lib/article.css";

  import { invalidateAll } from "$app/navigation";
  import favicon from "$lib/assets/chicken.svg";
  import NavItem from "$lib/components/NavItem.svelte";
  import ChickenLogo from "$lib/components/ChickenLogo.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import {
    defaultPalette,
    setPaletteContext,
    type Palette,
    type PaletteLayers,
  } from "$lib/palette";
  import { setContext } from "svelte";

  let { children } = $props();

  if (import.meta.hot) {
    import.meta.hot.on("content-update", () => {
      invalidateAll();
    });
  }

  let paletteLayers: PaletteLayers = $state({
    page: null,
    active: null,
  });

  setPaletteContext((updater) => {
    paletteLayers = updater(paletteLayers);
  });
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>
<header class="siteHeader">
  <nav aria-label="Main navigation">
    <a href="/" class="logo"> <ChickenLogo></ChickenLogo> </a>

    <ul class="navLinks">
      <li><NavItem href="/about">About</NavItem></li>
      <li><NavItem href="/writing">Writing</NavItem></li>
    </ul>
  </nav>
</header>
<main>
  {@render children()}
</main>
<PaletteDisplay palette={paletteLayers.active}></PaletteDisplay>

<style>
  main {
    padding: 0px 8px;
    max-width: 40em;

    margin: auto;
  }

  .siteHeader nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--pad);
  }

  .navLinks {
    display: flex;
    gap: 1.5rem;
    list-style: none;
    margin: 0;
    padding: 0 var(--pad-big);
  }

  .logo {
    font-weight: bold;
    text-decoration: none;
    font-size: 1.25rem;
  }
</style>
