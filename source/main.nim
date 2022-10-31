# Magic string for emulators and flashcards to auto-detect save type.
asm """
.balign 4
.string "SRAM_V100"
.balign 4
"""

include prelude
import audio
import scenes/[game,intro]
import savedata
import fader

var canRedraw = false

proc onVBlank() {.codegenDecl: ArmCodeInIwram.}  =
  audio.vblank()
  if canRedraw:
    canRedraw = false
    flushPalsWithFade()
    drawScene()
    oamUpdate()  # clear unused entries, reset allocation counters
  audio.frame()

proc main =
  
  dispcnt.init()
  
  #bgColorBuf[0] = rgb5(31,0,0)
  
  # Recommended waitstate configuration
  waitcnt.init(
    sram = N8S8,      # 8 cycles to access SRAM.
    rom0 = N3S1,      # 3 cycles to access ROM, or 1 cycle for sequential access.
    rom2 = N8S8,      # 8 cycles to access ROM (mirror #2) which may be used for flash storage.
    prefetch = true   # prefetch buffer enabled.
  )
  
  savedata.load()
  
  audio.init()
  
  irq.init()
  irq.put(iiVBlank, onVBlank)
  
  setScene(IntroScene)
  #setScene(GameScene)
  
  while true:
    discard rand()  # introduce some nondeterminism to the RNG
    keyPoll()
    updateScene()
    canRedraw = true
    VBlankIntrWait()

main()
