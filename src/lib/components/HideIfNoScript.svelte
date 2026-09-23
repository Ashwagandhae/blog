<script lang="ts">
  import { type Snippet } from "svelte";
  let { children, name }: { children: Snippet; name: string } = $props();
</script>

<noscript>
  <div class="warning">
    <p>
      <strong>{name}</strong> requires JavaScript to work properly, but you've disabled
      JavaScript, so I've hidden it.
    </p>
  </div>
</noscript>
<div class="hider">
  {@render children()}
</div>

<style>
  .hider {
    display: none;
  }
  :global(.js-enabled) .hider {
    display: block;
  }
  .warning {
    background: var(--transparent-back);
    padding: var(--pad);
    border-radius: var(--radius);
    margin: var(--pad) 0;
    gap: var(--pad);
  }
  p {
    margin: 0;
  }
</style>
