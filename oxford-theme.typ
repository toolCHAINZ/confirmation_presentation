// Oxford theme for typslides.
// Colours come exclusively from oxford-colors.typ; fonts are bundled in fonts/.
//
// Usage:
//   #import "oxford-theme.typ": *
//   #show: oxford-theme.with(...)
//
// Everything typslides exports is re-exported here; the colour helpers
// (bluey, reddy, …), `framed` and `grayed` are shadowed with Oxford versions.

#import "@preview/typslides:1.4.0": *
#import "@preview/typslides:1.4.0" as ts
#import "oxford-colors.typ" as ox

// ── Typography ──────────────────────────────────────────────────────────
// typslides uses one face for everything; pick it with
// `typst compile --input fonts=<name>`.
#let presets = (
  plex: "IBM Plex Sans",
  plex-serif: "IBM Plex Serif",
  spectral: "Spectral",
  fira: "Fira Sans",
)
#let body-font = presets.at(sys.inputs.at("fonts", default: "plex"))
#let mono-font = "IBM Plex Mono"
#let header-font = "Spectral"

// ── Colour helpers: typslides' named colours mapped onto the Oxford palette ──
#let bluey(body) = text(fill: ox.oxroyalblue, body)
#let reddy(body) = text(fill: ox.oxred, body)
#let greeny(body) = text(fill: ox.oxgreen, body)
#let yelly(body) = text(fill: ox.oxsienna, body) // ochre is too light for text on white
#let purply(body) = text(fill: ox.oxplum, body)
#let dusky(body) = text(fill: ox.oxblue, body)
#let accented(body) = text(fill: ox.accent, body)
#let muted(body) = text(fill: ox.muted, body)

/// `framed` with the Oxford off-white instead of typslides' cream.
#let framed(title: none, back-color: none, content) = ts.framed(
  title: title,
  back-color: if back-color == none and title == none { ox.surface } else {
    back-color
  },
  content,
)

/// `grayed` on the Oxford off-white.
#let grayed(text-size: 24pt, fill-color: ox.surface, content) = ts.grayed(
  text-size: text-size,
  fill-color: fill-color,
  content,
)

/// Flag something to come back to:  #todo[tighten wording]   or bare  #todo()
/// Renders as a coral tag inline. Hide all of them for a clean build with
/// `typst compile --input todos=hide main.typ`; list them with `just todos`.
#let todo(..args) = {
  if sys.inputs.at("todos", default: "show") == "hide" { return }
  let body = args.pos().at(0, default: none)
  box(
    fill: ox.accent.lighten(80%),
    stroke: 0.6pt + ox.accent,
    radius: 2pt,
    inset: (x: .35em, y: .2em),
    text(size: .7em, fill: ox.danger, [TODO#if body != none [: #body]]),
  )
}

/// Vertical timeline. Entries are built with `tl-point` (a single date) and
/// `tl-range` (a start–end span, drawn as a capsule on the spine):
///   #timeline(
///     tl-point[Dec 2023][Began work],
///     tl-range[Nov 2024][Jan 2025][Revisions],
///     tl-point(key: true)[Aug 2025][Published],
///     tl-point(future: true)[Dec 2025][Planned submission],
///   )
/// `key: true` marks a milestone in the accent colour. `future: true` marks a
/// planned entry: hollow dashed marker, dashed spine leading into it, and
/// muted italic text.
#let tl-point(key: false, future: false, date, body) = (
  date: date,
  body: body,
  range: false,
  key: key,
  future: future,
)
#let tl-range(key: false, future: false, start, end, body) = (
  date: [#start -- #end],
  body: body,
  range: true,
  key: key,
  future: future,
)
#let timeline(row-height: 2.3em, color: ox.header, ..entries) = {
  let es = entries.pos()
  let n = es.len()
  let spine-w = 1.6em
  let spine-color = color.lighten(45%)
  let spine(dashed) = (
    paint: spine-color,
    thickness: 1.5pt,
    dash: if dashed { "dashed" } else { none },
  )
  let marker(e) = {
    let c = if e.key { ox.accent } else { color }
    let stroke(w) = (
      paint: c,
      thickness: w,
      dash: if e.future { "dashed" } else { none },
    )
    if e.range {
      rect(
        width: .75em,
        height: row-height * 0.72,
        radius: .375em,
        fill: if e.future { white } else { c.lighten(70%) },
        stroke: stroke(1.5pt),
      )
    } else {
      circle(
        radius: if e.key { .45em } else { .33em },
        fill: if e.key and not e.future { c } else { white },
        stroke: stroke(1.8pt),
      )
    }
  }
  // A spine segment between two entries is dashed when it leads into a
  // future entry, so the solid line stops at the last thing that happened.
  let segment(from, to, dashed) = place(
    top + center,
    dy: from * row-height,
    line(length: (to - from) * row-height, angle: 90deg, stroke: spine(dashed)),
  )
  let spine-cell(i, e) = box(width: spine-w, height: row-height, {
    // Half-segments above and below the marker (omitted past the ends).
    if i > 0 { segment(0, 0.5, e.future) }
    if i < n - 1 { segment(0.5, 1, es.at(i + 1).future) }
    place(center + horizon, marker(e))
  })
  grid(
    columns: (auto, spine-w, 1fr),
    rows: row-height,
    column-gutter: .7em,
    align: (right + horizon, center + horizon, left + horizon),
    ..es
      .enumerate()
      .map(((i, e)) => (
        text(
          size: .85em,
          fill: if e.key { ox.accent } else { ox.muted },
          weight: if e.key { "medium" } else { "regular" },
          style: if e.future { "italic" } else { "normal" },
          e.date,
        ),
        spine-cell(i, e),
        {
          let body = if e.key { strong(e.body) } else { e.body }
          if e.future { text(fill: ox.muted, style: "italic", body) } else {
            body
          }
        },
      ))
      .flatten(),
  )
}

