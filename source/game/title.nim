include prelude

const
  gravity = fp(0.2)
  topLimit = fp(-40)
  bottomLimit = fp(20)
  
  titleWidth = fp(96)
  titleX = (ScreenWidth - titleWidth) / 2
  
  psWidth = fp(32)
  psX = (ScreenWidth - psWidth) / 2
  psTopLimit = fp(60)
  psBottomLimit = fp(ScreenHeight) + fp(8)

type
  TitleState = enum
    tsHide
    tsShow
  Title* = object
    obj: ObjAttr
    pos: Vec2f
    vel: Vec2f
    state: TitleState

proc show*(self: var Title) =
  self.state = tsShow
  self.vel = vec2f()
proc hide*(self: var Title) =
  self.state = tsHide
  self.vel = vec2f()

proc init*(self: var Title) =
  self.pos = vec2f(titleX, topLimit)
  self.vel = vec2f()
  
  self.state = tsHide
  
  self.obj.init(
    tid = allocObjTiles(gfxLogo.allTiles),
    pal = acquireObjPal(gfxLogo),
    size = gfxLogo.size,
    prio = prioGUI
  )
  copyAllframes(addr objTileMem[self.obj.tid], gfxLogo)

proc destroy*(self: var Title) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(gfxLogo)

proc update*(self: var Title) =
  case self.state:
    of tsHide:
      self.vel.y -= gravity
      self.pos.y += self.vel.y
      if self.pos.y < topLimit:
        self.vel.y = fp(0)
        self.pos.y = topLimit
    of tsShow:
      self.vel.y += gravity
      self.pos.y += self.vel.y
      if self.pos.y > bottomLimit:
        if self.vel.y > fp(1): self.vel.y *= fp(-0.75)
        else: self.vel.y = fp(0)
        self.pos.y = bottomLimit

proc draw*(self: var Title) =
  let screenpos = vec2i(self.pos)
  
  if onscreen(gfxLogo, screenpos):
    withObjs(3):
      objs[0] = self.obj.dup(pos = screenpos)
      objs[1] = self.obj.dup(pos = screenpos + vec2i(32,0), tid = self.obj.tid + 16)
      objs[2] = self.obj.dup(pos = screenpos + vec2i(64,0), tid = self.obj.tid + 32)


type
  PSTitle* = object
    obj: ObjAttr
    pos: Vec2f
    vel: Vec2f
    state: TitleState

proc show*(self: var PSTitle) =
  self.state = tsShow
  self.vel = vec2f()
proc hide*(self: var PSTitle) =
  self.state = tsHide
  self.vel = vec2f()

proc init*(self: var PSTitle) =
  self.pos = vec2f(psX, psBottomLimit)
  self.vel = vec2f()
  
  self.state = tsHide
  
  self.obj.init(
    tid = allocObjTiles(gfxPressStart),
    pal = acquireObjPal(gfxPressStart),
    size = gfxPressStart.size,
    prio = prioGUI
  )
  copyAllframes(addr objTileMem[self.obj.tid], gfxPressStart)

proc destroy*(self: var PSTitle) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(gfxLogo)

proc update*(self: var PSTitle) =
  case self.state:
    of tsHide:
      self.vel.y += gravity
      self.pos.y += self.vel.y
      if self.pos.y > psBottomLimit:
        self.vel.y = fp(0)
        self.pos.y = psBottomLimit
    of tsShow:
      self.vel.y -= gravity
      self.pos.y += self.vel.y
      if self.pos.y < psTopLimit:
        if self.vel.y < fp(-1): self.vel.y *= fp(-0.5)
        else: self.vel.y = fp(0)
        self.pos.y = psTopLimit

proc draw*(self: var PSTitle) =
  let screenpos = vec2i(self.pos)
  
  if onscreen(gfxLogo, screenpos):
    withObj:
      obj = self.obj.dup(pos = screenpos)