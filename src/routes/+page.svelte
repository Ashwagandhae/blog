<script>
  import InlineIcon from "$lib/components/InlineIcon.svelte";
  import { titleSuffix } from "$lib/title";
</script>

<svelte:head>
  <title>Home{titleSuffix}</title>
  <meta
    name="description"
    content="Julian Bauer's home on the internet. Explore my projects, read my writing, and learn about me."
  />
</svelte:head>
<h1>Home</h1>
<p>Welcome to Julian Bauer's home on the internet.</p>
<h2>Webrings</h2>
<div class="webring">
  <a class="webring-link" href="https://dan.onl/" aria-label="Left link">
    <InlineIcon name="triangleLeft" />
  </a>
  <div>Bay Leaf Webring</div>
  <a class="webring-link" href="https://kiyuri.ca/" aria-label="Right link">
    <InlineIcon name="triangleRight" />
  </a>
</div>

<style>
  a.webring-link {
    color: var(--text-weak);
    display: grid;
    width: 3ch;
    text-decoration: none;
    place-content: center;

    gap: var(--pad-small);
    max-width: 100%;
    box-sizing: border-box;
  }

  a.webring-link:hover {
    color: var(--text);
  }
  a.webring-link:active {
    color: var(--text-strong);
  }
  .webring {
    display: flex;
    align-items: center;
    flex-direction: row;
  }
</style>
