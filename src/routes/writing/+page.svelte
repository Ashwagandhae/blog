<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import ArticlePreview from "$lib/components/ArticlePreview.svelte";
  import { titleSuffix } from "$lib/title.js";

  let { data } = $props();
</script>

<svelte:head>
  <title>Writing{titleSuffix}</title>
</svelte:head>

<h1>Writing</h1>

<ArticleList articles={data.articles}></ArticleList>
