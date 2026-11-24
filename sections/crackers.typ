#import "../oxford-theme.typ": *

#title-slide[Conflict-driven]

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
