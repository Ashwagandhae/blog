<script lang="ts">
  import type { ArticleMeta } from "$lib/article";
  import ArticleTag from "$lib/components/ArticleTag.svelte";
  import InfoTag from "./InfoTag.svelte";
  import TagsContainer from "./TagsContainer.svelte";
  let { meta }: { meta: ArticleMeta } = $props();

  let formattedDate = $derived(
    new Date(meta.date).toLocaleDateString("en-US", {
      timeZone: "UTC",
      month: "short",
      day: "numeric",
      year: "numeric",
    }),
  );

  let readingTime = $derived(Math.ceil(meta.wordCount / 225));
</script>

<TagsContainer>
  <InfoTag icon="calendar">
    <time datetime={meta.date}>{formattedDate}</time>
  </InfoTag>
  <InfoTag icon="clock">
    {readingTime} min
  </InfoTag>
  {#each meta.tags as tag}<ArticleTag name={tag} />{/each}
</TagsContainer>
