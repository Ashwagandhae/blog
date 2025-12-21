<script lang="ts">
  let { user, domain } = $props();

  let email = $state("...");
  let href = $state("#");

  $effect(() => {
    const address = `${user}@${domain}`;
    email = address;
    href = `mailto:${address}`;
  });
</script>

<a {href}>
  {email}
</a>

<style>
</style>
