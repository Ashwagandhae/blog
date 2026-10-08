<script lang="ts">
  let { children } = $props();

  let isOpen = $state(false);

  const uid = $props.id();

  let wrapper: HTMLDivElement | undefined = $state();

  $effect(() => {
    if (wrapper == null) return;
    if (!isOpen) {
      const rect = wrapper?.getBoundingClientRect();
      if (rect && rect.top < 0) {
        wrapper.scrollIntoView();
      }
    }
  });
</script>

<div class="collapsible" bind:this={wrapper}>
  <div class="content">
    {@render children()}
  </div>

  <div class="fade"></div>

  <input
    class="toggle"
    type="checkbox"
    id={uid}
    bind:checked={isOpen}
    autocomplete="off"
  />
  <label class="toggle-button button" for={uid}>
    <span class="sr-only">Toggle collapsed</span></label
  >
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
  .collapsible:has(.toggle:checked) .content {
    max-height: none;
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

  .collapsible:has(.toggle:checked) .fade {
    display: none;
  }

  .toggle {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(50%);
    white-space: nowrap;
  }
  .toggle-button {
    text-align: center;
    display: block;
    width: 100%;
    box-sizing: border-box;
    border-radius: 0 0 var(--radius) var(--radius);
    font-size: var(--font-size-small);
  }

  .collapsible:has(.toggle:checked) .toggle-button {
    border-radius: var(--radius);
  }
  .toggle-button {
    display: block;
  }

  .toggle-button::after {
    content: "show more" / "";
  }

  .toggle:checked + .toggle-button::after {
    content: "show less" / "";
  }
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
  }
</style>
