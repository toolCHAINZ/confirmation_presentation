#import "../oxford-theme.typ": *
#import "../oxford-colors.typ" as ox

#title-slide[`simulacrop`#footnote[Name subject to revision]: Goal-directed Synthesis]

#slide(title: [Design goals, revisited])[
  // ✓ met · ~ partly met · ✗ not met. Columns coloured by paper.
  #let mark(fill, body) = text(size: 1.35em, fill: fill, weight: "bold", body)
  #let yes = mark(ox.success, sym.checkmark)
  #let part = mark(ox.oxsienna)[\~]
  #let no = mark(ox.danger, sym.times)
  #let goal(body) = (
    table.cell(colspan: 3, inset: (top: .7em, bottom: .25em), stress(body)),
  )
  #let row(body, a, b, note: none) = (
    [#body#if note != none [ #text(size: .75em, fill: ox.muted, note)]],
    a,
    b,
  )
  #set text(size: 18pt)
  #align(center + horizon, table(
    columns: (auto, 7em, 7em),
    align: (left + horizon, center + horizon, center + horizon),
    stroke: none,
    inset: (x: .6em, y: .3em),
    table.header(
      [],
      text(font: mono-font, fill: ox.paper1, weight: "medium")[crackers],
      text(font: mono-font, fill: ox.paper2, weight: "medium")[simulacrop],
    ),
    table.hline(stroke: 0.6pt + ox.rule),
    ..goal[1. Greater Expressive Power],
    ..row(
      [Specs other tools support],
      part,
      yes,
      note: [(`crackers`: fixed linear order)],
    ),
    ..row([Specs no other tool supports], no, yes, note: [(guarded chains)]),
    ..goal[2. Greater Synthesis Flexibility],
    ..row([No semantic binning of gadgets], yes, yes),
    ..row(
      [No fixed gadget shape],
      no,
      yes,
      note: [(multi-block, guard gadgets)],
    ),
    ..row([No architecture-specific assumptions], yes, yes),
    ..goal[3. Without Compromising on Scale],
    ..row(
      [Match or beat existing tools],
      part,
      yes,
      note: [(`crackers`: idealised benchmark)],
    ),
  ))
]

#slide(title: "Timeline")[
  #align(center + horizon, box(width: 87%, timeline(
    tl-point[July 2025][Began P-Code Analysis Work],
    tl-point[January 2026][Began Synthesis Algorithm Work],
    tl-point[May 2026][MVP completed],
    tl-point[June 2026][Submission to IEEE S&P 2027 (rejected)],
    tl-range[July][August 2026][Revisions],
    tl-point[August 2026][Submission to USENIX Security '27 (rejected)],
    tl-range[October 2026][Present][Revisions],
    tl-point(future: true)[\~December 2026][Submission to USENIX WOOT 2027],
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
