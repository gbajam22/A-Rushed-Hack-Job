include prelude
import common, camera

const
  topLimit = fp(16)
  bottomLimit = floorY - fp(32)
  
  centerLimit = (topLimit + bottomLimit) / 2
  limitAmplitude = centerLimit - topLimit
  
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
    tkSturdyMoving
    tkFast
  Target* = object
    body*: Body
    speed: Fixed
    kind: TargetKind
    invulTimer*: int
    ticker*: uint32
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
  result.invulTimer = 0
  result.body.size = vec2i(16,32)
  
  result.ticker = rand(uint32)
  
  result.pos = vec2f(rightLimit, rand(topLimit,bottomLimit))

proc destroy*(self: var Target) =
  discard

proc hit*(self: var Target) =
  playSound(pickRandom(breakEffects))
  if self.kind in {tkSturdy,tkSturdyMoving}:
    self.speed = fp(3)
    dec self.kind
    self.invulTimer = 10
  else:
    self.finished = true

proc update*(self: var Target) =
  if self.invulTimer > 0: dec self.invulTimer
  
  var approachSpeed = targetSpeed
  
  case self.kind:
    of tkNormal:
      discard
    of tkSturdy:
      discard
    of tkMoving:
      self.ticker += 200
      self.pos.y = centerLimit + (limitAmplitude * lusin(self.ticker).fp)
    of tkSturdyMoving:
      self.ticker += 150
      self.pos.y = centerLimit + (limitAmplitude * lusin(self.ticker).fp)
    of tkFast:
      approachSpeed *= fp(1.7)
  
  self.speed.approach(approachSpeed, fp(0.1))
  self.pos.x += self.speed
  
  if self.pos.x <= leftLimit:
    self.finished = true
    self.failed = true

proc draw*(self: var Target) =
  let screenpos = vec2i(self.pos) - cameraOffset
  
  let tidOffset = ord(self.kind) * 8
  
  if onscreen(gfxTarget, screenpos):
    withObj:
      obj = objTarget.dup(pos = screenpos, tid = objTarget.tid + tidOffset)