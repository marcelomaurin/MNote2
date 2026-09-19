#!/usr/bin/env python3
"""Validate that the extended test runner remains wired to critical flows.

This is intentionally dependency-free: the full Pascal test runner currently
requires external Lazarus/CHATGPT/Zeos packages that are not provisioned by the
clean CI image. This gate prevents critical tests from silently becoming
orphaned while that dependency setup is being made reproducible.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "tests" / "test_runner.lpr"

REQUIRED_UNITS = {
    "mnote_task_execution_flow": "task execution flow",
    "mnote_ai_actions": "AI action executor",
    "mnote_ai_service": "AI service",
    "mnote_ai_plan_contract": "AI plan contract",
    "mnote_project_service": "project service",
}

REQUIRED_TEST_CALLS = {
    "TestEndToEndTaskExecution": "end-to-end task execution",
    "TestAIActions": "AI tool actions",
    "TestAIToolLoop": "AI tool loop",
    "TestTaskCommentIndex": "task comment index",
    "TestDiagnosticsAndOutput": "diagnostics/output",
    "TestProcessService": "process service",
}


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


if not RUNNER.is_file():
    fail(f"missing {RUNNER.relative_to(ROOT)}")

text = RUNNER.read_text(encoding="utf-8", errors="strict")
lower = text.lower()

missing_units = [name for name in REQUIRED_UNITS if name.lower() not in lower]
if missing_units:
    fail("test_runner lost required units: " + ", ".join(sorted(missing_units)))

# A procedure name appearing only in its declaration/body is not enough.
# Require at least two textual occurrences: declaration + invocation.
missing_calls = []
for name in REQUIRED_TEST_CALLS:
    count = len(re.findall(rf"\b{re.escape(name)}\b", text, flags=re.IGNORECASE))
    if count < 2:
        missing_calls.append(f"{name} ({count} occurrence(s))")

if missing_calls:
    fail("critical tests are no longer invoked: " + ", ".join(missing_calls))

print("OK: extended test runner keeps all critical project/AI test contracts wired.")
