include prelude
import scenes/game
import fader
import game

var introTimer: int

var fadeOut: bool

proc onShow =
  fadeAmount = 31
  
  introTimer = 240
  
  bgcnt[0].init(cbb = 1, sbb = 26)
  bgcnt[0].load(bgGBAJamLogo)
  
  bgofs[0].x = 0
  bgofs[0].y = 0
  
  bgColorBuf[0] = rgb5(0,0,0)
  
  dispcnt.init()
  
  display.layers = {lBg0}  # enable sprites
  display.obj1d = true

proc onHide =
  discard

proc onUpdate =
  if anyKeyHit({kiA,kiB,kiStart,kiSelect}):
    introTimer = 0
    fadeOut = true
  
  if introTimer >= 0: dec introTimer
  if introTimer == 0: fadeOut = true
  
  if fadeAmount > 0 and not fadeOut: dec fadeAmount
  
  if fadeOut:
    if fadeAmount < 31: inc fadeAmount
    else: setScene(GameScene)

proc onDraw =
  discard



const IntroScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)