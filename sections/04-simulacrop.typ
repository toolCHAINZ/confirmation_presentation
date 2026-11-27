#import "../oxford-theme.typ": *
#import "../oxford-colors.typ" as ox
#import "@preview/cetz:0.3.4" as cetz

#title-slide[`simulacrop`#footnote[Name subject to revision]: Goal-directed Synthesis]

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

#focus-slide[Design Decisions]

#slide(title: "How to describe Gadgets?")[
  - Gadget analysis as a #stress[Configurable Program Analysis] (CPA)
    - Abstract interpretation over the P-Code CFG of each gadget
    - Bounded and loop-free; states are #stress[joined] where paths reconverge
  - An abstract state is a pair of lattice elements
    - #stress[Location]: where control is
    - #stress[Value]: what each varnode holds, as a SpIL term over the entry state
  - Output: one effect summary $Phi$ per gadget exit
]

// Hasse diagram of a flat join-semilattice: ⊤ over a row of incomparable elements.
// Each element is (body, caption); `gap` inserts an ellipsis column before index `dots`.
#let flat-lattice(elems, gap: none, width: 15, hl: ()) = cetz.canvas(
  length: 1cm,
  {
    import cetz.draw: *
    let n = elems.len() + if gap != none { 1 } else { 0 }
    let dx = width / n
    let xs = range(n).map(i => (i + 0.5) * dx)
    let (ty, by, bh) = (2.6, 0, 0.75)
    let k = 0
    for (i, x) in xs.enumerate() {
      if gap != none and i == gap {
        content((x, by), text(size: 16pt, fill: diag.label)[$dots.c$])
        continue
      }
      let (body, caption) = elems.at(k)
      k += 1
      let stroke = if k - 1 in hl { diag.group } else { 0.6pt + ox.header.lighten(45%) }
      line((x, by + bh / 2), (width / 2, ty - 0.42), stroke: stroke)
      let bw = dx - 0.3
      rect(
        (x - bw / 2, by - bh / 2),
        (x + bw / 2, by + bh / 2),
        ..diag-rect,
        fill: if k - 1 in hl { diag.highlight } else { diag.fill },
      )
      content((x, by), text(size: 13pt, body))
      content((x, by - bh / 2 - 0.4), diag-label(text(size: 11pt, caption)))
    }
    circle((width / 2, ty), radius: 0.42, ..diag-node)
    content((width / 2, ty), text(size: 18pt, fill: diag.on-node)[$top$])
    content((width / 2 + 0.6, ty), anchor: "west", diag-label[unknown / several])
  },
)

#cols-slide(title: [Location lattice], columns: (1fr, 1.7fr))[
  - #stress[Where] can control be?
  - A flat lattice: distinct locations join to $top$
  - Gadget exits must be #stress[Indirect] or #stress[Computed]: a controllable branch
    - `ret` on x64 #sym.arrow $"Computed"(mono("RIP"), "Offset"(mono("rsp"), 0))$
  - Paths merge only at #emph[matching] locations
    - Two distinct symbolic exits stay separate #sym.arrow #stress[guard gadgets]
][
  #align(center + horizon, flat-lattice(
    (
      ([`0x401a2c`], [Const]),
      ([`0x401a30`], [Const]),
      ([`[RIP]`], [Indirect]),
      ([`[rsp]`], [Computed]),
      ([`[rsp+8]`], [Computed]),
    ),
    gap: 2,
    hl: (3,),
  ))
  #align(center, diag-label[
    $"Computed"(n, v)$ refines $"Indirect"(n)$ with its target $v$ \
    but the two are incomparable: they join to $top$
  ])
]

#cols-slide(title: [Value lattice], columns: (1fr, 1.7fr))[
  - #stress[What] does each varnode hold?
  - Elements are SpIL terms over the #emph[entry] state
  - Flat: $v_1 union.sq v_2 = v_1$ if $v_1 = v_2$, else $top$
    - A write on only one path is also $top$
  - Joins lose precision, never soundness
    - $top$ is a clobber the search must avoid relying on
][
  #align(center + horizon, stack(
    spacing: 1.2em,
    flat-lattice(
      (
        ([$1$], [Const]),
        ([$"Entry"(mono("rdx"))$], [Entry]),
        ([$"Entry"(mono("rsp")) + 16$], [BinOp]),
      ),
      gap: 3,
      hl: (0, 1),
    ),
    {
      set text(size: 14pt)
      table(
        columns: 4,
        stroke: none,
        align: (left, center, center, center),
        inset: (x: .6em, y: .3em),
        table.header([], diag-label[path A], diag-label[path B], diag-label[join]),
        table.hline(stroke: 0.5pt + ox.rule),
        `rdi`, `[rsp]`, `[rsp]`, text(fill: ox.success)[`[rsp]`],
        `rdx`, $"Entry"(mono("rdx"))$, $1$, text(fill: ox.danger)[$top$],
        `rsp`, $"Entry"(mono("rsp")) + 16$, $"Entry"(mono("rsp")) + 16$, text(fill: ox.success)[$"Entry"(mono("rsp")) + 16$],
      )
    },
    diag-label[the multi-path gadget from later: `jz` skips `mov rdx, 1`],
  ))
]

