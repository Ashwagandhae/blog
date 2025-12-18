<script lang="ts">
  import ArticleList from "$lib/components/ArticleList.svelte";
  import ArticlePreview from "$lib/components/ArticlePreview.svelte";

  let { data } = $props();
</script>

<h1>All articles</h1>

<ArticleList articles={data.articles}></ArticleList>
