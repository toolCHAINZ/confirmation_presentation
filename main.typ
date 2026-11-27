// Confirmation of Status — entry point.
// Build:  just build
#import "oxford-theme.typ": *

#show: oxford-theme

#front-slide(
  title: [Automated Synthesis of Code-Reuse Attacks],
  subtitle: [from Branching-Time Specifications],
  authors: [Mark DenHoed],
  info: [Balliol College · Supervisor: Prof. Tom Melham],
)

#include "sections/00-intro.typ"
#include "sections/01-code-reuse-attacks.typ"
#include "sections/02-goals.typ"

#include "sections/03-crackers.typ"
#include "sections/04-simulacrop.typ"

#bibliography-slide(bibliography("refs.bib"))