#cols-slide(title: [SpIL: Simulac-ROP P-Code IL], columns: (1fr, 1fr))[
  - Bitvector-valued #stress[ASTs] whose internal nodes are P-Code operations
  - Leaves: $"Entry"(n)$, constants, $"Bind"_i$ (existentials solved by SMT)
  - Locations: $"Direct"(n)$ or $"Indirect"(v)$
    - Indirect accesses alias only if pointers are syntactically equal
  - Same operation semantics as the P-Code #sym.arrow SMT encoding
][
  #set text(size: 16pt)
  #align(center, scale(140%, reflow: true, diag-gadget([`pop rax`], [`ret`])))
  $
    Phi = {
      & "Direct"(mono("rax")) |-> "Offset"(mono("rsp"), 0) \
      & "Direct"(mono("rsp")) |-> "Entry"(mono("rsp")) + 16
    }
  $
]

#cols-slide(title: [One language, two roles])[
  #stress[Effects] $ell |-> v$ #muted[(descriptive)]
  - What a gadget #emph[does], over its entry state
  - Produced by the CPA
  - Compose by #stress[concat] $Phi_1 ; Phi_2$
][
  #stress[Goals] $ell := v$ #muted[(prescriptive)]
  - What a chain #emph[must achieve]
  - Written by the user: the specification
  - Compose by #stress[merge] $G_1 union.sq G_2$ (may fail: $bot$)
][
  #set text(size: 16pt)
  #v(1em)
  $mono("rax") := 40$ #h(.4em) #muted[constant]

  $mono("rax") := "Entry"(mono("rbx")) + 5$ #h(.4em) #muted[computation]

  $mono("rax") := "Entry"(mono("rax"))$ #h(.4em) #muted[preservation (trivial)]

  #v(.6em)
  #grayed(text-size: 18pt)[No order, no gadget-per-step: unlike a `crackers` reference program]
]

#cols-slide(title: [Chain structure: patches, from ropbot], columns: (1fr, 1.2fr))[
  #set text(size: 18pt)
  #stress[ropbot] @zeng2026ropbot #muted[(origin of the patch)]
  - Chain runs on a #stress[virtual PC] (vPC), e.g. the stack pointer
  - Each step advances vPC by fixed $n$; its #stress[patch] is #box[$["vPC", "vPC" + n)$]
  - Branch destinations come only from inside the patch
  - So any two patches compose #sym.arrow search over a register data-movement graph
][
  #align(center + horizon, stack(
    spacing: 1em,
    image("../figures/basic-constraints.pdf", width: 100%),
    diag-label[One gadget's patch: constraints sit at fixed offsets from vPC,\ including where the next PC is read from],
  ))
]

#cols-slide(title: [Extending the patch], columns: (1fr, 1fr))[
  #set text(size: 18pt)
  #text(fill: ox.paper2, weight: "bold")[simulacrop] #muted[(same threat model and layout)]
  - Patch $p = (n, a, C, d)$: size, first gadget, #stress[constraints], destination
  - $C$: equalities over SpIL values rooted in patch bytes
    - Arbitrary goals, not only data movement
    - Conflicts found syntactically, by byte range
  - Bytes chosen only at the end, by SMT
  - Patches #stress[merge] and #stress[concat] #sym.arrow basis for guarded chains
][
  #align(center + horizon, image("../figures/patch-encoding.pdf", height: 100%))
]

#cols-slide(title: [Contribution: multi-path gadgets for free], columns: (
  1.3fr,
  1fr,
))[
  - Effects of reconverging paths are #stress[joined] by the value lattice
    - Disagreeing writes become $top$: a sound over-approximation
  - A multi-block gadget is still #stress[one] effect set $Phi$
    - No per-path constraints, no path explosion during search
  - Gadgets with #emph[two] controllable exits are kept apart #sym.arrow #stress[guard gadgets]
][
  #align(center + horizon, scale(160%, reflow: true, stack(
    spacing: 1em,
    diag-gadget(
      [`test rcx, rcx`],
      [`jz L`],
      ([`mov rdx, 1`], diag.highlight),
      [`L: pop rdi`],
      [`ret`],
    ),
    diag-label[$mono("rdi") |-> "Offset"(mono("rsp"), 0)$\ $mono("rdx") |-> top$],
  )))
]

#cols-slide(title: [Contribution: backwards goal-directed search], columns: (
  1fr,
  1.6fr,
))[
  - Start from the goal set $G$
  - For each gadget, compute the #stress[residual]: the precondition $G'$ that must hold #emph[before] it runs
  - Repeat until the residual is #stress[trivial]
  - First gadget found executes last
][
  #align(center + horizon, image("../figures/search-loop.pdf", height: 100%))
]

