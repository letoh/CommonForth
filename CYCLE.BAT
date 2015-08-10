gcc cf.cc -c -g -fomit-frame-pointer -o cf.o
gcc invokec.cc -c -g -fomit-frame-pointer -o invokec.o
gcc extended.cc -c -g -fomit-frame-pointer -o extended.o
gcc cf.o invokec.o extended.o -fomit-frame-pointer -o cf -lc -lg -lgpp -lgcc -lgpl -lm -lpc -lgrx -Wl,-Map,CF.MAP,-T,SECTIONS.LD
