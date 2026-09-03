#!/usr/bin/env python3
"""Generate the registered eval suites from the goals files.

Single source of truth for every word an arm sees. The emitted evals.json
files are committed alongside this generator; re-running it must reproduce
them byte for byte (sorted keys, fixed templates, no timestamps).

Arms see question TEXT only. The open/dictated markings and the answer keys
in the goals files never enter a prompt — leaking a marking would tell an arm
which answers are fixed, which is exactly what falsifier F1 tests.
"""

from __future__ import annotations

import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parent

STAGE1_SCHEMA = """{
  "task": "%(task)s",
  "latitude": {"genuine": true or false, "why": "at most 40 words. true only if MATERIAL design decisions are open - decisions a reviewer would debate; implementation trivia does not count"},
  "answers": {
    "q1": {"position": "your decision, at most 35 words, stated as a decision rather than a discussion",
           "surface": "the repository path most affected, or '-'",
           "rationale": "at most 25 words"}
    // ... one entry per question id listed above, q1 through %(last_q)s ...
  },
  %(threshold_field)s"out_of_scope_touched": []
}"""

STAGE1_TEMPLATE = """You are planning work on this repository. Below is a ticket and the planning \
questions your plan must take a position on. Plan only: do not implement the ticket, do not modify \
tracked files, do not run builds, and do not use the network. Read the repository as needed to \
ground your decisions.

<ticket>
%(brief)s
</ticket>

Your plan must take a clear position on every one of these questions:

%(questions)s
%(threshold_note)s
Out of scope for this ticket (a plan touching one must say so): %(out_of_scope)s

Output contract, follow it exactly. Write your plan as a declaration file at the repository root \
named PLAN-1.json. If your method produces several plans, number them PLAN-2.json, PLAN-3.json; \
with no instruction otherwise, produce one. Each file must be valid JSON in this shape:

%(schema)s

An empty out_of_scope_touched list claims your plan touches none of the stated out-of-scope items. \
You may write free-form working notes to PLAN-<n>.notes.md; only the .json files are assessed."""

STAGE2_SCHEMA = """{
  "task": "%(task)s",
  "answers": {
    "q1": {"adopted_from": "path-1" or "path-2" or "path-3" or "novel",
           "position": "copied VERBATIM from the source path's position for this question; your own text only when adopted_from is novel",
           "modification": "at most 25 words; optional"}
    // ... one entry per question id, q1 through %(last_q)s ...
  },
  %(threshold_field)s"undecidable_on_paper": [],
  "out_of_scope_touched": []
}"""

STAGE2_TEMPLATE = """Three candidate paths through one ticket sit in this workspace as path-1.json, \
path-2.json and path-3.json, with the goal outcomes they must serve in goals-questions.md. They \
were produced elsewhere; you have no other context on how, and their order carries no meaning. \
Work on paper only: judge against the stated goals and questions, do not use the network, and do \
not bring in outside knowledge of the codebase.

Produce the single plan that should go forward. Write it to HARMONISED.json at the workspace root, \
valid JSON in this shape:

%(schema)s

undecidable_on_paper lists any question id where the paths cannot be told apart on paper against \
these goals; an empty list claims every question was decidable. An empty out_of_scope_touched list \
claims the plan touches none of the out-of-scope items stated in goals-questions.md. You may write \
working notes to HARMONISED.notes.md; only HARMONISED.json is assessed."""


def load_goals(task: str) -> dict:
    return json.loads((BASE / "goals" / f"goals-{task}.json").read_text())


def questions_block(goals: dict) -> str:
    lines = []
    for qid, q in goals["questions"].items():
        lines.append(f"- {qid}: {q['text']}")
    return "\n".join(lines)


def threshold_note(goals: dict) -> str:
    if not goals["thresholds_required"]:
        return ""
    parts = [f"{tid} ({text})" for tid, text in goals["thresholds_required"].items()]
    return (
        "\nWhere a question demands a named number, record it in the thresholds field: "
        + "; ".join(parts)
        + "\n"
    )


def threshold_field(goals: dict) -> str:
    if not goals["thresholds_required"]:
        return ""
    example = ", ".join(f'"{tid}": <number>' for tid in goals["thresholds_required"])
    return "\"thresholds\": {%s},\n  " % example


