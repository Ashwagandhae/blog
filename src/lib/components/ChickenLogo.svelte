<script>
  import Chicken from "./Chicken.svelte";
</script>

<div class="chicken">
  <Chicken></Chicken>
</div>

<style>
  .chicken {
    width: calc(var(--logo-size) * 1.4);
    height: var(--logo-size);
    position: relative;
  }
</style>
