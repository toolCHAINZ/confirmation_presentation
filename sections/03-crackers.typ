#import "../oxford-theme.typ": *
#import "../oxford-colors.typ" as ox
#import "@preview/cetz:0.3.4" as cetz

#title-slide[`crackers`: Conflict-driven Synthesis]

#slide(title: "Timeline")[
  #align(center + horizon, box(width: 75%, timeline(
    tl-point[Dec 2023][Began work],
    tl-point[May 2024][MVP completed],
    tl-point[Sep 2024][Submitted to USENIX Security],
    tl-range[Nov 2024][Jan 2025][Revisions],
    tl-range[Mar 2025][May 2025][Artifact evaluation],
    tl-point(key: true)[Aug 2025][Published at USENIX Security ’25],
  )))
]

#cols-slide(title: "Approach")[
  - The state of the art was SGC
  - SGC's chief issue was scalability
    - A fully-connected Single-Static-Assignment
      formula for all possible chains
    - Scales poorly with library size
    - Requires aggressive downsampling
][
  // ── SGC: one formula over every gadget in every chain slot ──
  #let sgc-fig = cetz.canvas(length: 1.35cm, {
    import cetz.draw: *
    let slots = ([1], [2], [$L$])
    let gadgets = ([$g_1$], [$g_2$], [$g_3$], [$g_N$])
    let (bw, bh, dx, dy) = (1.0, 0.55, 2.1, 0.85)
    let n = gadgets.len()
    let ys = range(n).map(r => (
      (n - 1) / 2 * dy - r * dy - if r == n - 1 { 0.35 } else { 0 }
    ))
    let xs = range(slots.len()).map(c => (c + 1) * dx)
    let x-end = (slots.len() + 1) * dx

    // Every gadget in slot k may be followed by every gadget in slot k+1.
    for y in ys { line((0.45, 0), (xs.first() - bw / 2, y), stroke: diag.wire) }
    for c in range(slots.len() - 1) {
      for y0 in ys {
        for y1 in ys {
          line(
            (xs.at(c) + bw / 2, y0),
            (xs.at(c + 1) - bw / 2, y1),
            stroke: diag.wire,
          )
        }
      }
    }
    for y in ys {
      line((xs.last() + bw / 2, y), (x-end - 0.45, 0), stroke: diag.wire)
    }

    for (c, x) in xs.enumerate() {
      for (r, y) in ys.enumerate() {
        rect((x - bw / 2, y - bh / 2), (x + bw / 2, y + bh / 2), ..diag-rect)
        content((x, y), text(size: 14pt, gadgets.at(r)))
      }
      content((x, (ys.at(n - 2) + ys.at(n - 1)) / 2), text(
        size: 11pt,
        fill: diag.label,
      )[$dots.v$])
      content((x, ys.last() - 0.75), diag-label[slot #slots.at(c)])
    }
    content((xs.at(1) + dx / 2, ys.last() - 0.75), text(
      size: 11pt,
      fill: diag.label,
    )[$dots$])

    circle((0, 0), radius: 0.45, ..diag-node)
    content((0, 0), text(size: diag.size, fill: diag.on-node)[pre])
    circle((x-end, 0), radius: 0.45, ..diag-node)
    content((x-end, 0), text(size: diag.size, fill: diag.on-node)[post])

    // The whole thing is a single SMT query.
    let top = ys.first() + bh / 2 + 0.25
    rect(
      (-0.75, ys.last() - 1.15),
      (x-end + 0.75, top + 0.55),
      stroke: diag.group,
      radius: 4pt,
    )
    content((x-end / 2, top + 0.25), text(
      size: 14pt,
      fill: diag.group-label,
    )[one SSA formula])
  })

  #align(center + horizon, stack(spacing: 1em, sgc-fig, diag-label[
    $N$ gadgets #sym.times $L$ slots
    $=> N^L$ candidate chains in one query
  ]))
]

