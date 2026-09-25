<script lang="ts">
  import InlineIcon from "./InlineIcon.svelte";
  import { type Snippet } from "svelte";

  let {
    children,
    left,
    right,
  }: { children: Snippet; left: string; right: string } = $props();
</script>

<div class="webring">
  <a class="webring-link" href={left} aria-label="Left link">
    <InlineIcon name="triangleLeft" />
  </a>
  <div>{@render children()}</div>
  <a class="webring-link" href={right} aria-label="Right link">
    <InlineIcon name="triangleRight" />
  </a>
</div>

<style>
  a.webring-link {
    color: var(--text-weak);
    display: grid;
    width: 3ch;
    text-decoration: none;
    place-content: center;

    gap: var(--pad-small);
    max-width: 100%;
    box-sizing: border-box;
  }

  a.webring-link:hover {
    color: var(--text);
  }
  a.webring-link:active {
    color: var(--text-strong);
  }
  .webring {
    display: flex;
    align-items: center;
    flex-direction: row;
  }
</style>
