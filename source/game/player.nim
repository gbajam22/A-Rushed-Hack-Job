include prelude
import common, camera

const
  maxJumps = 2
  jumpHeight = fp(-4.5)
  
  maxSwordCooldown = 15
  
  swishEffects = [
    sfxSwish1,
    sfxSwish2,
    sfxSwish3,
    sfxSwish4,
    sfxSwish5,
    sfxSwish6,
    sfxSwish7,
    sfxSwish8,
    sfxSwish9,
    sfxSwish10,
    sfxSwish11,
    sfxSwish12,
    sfxSwish13,
  ]

type
  Player* = object
    obj: ObjAttr
    body*: Body
    vel*: Vec2f
    cameraOffset*: Vec2i
    jumpsRemaining: int
    anim: SimpleAnim
    onFloor: bool
    backSwing*: bool
    swordCooldown: int

proc setAnimToRunning(self: var Player) = self.anim.reset(9,4,0,0)
proc setAnimToJumping(self: var Player) = self.anim.reset(1,4,0,9)

proc x*(self: Player): Fixed =            self.body.pos.x
proc x*(self: var Player): var Fixed =    self.body.pos.x
proc `x=`*(self: var Player, x: Fixed) =  self.body.pos.x = x

proc y*(self: Player): Fixed =            self.body.pos.y
proc y*(self: var Player): var Fixed =    self.body.pos.y
proc `y=`*(self: var Player, y: Fixed) =  self.body.pos.y = y

proc pos*(self: Player): Vec2f =            self.body.pos
proc pos*(self: var Player): var Vec2f =    self.body.pos
proc `pos=`*(self: var Player, pos: Vec2f) =  self.body.pos = pos

proc jump*(self: var Player) =
  if self.jumpsRemaining > 0:
    self.vel.y = jumpHeight
    dec self.jumpsRemaining
    self.setAnimToJumping()
    self.onFloor = false

proc swordSlash*(self: var Player): bool =
  if self.swordCooldown <= 0:
    self.swordCooldown = maxSwordCooldown
    playSound(pickRandom(swishEffects))
    self.backSwing = not self.backSwing
    return true
  else:
    return false

proc reset*(self: var Player) =
  self.pos = vec2f(100,floorY - fp(self.body.h))
  self.vel = vec2f()
  self.swordCooldown = 0
  self.setAnimToRunning()

proc init*(self: var Player) =
  self.body.size = vec2i(8,28)
  
  self.reset()
  
  self.obj.init(
    tid = allocObjTiles(gfxPlayer),
    pal = acquireObjPal(gfxPlayer),
    size = gfxPlayer.size,
    prio = prioForeground
  )


proc destroy*(self: var Player) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(gfxPlayer)

proc update*(self: var Player) =
  let wasOnFloor = self.onFloor
  
  self.vel.y += gravity
  
  let targetVelX = fp(1.5) * (
    (if keyIsDown(kiLeft): -1 else: 0) +
    (if keyIsDown(kiRight): 1 else: 0)
  )
  
  self.vel.x.approach(targetVelX, fp(0.3))
  
  if self.swordCooldown > 0: dec self.swordCooldown
  
  self.pos += self.vel
  
  if self.body.bottom > floorY:
    self.pos.y = floorY - self.body.h
    self.vel.y = fp(0)
    self.jumpsRemaining = maxJumps
    self.onFloor = true
  
  const leftLimit = fp(0)
  if self.body.left < leftLimit:
    self.pos.x = leftLimit
    self.vel.x = fp(0)
  const rightLimit = fp(ScreenWidth)
  if self.body.right > rightLimit:
    self.pos.x = rightLimit - self.body.w
    self.vel.x = fp(0)
  
  if self.onFloor and not wasOnFloor: self.setAnimToRunning()
  
  self.anim.update()

proc draw*(self: var Player) =
  let screenpos = vec2i(self.body.centerBottom) - cameraOffset + vec2i(-16,-32)
  
  if self.anim.dirty():
    copyframe(addr objTileMem[self.obj.tid], gfxPlayer, self.anim.frame)
  
  if onscreen(gfxPlayer, screenpos):
    withObj:
      obj = self.obj.dup(pos = screenpos)