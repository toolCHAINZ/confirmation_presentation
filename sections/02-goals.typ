#import "../oxford-theme.typ": *
#import "../oxford-colors.typ" as ox
#import "@preview/primaviz:0.12.1" as pv
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.3.4" as cetz

#focus-slide("Automated CR Synthesis")

#blank-slide()[
  Given a #stress[specification] and a #stress[binary], can we automatically construct a CR Attack?
]

#focus-slide[A wide design space]

#cols-slide(title: "Specifications")[
  - What is the form of the specification?
  - How expressive should it be?
][
  #set text(size: 14pt)
  // Example specifications, from least to most expressive.
  #let spec(level, body) = (text(fill: ox.muted, level), body)
  #grid(
    columns: (auto, 1fr),
    column-gutter: .8em,
    row-gutter: .55em,
    align: (right + horizon, left + horizon),
    ..spec[Concrete Register Assignments][`rax = 59`],
    ..spec[Data movement][`rdi ← rsp + 8`],
    ..spec[Operations & Memory][`*0x800000 ← rax + rbx`],
    ..spec[Logic][`if rax = 0 then …`],
  )
  #v(.6em)
  #show regex("\d"): hide
  #pv.line-chart(
    (
      labels: ("Values", "Movement", "Operations", "Logic"),
      values: (1, 2, 4, 9),
    ),
    width: 100%,
    height: 6.5cm,
    line-interpolation: "catmull-rom",
    x-label: [Specification complexity],
    y-label: [Synthesis difficulty],
    theme: (
      ..pv.themes.presentation,
      palette: (ox.header,),
      text-color: ox.ink,
      text-color-light: ox.muted,
      axis-stroke: 0.5pt + ox.rule,
    ),
  )
]

#cols-slide(title: "Gadgets", columns: (1fr, 2fr))[
  - What counts as a gadget?
  - How do we find them?
][
  #set text(size: 14pt)
  #let cap(body) = text(size: 13pt, fill: ox.muted, body)
  #let blk(body) = box(
    fill: ox.surface,
    stroke: 0.6pt + ox.header,
    inset: (x: .5em, y: .4em),
    radius: 2pt,
    align(left, text(size: 13pt, body)),
  )

  // ── Gadget shape: one basic block vs. a control-flow graph ──
  #align(center, grid(
    columns: (auto, auto),
    column-gutter: 3em,
    row-gutter: .5em,
    align: center + horizon,
    blk[`pop rdi`\ `pop rsi`\ `ret`],
    // The entry node, `ret` and the caption share one centre line: both side
    // columns get the wider branch's width, and the narrower `pop rdi` side is
    // padded so the diagram's bounding box is symmetric about that line.
    context {
      let w(body) = measure(text(size: 13pt, body)).width
      let (narrow, wide) = (w[`pop rdi`], w[`mov rdi, rbx`])
      pad(left: (wide - narrow) / 2, fletcher.diagram(
      cell-size: (wide + .8em, 0pt),
      spacing: (1.4em, 1.3em),
      edge-stroke: 0.6pt + ox.header,
      node-stroke: 0.6pt + ox.header,
      node-fill: ox.surface,
      node-corner-radius: 2pt,
      node-inset: .4em,
      {
        let n(pos, body, name) = fletcher.node(pos, text(size: 13pt, body), name: name)
        n((1, 0), [`pop rsi`\ `test rax, rax`\ `je L`], <a>)
        n((0, 1), [`pop rdi`], <b>)
        n((2, 1), [`mov rdi, rbx`], <c>)
        n((1, 2), [`ret`], <d>)
        fletcher.edge(<a>, <b>, "-|>")
        fletcher.edge(<a>, <c>, "-|>")
        fletcher.edge(<b>, <d>, "-|>")
        fletcher.edge(<c>, <d>, "-|>")
      },
    ))
    },
    cap[#stress[Simple]], cap[#stress[Complicated]],
  ))

  #v(1em)

  // ── Gadget discovery over the same bytes ──
  #let bytes = ("48", "89", "c7", "5f", "c3", "0f", "1f", "41", "5e", "c3")
  #let cell = 1.0
  #let strip(overlay) = cetz.canvas(length: 1cm, {
    import cetz.draw: *
    for (i, b) in bytes.enumerate() {
      let is-ret = b == "c3"
      rect(
        (i * cell, 0), ((i + 1) * cell, cell),
        fill: if is-ret { ox.accent.lighten(55%) } else { ox.surface },
        stroke: 0.5pt + ox.rule,
      )
      content(((i + 0.5) * cell, cell / 2), text(size: 12pt, font: "IBM Plex Mono", b))
    }
    overlay(bytes)
  })

  #let backward(bytes) = {
    import cetz.draw: *
    for (r, b) in bytes.enumerate() {
      if b != "c3" { continue }
      for k in (1, 2, 3) {
        let (x0, x1) = ((r + 0.5) * cell, (r - k + 0.5) * cell)
        bezier(
          (x0, cell), (x1, cell),
          (x0, cell + 0.3 + k * 0.3), (x1, cell + 0.3 + k * 0.3),
          stroke: 0.6pt + ox.header,
          mark: (end: ">", fill: ox.header, scale: 0.7),
        )
      }
    }
  }

  #let everywhere(bytes) = {
    import cetz.draw: *
    for i in range(bytes.len()) {
      let x = (i + 0.5) * cell
      line((x, cell + 0.9), (x, cell + 0.08),
        stroke: 0.6pt + ox.header,
        mark: (end: ">", fill: ox.header, scale: 0.7))
    }
  }

  #align(center, grid(
    columns: (auto, auto),
    column-gutter: 1em,
    row-gutter: .8em,
    align: (right + bottom, left + bottom),
    cap[Find `ret`s,\ look backward], strip(backward),
    cap[Decode from\ every offset], strip(everywhere),
  ))
]