/// Month-granularity Gantt chart. Dates are `(year, month)` pairs. Rows are
/// built with `gt-task` (a bar spanning whole months, inclusive), `gt-milestone`
/// (a diamond in one month) and `gt-group` (a section heading):
///   #gantt(
///     start: (2026, 12), end: (2027, 12),
///     gt-group[Thesis],
///     gt-task((2027, 1), (2027, 3), color: ox.paper2)[Write Ch. 7],
///     gt-milestone(key: true, (2027, 9))[Submit],
///   )
/// `key: true` draws a milestone in the accent colour.
#let gt-task(color: ox.ongoing, from, to, body) = (
  kind: "task",
  from: from,
  to: to,
  body: body,
  color: color,
)
#let gt-milestone(key: false, at, body) = (
  kind: "milestone",
  from: at,
  to: at,
  body: body,
  key: key,
)
#let gt-group(body) = (kind: "group", body: body)
#let gantt(
  start: (2026, 12),
  end: (2027, 12),
  label-width: auto,
  row-height: 1.25em,
  ..rows,
) = {
  let idx(d) = (d.at(0) - start.at(0)) * 12 + (d.at(1) - start.at(1))
  let n = idx(end) + 1
  let initials = ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")
  let month-of(i) = calc.rem(start.at(1) - 1 + i, 12) // 0-based month
  let year-of(i) = start.at(0) + calc.quo(start.at(1) - 1 + i, 12)

  // Year header: one spanning cell per (partial) year.
  let years = ()
  let i = 0
  while i < n {
    let y = year-of(i)
    let span = calc.min(12 - month-of(i), n - i)
    years.push(grid.cell(colspan: span, align: center, text(
      size: .7em,
      fill: ox.muted,
      weight: "medium",
      str(y),
    )))
    i += span
  }
  let months = range(n).map(i => align(center, text(
    size: .6em,
    fill: ox.muted,
    initials.at(month-of(i)),
  )))

  let label(body, weight: "regular") = align(
    right + horizon,
    text(size: .75em, weight: weight, body),
  )
  let bar(c) = box(
    width: 100%,
    height: row-height * 0.55,
    fill: c,
    radius: 2pt,
  )
  let diamond(c) = align(center + horizon, rotate(45deg, square(
    size: row-height * 0.42,
    fill: c,
    stroke: none,
  )))

  let body-rows = rows
    .pos()
    .map(r => {
      if r.kind == "group" {
        return (
          grid.cell(
            colspan: n + 1,
            align: left,
            inset: (top: .55em, bottom: .1em),
            text(
            size: .75em,
            fill: ox.primary,
            weight: "semibold",
            r.body,
          ),
          ),
        )
      }
      let (f, t) = (idx(r.from), idx(r.to))
      let mark = if r.kind == "task" { bar(r.color) } else {
        diamond(if r.key { ox.accent } else { ox.header })
      }
      (
        label(r.body, weight: if r.kind == "milestone" and r.key {
          "semibold"
        } else { "regular" }),
        ..range(f).map(_ => []),
        grid.cell(colspan: t - f + 1, align: horizon, mark),
        ..range(n - t - 1).map(_ => []),
      )
    })
    .flatten()

  grid(
    columns: (label-width,) + (1fr,) * n,
    row-gutter: 0pt,
    column-gutter: 0pt,
    inset: (x: 1pt, y: .12em),
    rows: (auto, auto) + (row-height,) * 0,
    // Faint month rules; stronger at year boundaries.
    ..range(1, n).map(i => grid.vline(x: i + 1, start: 1, stroke: if month-of(
        i,
      )
        == 0 { 0.6pt + ox.muted.lighten(40%) } else { 0.3pt + ox.rule })),
    [], ..years,
    [], ..months,
    grid.hline(y: 2, start: 1, stroke: 0.6pt + ox.rule),
    ..body-rows,
  )
}

