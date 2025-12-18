<script lang="ts">
  import type { Snippet } from "svelte";
  import Icon from "./Icon.svelte";

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
    <div class="icon">
      <Icon name={icon}></Icon>
    </div>
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
    padding: 0 0.25em;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: var(--pad-small);
    line-height: 1.6;
    white-space: nowrap;
  }
  .icon {
    width: 1em;
    height: 1em;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
