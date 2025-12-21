// scripts/setup-typst.js
import fs from "fs";
import { execSync } from "child_process";
import { pipeline } from "stream/promises";

const VERSION = "v0.14.2";
const ARCH = "x86_64-unknown-linux-musl";
const FILENAME = `typst-${ARCH}.tar.xz`;
const URL = `https://github.com/typst/typst/releases/download/${VERSION}/${FILENAME}`;

async function install() {
  if (process.platform !== "linux") {
    console.log("skipping typst download (not Linux)");
    return;
  }

  console.log(`downloading Typst ${VERSION} from:`);
  console.log(URL);

  const response = await fetch(URL);

  if (!response.ok) {
    throw new Error(
      `failed to download: ${response.status} ${response.statusText}`
    );
  }
  if (response.body == null) {
    throw new Error("response body is null");
  }

  const fileStream = fs.createWriteStream("typst.tar.xz");

  await pipeline(response.body, fileStream);

  console.log("download complete. extracting...");

  try {
    execSync("tar -xf typst.tar.xz");
  } catch (e) {
    console.error("tar extraction failed.");
    throw e;
  }

  const folderName = `typst-${ARCH}`;

  if (fs.existsSync("typst")) fs.unlinkSync("typst");

  fs.renameSync(`${folderName}/typst`, "./typst");

  fs.unlinkSync("typst.tar.xz");
  fs.rmSync(folderName, { recursive: true, force: true });

  fs.chmodSync("./typst", "755");

  console.log("typst installed successfully.");
}

install().catch((err) => {
  console.error(err);
  process.exit(1);
});
