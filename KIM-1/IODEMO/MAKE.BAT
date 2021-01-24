..\..\ca65.exe IODEMO.ASM -o IODEMO.O -l IODEMO.LST
..\..\ld65.exe --cfg-path ..\..\cfg -t none -vm -o IODEMO.OUT IODEMO.O
..\..\srec_cat.exe IODEMO.OUT -binary -offset 0x0200 -Output IODEMO.PTP -MOS_Technologies