#cols-slide(title: [Contribution: indirect side-effects])[
  - Gadgets often read or write memory #emph[incidentally]
    - Prior tools discard them, or slow down when they are included
  - In SpIL, an incidental access is just another effect $"Indirect"(v) |-> dots$
  - Matching turns it into #stress[patch constraints]: its pointer must be a controlled value in legal memory
    - Detected syntactically, resolved by the same residual step
][
  #align(center + horizon, scale(140%, reflow: true, stack(
    spacing: 1em,
    diag-gadget(([`mov [rbx+8], rax`], diag.highlight), [`pop rdi`], [`ret`]),
    diag-label[$"Indirect"(mono("rbx") + 8) |-> "Entry"(mono("rax"))$],
    sym.arrow.b,
    diag-label[residual: $mono("rbx") := "Bind"_1$,\ $"Bind"_1 + 8 in$ writable],
  )))
]

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

#figure-slide(
  title: [Residuals over overlapping registers],
  image("../figures/register-overlap.pdf", height: 70%),
)

#focus-slide[Guarded Synthesis]

#cols-slide(title: [Guarded chains], columns: (1.1fr, 1fr))[
  - A guarded chain, after Dijkstra's guarded commands:
    $ C_G := "if" f(v) "then" C_1 "else" C_2 $
    - $f(v)$: a predicate over the chain's #emph[runtime] state
    - Arms are patches $p_1, p_2$, and may themselves be guarded
  - Use cases
    - #stress[Failure handling]: `mmap` returns $-1$ #sym.arrow `exit`
    - #stress[Targeting]: `geteuid() == 0` #sym.arrow shell
  - No other tool can #emph[express] these specs
][
  #stress[Algorithm]
  + Synthesise a #stress[guard prefix] ending in a guard gadget
  + #stress[Schedule] prefix and arm patches so no offsets overlap
  + Fill the gaps with #stress[padding] chains, equalising the vPC shift
  + #stress[Merge] both paths into one patch
]

#slide(title: [Guard gadgets])[
  - A gadget with #stress[two controllable exits], selected by a comparison
    - The CPA keeps them separate: their locations do not match
  - Common wherever code dispatches through function pointers
    - e.g. the loop in `__libc_csu_init`, already a favourite of prior work @zeng2026ropbot
  #v(.6em)
  #align(center, image("../figures/guarded-gadget.pdf", width: 78%))
  #align(center, diag-label[`jne` either falls through to a `ret` (z = 1) or calls a function pointer from the patch (z = 0)])
]

#cols-slide(title: [Step 1: the guard prefix], columns: (1.15fr, 1fr))[
  #set text(size: 18pt)
  - P-Code writes every branch condition as a boolean guard varnode for `CBRANCH`: just another SpIL value
  - Matching gadget guard $v_gamma$ to spec guard $v$ yields data movement:
    #align(center)[$"match"(mono("r1") = 0, mono("r0") = 0) = {mono("r1") := mono("r0")}$]
  - Constrain #emph[both] exits independently:
    #align(center, text(size: 15pt)[$R_d = "match"(v_gamma, v) union.sq "constrain"(Phi_1) union.sq "constrain"(Phi_2)$])
  - Search for $R_d$ as usual, then append $gamma$
  - Also try $not v_gamma$ with the arms swapped
][
  #align(center + horizon, stack(
    spacing: 1em,
    image("../figures/divergent-patches.pdf", width: 100%),
    diag-label[The prefix has two paths: shared constraints,\ different destinations and vPC shifts],
  ))
]

#cols-slide(title: [Steps 2–3: scheduling and padding], columns: (1fr, 1.1fr))[
  - Fix the prefix; the shorter path is $p_"min"$, its arm $p_"slide"$
  - The other path and its arm form $p_"maj"$
  - Slide $p_"slide"$ right by $i = 0, 1, dots$
    - Rewrite $"Offset"("vPC", n) -> "Offset"("vPC", n + i)$
    - Stop at the first $i$ with no overlap with $p_"maj"$: a #emph[syntactic] check
  - Fill each gap of size $k$ with a padding chain:
    $ "FrontierSearch"({"vPC" := "vPC" + k}) $
    - Memoised per $k$; skipped after a no-return call
][
  #align(center + horizon, image("../figures/guarded-scheduling.pdf", width: 100%))
]

#slide(title: [Step 4: the guarded patch])[
  #align(center + horizon, stack(
    spacing: 1.2em,
    image("../figures/guarded-patch.pdf", width: 92%),
    diag-label[Prefix, arms and padding share one region of memory; both paths are padded to the same length and merged.\ The two paths never place conflicting constraints on the same offset, so one byte string serves either branch.],
  ))
]

#cols-slide(title: [Where guarded synthesis falls short])[
  #stress[Soundness]
  - Per-path validation ran angr with one concrete return value per branch
  - Reviewer counterexample: a guard testing $2x = 0$ also accepts #box[$x = mono("0x80000000")$]
  - Stricter revalidation: most x64 guarded chains became #text(fill: ox.danger)[invalid]
    - e.g. `g.facefeed`: 354 verified #sym.arrow 0
  - Arm inputs must also survive the prefix and padding
][
  #stress[Scale]
  - Every guard gadget is tried for every guard in the spec
  - Three nested guards (`g.dup+root`): 20 of 32 time out
  #v(.6em)
  #grayed(text-size: 18pt)[Fixing both is the current work: see the plan]
]