#cols-slide(title: "Approach")[
  - Can we improve scalability?
    - Models of individual chains are cheap to reason over
    - Separating gadget selection from byte-precise chain modeling could avoid SMT blowup and allow extra candidates.
  - Can we improve flexibility?
    - SGC's artifact is specific to x64
    - Can we be architecture-agnostic?
][
  // ── crackers: SAT picks gadget ids per slot; SMT checks one chain at a time ──
  #let crackers-fig = cetz.canvas(length: 1.05cm, {
    import cetz.draw: *
    let picks = ([$g_7$], [$g_2$], [$g_41$])
    let (bw, bh) = (1.0, 0.55)
    let xs = (2.6, 4.5, 6.4)
    let arrow = (stroke: diag.stroke, mark: diag.mark)
    let group(a, b, label) = {
      rect(a, b, stroke: diag.group, radius: 4pt)
      content(((a.at(0) + b.at(0)) / 2, b.at(1) - 0.3), text(
        size: diag.size,
        fill: diag.group-label,
        label,
      ))
    }
    let gadget(x, y, body) = {
      rect((x - bw / 2, y - bh / 2), (x + bw / 2, y + bh / 2), ..diag-rect)
      content((x, y), text(size: 14pt, body))
    }

    // Selection: one SAT problem assigns a gadget id to every slot.
    group((0, 4.2), (9, 6.4), [one SAT problem: pick a gadget per slot])
    for (i, x) in xs.enumerate() {
      gadget(x, 5.25, picks.at(i))
      content((x, 4.6), diag-label[slot #(i + 1)])
    }

    // Hand one candidate down to be modelled concretely.
    line((4.5, 4.2), (4.5, 3.1), ..arrow)
    content((4.35, 3.65), anchor: "east", diag-label[candidate])

    // Validation: one SMT problem for just this chain.
    group((0, 0.8), (9, 3.1), [one SMT problem per candidate])
    let y = 1.65
    circle((0.9, y), radius: 0.52, ..diag-node)
    content((0.9, y), text(size: diag.size, fill: diag.on-node)[pre])
    circle((8.1, y), radius: 0.52, ..diag-node)
    content((8.1, y), text(size: diag.size, fill: diag.on-node)[post])
    for (i, x) in xs.enumerate() { gadget(x, y, picks.at(i)) }
    let stops = (
      (1.42,) + xs.map(x => (x - bw / 2, x + bw / 2)).flatten() + (7.58,)
    )
    for i in range(0, stops.len(), step: 2) {
      line((stops.at(i), y), (stops.at(i + 1), y), ..arrow)
    }

    // Failure feeds back into selection; success ends the search.
    bezier((9, 1.95), (9, 5.3), (10.3, 1.95), (10.3, 5.3), ..arrow)
    content(
      (10.15, 3.65),
      anchor: "west",
      diag-label[UNSAT core\ #sym.arrow.r conflict clause],
    )
    line((4.5, 0.8), (4.5, 0.0), ..arrow)
    content((4.5, -0.3), diag-label[valid chain])
  })

  #align(center + horizon, stack(spacing: 1em, crackers-fig))
]

#focus-slide[Design Decisions]

#cols-slide(title: "How to describe Gadgets?", columns: (2fr, 1fr))[
  - Chose the #stress[P-Code] IL of Ghidra
    - RE-focused RTL-style IL
    - Support for #stress[30+ ISAs] bundled in Ghidra
  - A natural fit: we need to analyze and disassemble
    gadgets anyway
][
  #set align(center)
  #image("../figures/ghidra.svg")
]

#cols-slide(title: "Specification Form", columns: (2fr, 1fr))[
  - Need a specification language easily mappable to our
    model of gadget effects.
  #uncover("2-")[
    #grayed[P-Code programs can be specifications!]
  ]
][
  #set align(center)
  #uncover("2-")[
    #image("../figures/ghidra.svg")
  ]
]

