import { spawn, execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import chokidar from "chokidar";

const ROOT = process.cwd();
const SOURCE_DIR = "src/writing";
const TARGET_DIR = "src/writing/target";
const EXCLUDE = ["lib.typ"];
const ABS_TARGET = path.resolve(ROOT, TARGET_DIR);

if (!fs.existsSync(path.join(ROOT, TARGET_DIR))) {
  fs.mkdirSync(path.join(ROOT, TARGET_DIR), { recursive: true });
}

const activeWatchers = new Map();

const mode = process.argv[2] || "build";

if (mode === "build") {
  buildAll();
} else if (mode === "dev") {
  buildAll();
  startDevMode();
} else {
  console.log("Usage: node scripts/typst-manager.js [dev|build]");
}

function getTypstFiles() {
  const dir = path.join(ROOT, SOURCE_DIR);
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".typ") && !EXCLUDE.includes(f));
}

function compileFile(fileName: string) {
  const source = path.join(SOURCE_DIR, fileName);
  const target = path.join(TARGET_DIR, fileName.replace(".typ", ".html"));

  try {
    execSync(
      `typst compile "${source}" "${target}" --format html --features html`,
      { stdio: "inherit" }
    );
    console.log(`built ${fileName}`);
  } catch (e) {
    console.error(`failed to build ${fileName}`);
  }
}

function buildAll() {
  console.log("\nstarting full typst build...");
  const files = getTypstFiles();
  files.forEach(compileFile);
  console.log("build complete.\n");
}

function startDevMode() {
  console.log("watching for changes...");

  const watcher = chokidar.watch(SOURCE_DIR, {
    persistent: true,
    ignoreInitial: true,
    ignored: [ABS_TARGET],
  });

  watcher.on("all", (event, filePath) => {
    const fileName = path.basename(filePath);
    const ext = path.extname(filePath).toLowerCase();

    if (!filePath.endsWith(".typ") || EXCLUDE.includes(fileName)) {
      return;
    }

    if (activeWatchers.has(fileName)) {
      return;
    }

    if (event === "change" || event === "add") {
      spawnDedicatedWatcher(fileName);
    }
  });

  process.on("SIGINT", () => {
    console.log("\nstopping all typst watchers...");
    activeWatchers.forEach((child, name) => {
      child.kill();
    });
    process.exit();
  });
}

function spawnDedicatedWatcher(fileName: string) {
  console.log(`spawning dedicated watcher for: ${fileName}`);

  const source = path.join(SOURCE_DIR, fileName);
  const target = path.join(TARGET_DIR, fileName.replace(".typ", ".html"));

  const child = spawn(
    "typst",
    ["watch", source, target, "--format", "html", "--features", "html"],
    {
      stdio: "inherit",
      shell: true,
    }
  );

  activeWatchers.set(fileName, child);

  child.on("close", () => {
    activeWatchers.delete(fileName);
  });
}
