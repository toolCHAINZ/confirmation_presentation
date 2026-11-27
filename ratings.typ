// Reusable "scorecard" charts for rating synthesis methods.
//
//   #import "../ratings.typ": *
//
//   // One method: concentric rings, one per dimension
//   #rating([CRACKERS], spec: 4, flex: 4, scale: 3)
//
//   // Several methods overlaid on one radar
//   #rating-compare(
//     (name: [angrop],   spec: 2, flex: 2, scale: 3),
//     (name: [CRACKERS], spec: 4, flex: 4, scale: 3, color: ox.oxceruleanblue),
//   )
//
// Scores run 0..`max-score`; higher = better. Every dimension must be given
// (a missing or misspelt one is a compile error, never a silent zero).
// To add / rename / reorder a dimension, edit `dimensions` below.

#import "@preview/primaviz:0.12.1" as pv
#import "oxford-colors.typ" as ox

#let max-score = 5

// key: the argument name; label: shown on the chart.
#let dimensions = (
  (key: "spec", label: [Expressive Power]),
  (key: "flex", label: [Generality]),
  (key: "scale", label: [Scalability]),
)

// Lighter Oxford secondary colours (the primaries are heavy as big rings).
// One colour per dimension (rings) — cycles if you add more.
#let dimension-colors = (
  ox.oxceruleanblue,
  ox.oxpeach,
  ox.oxoceangrey,
  ox.oxyellowochre,
  ox.oxmauve,
  ox.oxaqua,
)

// Colours for radar series that don't pass their own `color:`.
#let method-colors = (
  ox.oxpeach,
  ox.oxoceangrey,
  ox.oxyellowochre,
  ox.oxmauve,
  ox.oxdusk,
)

// ── Internals ───────────────────────────────────────────────────────────
#let _theme = (
  ..pv.themes.presentation,
  base-size: 14pt,
  category-label-min-size: 13pt, // radar otherwise shrinks axis names to grow the plot
  text-color: ox.ink,
  text-color-light: ox.muted,
  grid-stroke: 0.6pt + ox.rule.darken(15%),
  axis-stroke: 0.5pt + ox.rule,
  background: ox.bg,
  title-weight: "regular",
)

// primaviz hard-codes bold for ring names; force everything to regular.
#let _unbold(body) = {
  show text.where(weight: "bold"): set text(weight: "regular")
  body
}

#let _keys = dimensions.map(d => d.key)

// Validate a score dictionary against `dimensions`; returns scores in order.
#let _scores(scores, who) = {
  for k in scores.keys() {
    assert(
      k in _keys,
      message: "ratings: "
        + who
        + ": unknown dimension '"
        + k
        + "' (expected one of "
        + _keys.join(", ")
        + ")",
    )
  }
  dimensions.map(d => {
    assert(
      d.key in scores,
      message: "ratings: " + who + ": missing score for '" + d.key + "'",
    )
    let v = scores.at(d.key)
    assert(
      v >= 0 and v <= max-score,
      message: "ratings: "
        + who
        + ": '"
        + d.key
        + "' must be 0.."
        + str(max-score),
    )
    v
  })
}

#let _dim-color(i) = dimension-colors.at(calc.rem(i, dimension-colors.len()))

// ── Single method: concentric rings, one per dimension ──────────────────
// `title` is optional. `show-labels: false` drops the per-chart legend; pair
// with `rating-legend()` when several rings sit side by side.
#let rating(
  title,
  size: 6cm,
  show-labels: true,
  ring-width: 16pt,
  ..scores,
) = {
  assert(
    scores.pos().len() == 0,
    message: "ratings: rating takes one title then named scores, e.g. rating([X], spec: 3, ...)",
  )
  let values = _scores(scores.named(), "rating")
  _unbold(pv.ring-progress(
    dimensions
      .zip(values)
      .map(((d, v)) => (name: d.label, value: v, max: max-score)),
    size: size,
    ring-width: ring-width,
    gap: 4pt,
    show-labels: show-labels,
    show-values: false,
    title: title,
    theme: (.._theme, palette: array.range(dimensions.len()).map(_dim-color)),
  ))
}

// Shared legend for a row of `rating(..., show-labels: false)` charts.
#let rating-legend(dir: ltr, spacing: 1.5em, size: 14pt) = {
  set text(size: size, fill: ox.ink)
  show linebreak: [ ] // labels may wrap on the charts; keep legend entries on one line
  stack(dir: dir, spacing: spacing, ..dimensions
    .enumerate()
    .map(((i, d)) => box(
      stack(
        dir: ltr,
        spacing: .4em,
        box(
          width: .8em,
          height: .8em,
          radius: 2pt,
          fill: _dim-color(i),
          baseline: .1em,
        ),
        d.label,
      ),
    )))
}

// ── Several methods: one radar, one polygon per method ──────────────────
// Each positional arg: (name: [...], <dimension>: score, ..., color: optional).
#let rating-compare(
  ..ms,
  size: 13cm,
  title: none,
  show-legend: true,
  fill-opacity: 22%,
) = {
  let ms = ms.pos()
  let k = 0
  let palette = ()
  for m in ms {
    if "color" in m { palette.push(m.color) } else {
      palette.push(method-colors.at(calc.rem(k, method-colors.len())))
      k += 1
    }
  }
  _unbold(pv.radar-chart(
    (
      labels: dimensions.map(d => d.label),
      series: ms.map(m => {
        let scores = m
          .keys()
          .filter(x => x not in ("name", "color"))
          .map(x => (x, m.at(x)))
          .to-dict()
        (
          name: m.name,
          values: _scores(scores, "rating-compare " + repr(m.name)),
        )
      }),
    ),
    size: size,
    axis-max-value: max-score,
    title: title,
    show-legend: show-legend,
    show-value-labels: false,
    fill-opacity: fill-opacity,
    theme: (.._theme, palette: palette),
  ))
}

// ── Per-dimension descriptions: a compact colour-keyed table ────────────
// Rows follow `dimensions` order and reuse the ring colours, so it reads as
// the caption for a `rating` on the same slide. Any subset of dimensions:
//
//   #cols-slide(title: [angrop], footer: rating-notes(
//     spec: [Register values only],
//     flex: [Fixed gadget templates],
//     scale: [Fast on small binaries],
//   ))[...][#rating(none, spec: 2, flex: 2, scale: 3)]
#let rating-notes(size: 15pt, label-width: auto, ..notes) = {
  assert(
    notes.pos().len() == 0,
    message: "ratings: rating-notes takes named descriptions, e.g. rating-notes(spec: [...])",
  )
  let notes = notes.named()
  for k in notes.keys() {
    assert(
      k in _keys,
      message: "ratings: rating-notes: unknown dimension '"
        + k
        + "' (expected one of "
        + _keys.join(", ")
        + ")",
    )
  }
  let rows = dimensions.enumerate().filter(((_, d)) => d.key in notes)
  set text(size: size, fill: ox.ink)
  block(width: 100%, above: 0pt, breakable: false, {
    grid(
      columns: (label-width, 1fr),
      column-gutter: 1em,
      row-gutter: .55em,
      align: (left + horizon, left + horizon),
      ..rows
        .map(((i, d)) => (
          stack(
            dir: ltr,
            spacing: .45em,
            box(
              width: .3em,
              height: 1.1em,
              radius: 1pt,
              fill: _dim-color(i),
              baseline: .25em,
            ),
            text(fill: ox.muted, d.label),
          ),
          notes.at(d.key),
        ))
        .flatten(),
    )
  })
}
