#import "../oxford-theme.typ": *

#focus-slide("Goals")

#slide(title: "State-of-the-Art (2023)")[
  - Automation exists, but is brittle
  - ROP synthesizers exist for x86/x64 linux targets and not much else
    - Trying to exploit firmware on a ARM64 or RISCV RTOS? Prepare to ROP by hand.
  - ROP is Turing-Complete, BUT:
    - In practice, "most" ROP is 
]