<script>
  import InlineIcon from "$lib/components/InlineIcon.svelte";
  import Webring from "$lib/components/Webring.svelte";
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
<div class="webrings">
  <Webring left="https://dan.onl/" right="https://kiyuri.ca/"
    >Bay Leaf Webring</Webring
  >
  <Webring
    left="https://www.romanreddick.com/"
    right="https://henrygustafson.com/">Gimkit Webring</Webring
  >
</div>

<style>
  .webrings {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
  }
</style>
