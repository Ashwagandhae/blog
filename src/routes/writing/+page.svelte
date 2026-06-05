<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import InfoTag from "$lib/components/InfoTag.svelte";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();
</script>

<svelte:head>
  <title>Writing{titleSuffix}</title>
  <meta
    name="description"
    content="Technical writing and deep dives in the library of Julian Bauer's home on the internet, covering Rust, Typst, and other interests."
  />
</svelte:head>

<div class="title">
  <h1>Writing</h1>
  <a href="/writing/tags"><InfoTag icon="tag">all tags</InfoTag></a>
</div>

<ArticleList articles={data.articles}></ArticleList>

<style>
  .title {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
  }

  .title a {
    text-decoration: none;
  }

  .title a:hover,
  .title a:active {
    text-decoration: underline;
  }
</style>
