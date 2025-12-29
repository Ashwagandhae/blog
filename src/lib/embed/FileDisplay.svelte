<script lang="ts">
  import type { Snippet } from "svelte";

  let { children, path }: { children: Snippet; path: string } = $props();

  let lastSlash = $derived(path.lastIndexOf("/"));

  let dir: string | null = $derived(
    lastSlash <= 0 ? null : path.substring(0, lastSlash + 1)
  );

  let file = $derived(lastSlash === -1 ? path : path.substring(lastSlash + 1));

  let showDir = $state(false);
</script>

<div class="fileDisplay">
  <div class="path">
    {#if dir != null}
      <button class="dir" onclick={() => (showDir = !showDir)}>
        {#if showDir}
          {dir}
        {:else}
          …/
        {/if}
      </button>{/if}<span class="file">
      {file}
    </span>
  </div>
  {@render children()}
</div>

<style>
  .fileDisplay {
    width: 100%;
    box-sizing: border-box;
  }
  div.path {
    display: flex;
    align-items: baseline;

    max-width: calc(100% - var(--pad));
    width: min-content;
    overflow-x: auto;

    background: var(--transparent-back);
    padding: var(--pad-small);
    border-radius: var(--radius) var(--radius) 0 0;
    font-size: var(--font-size-small);
    margin-top: var(--margin);

    box-sizing: border-box;
  }
  .dir,
  .file {
    white-space: nowrap;
  }
  .dir {
    background: none;
    border: none;
    padding: 0;
    margin: 0;

    font-family: inherit;
    font-size: inherit;
    line-height: inherit;
    color: var(--text-weak);

    vertical-align: baseline;
  }
  .dir:hover {
    text-decoration: underline;
  }
</style>
