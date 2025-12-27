<script lang="ts">
  import Icon from "./Icon.svelte";

  let { name }: { name: string } = $props();
</script>

<div class="icon">
  <Icon {name}></Icon>
</div>

<style>
  .icon {
    width: 1em;
    height: 1em;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
