include prelude
import common, camera

const
  topLimit = fp(40)
  bottomLimit = floorY - fp(20)

var
  objTarget: ObjAttr

proc setupTargetModule*() =
  objTarget.init(
    tid = allocObjTiles(gfxTarget.allTiles),
    pal = acquireObjPal(gfxTarget),
    size = gfxTarget.size
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
    pos: Vec2f
    kind: TargetKind
    finished: bool