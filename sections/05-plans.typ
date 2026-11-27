#import "../oxford-theme.typ": *
#import "../oxford-colors.typ" as ox

#title-slide[Plans for Submission]

// ── Remaining work ──────────────────────────────────────────────────────

#cols-slide(title: [Remaining work])[
  #stress[Code changes]
  - #todo[`simulacrop` change 1]
  - #todo[`simulacrop` change 2]
  - #todo[Artifact packaging / release]
][
  #stress[Experiments]
  - #todo[Head-to-head vs. `crackers` & prior tools]
  - #todo[Guarded-chain case studies]
  - #todo[Scaling: binary size, chain length]
]

#slide(title: [Evaluation plan])[
  // One row per question the evaluation chapter / paper must answer.
  #let st(fill, body) = text(size: .8em, fill: fill, weight: "medium", body)
  #let done = st(ox.success)[done]
  #let partial = st(ox.oxsienna)[partial]
  #let todo-st = st(ox.danger)[not started]
  #set text(size: 17pt)
  #align(center + horizon, table(
    columns: (auto, 1fr, auto),
    align: (left + horizon, left + horizon, center + horizon),
    inset: (x: .6em, y: .45em),
    table.header(
      stress[Question],
      stress[Experiment],
      stress[Status],
    ),
    table.hline(stroke: 0.6pt + ox.rule),
    [RQ1: Expressiveness], [#todo[Which specs can each tool express?]], partial,
    [RQ2: Performance], [#todo[Time-to-chain on benchmark suite]], partial,
    [RQ3: Scale], [#todo[Large real-world binaries]], todo-st,
    [RQ4: Guarded chains], [#todo[Case studies]], todo-st,
  ))
]

// ── Publication plans ───────────────────────────────────────────────────

#slide(title: [Publication plan])[
  #set text(size: 17pt)
  #let tool(c, name) = text(font: mono-font, fill: c, weight: "medium", name)
  #align(center + horizon, table(
    columns: (auto, auto, 1fr, auto),
    align: (left + horizon,) * 4,
    inset: (x: .6em, y: .55em),
    table.header(
      stress[Work], stress[Venue], stress[Status], stress[Thesis],
    ),
    table.hline(stroke: 0.6pt + ox.rule),
    tool(ox.paper1)[crackers],
    [USENIX Security ’25],
    text(fill: ox.success)[Published (Aug 2025)],
    [Ch. 3--5],

    tool(ox.paper2)[simulacrop],
    [USENIX WOOT ’27],
    [Revising after S&P ’27 and USENIX Sec ’27; submit \~Dec 2026],
    [Ch. 6, 8],

    tool(ox.ongoing)[guarded synthesis],
    [#todo[venue?]],
    [#todo[Fold into `simulacrop`, or a separate third paper?]],
    [Ch. 7],
  ))
]

#cols-slide(title: [Revising simulacrop], columns: (1fr, 1fr, 1.2fr))[
  #stress[What reviewers said]
  - #todo[Feedback theme 1]
  - #todo[Feedback theme 2]
  - #todo[Feedback theme 3]
][
  #stress[What we are changing]
  - #todo[Response 1]
  - #todo[Response 2]
  - #todo[Response 3]
][
  #stress[If WOOT says no]
  - #todo[Fallback venue(s)]
  - Preprint + code release anyway
  - Thesis doesn't hinge on acceptance
]

// ── Thesis submission ───────────────────────────────────────────────────

#slide(title: [Thesis structure])[
  // Word counts as of 27 Nov 2026 (dissertation/text/ch*.tex).
  #let st(fill, body) = text(size: .8em, fill: fill, weight: "medium", body)
  #let drafted = st(ox.success)[drafted]
  #let partial = st(ox.oxsienna)[in progress]
  #let stub = st(ox.danger)[outline]
  #let src(c, name) = text(font: mono-font, size: .85em, fill: c, name)
  #set text(size: 16pt)
  #align(center + horizon, table(
    columns: (auto, auto, auto, auto),
    align: (right + horizon, left + horizon, left + horizon, center + horizon),
    inset: (x: .6em, y: .32em),
    table.header([], stress[Chapter], stress[Source], stress[Status]),
    table.hline(stroke: 0.6pt + ox.rule),
    [1], [Introduction], [], partial,
    [2], [Background], [], drafted,
    [3], [P-Code Modeling], src(ox.paper1)[crackers], drafted,
    [4], [Conflict-Driven Synthesis], src(ox.paper1)[crackers], drafted,
    [5], [Evaluation: Conflict-Driven], src(ox.paper1)[crackers], stub,
    [6], [Goal-Directed Synthesis], src(ox.paper2)[simulacrop], partial,
    [7], [Guarded Synthesis], src(ox.ongoing)[guarded], stub,
    [8], [Evaluation: Goal-Directed], src(ox.paper2)[simulacrop], stub,
    [9], [Prospects], [], stub,
  ))
]

#slide(title: [Submission timeline])[
  // All dates provisional.
  #todo[check dates]
  #align(center + horizon, box(width: 92%, gantt(
    start: (2026, 12),
    end: (2027, 12),
    gt-group[Research],
    gt-task((2026, 12), (2027, 2), color: ox.ongoing)[Code changes],
    gt-task((2027, 1), (2027, 4), color: ox.ongoing)[Experiments],
    gt-group[Publication],
    gt-milestone((2026, 12))[`simulacrop` → WOOT ’27],
    gt-milestone((2027, 3))[WOOT notification],
    gt-group[Thesis],
    gt-task((2026, 12), (2027, 1), color: ox.paper1)[Ch. 5 (from `crackers`)],
    gt-task((2027, 1), (2027, 3), color: ox.paper2)[Ch. 6--7],
    gt-task((2027, 4), (2027, 5), color: ox.paper2)[Ch. 8],
    gt-task((2027, 5), (2027, 6), color: ox.oxsienna)[Ch. 1, 9, polish],
    gt-milestone((2027, 6))[Full draft to supervisor],
    gt-task((2027, 7), (2027, 8), color: ox.oxsienna)[Revisions],
    gt-milestone(key: true, (2027, 9))[Submission],
    gt-milestone((2027, 12))[Viva],
  )))
]
