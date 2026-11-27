#import "../oxford-theme.typ": *

#title-slide[`simulacrop`#footnote[Name subject to revision]: Goal-directed Synthesis]

#slide[
  #todo[a checklist of my goals vs crackers, showing that this one gets them all]
]

#slide(title: "Timeline")[
  #align(center + horizon, box(width: 80%, timeline(
    tl-point[July 2025][Began P-Code Analysis Work],
    tl-point[January 2026][Began Synthesis Algorithm Work],
    tl-point[May 2026][MVP completed],
    tl-point[June 2026][Submission to IEEE S&P 2027 (rejected)],
    tl-range[July][August 2026][Revisions],
    tl-point[August 2026][Submission to USENIX Security '27 (rejected)],
    tl-range[October 2026][Present][Revisions],
    tl-point[$~$ December 2026][Submission to USENIX WOOT 2027 #todo[might be good to have an explicit "future" style]]
  )))
]


#figure-slide(title: [Key idea: search backwards from goals], image(
  "../figures/search-loop.pdf",
  height: 100%,
))

#figure-slide(
  title: [Patches and residuals],
  image("../figures/basic-constraints.pdf", height: 45%),
  image("../figures/register-overlap.pdf", height: 40%),
)

#figure-slide(
  title: [Guarded synthesis],
  image("../figures/guarded-patch.pdf", height: 45%),
  image("../figures/guarded-scheduling.pdf", height: 45%),
)
