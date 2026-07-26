#!/usr/bin/env python3
"""GOLD EA input artifact ingest & discovery.

input_artifacts/ に置かれたZIP群を検証・展開し、全CSVを目録化する。
充填(Phase B/F/G)の前段。データの改変・補間は一切行わない。

Usage: python3 research/gold-ea-hardstop-analysis/ingest_verify.py
Exit codes: 0 = OK, 1 = 期待ZIP欠落, 2 = 期待値照合の不一致(要人間確認)
"""

import csv
import hashlib
import json
import sys
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
IN_DIR = REPO / "input_artifacts"
EXTRACT_DIR = IN_DIR / "extracted"
OUT_DIR = REPO / "research" / "gold-ea-hardstop-analysis"

EXPECTED_ZIPS = [
    "KOUCHA_GOLD_MULTILAYER_PHASE1_SHADOW_FIX_AUDIT.zip",
    "KOUCHA_GOLD_MA_CROSS_10EMA20SMA_AUDIT.zip",
    "KOUCHA_GOLD_PHASE1_RUNTIME_MA_CROSS_OVERLAY_AUDIT.zip",
    "KOUCHA_GOLD_M15_REVERSE_CROSS_SHADOW_DESIGN_AUDIT.zip",
    "KOUCHA_GOLD_CURRENT_EA_BASKET_PAYOFF_STRUCTURE_AUDIT.zip",
    "KOUCHA_GOLD_HARDSTOP_ROOT_CAUSE_MULTI_LOGIC_AUDIT.zip",
    "KOUCHA_GOLD_EVENT_BLACKOUT_WINDOW_AUDIT.zip",
]
EXPECTED_EA_FILES = [
    "KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.mq5",
    "KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.ex5",
]
# SESSION_REPORTED_AGGREGATE の期待値(照合のみ。合わせ込み禁止)
EXPECTED_COUNTS = {"runtime_snapshots": 169305, "baskets": 442, "hardstops": 37}

KEY_COLUMN_HINTS = [
    "basket_uid", "basket_id", "root_snapshot_id", "snapshot_id",
    "run_id", "capital", "time", "reason", "profit", "pl", "hardstop",
    "hedge", "direction", "cross", "regime", "event",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def sniff_csv(path: Path) -> dict:
    """ヘッダと行数を安全に取得。区切り文字はsniffし、失敗時はカンマ。"""
    info = {"path": str(path.relative_to(REPO)), "error": None}
    try:
        with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as f:
            sample = f.read(8192)
            f.seek(0)
            try:
                dialect = csv.Sniffer().sniff(sample, delimiters=",;\t")
                delim = dialect.delimiter
            except csv.Error:
                delim = ","
            reader = csv.reader(f, delimiter=delim)
            header = next(reader, [])
            n_rows = sum(1 for _ in reader)
        info.update({
            "delimiter": delim,
            "n_columns": len(header),
            "n_data_rows": n_rows,
            "header": header,
            "key_column_matches": sorted(
                {c for c in header for hint in KEY_COLUMN_HINTS if hint in c.lower()}
            ),
        })
    except Exception as e:  # 目録化は止めない。エラーは記録する
        info["error"] = repr(e)
    return info


def main() -> int:
    if not IN_DIR.is_dir():
        print(f"NG: {IN_DIR} が存在しない。input_artifacts/README.md の手順でpushすること。")
        return 1

    missing = [z for z in EXPECTED_ZIPS if not (IN_DIR / z).is_file()]
    present = [z for z in EXPECTED_ZIPS if (IN_DIR / z).is_file()]
    ea_status = {
        name: (sha256(IN_DIR / name) if (IN_DIR / name).is_file() else "MISSING")
        for name in EXPECTED_EA_FILES
    }

    manifest = {"zips": {}, "ea_files": ea_status, "csv_catalog": [], "checks": {}}

    EXTRACT_DIR.mkdir(parents=True, exist_ok=True)
    for name in present:
        zp = IN_DIR / name
        dest = EXTRACT_DIR / zp.stem
        entry = {"sha256": sha256(zp), "size_bytes": zp.stat().st_size, "members": 0}
        try:
            with zipfile.ZipFile(zp) as zf:
                bad = zf.testzip()
                if bad is not None:
                    entry["error"] = f"corrupt member: {bad}"
                else:
                    dest.mkdir(parents=True, exist_ok=True)
                    zf.extractall(dest)
                    entry["members"] = len(zf.namelist())
        except zipfile.BadZipFile as e:
            entry["error"] = repr(e)
        manifest["zips"][name] = entry

    for csv_path in sorted(EXTRACT_DIR.rglob("*.csv")):
        manifest["csv_catalog"].append(sniff_csv(csv_path))

    # 期待値照合: 行数が期待値に一致するCSVを探す(発見のみ。無ければ不一致として報告)
    rows_by_file = {c["path"]: c.get("n_data_rows") for c in manifest["csv_catalog"]}
    for label, expected in EXPECTED_COUNTS.items():
        hits = [p for p, n in rows_by_file.items() if n == expected]
        manifest["checks"][label] = {"expected_rows": expected, "matching_files": hits}

    out_json = OUT_DIR / "artifact_discovery_report.json"
    out_json.write_text(json.dumps(manifest, ensure_ascii=False, indent=2))

    lines = ["# artifact_discovery_report.md", "",
             f"- ZIP present: {len(present)}/{len(EXPECTED_ZIPS)}",
             f"- ZIP missing: {missing if missing else 'なし'}",
             f"- EA files: {ea_status}", "", "## CSV目録", ""]
    for c in manifest["csv_catalog"]:
        lines.append(f"- `{c['path']}`: rows={c.get('n_data_rows')} cols={c.get('n_columns')}"
                     f" keys={c.get('key_column_matches')} err={c.get('error')}")
    lines += ["", "## 期待値照合", ""]
    ok = True
    for label, chk in manifest["checks"].items():
        status = "MATCH" if chk["matching_files"] else "NO_MATCH(要人間確認)"
        if not chk["matching_files"]:
            ok = False
        lines.append(f"- {label}: expected {chk['expected_rows']} -> {status} {chk['matching_files']}")
    (OUT_DIR / "artifact_discovery_report.md").write_text("\n".join(lines) + "\n")

    print("\n".join(lines))
    if missing:
        return 1
    return 0 if ok else 2


if __name__ == "__main__":
    sys.exit(main())
