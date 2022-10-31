import os, strutils
import natu/config

const main = "source/main.nim"         # path to project file
const name = "ARushedHackJob"                    # name of ROM

put "natu.toolchain", "devkitarm"
put "natu.gameTitle", "RUSHHACKJOB"           # max 12 chars, uppercase
put "natu.gameCode", "2HJP"            # "2" = SRAM on EverDrive; "SF" = Stick Flip; P = Europe

switch "experimental", "overloadableEnums"

if projectPath() == thisDir() / main:
  # This runs only when compiling the project file:
  gbaCfg()                             # set C compiler + linker options for GBA target
  switch "os", "any"
  switch "gc", "arc"
  switch "define", "useMalloc"
  switch "define", "noSignalHandler"
  switch "lineTrace", "on"
  # switch "define", "panics:on"
  # switch "checks", "off"               # toggle assertions, bounds checking, etc.
  switch "path", projectDir()          # allow imports relative to the main file
  switch "header"                      # output "{project}.h"
  switch "nimcache", "nimcache"        # output C sources to local directory
  switch "cincludes", nimcacheDir()    # allow external C files to include "{project}.h"

task assets, "builds just the assets":
  gfxConvert "graphics.nims"
  bgConvert "backgrounds.nims"
  mmConvert "audio.nims"

task build, "builds the GBA rom":
  let args = commandLineParams()[1..^1].join(" ")
  gfxConvert "graphics.nims"
  bgConvert "backgrounds.nims"
  mmConvert "audio.nims"
  selfExec "c " & args & " -o:" & name & ".elf " & thisDir() / main
  gbaStrip name & ".elf", name & ".gba"
  gbaFix name & ".gba"

task clean, "removes build files":
  rmDir "nimcache"
  rmDir "output"
  rmFile name & ".gba"
  rmFile name & ".elf"
  rmFile name & ".elf.map"
