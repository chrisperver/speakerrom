# BUILD BINARIES

./rasm.exe -amper ../speakerromsource.asm -ob MYROM.rom

# PAD TO 16K

dd if=MYROM.rom ibs=16k of=./build/SpeakerROM.rom conv=sync

# MAKE ARCHIVE

zip -j ./build/SpeakerROM.zip ./build/SpeakerROM.rom
