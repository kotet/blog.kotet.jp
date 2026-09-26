// 記事フロントマターのタグ表記を検査する。違反があれば一覧を表示して終了コード1を返す。
//
// 検査項目:
//   1. タグの元データが英語小文字とアンダースコアのみで構成されているか
//   2. すべてのタグに content/tags/<tag>/_index.md と _index.en.md があるか
//   3. content/tags/ に記事から参照されていないタグページが残っていないか
//   4. 対訳記事(foo.md と foo.en.md)のタグ集合が一致しているか
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const CONTENT_DIR = new URL("../content/", import.meta.url).pathname;
const TAGS_DIR = join(CONTENT_DIR, "tags");
const VALID_TAG = /^[a-z0-9]+(_[a-z0-9]+)*$/;

function walkArticles(dir) {
  const found = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      if (full !== TAGS_DIR.replace(/\/$/, "")) found.push(...walkArticles(full));
    } else if (entry.endsWith(".md") && !entry.startsWith("_index")) {
      found.push(full);
    }
  }
  return found;
}

// YAMLフロントマターの tags リストを抽出する。ブロック形式とインライン形式の両方に対応する。
function extractTags(text) {
  if (!text.startsWith("---")) return [];
  const end = text.indexOf("\n---", 3);
  if (end < 0) return [];
  const tags = [];
  let inTags = false;
  for (const line of text.slice(3, end).split("\n")) {
    if (/^tags:[ \t]*$/.test(line)) {
      inTags = true;
      continue;
    }
    if (inTags) {
      const item = line.match(/^\s*-\s+(.*\S)\s*$/);
      if (item) {
        tags.push(item[1].replace(/^["']|["']$/g, ""));
        continue;
      }
      inTags = false;
    }
    const inline = line.match(/^tags:\s*\[(.*)\]\s*$/);
    if (inline) {
      for (const t of inline[1].split(",")) tags.push(t.trim().replace(/^["']|["']$/g, ""));
    }
  }
  return tags;
}

const problems = [];
const usedTags = new Set();
const tagsByArticleBase = new Map();

for (const path of walkArticles(CONTENT_DIR).sort()) {
  const rel = relative(CONTENT_DIR, path);
  const tags = extractTags(readFileSync(path, "utf8"));
  const isEnglish = rel.endsWith(".en.md");
  const base = isEnglish ? rel.slice(0, -6) : rel.slice(0, -3);
  if (!tagsByArticleBase.has(base)) tagsByArticleBase.set(base, {});
  tagsByArticleBase.get(base)[isEnglish ? "en" : "ja"] = tags;

  for (const tag of tags) {
    usedTags.add(tag);
    if (!VALID_TAG.test(tag)) {
      problems.push(`${rel}: タグ "${tag}" は英語小文字とアンダースコア区切りではありません`);
    }
  }
}

const tagPageDirs = new Set(
  readdirSync(TAGS_DIR).filter((name) => statSync(join(TAGS_DIR, name)).isDirectory()),
);

for (const tag of [...usedTags].sort()) {
  for (const file of ["_index.md", "_index.en.md"]) {
    try {
      statSync(join(TAGS_DIR, tag, file));
    } catch {
      problems.push(`content/tags/${tag}/${file} がありません`);
    }
  }
}

for (const name of [...tagPageDirs].sort()) {
  if (!usedTags.has(name)) {
    problems.push(`content/tags/${name}/ はどの記事からも参照されていません`);
  }
}

for (const [base, langs] of tagsByArticleBase) {
  if (!langs.ja || !langs.en) continue;
  const ja = new Set(langs.ja);
  const en = new Set(langs.en);
  const onlyJa = [...ja].filter((t) => !en.has(t));
  const onlyEn = [...en].filter((t) => !ja.has(t));
  if (onlyJa.length || onlyEn.length) {
    problems.push(
      `${base}: 日本語版と英語版のタグが一致しません (ja のみ: ${onlyJa.join(", ") || "なし"} / en のみ: ${onlyEn.join(", ") || "なし"})`,
    );
  }
}

if (problems.length > 0) {
  console.error(`タグの検査で ${problems.length} 件の問題が見つかりました:`);
  for (const problem of problems) console.error(`  - ${problem}`);
  process.exit(1);
}

console.log(`タグの検査に成功しました (${usedTags.size} タグ)`);
