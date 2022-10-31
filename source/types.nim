import natu/[oam, math]

const prioGui* = 0
const prioForeground* = 1
const prioActor* = 2
const prioBackground* = 3

type Body* {.bycopy.} = object
  ## Combination of position + size
  ## Used for collisions and movement.
  pos*: Vec2f
  size*: Vec2i

{.push inline.}

proc x*(body: Body): Fixed =            body.pos.x
proc x*(body: var Body): var Fixed =    body.pos.x
proc `x=`*(body: var Body, x: Fixed) =  body.pos.x = x

proc y*(body: Body): Fixed =            body.pos.y
proc y*(body: var Body): var Fixed =    body.pos.y
proc `y=`*(body: var Body, y: Fixed) =  body.pos.y = y

proc w*(body: Body): int =            body.size.x
proc w*(body: var Body): var int =    body.size.x
proc `w=`*(body: var Body, w: int) =  body.size.x = w

proc h*(body: Body): int =            body.size.y
proc h*(body: var Body): var int =    body.size.y
proc `h=`*(body: var Body, h: int) =  body.size.y = h

proc initBody*(x, y: Fixed, w, h: int): Body {.inline, noinit.} =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc initBody*(x, y, w, h: int): Body {.noinit.} =
  initBody(fp(x), fp(y), w, h)

proc initBody*(pos: Vec2f, w, h: int): Body {.noinit.} =
  initBody(pos.x, pos.y, w, h)

proc hitbox*(b: Body): Rect {.noinit.} =
  result.x = flr(b.x)
  result.y = flr(b.y)
  result.width = b.w
  result.height = b.h

proc hitbox*(b: Body, offset: Vec2i): Rect {.noinit.} =
  result.x = flr(b.x + fp(offset.x))
  result.y = flr(b.y + fp(offset.y))
  result.width = b.w
  result.height = b.h

proc center*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y + Fixed(b.h shl 7)

proc `center=`*(b: var Body, p: Vec2f) =
  b.x = p.x - Fixed(b.w shl 7)
  b.y = p.y - Fixed(b.h shl 7)

proc centerX*(b: Body): Fixed {.noinit.} =
  b.x + Fixed(b.w shl 7)

proc centerY*(b: Body): Fixed {.noinit.} =
  b.y + Fixed(b.h shl 7)

proc top*(b: Body): Fixed =
  b.y
proc bottom*(b: Body): Fixed =
  b.y + b.h
proc left*(b: Body): Fixed =
  b.x
proc right*(b: Body): Fixed =
  b.x + b.w

proc topLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y
proc topRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y
proc bottomLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y + fp(b.h)
proc bottomRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y + fp(b.h)

proc centerLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y + Fixed(b.h shl 7)
proc centerRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y + Fixed(b.h shl 7)
proc centerTop*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y
proc centerBottom*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y + fp(b.h)