<script lang="ts">
  import Icon from "$lib/components/Icon.svelte";

  let { text }: { text?: string } = $props();

  function copyText() {
    if (text == null) return;
    navigator.clipboard.writeText(text);
  }
</script>

<button class="copyButton" onclick={copyText} aria-label="Copy code">
  <Icon name="copy" />
</button>

<style>
  .copyButton {
    position: absolute;
    top: 0;
    right: 0;
    width: 32px;
    box-sizing: border-box;
    opacity: 0;
    background: none;
    transition:
      opacity var(--transition-duration-slow),
      background var(--transition-duration-slow);
  }
  :global(div.raw):hover .copyButton {
    opacity: 1;
    transition:
      opacity var(--transition-duration),
      background var(--transition-duration-slow);
  }
  .copyButton:hover {
    background: var(--transparent-back);
    transition:
      opacity var(--transition-duration-slow),
      background var(--transition-duration);
  }
  :global(div.raw):hover .copyButton:hover {
    opacity: 1;
    background: var(--transparent-back);
    transition:
      opacity var(--transition-duration),
      background var(--transition-duration);
  }
  .copyButton:active {
    background: var(--transparent-back-1);
  }
  :global(div.raw):hover .copyButton:active {
    background: var(--transparent-back-1);
  }
</style>
