import { getContext, setContext } from "svelte";

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

export type Palette = {
  front: number;
  back: number;
};

export const defaultPalette: Palette = {
  front: 100,
  back: 280,
};

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
