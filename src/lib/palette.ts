import { getContext, setContext } from "svelte";
import type { ArticleMeta } from "./article";
import { getTagHue } from "./tag";

export function findMatchingFrontHue(backHue: number): number {
  return moveHueTowardsYellow(backHue, 80);
}

function moveHueTowardsYellow(currentHue: number, amount: number): number {
  const TARGET_HUE = 70;

  let delta = TARGET_HUE - currentHue;

  while (delta > 180) delta -= 360;
  while (delta < -180) delta += 360;

  if (Math.abs(delta) <= amount) {
    return TARGET_HUE;
  }

  const direction = Math.sign(delta);
  let newHue = currentHue + direction * amount;

  return ((newHue % 360) + 360) % 360;
}

export type Palette = number[];

const defaultBack = 280;

export const defaultPalette: Palette = [100, defaultBack];

export function setPaletteContext(
  updatePalette: (updater: (layers: PaletteLayers) => PaletteLayers) => void
) {
  setContext("palette", updatePalette);
}
export function getPaletteContext(): (
  updater: (layers: PaletteLayers) => PaletteLayers
) => void {
  return getContext("palette");
}

export type PaletteLayers = {
  active: Palette | null;
};

export function getArticlePalette(meta: ArticleMeta): Palette | null {
  let tagHues = meta.tags
    .map((tag) => getTagHue(tag))
    .filter((tag) => tag != null);
  if (tagHues.length == 0) return null;
  if (tagHues.length == 1) {
    return [tagHues[0], defaultBack];
  }
  return tagHues;
}

export function getTagPalette(name: string): Palette | null {
  let hue = getTagHue(name);
  if (hue == null) return null;
  return [hue, defaultBack];
}
