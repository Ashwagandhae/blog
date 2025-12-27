<script lang="ts">
  import type { Snippet } from "svelte";
  import Icon from "./Icon.svelte";
  import InlineIcon from "./InlineIcon.svelte";

  let {
    children,
    icon,
  }: {
    children: Snippet;
    icon?: string;
  } = $props();
</script>

<div class="tag">
  {#if icon}
    <InlineIcon name={icon} />
  {/if}
  <div class="content">
    {@render children()}
  </div>
</div>

<style>
  .tag {
    display: flex;
    background: var(--tag-back);
    transition: var(--tag-transition);
    border-radius: var(--radius);
    padding: var(--pad-small);
    line-height: 1;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: var(--pad-small);
    white-space: nowrap;
  }
</style>
