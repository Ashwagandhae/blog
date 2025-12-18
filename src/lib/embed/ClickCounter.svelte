<script lang="ts">
  let { count, celebrations }: { count: number; celebrations: string[] } =
    $props();
</script>

<div>
  Epic and cool click counter: {count}

  <button
    onclick={() => {
      count += 1;
    }}>increase the count</button
  >
  Celebration: {celebrations[count % celebrations.length]}
</div>
