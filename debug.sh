ELF_NAME="pong.elf"
if pidof "mgba-qt" > /dev/null; then
  echo "attaching to mgba"
  arm-none-eabi-gdb -q $ELF_NAME -ex "target remote localhost:2345"
else
  echo "launching mgba"
  ~/dev/mgba/build/qt/mgba-qt -g $ELF_NAME &
  sleep 2
  arm-none-eabi-gdb -q $ELF_NAME -ex "target remote localhost:2345"
  killall mgba-qt
fi