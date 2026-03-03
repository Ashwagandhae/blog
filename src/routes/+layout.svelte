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
  import { setPaletteContext, type PaletteLayers } from "$lib/palette";

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
  <link rel="icon" href={favicon} type="image/svg+xml" sizes="any" />

  <link rel="icon" href="/favicon.svg" type="image/svg+xml" sizes="any" />

  <link rel="icon" type="image/png" sizes="96x96" href="/favicon-96x96.png" />

  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
  <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />

  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />

  <link rel="manifest" href="/site.webmanifest" />

  <link rel="shortcut icon" href="/favicon.ico" />
</svelte:head>
<header>
  <nav aria-label="Main navigation">
    <a href="/" class="logo" aria-label="Home"> <ChickenLogo></ChickenLogo> </a>

    <ul class="navLinks">
      <li><NavItem href="/about" icon="person">about</NavItem></li>
      <li><NavItem href="/writing" icon="pen">writing</NavItem></li>
    </ul>
  </nav>
</header>
<main>
  <div class="content">
    {@render children()}
  </div>
</main>

<style>
  header {
    /* position: fixed; */
    top: 0;

    width: 100%;

    z-index: 100;

    /* background: var(--back-gradient); */
  }

  main {
    width: 100%;
    box-sizing: border-box;
    padding: 0 var(--pad);
    margin: auto;

    padding-bottom: calc(100vh - var(--logo-size) - 2lh);
  }

  .content {
    max-width: var(--content-width);
    margin: auto;
    box-sizing: border-box;
  }

  header nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--pad-big);
    /* max-width: calc(40rem + var(--logo-size)); */
    margin: auto;
  }

  .navLinks {
    display: flex;
    gap: var(--pad);
    list-style: none;
    margin: 0;
    padding: 0 var(--pad-small);
    align-items: center;
  }

  .logo {
    display: block;

    flex-shrink: 0;
    color: inherit;
  }
</style>
