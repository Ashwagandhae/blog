<script lang="ts">
  import defaultIcon from "../icons/circle.svg?raw";

  let { name }: { name: string } = $props();

  const modules = import.meta.glob("../icons/*.svg", {
    eager: true,
    query: "?raw",
    import: "default",
  });

  const icons: Record<string, string> = Object.fromEntries(
    Object.entries(modules).map(([path, content]) => {
      const fileName = path.split("/").pop()?.replace(".svg", "") ?? "";
      return [fileName, content as string];
    })
  );

  let icon = $derived(icons[name] ?? defaultIcon);
</script>

{@html icon}
