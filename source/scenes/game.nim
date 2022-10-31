include prelude
import natu/[maxmod]
import game/[player, slash, title, target]
import fader

type
  GameState = enum
    gsFadeIn
    gsTitle
    gsPlay
    gsGameOver
    gsFadeOut
  
  Game = object
    score: int
    player: Player
    slashes: List[10,Slash]
    targets: List[10,Target]
    title: Title
    psTitle: PSTitle
    
    
    targetSpawnTimer: int
    maxTargetSpawnTimer: int
    
    scrollPos: Fixed
    scrollSpeed: Fixed
    
    state: GameState

var game: Game

proc resetGame() =
  for s in game.slashes.mitems():
    s.destroy()
  game.slashes.clear()
  for t in game.targets.mitems():
    t.destroy()
  game.targets.clear()
  
  game.player.reset()
  
  game.maxTargetSpawnTimer = 60
  game.targetSpawnTimer = game.maxTargetSpawnTimer
  
  game.score = 0

proc setGameState(state: GameState) =
  case state:
    of gsFadeIn:
      fadeAmount = 31
      playSong(modNinjaGroove)
      resetGame()
    of gsTitle:
      printf("TITLE")
      game.title.show()
      game.psTitle.show()
    of gsPlay:
      printf("PLAY")
      game.title.hide()
      game.psTitle.hide()
    of gsGameOver:
      stopSong()
    of gsFadeOut:
      discard
  
  game.state = state

proc onShow =
  
  game.player.init()
  
  game.title.init()
  game.psTitle.init()
  
  setupTargetModule()
  
  bgcnt[0].init(cbb = 1, sbb = 26, prio = prioBackground)
  bgcnt[0].load(bgFloor)
  
  bgofs[0].x = 0
  bgofs[0].y = 64
  
  bgcnt[3].init(cbb = 0, sbb = 28, prio = prioBackground, size = reg64x32)
  bgcnt[2].init(cbb = 0, sbb = 30, prio = prioBackground, size = reg64x32)
  bgcnt[1].init(cbb = 2, sbb = 24, prio = prioBackground, size = reg64x32)
  
  bgcnt[1].load(bgTrees)
  
  bgcnt[3].load(bgMountains)
  
  bgofs[3].x = 0
  bgofs[3].y = 108
  
  bgofs[2].x = 0
  bgofs[2].y = 108
  
  bgofs[1].x = 0
  bgofs[1].y = 128
  
  bgColorBuf[0] = rgb5(5,5,12)
  
  dispcnt.init()
  
  display.layers = { lObj, lBg0, lBg1, lBg2, lBg3 }  # enable sprites
  display.obj1d = true
  
  setGameState(gsFadeIn)

proc onHide =
  game.player.destroy()
  
  for s in game.slashes.mitems():
    s.destroy()
  game.slashes.clear()
  for t in game.targets.mitems():
    t.destroy()
  game.targets.clear()
  
  game.title.destroy()
  game.psTitle.destroy()
  
  destroyTargetModule()

proc cleanUpSlashes(index: int = 0) =
  if index >= game.slashes.len: return
  
  if game.slashes[index].finished:
    game.slashes[index].destroy()
    game.slashes.delete(index)
    cleanUpSlashes(index)
  else:
    cleanUpSlashes(index + 1)

proc scorePoint(val: int = 1) = 
  game.score += val

proc takeDamage() =
  discard
  #TODO: ADD FAILURE

proc cleanUpTargets(index: int = 0) =
  if index >= game.targets.len: return
  
  if game.targets[index].failed: takeDamage()
  else: scorePoint()
  
  if game.targets[index].finished:
    game.targets[index].destroy()
    game.targets.delete(index)
    cleanUpSlashes(index)
  else:
    cleanUpSlashes(index + 1)

proc onUpdate =
  
  game.title.update()
  game.psTitle.update()
  
  case game.state:
    of gsFadeIn:
      if fadeAmount > 0: dec fadeAmount
      else: setGameState(gsTitle)
    of gsTitle:
      if keyHit(kiStart): setGameState(gsPlay)
    of gsPlay:
      dec game.targetSpawnTimer
      
      if game.targetSpawnTimer <= 0:
        game.targets.add(initTarget(tkNormal))
        game.targetSpawnTimer = game.maxTargetSpawnTimer
    of gsGameOver:
      if keyHit(kiStart): setGameState(gsFadeOut)
    of gsFadeOut:
      if fadeAmount < 31: inc fadeAmount
      else: setGameState(gsFadeIn)
  
  game.scrollSpeed.approach(fp(2),fp(0.2))
  game.scrollPos += game.scrollSpeed
  
  if keyHit(kiB):
    if game.player.swordSlash():
      game.slashes.add(
        createSlash(
          game.player.pos + vec2f(fp(16),fp(0)),
          vec2f(game.player.vel.x,fp(0)),
          game.player.backSwing)
      )
  
  if keyHit(kiA):
    game.player.jump()
  
  game.player.update()
  
  for s in game.slashes.mitems():
    s.update()
  cleanUpSlashes()
  
  for t in game.targets.mitems():
    t.update()
    for s in game.slashes.mitems():
      if not t.finished and collide(t.body,s.body):
        t.hit()
  cleanUpTargets()
  
  # wrap point needs to be a multiple of 4096
  const wrapPoint = fp(8192)
  # wrap player position to prevent overflow
  if game.scrollPos > wrapPoint:
    game.scrollPos -= wrapPoint

proc onDraw =
  let scroll = game.scrollPos.toInt() 
  
  bgofs[0].x = scroll.int16
  bgOfs[3].x = (scroll div 8).int16
  bgOfs[2].x = (scroll div 4).int16
  bgOfs[1].x = (scroll div 2).int16
  
  game.title.draw()
  game.psTitle.draw()
  game.player.draw()
  for s in game.slashes.mitems():
    s.draw()
  for t in game.targets.mitems():
    t.draw()

const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)