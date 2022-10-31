include prelude
import common, camera

const
  topLimit = fp(16)
  bottomLimit = floorY - fp(32)
  
  rightLimit = fp(ScreenWidth)
  leftLimit = fp(-16)
  
  targetSpeed = fp(-1)
  
  breakEffects = [
    sfxImpact1,
    sfxImpact2,
    sfxImpact3,
    sfxImpact4,
    sfxImpact5,
    sfxImpact6,
    sfxImpact7,
    sfxImpact8,
    sfxImpact9,
    sfxImpact10,
  ]

var
  objTarget: ObjAttr

proc setupTargetModule*() =
  objTarget.init(
    tid = allocObjTiles(gfxTarget.allTiles),
    pal = acquireObjPal(gfxTarget),
    size = gfxTarget.size,
    prio = prioActor
  )
  copyAllframes(addr objTileMem[objTarget.tid], gfxTarget)

proc destroyTargetModule*() =
  freeObjTiles(objTarget.tid)
  releaseObjPal(gfxTarget)

type
  TargetKind* = enum
    tkNormal
    tkSturdy
    tkMoving
  Target* = object
    body*: Body
    speed: Fixed
    kind: TargetKind
    finished*: bool
    failed*: bool

proc pos*(self: Target): Vec2f =            self.body.pos
proc pos*(self: var Target): var Vec2f =    self.body.pos
proc `pos=`*(self: var Target, pos: Vec2f) =  self.body.pos = pos

proc initTarget*(kind: TargetKind): Target =
  result.kind = kind
  
  result.finished = false
  result.failed = false
  
  result.speed = targetSpeed
  
  result.body.size = vec2i(16,32)
  
  result.pos = vec2f(rightLimit, rand(topLimit,bottomLimit))

proc destroy*(self: var Target) =
  discard

proc hit*(self: var Target) =
  playSound(pickRandom(breakEffects))
  if self.kind == tkSturdy:
    self.speed = fp(3)
    self.kind = tkNormal
  else:
    self.finished = true

proc update*(self: var Target) =
  self.speed.approach(targetSpeed, fp(0.1))
  self.pos.x += self.speed
  
  if self.pos.x <= leftLimit:
    self.finished = true
    self.failed = true

proc draw*(self: var Target) =
  if self.finished: return
  
  let screenpos = vec2i(self.pos) - cameraOffset
  
  let tidOffset = ord(self.kind) * 8
  
  if onscreen(gfxTarget, screenpos):
    withObj:
      obj = objTarget.dup(pos = screenpos, tid = objTarget.tid + tidOffset)