<script lang="ts">
  let { children } = $props();
</script>

<div class="metaScroll">
  <div class="meta">
    {@render children()}
  </div>
</div>

<style>
  .meta {
    display: flex;
    flex-direction: row;
    gap: var(--pad-big);
    align-items: center;
    width: 100%;
  }

  .metaScroll {
    overflow: auto;
    width: 100%;
    display: block;
    position: relative;
  }
</style>
