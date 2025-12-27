<script lang="ts">
  let { children } = $props();

  let isOpen = $state(false);

  let wrapper: HTMLDivElement | undefined = $state();
  function toggle() {
    if (wrapper == null) return;
    if (isOpen) {
      const rect = wrapper?.getBoundingClientRect();
      if (rect && rect.top < 0) {
        wrapper.scrollIntoView();
      }
    }

    isOpen = !isOpen;
  }
</script>

<div class="collapsible" class:open={isOpen} bind:this={wrapper}>
  <div class="content">
    {@render children()}
  </div>

  {#if !isOpen}
    <div class="fade"></div>
  {/if}

  <button onclick={toggle} class="toggle">
    {isOpen ? "show less" : "show more"}
  </button>
</div>

<style>
  .collapsible {
    position: relative;
    border-radius: 0.5rem;
    overflow: hidden;
  }

  .content {
    position: relative;
    overflow: hidden;
    max-height: 16em;
  }

  .open .content {
    max-height: none;
  }

  .toggle {
    display: block;
    width: 100%;
    border-radius: 0 0 var(--radius) var(--radius);
  }

  .open .toggle {
    border-radius: var(--radius);
  }

  .fade {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 8em;
    background: linear-gradient(
      to bottom,
      transparent,
      var(--transparent-back)
    );
    pointer-events: none;
  }
</style>
