<script lang="ts">
  import ArticleMeta from "$lib/components/ArticleMetaDisplay.svelte";
  import ContentRenderer from "$lib/components/ContentRenderer.svelte";
  import InlineIcon from "$lib/components/InlineIcon.svelte";
  import PaletteDisplay from "$lib/components/PaletteDisplay.svelte";
  import TableOfContents from "$lib/components/TableOfContents.svelte";
  import { getArticlePalette, type Palette } from "$lib/palette.js";
  import { titleSuffix } from "$lib/title.js";
  let { data } = $props();

  let palette: Palette | null = $derived(getArticlePalette(data.meta));
</script>

<svelte:head>
  <title>{data.meta.title}{titleSuffix}</title>
  <meta name="description" content={data.meta.description} />
  <meta property="article:published_time" content={data.meta.date} />
  {#each data.meta.tags as tag}
    <meta property="article:tag" content={tag} />
  {/each}
</svelte:head>

<PaletteDisplay {palette}></PaletteDisplay>

<article>
  <h1>{data.meta.title}</h1>
  <div class="meta">
    <ArticleMeta meta={data.meta}></ArticleMeta>
  </div>

  <div class="contentBody">
    {#key data.path}
      <TableOfContents toc={data.content.toc} />
    {/key}
    <ContentRenderer nodes={data.content.nodes}></ContentRenderer>
  </div>
</article>
<div class="nav">
  <div class="linkContainer">
    <a href="/writing/{data.next.path}">
      <InlineIcon name="triangleLeft" />
      <span class="text">{data.next.meta.title}</span>
    </a>
  </div>
  <div class="linkContainer bottom">
    <a href="/writing/{data.previous.path}">
      <span class="text">{data.previous.meta.title}</span>
      <InlineIcon name="triangleRight" />
    </a>
  </div>
</div>

<style>
  article {
    position: relative;
  }
  div.meta {
    padding-bottom: 2.5rem;
  }
  h1 {
    margin-bottom: 0.4em;
  }
  .contentBody {
    position: relative;
  }

  .nav {
    display: flex;
    flex: 1fr 1fr;
    flex-direction: row;
    flex-wrap: wrap;
    gap: var(--pad);
    width: 100%;
    justify-content: space-between;
    box-sizing: border-box;
  }

  .linkContainer {
    flex-grow: 1;
    display: flex;
    justify-content: start;

    min-width: 0;
    box-sizing: border-box;
  }

  .linkContainer a {
    color: var(--text);
    text-decoration: none;
  }

  .linkContainer :is(a:hover, a:active) {
    text-decoration: underline;
  }

  .linkContainer.bottom {
    justify-content: end;
  }

  .nav a {
    display: flex;
    align-items: center;
    text-align: center;

    gap: var(--pad-small);
    max-width: 100%;
    box-sizing: border-box;
  }

  .text {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;

    min-width: 0;
    flex: 0 1 auto;
  }

  :global(.nav a svg) {
    flex-shrink: 0;
  }
</style>
