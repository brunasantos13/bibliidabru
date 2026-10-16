import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const output = resolve(root, "dist");
const url = process.env.SUPABASE_URL?.trim();
const publishableKey = process.env.SUPABASE_PUBLISHABLE_KEY?.trim();

if (!url || !publishableKey) {
  console.error(
    "Configure SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY nas variáveis de ambiente do Netlify antes de publicar.",
  );
  process.exit(1);
}

await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });
await cp(resolve(root, "public"), output, { recursive: true });
await writeFile(
  resolve(output, "config.js"),
  `window.ENTRELINHAS_CONFIG = ${JSON.stringify({ url, publishableKey })};\n`,
  "utf8",
);

const html = await readFile(resolve(output, "index.html"), "utf8");
if (!html.includes("/app.js") || !html.includes("/config.js")) {
  throw new Error("A página principal não encontrou os arquivos de inicialização.");
}

console.log("Entrelinhas pronto para publicação no Netlify.");
