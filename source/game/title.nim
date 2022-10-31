include prelude

const
  gravity = fp(0.2)
  topLimit = fp(-40)
  bottomLimit = fp(20)
  
  titleWidth = fp(96)
  titleX = (ScreenWidth - titleWidth) / 2
  
  titleHidePos* = vec2f(titleX,topLimit)
  titleShowPos* = vec2f(titleX,bottomLimit)
  
  psWidth = fp(32)
  psX = (ScreenWidth - psWidth) / 2
  psTopLimit = fp(60)
  psBottomLimit = fp(ScreenHeight) + fp(8)
  
  psHidePos* = vec2f(psX,psBottomLimit)
  psShowPos* = vec2f(psX,psTopLimit)
  
  psgoShowPos* = vec2f(psX,fp(85))
  
  controlsY = fp(ScreenHeight) - fp(56)
  
  controlsHidePos* = vec2f(fp(ScreenWidth) + fp(8), controlsY)
  controlsShowPos* = vec2f(fp(ScreenWidth) - fp(70), controlsY)
  
  gameOverX = fp(ScreenWidth - 64) / 2
  
  gameOverHidePos* = vec2f(gameOverX, topLimit)
  gameOverShowPos* = vec2f(gameOverX, fp(30))
  
  newHighScoreX = fp(ScreenWidth - 64) / 2
  
  newHighScoreHidePos* = vec2f(newHighScoreX, fp(ScreenHeight) + fp(8))
  newHighScoreShowPos* = vec2f(newHighScoreX, fp(64))

type
  TitleState = enum
    tsHide
    tsShow
  Title* = object
    obj: ObjAttr
    pos: Vec2f
    vel: Vec2f
    state: TitleState
    hidePos: Vec2f
    showPos: Vec2f
    gfx: Graphic
    bounceDampening: Fixed

proc show*(self: var Title) =
  self.state = tsShow
  self.vel = vec2f()

proc show*(self: var Title, newShowPos: Vec2f) =
  self.pos = self.hidePos
  self.state = tsShow
  self.vel = vec2f()
  self.showPos = newShowPos

proc hide*(self: var Title) =
  self.state = tsHide
  self.vel = vec2f()

proc init*(self: var Title, gfx: Graphic, hidePos, showPos: Vec2f, bounceDampening: Fixed = fp(-0.5)) =
  self.pos = hidePos
  self.vel = vec2f()
  self.gfx = gfx
  self.state = tsHide
  
  self.hidePos = hidePos
  self.showPos = showPos
  self.bounceDampening = bounceDampening
  
  self.obj.init(
    tid = allocObjTiles(gfx.allTiles),
    pal = acquireObjPal(gfx),
    size = gfx.size,
    prio = prioGUI
  )
  copyAllframes(addr objTileMem[self.obj.tid], gfx)

proc destroy*(self: var Title) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(self.gfx)

proc approach(v: var Vec2f, t, a: Vec2f) =
  v.x.approach(t.x,a.x)
  v.y.approach(t.y,a.y)

proc update*(self: var Title) =
  case self.state:
    of tsHide:
      self.vel.x += gravity
      self.vel.y += gravity
      
      self.pos.approach(self.hidePos,self.vel)
      
      if self.pos.y == self.hidePos.y:
        self.vel.y = fp(0)
      if self.pos.x == self.hidePos.x:
        self.vel.x = fp(0)
      
    of tsShow:
      self.vel.x += gravity
      self.vel.y += gravity
      
      self.pos.approach(self.showPos,self.vel)
      
      if self.pos.y == self.showPos.y:
        if self.vel.y > fp(1): self.vel.y *= self.bounceDampening
        else: self.vel.y = fp(0)
      if self.pos.x == self.showPos.x:
        if self.vel.x > fp(1): self.vel.x *= self.bounceDampening
        else: self.vel.x = fp(0)

proc draw*(self: var Title) =
  let screenpos = vec2i(self.pos)
  
  if onscreen(gfxLogo, screenpos):
    if self.gfx == gfxLogo:
      withObjs(3):
        objs[0] = self.obj.dup(pos = screenpos)
        objs[1] = self.obj.dup(pos = screenpos + vec2i(32,0), tid = self.obj.tid + 16)
        objs[2] = self.obj.dup(pos = screenpos + vec2i(64,0), tid = self.obj.tid + 32)
    elif self.gfx == gfxNewHighScore:
      withObjs(2):
        objs[0] = self.obj.dup(pos = screenpos)
        objs[1] = self.obj.dup(pos = screenpos + vec2i(32,0), tid = self.obj.tid + 8)
    else:
      withObj:
        obj = self.obj.dup(pos = screenpos)
