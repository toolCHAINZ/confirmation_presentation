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
