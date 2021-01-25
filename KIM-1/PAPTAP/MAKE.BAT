..\..\ca65.exe PAPTAP.ASM -o PAPTAP.O -l PAPTAP.LST
..\..\ld65.exe --cfg-path ..\..\cfg -t none -vm -o PAPTAP.OUT PAPTAP.O
..\..\srec_cat.exe PAPTAP.OUT -binary -offset 0x9000 -Output PAPTAP.PTP -MOS_Technologies