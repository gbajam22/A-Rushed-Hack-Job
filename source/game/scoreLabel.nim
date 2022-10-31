include prelude
import natu/[tte,posprintf]
import labels

type
  ScoreLabel* = object
    label: Label
    buffer: array[32,char]
    prefix: cstring

proc setScore*(self: var ScoreLabel, score: int) =
  posprintf(addr self.buffer, "%s %d", self.prefix, score)
  self.label.put(addr self.buffer)

proc init*(self: var ScoreLabel, pos: Vec2i, prefix: cstring, score: int = 0) =
  self.label.init(pos, s8x16, 20, ink = 1, shadow = 2)
  self.label.pal = acquireObjPal(gfxLogo)
  self.prefix = prefix
  self.setScore(score)

proc destroy*(self: var ScoreLabel) =
  self.label.destroy()

proc update*(self: var ScoreLabel) =
  discard

proc draw*(self: var ScoreLabel) =
  self.label.draw()