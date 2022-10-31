include prelude
import natu/[maxmod]
import game/[player, slash, title, target, camera, scoreLabel]
import fader, saveData

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
    targets: List[20,Target]
    title: Title
    psTitle: Title
    controls: Title
    gameOverTitle: Title
    newHighScoreTitle: Title
    
    scoreLabel: ScoreLabel
    highScoreLabel: ScoreLabel
    
    freezeFrame: int
    freezeJumpBuffer: bool
    freezeSlashBuffer: bool
    
    targetSpawnTimer: int
    maxTargetSpawnTimer: int
    
    lives: int
    
    scrollPos: Fixed
    scrollSpeed: Fixed
    
    state: GameState

var game: Game

proc setScore(score: int) =
  game.score = score
  game.scoreLabel.setScore(game.score)

proc setHighScore(score: int) =
  game.highScoreLabel.setScore(score)
  saveBestScore(score.uint)

proc resetGame() =
  for s in game.slashes.mitems():
    s.destroy()
  game.slashes.clear()
  for t in game.targets.mitems():
    t.destroy()
  game.targets.clear()
  
  game.player.reset()
  
  game.maxTargetSpawnTimer = 120
  game.targetSpawnTimer = game.maxTargetSpawnTimer
  
  game.freezeFrame = 0
  
  game.lives = 3
  setScore(0)

proc setGameState(state: GameState) =
  case state:
    of gsFadeIn:
      fadeAmount = 31
      resetGame()
    of gsTitle:
      printf("TITLE")
      game.title.show()
      game.psTitle.show(psShowPos)
      game.controls.show()
    of gsPlay:
      printf("PLAY")
      game.title.hide()
      game.psTitle.hide()
      game.controls.hide()
    of gsGameOver:
      for t in game.targets.mitems:
        t.finished = true
      game.gameOverTitle.show()
      game.psTitle.show(psgoShowPos)
      if game.score > getBestScore().int:
        setHighScore(game.score)
        game.newHighScoreTitle.show()
    of gsFadeOut:
      fadeAmount = 0
      game.gameOverTitle.hide()
      game.newHighScoreTitle.hide()
      game.psTitle.hide()
  
  game.state = state

proc onShow =
  
  playSong(modNinjaGroove)
  
  cameraOffset = vec2i()
  
  game.player.init()
  
  game.title.init(gfxLogo, titleHidePos, titleShowPos)
  game.psTitle.init(gfxPressStart, psHidePos, psShowPos)
  game.controls.init(gfxControls, controlsHidePos, controlsShowPos)
  game.gameOverTitle.init(gfxGameOver, gameOverHidePos, gameOverShowPos)
  game.newHighScoreTitle.init(gfxNewHighScore, newHighScoreHidePos, newHighScoreShowPos)
  
  game.scoreLabel.init(vec2i(10,10), "Score: ".cstring)
  game.highScoreLabel.init(vec2i(10,20), "High Score: ".cstring, getBestScore().int)
  
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
  game.controls.destroy()
  game.gameOverTitle.destroy()
  game.newHighScoreTitle.destroy()
  
  game.scoreLabel.destroy()
  game.highScoreLabel.destroy()
  
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
  setScore(game.score + val)

proc takeDamage() =
  cameraShake(fp(3),fp(0.25))
  game.freezeFrame = 5
  dec game.lives
  playSound(sfxAlarm)
  
  if game.lives <= 0:
    setGameState(gsGameOver)
  #TODO: ADD FAILURE

proc cleanUpTargets(index: int = 0) =
  if index >= game.targets.len: return
  
  if game.targets[index].finished:
    if game.targets[index].failed: takeDamage()
    elif game.state == gsPlay: scorePoint()
    
    game.targets[index].destroy()
    game.targets.delete(index)
    
    cleanUpSlashes(index)
  else:
    cleanUpSlashes(index + 1)

proc onUpdate =
  
  updateCamera()
  
  if game.freezeFrame > 0:
    dec game.freezeFrame
    if keyHit(kiA): game.freezeJumpBuffer = true
    if keyHit(kiB): game.freezeSlashBuffer = true
    return
  
  game.title.update()
  game.psTitle.update()
  game.controls.update()
  game.gameOverTitle.update()
  game.newHighScoreTitle.update()
  
  game.scoreLabel.update()
  game.highScoreLabel.update()
  
  case game.state:
    of gsFadeIn:
      if fadeAmount > 0: dec fadeAmount
      else: setGameState(gsTitle)
    of gsTitle:
      if keyHit(kiStart): setGameState(gsPlay)
    of gsPlay:
      dec game.targetSpawnTimer
      
      if game.targetSpawnTimer <= 0:
        game.targets.add(initTarget(tkSturdy))
        game.targetSpawnTimer = game.maxTargetSpawnTimer
    of gsGameOver:
      if keyHit(kiStart): setGameState(gsFadeOut)
    of gsFadeOut:
      if fadeAmount < 31: inc fadeAmount
      else: setGameState(gsFadeIn)
  
  game.scrollSpeed.approach(fp(2),fp(0.2))
  game.scrollPos += game.scrollSpeed
  
  if keyHit(kiB) or game.freezeSlashBuffer:
    game.freezeSlashBuffer = false
    if game.player.swordSlash():
      game.slashes.add(
        createSlash(
          game.player.pos + vec2f(fp(16),fp(0)),
          vec2f(game.player.vel.x,fp(0)),
          game.player.backSwing)
      )
  
  if keyHit(kiA) or game.freezeJumpBuffer:
    game.freezeJumpBuffer = false
    game.player.jump()
  
  game.player.update()
  
  for s in game.slashes.mitems():
    s.update()
  cleanUpSlashes()
  
  for t in game.targets.mitems():
    t.update()
    if not t.finished and t.invulTimer <= 0:
      for s in game.slashes.mitems():
        if not t.finished and collide(t.body,s.body):
          t.hit()
          game.freezeFrame = 5
          cameraShake(fp(1.5),fp(0.25))
  cleanUpTargets()
  
  # wrap point needs to be a multiple of 4096
  const wrapPoint = fp(8192)
  # wrap player position to prevent overflow
  if game.scrollPos > wrapPoint:
    game.scrollPos -= wrapPoint

proc onDraw =
  let scroll = game.scrollPos.toInt() 
  
  bgofs[0].x = scroll.int16 - cameraOffset.x.int16
  bgofs[0].y = 64-cameraOffset.y.int16
  
  bgOfs[1].x = (scroll div 2).int16 - cameraOffset.x.int16
  bgofs[1].y = 128-cameraOffset.y.int16
  
  bgOfs[2].x = (scroll div 4).int16
  bgOfs[3].x = (scroll div 8).int16
  
  game.title.draw()
  game.psTitle.draw()
  game.controls.draw()
  game.gameOverTitle.draw()
  game.newHighScoreTitle.draw()
  
  if game.state in {gsPlay,gsGameOver,gsFadeOut}:
    game.scoreLabel.draw()
    game.highScoreLabel.draw()
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