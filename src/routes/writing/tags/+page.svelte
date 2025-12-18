<script lang="ts">
  import ArticleTag from "$lib/components/ArticleTag.svelte";

  let { data } = $props();
</script>

<h1>All tags</h1>
<ul>
  {#each data.tags as tag}
    <li>
      <ArticleTag name={tag}></ArticleTag>
    </li>
  {/each}
</ul>

<style>
  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
</style>
