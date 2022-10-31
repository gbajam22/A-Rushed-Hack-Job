include prelude
import labels
import natu/[tte,posprintf]

type
  LabelState = enum
    lsHide
    lsShow
  NowPlayingLabel* = object
    buffer: array[64,char]
    label: Label
    pos: Vec2f
    showY: Fixed
    hideY: Fixed
    showTimer: int
    state: LabelState

proc show*(self: var NowPlayingLabel, songName: cstring) =
  self.state = lsShow
  self.pos.y = self.hideY
  self.showTimer = 120
  
  posprintf(addr self.buffer, "Now Playing: %s", songName)
  self.label.put(addr self.buffer)
  self.pos.x = fp(ScreenWidth - 4) - fp(self.label.width.int)

proc hide(self: var NowPlayingLabel) =
  self.state = lsHide

proc init*(self: var NowPlayingLabel, hideY, showY: Fixed) =
  self.showY = showY
  self.hideY = hideY
  
  self.state = lsHide
  self.pos = vec2f(0,hideY)
  
  self.label.init(vec2i(100,100), s8x16, 20, ink = 1, shadow = 2)
  self.label.pal = acquireObjPal(gfxLogo)

proc destroy*(self: var NowPlayingLabel) =
  self.label.destroy()
  releaseObjPal(gfxLogo)

proc update*(self: var NowPlayingLabel) =
  case self.state:
    of lsHide:
      self.pos.y.approach(self.hideY,fp(1))
    of lsShow:
      self.pos.y.approach(self.showY,fp(1))
      dec self.showTimer
      if self.showTimer <= 0:
        self.hide()
  
  
  self.label.x = self.pos.x.toInt()
  self.label.y = self.pos.y.toInt()

proc draw*(self: var NowPlayingLabel) =
  self.label.draw()
