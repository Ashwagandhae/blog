<script lang="ts">
  import type { ArticleMeta } from "$lib/article";
  import ArticleTag from "$lib/components/ArticleTag.svelte";
  import Icon from "./Icon.svelte";
  import InfoTag from "./InfoTag.svelte";
  let { meta }: { meta: ArticleMeta } = $props();

  let formattedDate = $derived(
    new Date(meta.date).toLocaleDateString("en-US", {
      timeZone: "UTC",
      month: "short",
      day: "numeric",
      year: "numeric",
    })
  );

  let readingTime = $derived(Math.ceil(meta.wordCount / 225));
</script>

<div class="metaScroll">
  <div class="meta">
    <InfoTag icon="calendar">
      <time datetime={meta.date}>{formattedDate}</time>
    </InfoTag>
    <InfoTag icon="clock">
      {readingTime} min
    </InfoTag>

    {#each meta.tags as tag}<ArticleTag name={tag} />{/each}
  </div>
</div>

<style>
  .meta {
    display: flex;
    flex-direction: row;
    gap: var(--pad);
    align-items: center;
  }
  .metaScroll {
    overflow: scroll;
  }
</style>