#cols-slide(title: "P-Code in Brief", columns: (1.15fr, 1fr))[
  - #stress[Spaces]: flat, byte-addressed state
    - `register`, `ram`, `unique` (temporaries), `const`
  - #stress[Varnodes]: a fixed location $(s, ell, n)$
    - `RAX` $= ($`register`$, 0, 8)$
    - Overlapping varnodes model aliasing (`EAX`, `AL`, …)
  - #stress[Operations]: #emph[read] input varnodes, compute, #emph[write] at most one output varnode
    - `LOAD`/`STORE` for pointer-indirect access to `ram`
][
  #set align(horizon)
  ```pcode
  # pop rdi
  $U55480:8 = LOAD ram(RSP)
  RSP = INT_ADD RSP, 0x8:8
  RDI = COPY $U55480:8
  # ret
  RIP = LOAD ram(RSP)
  RSP = INT_ADD RSP, 0x8:8
  RETURN ram(RIP)
  ```
  #align(center, diag-label[x64 P-Code for `pop rdi; ret` (`5f c3`)])
]

#slide(title: "Modeling P-Code")[
  // ── The missing link: P-Code on one side, an SMT solver on the other ──
  #let gap-fig = cetz.canvas(length: 1.3cm, {
    import cetz.draw: *
    let (bw, bh) = (4.6, 1.6)
    let box-at(x, title, sub) = {
      rect((x - bw / 2, -bh / 2), (x + bw / 2, bh / 2), ..diag-rect)
      content((x, 0.22), text(size: 18pt, title))
      content((x, -0.35), diag-label(sub))
    }
    box-at(0, [P-Code], [gadgets & specifications])
    box-at(11, [SMT], [bit-vectors & arrays])
    line(
      (bw / 2 + 0.2, 0),
      (11 - bw / 2 - 0.2, 0),
      stroke: diag.group,
      mark: (end: ">", fill: diag.group-label, scale: 0.9),
    )
    content((5.5, 0.45), text(size: 26pt, fill: diag.group-label)[?])
  })

  #align(center, gap-fig)
  #v(1em)
  - Gadgets #emph[and] specifications are P-Code, so the solver must reason
    about P-Code directly
  - P-Code has no formal semantics #footnote[Though an operation semantics was defined by Naus #todo[cite]]: only documentation and the SLEIGH source
  - No existing SMT encoding we could adopt
]

#cols-slide(title: [Contribution: P-Code → SMT])[
  - Defined and implemented a multi-layered mapping of P-Code into SMT
    (bit-vectors + arrays)
    - #stress[State]: whole VM state as byte-precise terms
    - #stress[Read]: varnode #sym.arrow bit-vector
    - #stress[Operate]: state-free semantics $[|"op"|]$ per opcode
    - #stress[Write]: new state, updated at one varnode
  - `Read`; `Operate`; `Write` per op gives a gadget's final state over its initial state
][
  #image(
    "../figures/pcode-smt-layers.pdf",
    height: 100%,
  )
]

#cols-slide(title: [Contribution: conflict-driven synthesis], columns: (
  1fr,
  3fr,
))[
  - Gadget Selection $->$ SAT
  - Candidate Chain $->$ SMT
    - UNSAT Core $->$ SAT assertion
][
  #image(
    "../figures/synthesis-loop.pdf",
    width: 100%,
  )
]

#slide(title: "Evaluation")[
  - Needed a way to evaluate our method against others
  - Previous academic efforts tested against small fixed sets of binaries
  - USENIX reviewers wanted a broader evaluation
  #grayed[No existing benchmark for measuring CR synthesis]
]

#slide(title: "Contribution: A large CR benchmark")[
  - 1000 x64 binaries from the ALLSTAR #todo[cite] dataset
  - Synthesized a fixed specification expressable by all evaluated tools
    - `0xfacefeed(0xdeadbeef, 0x40, 0x7b)`
  - Intended as a measurement of ideal synthesis ability of each algorithm divorced from realistic constraints
]

#cols-slide(
  title: [Results (USENIX Security '25)],
  footer: [Main eval is `crackers` VS `SGC`; other tools evaluated for context],
)[
  #image(
    "../figures/crackers-all-tool.pdf",
  )
]

#slide(title: "Limitations")[
  - Evaluation setup does not hold to real-world constraints!
    - Difficult to fairly evaluate against tools that by construction uphold these constraints (e.g. `angrop` and `exrop`)
  - Succeeds at incremental improvement of SMT-based before/after synthesis
    - Imposes arbitrary order on chain operations
    - Allows larger gadget library, but still requires downsampling
    - Does not admit more complex gadgets
    - Does not admit more complex specifications
]
