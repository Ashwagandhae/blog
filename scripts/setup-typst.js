import fs from "fs";
import { execSync } from "child_process";
import { pipeline } from "stream/promises";
import path from "path";

const VERSION = "v0.12.0";
const ARCH = "x86_64-unknown-linux-musl";
const FILENAME = `typst-${ARCH}.tar.xz`;
const URL = `https://github.com/typst/typst/releases/download/${VERSION}/${FILENAME}`;

async function install() {
  if (process.platform !== "linux") {
    console.log("skipping typst download (not Linux)");
    return;
  }

  console.log(`downloading typst ${VERSION}...`);
  const response = await fetch(URL);
  if (!response.ok)
    throw new Error(`failed to download: ${response.statusText}`);

  const fileStream = fs.createWriteStream("typst.tar.xz");

  await pipeline(response.body, fileStream);

  console.log("extracting...");
  execSync("tar -xf typst.tar.xz");

  const sourceDir = `typst-${ARCH}`;
  const targetDir = path.resolve("node_modules", ".bin");
  const targetPath = path.join(targetDir, "typst");

  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }

  if (fs.existsSync(targetPath)) fs.unlinkSync(targetPath);
  fs.renameSync(`${sourceDir}/typst`, targetPath);

  fs.unlinkSync("typst.tar.xz");
  fs.rmSync(sourceDir, { recursive: true, force: true });

  console.log(`typst installed to ${targetPath}`);
}

install().catch((err) => {
  console.error(err);
  process.exit(1);
});
