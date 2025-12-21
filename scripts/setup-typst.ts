import fs from "fs";
import { execSync } from "child_process";

const VERSION = "v0.14.2";
const FILENAME = `typst-x86_64-unknown-linux-musl.tar.xz`;
const URL = `https://github.com/typst/typst/releases/download/${VERSION}/${FILENAME}`;

function install() {
  if (process.platform !== "linux") {
    console.log("skipping typst download (not linux)");
    return;
  }

  console.log(`downloading typst ${VERSION}...`);

  execSync(`curl -L -o typst.tar.xz ${URL}`);

  execSync("tar -xf typst.tar.xz");

  const folderName = FILENAME.replace(".tar.xz", "");
  fs.renameSync(`${folderName}/typst`, "./typst");

  fs.rmSync("typst.tar.xz");
  fs.rmSync(folderName, { recursive: true, force: true });

  console.log("yypst installed successfully.");
}

install();
