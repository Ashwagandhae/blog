<script lang="ts">
  import { page } from "$app/state";
  import type { Snippet } from "svelte";
  import Icon from "./Icon.svelte";
  import InlineIcon from "./InlineIcon.svelte";

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
    <InlineIcon name={icon}></InlineIcon>
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
    padding: var(--pad);
    line-height: 1;

    gap: var(--pad-small);

    white-space: nowrap;
    text-decoration: none;
    color: inherit;

    transition: background var(--transition-duration-slow);
  }
  a:hover {
    background: var(--transparent-back);
    transition: background var(--transition-duration);
  }
  a:active {
    background: var(--transparent-back-1);
    transition: background var(--transition-duration);
  }
  a.current {
    background: var(--transparent-back);
  }
</style>
