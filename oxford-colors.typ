// Oxford University brand colours.
// Hex values mirror dissertation/pygments_oxford/src/pygments_oxford/oxford_style.py
// and the \definecolor block in dissertation/macros.tex.
// Pure data: no imports, safe to use from any Typst document.

// ── Primary ─────────────────────────────────────────────────────────────
#let oxblue = rgb("#002147") // Pantone 282

// ── Secondary ───────────────────────────────────────────────────────────
#let oxmauve = rgb("#776885") // Pantone 667C
#let oxpeach = rgb("#E08D79") // Pantone 4051C
#let oxpotterspink = rgb("#ED9390") // Pantone 2339C
#let oxdusk = rgb("#C4A29E") // Pantone 6030C
#let oxlilac = rgb("#D1BDD5") // Pantone 524C
#let oxsienna = rgb("#994636") // Pantone 4036C
#let oxred = rgb("#AA1A2D") // Pantone 187C
#let oxplum = rgb("#7F055F") // Pantone 2425C
#let oxcoral = rgb("#FE615A") // Pantone 178C
#let oxlavender = rgb("#D4CDF4") // Pantone 2635C
#let oxorange = rgb("#FB5607") // Pantone 1655C
#let oxpink = rgb("#E6007E") // Pantone 2385C
#let oxgreen = rgb("#426A5A") // Pantone 5545C
#let oxoceangrey = rgb("#789E9E") // Pantone 2211C
#let oxyellowochre = rgb("#E2C044") // Pantone 4016C
#let oxcoolgrey = rgb("#E4F0EF") // Pantone 7541C
#let oxskyblue = rgb("#B9D6F2") // Pantone 277C
#let oxviridian = rgb("#15616D") // Pantone 5473C
#let oxroyalblue = rgb("#1D42A6") // Pantone 2126C
#let oxaqua = rgb("#00AAB4") // Pantone 7710C
#let oxvividgreen = rgb("#65E5AE") // Pantone 3385C
#let oxlimegreen = rgb("#95C11F") // Pantone 2292C
#let oxceruleanblue = rgb("#49B6FF") // Pantone 292C
#let oxlemonyellow = rgb("#F7EF66") // Pantone 3935C

// ── Neutrals ────────────────────────────────────────────────────────────
#let oxcharcoal = rgb("#211D1C") // Pantone 419C
#let oxashgrey = rgb("#61615F") // Pantone 6215C
#let oxumber = rgb("#89827A") // Pantone 403C
#let oxstonegrey = rgb("#D9D8D6") // Pantone Cool Gray 1C
#let oxshellgrey = rgb("#F1EEE9") // Pantone Warm Gray 1C
#let oxoffwhite = rgb("#F2F0F0") // Pantone 663C

// Every brand colour by name (for swatches / loops).
#let palette = (
  oxblue: oxblue,
  oxmauve: oxmauve,
  oxpeach: oxpeach,
  oxpotterspink: oxpotterspink,
  oxdusk: oxdusk,
  oxlilac: oxlilac,
  oxsienna: oxsienna,
  oxred: oxred,
  oxplum: oxplum,
  oxcoral: oxcoral,
  oxlavender: oxlavender,
  oxorange: oxorange,
  oxpink: oxpink,
  oxgreen: oxgreen,
  oxoceangrey: oxoceangrey,
  oxyellowochre: oxyellowochre,
  oxcoolgrey: oxcoolgrey,
  oxskyblue: oxskyblue,
  oxviridian: oxviridian,
  oxroyalblue: oxroyalblue,
  oxaqua: oxaqua,
  oxvividgreen: oxvividgreen,
  oxlimegreen: oxlimegreen,
  oxceruleanblue: oxceruleanblue,
  oxlemonyellow: oxlemonyellow,
  oxcharcoal: oxcharcoal,
  oxashgrey: oxashgrey,
  oxumber: oxumber,
  oxstonegrey: oxstonegrey,
  oxshellgrey: oxshellgrey,
  oxoffwhite: oxoffwhite,
)

// ── Semantic roles (what the theme actually uses) ───────────────────────
#let primary = oxblue
// Header bands / section slides / bullets / progress bar (typslides' theme colour).
#let header = oxroyalblue
// Text on `header` fills: pale sky tint instead of pure white to soften contrast.
#let on-header = oxskyblue.mix((white, 55%))
#let on-header-muted = oxskyblue.mix((header, 30%))
#let accent = oxcoral
#let link-color = oxroyalblue
#let bg = white
#let surface = oxoffwhite
#let ink = oxcharcoal
#let muted = oxashgrey
#let rule = oxstonegrey
#let success = oxgreen
#let warn = oxyellowochre
#let danger = oxred

// ── Series colours: one per strand of work ──────────────────────────────
#let paper1 = oxroyalblue // CRACKERS (USENIX Security '25)
#let paper2 = oxplum // Simulac-ROP
#let ongoing = oxviridian // current / future work
#let series = (paper1, paper2, ongoing, oxsienna, oxaqua, oxmauve)
