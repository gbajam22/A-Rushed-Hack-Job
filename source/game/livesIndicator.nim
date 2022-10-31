include prelude

type
  LivesIndicator* = object
    obj: ObjAttr
    total*: int
    remaining*: int

proc init*(self: var LivesIndicator, total: int) =
  self.total = total
  
  let screenpos = vec2i((ScreenWidth - ((total * 18) - 2)) div 2, ScreenHeight - 17)
  
  self.obj.init(
    tid = allocObjTiles(gfxLives.allTiles),
    pal = acquireObjPal(gfxLives),
    size = gfxLives.size,
    prio = prioGUI,
    pos = screenpos
  )
  copyAllframes(addr objTileMem[self.obj.tid], gfxLives)

proc destroy*(self: var LivesIndicator) =
  freeObjTiles(self.obj.tid)
  releaseObjPal(gfxLives)

proc setLives*(self: var LivesIndicator, val: int) =
  self.remaining = val

proc draw*(self: var LivesIndicator) =
  var total = self.total
  var remain = self.remaining
  
  for i in 0..self.total-1:
    var tidOffset = 0
    if total != remain:
      tidOffset = 4
      dec total
    
    withObj:
      obj = self.obj.dup(
        pos = self.obj.pos + vec2i(i*18,0),
        tid = self.obj.tid + tidOffset
      )