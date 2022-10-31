
type SimpleAnim* = object
  ## A basic looping animation
  timer*: int
  pos*: int
  offset*: int
  len*: int
  speed*: int

proc frame*(a: SimpleAnim): int = a.pos + a.offset

proc atPos*(a: SimpleAnim, pos: int): bool =
  ## True if we just arrived at a given frame
  a.pos == pos and a.timer == a.speed

proc atEnd*(a: SimpleAnim): bool =
  ## True if the end of the anim has just been reached (i.e. about to loop on the next frame)
  a.pos == a.len-1 and a.timer == 0

proc dirty*(a: SimpleAnim): bool =
  ## True if now is a good time to copy this frame's tiles into VRAM
  a.timer == a.speed

proc init*(a: var SimpleAnim, len, speed: int, p: int = 0, offset: int = 0) =
  a.timer = speed + 1
  a.pos = p
  a.offset = offset
  a.len = len
  a.speed = speed

proc reset*(a: var SimpleAnim, len, speed: int, p: int = 0, offset: int = 0) =
  a.timer = speed + 1
  a.pos = p
  a.offset = offset
  a.len = len
  a.speed = speed

proc update*(a: var SimpleAnim) {.inline.} =
  ## Progress anim timer, advance to the next frame if necessary.
  if a.timer > 0:
    dec a.timer
  else:
    inc a.pos
    if a.pos >= a.len:
      a.pos = 0
    a.timer = a.speed