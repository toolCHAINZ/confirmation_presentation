export TYPST_FONT_PATHS := justfile_directory() + "/fonts"

dissertation := "../dissertation/diagrams/dist"
crackers     := "../code_reuse_synthesis"

default: build

# Copy figures from sibling projects (Typst can't read outside the project root).
figures:
    mkdir -p figures
    cp {{dissertation}}/c-stack-example.pdf \
       {{dissertation}}/c-stack-callsite.pdf \
       {{dissertation}}/c-stack-buffer.pdf \
       {{dissertation}}/c-stack-canary.pdf \
       {{dissertation}}/example-stack.pdf \
       {{dissertation}}/execve-chain.pdf \
       {{dissertation}}/pcode-smt-layers.pdf \
       {{dissertation}}/step-partitions.pdf \
       {{dissertation}}/synthesis-loop.pdf \
       {{dissertation}}/search-loop.pdf \
       {{dissertation}}/patch-encoding.pdf \
       {{dissertation}}/basic-constraints.pdf \
       {{dissertation}}/register-overlap.pdf \
       {{dissertation}}/divergent-patches.pdf \
       {{dissertation}}/guarded-patch.pdf \
       {{dissertation}}/guarded-scheduling.pdf \
       {{dissertation}}/scatter-x64-facefeed-chain.pdf \
       figures/
    cp {{crackers}}/src/evaluation/images/all-tool-cropped.pdf figures/crackers-all-tool.pdf
    cp {{crackers}}/presentation/flowchart.svg figures/crackers-flowchart.svg
    cp {{crackers}}/presentation/Ghidra_logo.svg figures/ghidra.svg

build:
    typst compile main.typ

watch:
    typst watch main.typ

# Render PNGs; pass a font preset, e.g. `just png plex-serif`.
png fonts="plex":
    mkdir -p out
    typst compile --input fonts={{fonts}} main.typ 'out/{p}.png' --ppi 50
