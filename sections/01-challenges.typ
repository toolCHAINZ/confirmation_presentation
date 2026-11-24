#import "../oxford-theme.typ": *

// Text (left) + stack-overflow diagram (right).
#let stack-slide(title: none, diagram, body) = slide(title: title)[
  #cols(columns: (1fr, 1fr), gutter: 1.5em,
    align(horizon, body),
    align(center + horizon, image(diagram, width: 100%)),
  )
]

#focus-slide("Code-Reuse Attacks")

#stack-slide(title: [Stack Frames], "../figures/c-stack-example.pdf")[
  The #stress[stack] is a ubiquitous data structure used to hold local context. 
]

#stack-slide(title: [Control data], "../figures/c-stack-callsite.pdf")[
  Sometimes data is just data 

  Sometimes it controls the flow of execution
]

#stack-slide(title: [Buffer Overflows], "../figures/c-stack-buffer.pdf")[
  Legacy languages with no memory safety guarantees (e.g. C) allow programmers
  to make dumb mistakes

  One common mistake: stack buffer overflows

  #framed("Control data corruption " + $->$ +  " exploits")
]

#figure-slide(title: [Shell Code])[
#image("../figures/shellcode.pdf")
]

#slide(title: "Mitigation: " + $W xor X$)[
  #grayed("No memory should be both writable and executable")
]

#figure-slide(title: [Code-reuse attacks],
  image("../figures/execve-chain.pdf", height: 100%),
)