#cols-slide(title: "Synthesis", columns: (1fr, 2fr))[
  - How to maintain control-flow?
  - How to avoid crashing side-effects?
  - How to scale with binary size?
][
  #set text(size: 14pt)
  #let cap(body) = text(size: 13pt, fill: ox.muted, body)
  #let blk(body, stroke: ox.header) = box(
    fill: ox.surface,
    stroke: 0.6pt + stroke,
    inset: (x: .7em, y: .5em),
    radius: 2pt,
    align(left, text(size: 13pt, body)),
  )
  // A gadget box whose lines can be individually highlighted.
  #let gadget(..lines) = blk(stack(
    spacing: .3em,
    ..lines.pos().map(l => if type(l) == array {
      let (body, fill) = l
      box(fill: fill, outset: (x: .3em, y: .2em), radius: 1pt, body)
    } else { l }),
  ))

  // ── Control flow: where does each gadget hand off? ──
  #let handoff(g, target, colour) = fletcher.diagram(
    spacing: (2em, 0pt),
    edge-stroke: 0.6pt + colour,
    {
      fletcher.node((0, 0), g, name: <g>)
      fletcher.node((1, 0), text(size: 13pt, fill: colour, target), name: <t>, inset: .2em)
      fletcher.edge(<g>, <t>, "-|>")
    },
  )
  #let fig-flow = grid(
    columns: (auto, auto),
    column-gutter: 1.5em,
    align: horizon,
    handoff(gadget[`pop rdi`][`ret`], [`[rsp]` = ?], ox.header),
    handoff(gadget[`pop rdi`][`jmp rax`], [`rax` = ?], ox.header),
  )

  // ── Side effects: useful vs. collateral instructions ──
  #let fig-effects = grid(
    columns: (auto, auto),
    column-gutter: 1em,
    align: (center + horizon, left + horizon),
    gadget(
      ([`pop rdi`]),
      ([`mov [rbx], rax`], ox.accent.lighten(55%)),
      ([`ret`]),
    ),
    cap[
      #text(fill: ox.accent)[■] may crash!
    ],
  )

  // ── Scale: candidate chains grow as nᵏ ──
  // n ≈ 10⁵ gadgets (typical libc); bar height is log₁₀(nᵏ) = 5k.
  #let fig-scale = cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let (bw, gap, sy) = (0.9, 0.35, 0.09)
    for k in range(1, 6) {
      let x = (k - 1) * (bw + gap)
      let h = 5 * k * sy
      rect((x, 0), (x + bw, h),
        fill: ox.header.lighten(100% - k * 15%), stroke: none)
      content((x + bw / 2, h + 0.25),
        text(size: 11pt, fill: ox.ink)[10#super[#(5 * k)]])
      content((x + bw / 2, -0.3), text(size: 11pt, fill: ox.muted, str(k)))
    }
    line((-0.1, 0), (5 * (bw + gap) - gap + 0.1, 0), stroke: 0.5pt + ox.rule)
    content(((5 * (bw + gap) - gap) / 2, -0.8),
      text(size: 11pt, fill: ox.muted)[chain length])
  })

  #align(center, grid(
    columns: (auto, auto),
    column-gutter: 1.2em,
    row-gutter: 2.4em,
    align: (right + horizon, left + horizon),
    cap[Every gadget must\ hand off to the next], fig-flow,
    cap[Gadgets have\ side-effects], fig-effects,
    cap[Possible $N$-length chains\ for \~10#super[5] gadgets], fig-scale,
  ))
]

#slide(title: "State-of-the-Art (2023)")[
  - Many practitioners still still make ROP chains #stress[by hand].
  - Several automated ROP synthesizers exist
    - Exploit-Practitioner community tools target fixed specifications, using
      (e.g. `execve`) using fixed strategies
    - But lack wider platform support (e.g. only x64 linux supported)/lack flexibility
    - Academic approaches use more sophisiticated semantic searches
    - But these may still rely on templates, or else require expensive SAT/SMT solving, limiting their scalability
  - ROP is Turing-Complete, and two methods are published for synthesizing arbitrary programs
    - Both rely on 
]