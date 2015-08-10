project : cf.exe .SYMBOLIC

wpp_options = -4s -w4 -e25 -zq -of -otexan -d3 -fp3 -fpi87 -mf -bt=dos
objs = cf.obj,invokec.obj,extended.obj

.cpp.obj: .AUTODEPEND
	wpp386 $[* $(wpp_options)

cf.obj : cf.cpp bind.h invokec.h 

invokec.obj : invokec.cpp invokec.h

extended.obj : extended.cpp invokec.h

cf.exe : cf.obj invokec.obj extended.obj
 *wlink @cf.lnk system pmodew file $(objs) nam cf

