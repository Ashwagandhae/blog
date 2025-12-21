<script lang="ts">
  import { page } from "$app/state";
  import type { Snippet } from "svelte";
  import Icon from "./Icon.svelte";

  let {
    href,
    children,
    icon,
  }: {
    href: string;
    children: Snippet;
    icon?: string;
  } = $props();

  let isActive = $derived(
    href === "/"
      ? page.url.pathname === "/"
      : page.url.pathname.startsWith(href)
  );
</script>

<a {href} class:current={isActive} aria-current={isActive ? "page" : undefined}>
  {#if icon}
    <div class="icon">
      <Icon name={icon}></Icon>
    </div>
  {/if}
  {@render children()}
</a>

<style>
  a {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;

    border-radius: var(--radius);
    padding: 0 0.25em;

    gap: var(--pad-small);
    line-height: 1.6;

    white-space: nowrap;
    text-decoration: none;
    color: inherit;

    transition: background var(--transition-duration-slow);
  }
  a:hover {
    text-decoration: underline;
    background: var(--transparent-back);
    transition: background var(--transition-duration);
  }
  a:active {
    text-decoration: underline;
    background: var(--transparent-back-1);
    transition: background var(--transition-duration);
  }
  a.current {
    background: var(--transparent-back);
  }

  .icon {
    width: 1em;
    height: 1em;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