def stage1_eval(task: str, skill_name: str) -> dict:
    goals = load_goals(task)
    brief = (BASE / "briefs" / f"{task}-brief.md").read_text().strip()
    last_q = list(goals["questions"])[-1]
    schema = STAGE1_SCHEMA % {
        "task": task,
        "last_q": last_q,
        "threshold_field": threshold_field(goals),
    }
    prompt = STAGE1_TEMPLATE % {
        "brief": brief,
        "questions": questions_block(goals),
        "threshold_note": threshold_note(goals),
        "out_of_scope": "; ".join(goals["out_of_scope"]),
        "schema": schema,
    }
    return {
        "skill_name": skill_name,
        "evals": [
            {
                "id": f"{task}-plan",
                "prompt": prompt,
                "expected_output": (
                    "One or more plan declarations at PLAN-<n>.json, each valid JSON per the "
                    "stated contract, taking a position on every stated question and staying "
                    "inside the ticket's scope."
                ),
                "files": [],
                "force_skill_invocation": True,
                "side_effect_level": "local-only",
                "assertions": [
                    {"type": "file_exists", "path": "PLAN-1.json"},
                    {"type": "json_path", "path": "PLAN-1.json", "json_path": "latitude.genuine"},
                    {"type": "json_path", "path": "PLAN-1.json", "json_path": "answers.q1.position"},
                    {
                        "type": "json_path_not_exists",
                        "path": "PLAN-1.json",
                        "json_path": "out_of_scope_touched.0",
                    },
                ],
            }
        ],
    }


def stage2_eval(task: str, skill_name: str) -> dict:
    goals = load_goals(task)
    last_q = list(goals["questions"])[-1]
    schema = STAGE2_SCHEMA % {
        "task": task,
        "last_q": last_q,
        "threshold_field": threshold_field(goals),
    }
    prompt = STAGE2_TEMPLATE % {"schema": schema}
    return {
        "skill_name": skill_name,
        "evals": [
            {
                "id": f"{task}-harmonise",
                "prompt": prompt,
                "expected_output": (
                    "A single plan at HARMONISED.json, valid JSON per the stated contract, with "
                    "per-question provenance and an explicit undecidable_on_paper list."
                ),
                "files": [
                    "files/goals-questions.md",
                    "files/path-1.json",
                    "files/path-2.json",
                    "files/path-3.json",
                ],
                "force_skill_invocation": True,
                "side_effect_level": "local-only",
                "assertions": [
                    {"type": "file_exists", "path": "HARMONISED.json"},
                    {"type": "json_path", "path": "HARMONISED.json", "json_path": "answers.q1.adopted_from"},
                    {"type": "json_path", "path": "HARMONISED.json", "json_path": "undecidable_on_paper"},
                    {
                        "type": "json_path_not_exists",
                        "path": "HARMONISED.json",
                        "json_path": "out_of_scope_touched.0",
                    },
                ],
            }
        ],
    }


def arm_visible_goals(task: str) -> str:
    """The goals text the stage-2 agent sees: questions, thresholds, scope. No keys."""
    goals = load_goals(task)
    parts = [
        f"# Goal outcomes - {goals['title']}",
        "",
        "The plan that goes forward must take a clear position on every question:",
        "",
        questions_block(goals),
    ]
    tn = threshold_note(goals)
    if tn:
        parts.append(tn.strip())
    parts += [
        "",
        "Out of scope (a plan touching one must say so): " + "; ".join(goals["out_of_scope"]),
        "",
    ]
    return "\n".join(parts)


def main() -> None:
    out = BASE / "evals"
    out.mkdir(exist_ok=True)
    targets = {
        "stage1-td196.evals.json": stage1_eval("td196", "trident-generate"),
        "stage1-td178.evals.json": stage1_eval("td178", "trident-generate"),
        "stage2-td196.evals.json": stage2_eval("td196", "trident-harmonise"),
    }
    for name, data in targets.items():
        (out / name).write_text(json.dumps(data, indent=2, sort_keys=False) + "\n")
        print(f"wrote evals/{name}")
    gq = arm_visible_goals("td196")
    (out / "goals-questions-td196.md").write_text(gq)
    print("wrote evals/goals-questions-td196.md (stage-2 fixture source)")


if __name__ == "__main__":
    main()
