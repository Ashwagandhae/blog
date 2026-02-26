<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
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

<h1>Writing</h1>

<ArticleList articles={data.articles}></ArticleList>
