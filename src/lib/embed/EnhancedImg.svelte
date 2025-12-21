<script lang="ts">
  let { src, alt }: { src?: string; alt?: string } = $props();
  const imageModules = import.meta.glob(
    "/src/writing/**/*.{png,jpg,jpeg,webp,gif}",
    {
      eager: true,
      query: { enhanced: true },
    }
  );
  function getImageModule(filename: string) {
    for (const path in imageModules) {
      if (path.endsWith(filename)) {
        // @ts-ignore
        return imageModules[path].default;
      }
    }
    return null;
  }

  let imgModule = $derived(src == undefined ? undefined : getImageModule(src));
</script>

<enhanced:img {alt} src={imgModule} />