// ── Diagram style ───────────────────────────────────────────────────────
// One look for every hand-drawn figure, whether cetz or fletcher. Everything
// is derived from the semantic roles in oxford-colors.typ, so retheming the
// palette rethemes the diagrams.

/// Raw style tokens.
#let diag = (
  ink: ox.header, // outlines, arrows, emphasis
  stroke: 0.6pt + ox.header, // box / node outline
  wire: 0.4pt + ox.header.lighten(45%), // dense background connections
  mark: (end: ">", fill: ox.header, scale: 0.7), // cetz arrowhead
  fill: ox.surface, // box / node fill
  radius: 2pt,
  inset: (x: .5em, y: .4em),
  size: 13pt, // text inside boxes
  label: ox.muted, // captions and axis labels
  highlight: ox.accent.lighten(55%), // background for a highlighted line
  group: (paint: ox.accent, thickness: 0.8pt, dash: "dashed"), // dashed grouping outline
  group-label: ox.accent,
  node: ox.header, // solid-filled state nodes
  on-node: ox.on-header, // text on a solid node
)

/// Muted caption beside or under a figure.
#let diag-label(body) = text(size: diag.size, fill: diag.label, body)

/// Outlined box holding left-aligned content (code, a gadget, …).
#let diag-box(body, stroke: diag.stroke, inset: diag.inset) = box(
  fill: diag.fill,
  stroke: stroke,
  inset: inset,
  radius: diag.radius,
  align(left, text(size: diag.size, body)),
)

/// A gadget as a stack of lines; pass `(line, fill)` to highlight one.
///   #diag-gadget([`pop rdi`], ([`mov [rbx], rax`], diag.highlight), [`ret`])
#let diag-gadget(..lines) = diag-box(inset: (x: .7em, y: .5em), stack(
  spacing: .3em,
  ..lines
    .pos()
    .map(l => if type(l) == array {
      let (body, fill) = l
      box(fill: fill, outset: (x: .3em, y: .2em), radius: 1pt, body)
    } else { l }),
))

/// Spread into `fletcher.diagram(..diag-fletcher, …)`.
#let diag-fletcher = (
  edge-stroke: diag.stroke,
  node-stroke: diag.stroke,
  node-fill: diag.fill,
  node-corner-radius: diag.radius,
  node-inset: .4em,
)

/// Spread into cetz `rect(a, b, ..diag-rect)` for a box.
#let diag-rect = (fill: diag.fill, stroke: diag.stroke, radius: diag.radius)
/// Spread into cetz `circle(c, ..diag-node)` for a solid state node; label it
/// with `text(fill: diag.on-node, …)`.
#let diag-node = (fill: diag.node, stroke: none)

/// Centred figure filling the slide body.
#let figure-slide(title: none, ..figures) = slide(title: title, align(
  center + horizon,
  {
    let fs = figures.pos()
    if fs.len() == 1 { fs.first() } else { stack(spacing: 1em, ..fs) }
  },
))

/// Multi-column slide built on typslides' `cols`: one column per content block.
///   #cols-slide(title: [Title])[left][middle][right]
/// Columns are equal width unless `columns` is given, e.g. `columns: (1fr, 2fr)`.
/// `footer` is pinned to the bottom of the slide; the columns stay centred above it.
#let cols-slide(
  title: none,
  columns: auto,
  gutter: 1.5em,
  footer: none,
  ..bodies,
) = {
  let bs = bodies.pos()
  let main = cols(
    columns: if columns == auto { (1fr,) * bs.len() } else { columns },
    gutter: gutter,
    ..bs,
  )
  slide(
    title: title,
    if footer == none { main } else {
      v(1fr)
      main
      v(1fr)
      footer
    },
  )
}

// ── Theme entry point ───────────────────────────────────────────────────

#let oxford-theme(ratio: "16-9", show-progress: true, ..args, body) = {
  show: typslides.with(
    ratio: ratio,
    theme: ox.header,
    font: body-font,
    font-size: 20pt,
    show-progress: show-progress,
    back-color: ox.bg,
    ..args,
  )
  set text(fill: ox.ink)
  // typslides hard-codes semibold white for header/section text; soften colour and weight.
  show text.where(fill: white): set text(
    font: header-font,
    fill: ox.on-header,
    weight: "regular",
  )
  show text.where(fill: white, size: 12pt): set text(
    font: body-font,
    fill: ox.on-header-muted,
  )
  show raw: set text(font: mono-font, weight: "regular")
  show raw.where(block: true): set raw(
    syntaxes: "pcode.sublime-syntax",
    theme: "oxford.tmTheme",
  )
  show raw.where(block: true): it => block(
    width: 100%,
    fill: ox.surface,
    inset: (x: .8em, y: .65em),
    radius: 2pt,
    it,
  )
  show raw.where(block: false): set text(fill: ox.oxviridian)
  show link: set text(fill: ox.link-color)
  show strong: set text(weight: "semibold", fill: ox.primary)
  set table(stroke: none)
  body
}
