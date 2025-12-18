import rawTagColors from "../writing/tag-colors.json";

const tagColors = rawTagColors as Record<string, number>;

export function getTagHue(name: string): number | null {
  return tagColors[name] ?? null;
}
