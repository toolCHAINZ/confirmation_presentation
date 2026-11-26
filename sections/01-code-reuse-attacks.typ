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

#slide(title: "Mitigation: ASLR")[
  #grayed("A program's memory layout should change every execution")
]

#slide(title: [Code Reuse Attacks])[
  - Corrupt control data to force a program to follow an attacker-chosen path through its
    own code
  - No need for code injection: the code is already there!
  - No need to bypass $W \xor X$: the code is already executable!
]


#figure-slide(title: [Code-reuse attacks],
  image("../figures/execve-chain.pdf", height: 100%),
)

#slide(title: [A general technique])[
  - Also applicable in heap/Use-After-Free scenarios after some setup
  - Code-Reuse Attacks are a big deal, and are ubiquitous in modern exploitation @burow2019sok
  - Powerful processor and kernel mitigations work, but are not ubiquitous
  - CR Attacks will be relevant for some time yet
]

// I need to put something somewhere in here about ROP and turing completeness. Not sure
// if here or the next section

#slide(title: [Terminology])[
  - #stress[Code-Reuse (CR) Attacks]: attacks that violate control-flow integrity using existing code
  - #stress[Return-Oriented Programming (ROP)]: a particular subset of CR attack
    - Only `ret`-type gadgets
    - Formalized by Shacham @shacham2007geometry
    - Turing-Complete
    - Often used informally as a term for CR
  - #stress[Gadget/ROP Gadget]: a small piece of code used in a CR attack/ROP attack
  - #stress[Chain/ROP Chain]: a sequence of gadgets; the ending artifact of a CR/ROP attack
  - #stress[Exploit Practitioner]: A term coined by Dullien (cite) to describe non-academic security researchers (e.g. industrial researchers, hackers, etc)
]