#import "../oxford-theme.typ": *

// Text (left) + stack-overflow diagram (right).
#let stack-slide(title: none, diagram, body) = slide(title: title)[
  #cols(columns: (1fr, 1fr), gutter: 1.5em,
    align(horizon, body),
    align(center + horizon, image(diagram, width: 100%)),
  )
]

#stack-slide(title: [A C procedure and its stack frame], "../figures/c-stack-example.pdf")[
  // TODO: text
]

#stack-slide(title: [Two frames on the call stack], "../figures/c-stack-callsite.pdf")[
  // TODO: text
]

#stack-slide(title: [A stack-resident buffer], "../figures/c-stack-buffer.pdf")[
  // TODO: text
]

#stack-slide(title: [Stack canaries], "../figures/c-stack-canary.pdf")[
  // TODO: text
]

#figure-slide(title: [Code-reuse attacks],
  image("../figures/execve-chain.pdf", height: 100%),
)
