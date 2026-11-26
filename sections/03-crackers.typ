#import "../oxford-theme.typ": *

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

#cols-slide[
  - The state of the art at the time was SGC
  - SGC's chief issue was scalability
    - A fully-connected Single-Static-Assignment
      formula for all possible chains
    - Scales poorly with library size
    - Requires aggressive downsampling
][
  #todo[figure of sgc's algorithm. Mainly want to emphasize the synth method: it builds a single formula representing all combinations of N gadgets up to length L. This looks like a fully connected graph of blocks connecting a start and an end state. I'd like a simple diagram of this]
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
