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
    <div class="content-scroll">
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

    <svg class="corner-right" viewBox="0 0 20 20">
      <path d="M 0 0 A 20 20 0 0 0 20 20 L 0 20 Z" />
    </svg>
  </div>

  {@render children()}
</div>

<style>
  .fileDisplay {
    width: 100%;
    box-sizing: border-box;
  }

  div.path {
    position: relative;

    display: flex;
    width: fit-content;
    max-width: calc(100% - var(--pad) - var(--radius));
    margin-top: var(--margin);

    background: var(--transparent-back);
    border-radius: var(--radius) var(--radius) 0 0;

    padding: 0;
  }

  .content-scroll {
    display: flex;
    align-items: baseline;

    padding: var(--pad-small);

    overflow-x: auto;
    white-space: nowrap;

    font-size: var(--font-size-small);
    font-family: inherit;

    scrollbar-width: none;
  }

  .corner-right {
    position: absolute;
    bottom: 0;

    right: calc(var(--radius) * -1);

    width: var(--radius);
    height: var(--radius);

    fill: var(--transparent-back);

    pointer-events: none;
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
    cursor: pointer;
  }
  .dir:hover {
    text-decoration: underline;
  }
</style>
