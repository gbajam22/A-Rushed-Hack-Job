include prelude
import camera

type
  Slash* = object
    obj: ObjAttr
    anim: SimpleAnim
    body: Body
    vel: Vec2f
    finished*: bool

proc pos*(self: Slash): Vec2f =            self.body.pos
proc pos*(self: var Slash): var Vec2f =    self.body.pos
proc `pos=`*(self: var Slash, pos: Vec2f) =  self.body.pos = pos

proc createSlash*(pos, vel: Vec2f, vflip: bool): Slash =
  result.obj.init(
    tid = allocObjTiles(gfxSlash),
    pal = acquireObjPal(gfxSlash),
    size = gfxSlash.size,
    vflip = vflip,
  )
  result.body.size = vec2i(18,20)
  result.anim.init(8,0)
  result.pos = pos
  result.vel = vel

proc destroy*(self: var Slash) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(gfxSlash)

proc update*(self: var Slash) =
  if self.finished: return
  
  self.vel.y.approach(fp(0), fp(0.1))
  self.vel.x.approach(fp(0), fp(0.1))
  
  self.pos += self.vel
  
  self.anim.update()
  if self.anim.atEnd():
    self.finished = true

proc draw*(self: var Slash) =
  if self.finished: return
  
  let screenpos = vec2i(self.body.center) - cameraOffset + vec2i(-16,-16)
  
  if self.anim.dirty():
    copyframe(addr objTileMem[self.obj.tid], gfxSlash, self.anim.frame)
  
  if onscreen(gfxSlash, screenpos):
    withObj:
      obj = self.obj.dup(pos = screenpos)