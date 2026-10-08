#!/usr/bin/env python3
"""Runs a systematic mutation sweep of one production file of a case against
the case's current (agent-visible) tests, in Docker.

Usage: mutation-sweep.py <case-dir> <source-file> [--jobs N]

Mutants, generated line by line (comments and imports skipped):
  - comparison operators: < <= > >= == != swapped with their neighbours
  - integer literals: n -> n+1 and n -> n-1
  - identifiers compared against: `< X` -> `< X-1` and `< X+1` (same for <= > >=)
  - arithmetic: + <-> -, * -> /
  - boolean operators: || <-> &&, and <-> or

Each mutant is applied to a fresh copy of the case's git-tracked files (without
_eval/) and the case's SUITE_CMD runs in its Docker image. Outcomes: killed
(tests failed), survived (tests passed), invalid (build or collection error,
matched by the case's ERROR_RE). Prints one line per mutant and a summary;
exits 1 if any mutant survived.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CMP_SWAPS = {"<=": ["<", ">="], ">=": [">", "<="], "<": ["<=", ">"], ">": [">=", "<"],
             "==": ["!="], "!=": ["=="]}


def case_settings(case_dir):
    script = (
        'export VERIFY_DRY=1; source "$1/_eval/verify.sh" >/dev/null 2>&1; '
        'printf "%s\\0%s\\0%s\\0%s\\0" "$IMAGE" "$SETUP" "$SUITE_CMD" "$ERROR_RE"; '
        'printf "%s\\0" "${DOCKER_ARGS[@]}"'
    )
    out = subprocess.run(["bash", "-c", script, "_", case_dir], capture_output=True, text=True, check=True).stdout
    parts = out.split("\0")
    image, setup, suite, error_re = parts[:4]
    docker_args = [p for p in parts[4:] if p]
    if not suite:
        sys.exit(f"SUITE_CMD not set in {case_dir}/_eval/verify.sh")
    return image, setup, suite, error_re, docker_args


def generate(lines):
    comment = re.compile(r"^\s*(//|#|\*|/\*|import\b|from\b|package\b)")
    mutants = []
    for i, line in enumerate(lines):
        if comment.match(line) or not line.strip():
            continue
        strings = [m.span() for m in re.finditer(r'"[^"]*"|\'[^\']*\'|`[^`]*`', line)]
        seen = set()

        def in_string(m):
            return any(a <= m.start() < b for a, b in strings)

        def add(new, what):
            if new != line and new not in seen:
                seen.add(new)
                mutants.append((i, new, what))

        for m in re.finditer(r"<=|>=|==|!=|(?<![<>=!-])<(?![<=-])|(?<![<>=-])>(?![>=])", line):
            if not in_string(m):
                for rep in CMP_SWAPS[m.group(0)]:
                    add(line[:m.start()] + rep + line[m.end():], f"{m.group(0)} -> {rep}")
        for m in re.finditer(r"(?<![\w.])(\d[\d_]*)(?![\w.])", line):
            if in_string(m):
                continue
            n = int(m.group(1).replace("_", ""))
            for d in (1, -1):
                add(line[:m.start()] + str(n + d) + line[m.end():], f"{m.group(1)} -> {n + d}")
        for m in re.finditer(r"(<=|>=|<|>)\s*([A-Za-z_]\w*)\b(?![\w.(])", line):
            for d in ("-1", "+1"):
                add(line[:m.end()] + d + line[m.end():], f"{m.group(0)} -> {m.group(0)}{d}")
        for m in re.finditer(r"(?<=[\w)\]] )([+\-*])(?= [\w(])", line):
            rep = {"+": "-", "-": "+", "*": "/"}[m.group(1)]
            add(line[:m.start()] + rep + line[m.end():], f"{m.group(1)} -> {rep}")
        for a, b in (("||", "&&"), ("&&", "||"), (" and ", " or "), (" or ", " and ")):
            for m in re.finditer(re.escape(a), line):
                if not in_string(m):
                    add(line[:m.start()] + b + line[m.end():], f"{a.strip()} -> {b.strip()}")
    return mutants


def run_mutant(case_dir, source, lines, mutant, settings):
    image, setup, suite, error_re, docker_args = settings
    i, new_line, what = mutant
    work = tempfile.mkdtemp()
    try:
        files = subprocess.run(["git", "-C", case_dir, "ls-files", "--", ".", ":(exclude)_eval"],
                               capture_output=True, text=True, check=True).stdout.split()
        for f in files:
            dest = os.path.join(work, f)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copy2(os.path.join(case_dir, f), dest)
        mutated = list(lines)
        mutated[i] = new_line
        with open(os.path.join(work, source), "w") as fh:
            fh.writelines(mutated)
        cmd = f"{setup} && {suite}; rc=$?; chown -R {os.getuid()}:{os.getgid()} /work; exit $rc"
        proc = subprocess.run(["docker", "run", "--rm", "-v", f"{work}:/work", "-w", "/work",
                               "-e", "NO_COLOR=1", "-e", "CI=1", *docker_args, image, "sh", "-c", cmd],
                              capture_output=True, text=True)
        output = proc.stdout + proc.stderr
        if proc.returncode == 0:
            outcome = "survived"
        elif error_re and re.search(error_re, output, re.M):
            outcome = "invalid"
        else:
            outcome = "killed"
        return outcome, f"{source}:{i + 1}: {what}"
    finally:
        shutil.rmtree(work, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("case_dir")
    ap.add_argument("source")
    ap.add_argument("--jobs", type=int, default=4)
    args = ap.parse_args()
    case_dir = os.path.abspath(args.case_dir)
    with open(os.path.join(case_dir, args.source)) as fh:
        lines = fh.readlines()
    settings = case_settings(case_dir)
    mutants = generate(lines)
    with ThreadPoolExecutor(args.jobs) as pool:
        results = list(pool.map(lambda m: run_mutant(case_dir, args.source, lines, m, settings), mutants))
    counts = {"killed": 0, "survived": 0, "invalid": 0}
    for outcome, label in results:
        counts[outcome] += 1
        print(f"{outcome:8} {label}")
    print(f"summary: {len(results)} mutants, {counts['killed']} killed, "
          f"{counts['survived']} survived, {counts['invalid']} invalid")
    return 1 if counts["survived"] else 0


if __name__ == "__main__":
    sys.exit(main())
