project : .\cf.exp .SYMBOLIC

!define BLANK ""
.\cf.obj : .\cf.cpp .AUTODEPEND
 *wpp386 cf.cpp -4s -w4 -e25 -zq -of -otexan -d2 -fp3 -fpi87 -mf -bt=dos

.\invokec.obj : .\invokec.cpp .AUTODEPEND
 *wpp386 invokec.cpp -4s -w4 -e25 -zq -of -otexan -d2 -fp3 -fpi87 -mf -bt=dos

.\extended.obj : .\extended.cpp .AUTODEPEND
 *wpp386 extended.cpp -4s -w4 -e25 -zq -of -otexan -d2 -fp3 -fpi87 -mf -bt=dos

.\cf.exp : .\cf.obj .\invokec.obj .\extended.obj .AUTODEPEND
 @%write cf.lk1 NAME cf
 @%append cf.lk1 FIL cf.obj,invokec.obj,extended.obj
 @%append cf.lk1 
 *wlink op m SYS pharlap d all op st=8192 op maxe=25 op q op symf @cf.lk1
 @*del cf.lk1
 @copy cf.exp turnkey.
