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
    let ys = range(n).map(r => (n - 1) / 2 * dy - r * dy - if r == n - 1 { 0.35 } else { 0 })
    let xs = range(slots.len()).map(c => (c + 1) * dx)
    let x-end = (slots.len() + 1) * dx

    // Every gadget in slot k may be followed by every gadget in slot k+1.
    for y in ys { line((0.45, 0), (xs.first() - bw / 2, y), stroke: diag.wire) }
    for c in range(slots.len() - 1) {
      for y0 in ys { for y1 in ys {
        line((xs.at(c) + bw / 2, y0), (xs.at(c + 1) - bw / 2, y1), stroke: diag.wire)
      } }
    }
    for y in ys { line((xs.last() + bw / 2, y), (x-end - 0.45, 0), stroke: diag.wire) }

    for (c, x) in xs.enumerate() {
      for (r, y) in ys.enumerate() {
        rect((x - bw / 2, y - bh / 2), (x + bw / 2, y + bh / 2),
          ..diag-rect)
        content((x, y), text(size: 14pt, gadgets.at(r)))
      }
      content((x, (ys.at(n - 2) + ys.at(n - 1)) / 2), text(size: 11pt, fill: diag.label)[$dots.v$])
      content((x, ys.last() - 0.75), diag-label[slot #slots.at(c)])
    }
    content((xs.at(1) + dx / 2, ys.last() - 0.75), text(size: 11pt, fill: diag.label)[$dots$])

    circle((0, 0), radius: 0.45, ..diag-node)
    content((0, 0), text(size: diag.size, fill: diag.on-node)[pre])
    circle((x-end, 0), radius: 0.45, ..diag-node)
    content((x-end, 0), text(size: diag.size, fill: diag.on-node)[post])

    // The whole thing is a single SMT query.
    let top = ys.first() + bh / 2 + 0.25
    rect((-0.75, ys.last() - 1.15), (x-end + 0.75, top + 0.55),
      stroke: diag.group, radius: 4pt)
    content((x-end / 2, top + 0.25), text(size: 14pt, fill: diag.group-label)[one SSA formula])
  })

  #align(center + horizon, stack(spacing: 1em,
    sgc-fig,
    diag-label[
      $N$ gadgets #sym.times $L$ slots
      $=> N^L$ candidate chains in one query
    ],
  ))
]

#cols-slide(title: "Approach")[
  - Can we improve scalability?
   - Models of individual chains are cheap to reason over
   - Separating gadget selection from byte-precise chain modeling could avoid SMT blowup and allow extra candidates.
  - Can we improve flexibility?
   - SGC is specific to x64
   - Can we be architecture-agnostic?
][
  #todo[Graphic showing crackers' very rough approach. This can be very high level, the important part is that we have one SAT problem for selecting gadgets (ids assigned to slots) and one SMT problem per candidate chain]
]

#figure-slide(title: [Why p-code?],
  image("../figures/ghidra.svg", height: 50%),
)

#figure-slide(title: [Contribution ①: p-code → SMT],
  image("../figures/pcode-smt-layers.pdf", height: 100%),
)

#slide(title: [Contribution ②: conflict-driven synthesis])[
  #cols(columns: (1fr, 1.3fr), gutter: 1.5em,
    align(center + horizon, image("../figures/step-partitions.pdf", width: 100%)),
    align(center + horizon, image("../figures/synthesis-loop.pdf", width: 100%)),
  )
]

#figure-slide(title: [Results (USENIX Security '25)],
  image("../figures/crackers-all-tool.pdf", height: 100%),
)
