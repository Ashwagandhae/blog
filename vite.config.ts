import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import { enhancedImages } from "@sveltejs/enhanced-img";

export default defineConfig({
  plugins: [
    sveltekit(),
    enhancedImages(),
    {
      name: "watch-content",
      handleHotUpdate({ file, server }) {
        if (file.endsWith(".html")) {
          server.ws.send({ type: "custom", event: "content-update" });
        }
      },
    },
  ],
});
