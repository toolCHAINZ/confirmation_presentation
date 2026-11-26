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
  back-color: if back-color == none and title == none { ox.surface } else { back-color },
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
///   )
/// `key: true` marks a milestone in the accent colour.
#let tl-point(key: false, date, body) = (date: date, body: body, range: false, key: key)
#let tl-range(key: false, start, end, body) = (
  date: [#start -- #end], body: body, range: true, key: key,
)
#let timeline(row-height: 2.3em, color: ox.header, ..entries) = {
  let es = entries.pos()
  let n = es.len()
  let spine-w = 1.6em
  let spine = 1.5pt + color.lighten(45%)
  let marker(e) = {
    let c = if e.key { ox.accent } else { color }
    if e.range {
      rect(width: .75em, height: row-height * 0.72, radius: .375em,
        fill: c.lighten(70%), stroke: 1.5pt + c)
    } else {
      circle(radius: if e.key { .45em } else { .33em },
        fill: if e.key { c } else { white }, stroke: 1.8pt + c)
    }
  }
  let spine-cell(i, e) = box(width: spine-w, height: row-height, {
    // Line segment above and below the marker (omitted past the ends).
    let y0 = if i == 0 { 0.5 } else { 0 }
    let y1 = if i == n - 1 { 0.5 } else { 1 }
    place(top + center, dy: y0 * row-height,
      line(length: (y1 - y0) * row-height, angle: 90deg, stroke: spine))
    place(center + horizon, marker(e))
  })
  grid(
    columns: (auto, spine-w, 1fr),
    rows: row-height,
    column-gutter: .7em,
    align: (right + horizon, center + horizon, left + horizon),
    ..es.enumerate().map(((i, e)) => (
      text(size: .85em, fill: if e.key { ox.accent } else { ox.muted }, weight: if e.key { "medium" } else { "regular" }, e.date),
      spine-cell(i, e),
      if e.key { strong(e.body) } else { e.body },
    )).flatten(),
  )
}

/// Centred figure filling the slide body.
#let figure-slide(title: none, ..figures) = slide(title: title, align(center + horizon, {
  let fs = figures.pos()
  if fs.len() == 1 { fs.first() } else { stack(spacing: 1em, ..fs) }
}))

/// Multi-column slide built on typslides' `cols`: one column per content block.
///   #cols-slide(title: [Title])[left][middle][right]
/// Columns are equal width unless `columns` is given, e.g. `columns: (1fr, 2fr)`.
/// `footer` is pinned to the bottom of the slide; the columns stay centred above it.
#let cols-slide(title: none, columns: auto, gutter: 1.5em, footer: none, ..bodies) = {
  let bs = bodies.pos()
  let main = cols(columns: if columns == auto { (1fr,) * bs.len() } else { columns }, gutter: gutter, ..bs)
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
  show text.where(fill: white): set text(font: header-font, fill: ox.on-header, weight: "regular")
  show text.where(fill: white, size: 12pt): set text(font: body-font, fill: ox.on-header-muted)
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
