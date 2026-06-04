<script lang="ts">
  import LinkTag from "./LinkTag.svelte";

  let { name }: { name: string } = $props();
</script>

<LinkTag {name} route="/projects/tags" />
