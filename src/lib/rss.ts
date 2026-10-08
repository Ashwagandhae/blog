import { getContext, setContext } from "svelte";

export function getIsRss(): boolean {
	return getContext("isRss");
}
