<script lang="ts">
  import { page } from "$app/state";

  let { href, children } = $props();

  let isActive = $derived(
    href === "/"
      ? page.url.pathname === "/"
      : page.url.pathname.startsWith(href)
  );
</script>

<a {href} class:current={isActive} aria-current={isActive ? "page" : undefined}>
  {@render children()}
</a>

<style>
  a {
    color: inherit;
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
  a.current {
    text-decoration: underline;
  }
</style>
