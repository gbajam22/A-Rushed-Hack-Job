include prelude

type Label = object
  pos: Vec2i
  index: int
  finished: bool
  showTimer: int
  fadeTimer: int
  fadeTimerMax: int

type Labeller* = object
  labels: seq[Label]
  labelsTid: int
  labelsPalId: int
  gfx: Graphic
  indexOffset: int

proc init*(self: var Labeller, gfx: Graphic) =
  self.labelsTid = allocObjTiles(gfx.allTiles)
  copyAllFrames(addr objTileMem[self.labelsTid], gfx)
  self.labelsPalId = acquireObjPal(gfx)
  self.gfx = gfx
  self.labels.setLen(0)
  self.indexOffset = gfx.frameTiles()

proc destroy*(self: var Labeller) =
  freeObjTiles(self.labelsTid)
  releaseObjPal(self.gfx)

proc update(label: var Label) =
  dec label.showTimer
  if label.showTimer <= 0:
    dec label.fadeTimer
    if label.fadeTimer <= 0: label.finished = true

proc draw(label: Label, labeller: Labeller) =
  withObjAndAff:
    aff.setToScaleInv(fp 1, (fp label.fadeTimer / label.fadeTimerMax).clamp(fp 0, fp 1))
    obj.init(
      mode = omAff,
      aff = affId,
      pos = label.pos,
      tid = labeller.labelsTid + (label.index * labeller.indexOffset),
      pal = labeller.labelsPalId,
      size = labeller.gfx.size
    )

proc addLabel*(self: var Labeller, pos: Vec2i = vec2i(0,0), index = 0, showTimer = 25, fadeTimer = 10) = 
  
  var label: Label
  
  label.index = index
  label.pos = pos
  label.showTimer = showTimer
  label.fadeTimer = fadeTimer
  label.fadeTimerMax = fadeTimer
  label.finished = false
  
  self.labels.insert(label)
  

proc update*(self: var Labeller) =
  var i = 0
  
  while i < self.labels.len:
    self.labels[i].update()
    if self.labels[i].finished:
      self.labels.delete(i)
    else:
      inc i
  

proc draw*(self: Labeller) =
  for label in self.labels:
    label.draw(self)


