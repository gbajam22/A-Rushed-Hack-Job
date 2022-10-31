include prelude
import natu/[tte,posprintf]
import labels

type
  ScoreLabel* = object
    label: Label
    buffer: array[15,char]

proc setScore*(self: var ScoreLabel, score: int) =
  posprintf(addr self.buffer, "Score: %d", score)
  self.label.put(addr self.buffer)

proc init*(self: var ScoreLabel, pos: Vec2i, score: int = 0) =
  self.label.init(pos, s8x16, 10, ink = 1, shadow = 2)
  self.label.pal = acquireObjPal(gfxLogo)
  self.setScore(score)

proc destroy*(self: var ScoreLabel) =
  self.label.destroy()

proc update*(self: var ScoreLabel) =
  discard

proc draw*(self: var ScoreLabel) =
  self.label.draw()