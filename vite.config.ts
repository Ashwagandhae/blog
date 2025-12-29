import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig, type ViteDevServer } from "vite";
import { enhancedImages } from "@sveltejs/enhanced-img";

import { spawn, type ChildProcess } from "child_process";

const typstWatchPlugin = () => {
  let typstProcess: ChildProcess | null = null;

  return {
    name: "typst-watcher",

    configureServer(_server: ViteDevServer) {
      console.log("starting typst manager...");

      typstProcess = spawn("npx", ["tsx", "scripts/typst-manager.ts", "dev"], {
        stdio: "inherit",
        shell: true,
      });

      typstProcess.on("error", (err) => {
        console.error("typst manager failed to start:", err);
      });
    },

    closeBundle() {
      if (typstProcess) {
        console.log("stopping typst manager...");
        typstProcess.kill();
      }
    },
  };
};

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
    typstWatchPlugin(),
  ],
});
