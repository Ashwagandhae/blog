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
  <link rel="icon" href={favicon} />
</svelte:head>
<div class="wrapper">
  <header>
    <nav aria-label="Main navigation">
      <a href="/" class="logo"> <ChickenLogo></ChickenLogo> </a>

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
</div>

<style>
  .wrapper {
    display: flex;
    height: 100vh;
    flex-direction: column;
  }
  main {
    padding: 0px var(--pad);

    width: 100%;
    box-sizing: border-box;
    overflow: scroll;
  }
  .content {
    margin: auto;

    max-width: 40em;
  }

  header {
    width: 100%;
    background: var(--back-gradient);
    background-attachment: fixed;
    background-size: cover;
    z-index: 9999;
  }

  header nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--pad-small);
  }

  .navLinks {
    display: flex;
    gap: var(--pad);
    list-style: none;
    margin: 0;
    padding: 0 var(--pad-big);
    align-items: center;
  }

  .logo {
    display: block;

    flex-shrink: 0;
    color: inherit;
  }
</style>
