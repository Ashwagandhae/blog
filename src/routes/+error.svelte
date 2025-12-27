<script lang="ts">
  import { page } from "$app/state";
  import { titleSuffix } from "$lib/title";
</script>

<svelte:head>
  <title>{page.status}{titleSuffix}</title>
</svelte:head>

<h1>{page.status}</h1>
<p>{page.error?.message}</p>
