@REM
@REM  RELEASE [PATH]         = Copy a release of current version
@REM  RELEASE [PATH] HISTORY = Make a history record for current verision,
@REM                           use HISTORY.BAT to achieve this.

@IF %1.==. GOTO ERROR
@IF %1.==HISTORY. GOTO ERROR
@IF NOT %2.==HISTORY. GOTO START

:MkHistory
COPY RELEASE.BAT        %1 >NUL
COPY HISTORY.BAT        %1 >NUL

:START
COPY GO32.EXE           %1 >NUL
COPY EMU387             %1 >NUL
COPY VESADRV.VDR        %1 >NUL
COPY STRIP.EXE          %1 >NUL

:CopyBatch
COPY CYCLE.BAT          %1 >NUL
COPY BIND.BAT           %1 >NUL

COPY HI.4TH             %1 >NUL
COPY STRUCT.4TH         %1 >NUL
COPY HEAD.4TH           %1 >NUL
COPY MEMMAP.4TH         %1 >NUL
COPY CASE.4TH           %1 >NUL
COPY DOLOOP.4TH         %1 >NUL
COPY VOCAB.4TH          %1 >NUL
COPY MULTASK.4TH        %1 >NUL
COPY INVOKEC.4TH        %1 >NUL
COPY TRACER.4TH         %1 >NUL
COPY STKEXPR.4TH        %1 >NUL
COPY SHORTCUT.4TH       %1 >NUL
COPY #IF.4TH            %1 >NUL
COPY ASSERT.4TH         %1 >NUL
COPY FSAVE.4TH          %1 >NUL
COPY KEYBUF.4TH         %1 >NUL

COPY CPU80486.4TH       %1 >NUL
COPY VERIFY.4TH         %1 >NUL
COPY VERIFYPO.4TH       %1 >NUL
COPY DISASM.4TH         %1 >NUL
COPY SEE.4TH            %1 >NUL
COPY FLOAT.4TH          %1 >NUL
COPY LOADINFO.4TH       %1 >NUL
COPY 387FLOAT.4TH       %1 >NUL
COPY GRX.OLD            %1 >NUL
COPY GRX.4TH            %1 >NUL
COPY FONTDATA.4TH       %1 >NUL
COPY GRAPHICS.4TH       %1 >NUL
COPY LL(K)GEN.4TH       %1 >NUL
COPY INFIX.4TH          %1 >NUL
COPY LL(K)GEN.ART       %1 >NUL
COPY INFIX.ART          %1 >NUL
COPY DOSCMD.4TH         %1 >NUL
COPY INTR.4TH           %1 >NUL
COPY DBG1652.4TH        %1 >NUL
COPY CHINESE.4TH        %1 >NUL
COPY KEYTABLE.4TH       %1 >NUL
COPY SPOOLER.4TH        %1 >NUL

COPY DEMO_C.4TH         %1 >NUL
COPY DEMO_SEE.4TH       %1 >NUL
COPY DEMO_GRX.4TH       %1 >NUL
COPY DEMO_IFX.4TH       %1 >NUL
COPY 3DROTATE.4TH       %1 >NUL
COPY 3DR.4TH            %1 >NUL
COPY 3DRP.4TH           %1 >NUL
COPY HANOI.4TH          %1 >NUL
COPY FIB.4TH            %1 >NUL
COPY ROMAN.4TH          %1 >NUL
COPY ALLTOOLS.4TH       %1 >NUL

COPY CFMETA.4TH         %1 >NUL
COPY CF0.4TH            %1 >NUL
COPY META2              %1 >NUL
COPY CFMETA             %1 >NUL

COPY INVOKEC.H          %1 >NUL
COPY INVOKEC.CC         %1 >NUL
COPY EXTENDED.CC        %1 >NUL
COPY CF.CC              %1 >NUL
COPY SECTIONS.LD        %1 >NUL
COPY MAKEFILE           %1 >NUL
COPY CF                 %1 >NUL
COPY CF TURNKEY >NUL
STRIP TURNKEY

COPY RKSEARCH.4TH       %1 >NUL
COPY TURNKEY.4TH        %1 >NUL
COPY T3DR.4TH           %1 >NUL
COPY T3DRP.4TH          %1 >NUL
COPY THANOI.4TH         %1 >NUL
COPY TURNKEY            %1 >NUL

COPY CF.IMG             %1.\CF_IMG.BAK >NUL
COPY CF.HED             %1.\CF_HED.BAK >NUL
REM ATTRIB +R           %1.\CF_IMG.BAK >NUL
REM ATTRIB +R           %1.\CF_HED.BAK >NUL
COPY CF.EXE             %1 >NUL
COPY CF.IMG             %1 >NUL
COPY CF.HED             %1 >NUL
COPY CF0.INI            %1.\SAMPLECF.INI >NUL

COPY LIBGRX.DOC         %1 >NUL
COPY INTERNAL.DOC       %1 >NUL
COPY DRIVERS.DOC        %1 >NUL

COPY README.DJ          %1 >NUL
COPY README.G32         %1 >NUL
COPY README.GRX         %1 >NUL
COPY README.2ND         %1 >NUL
COPY README.TXT         %1 >NUL
COPY MANUAL.DOC         %1 >NUL
COPY DEMO.BAT           %1 >NUL

REM -- Copy only necessary fonts --
MD %1.\FONTS >NUL
XCOPY FONTS             %1.\FONTS >NUL
MD %1.\DRIVERS >NUL
XCOPY DRIVERS           %1.\DRIVERS >NUL
MD %1.\SAMPLES >NUL
XCOPY SAMPLES           %1.\SAMPLES >NUL
MD %1.\MF >NUL
XCOPY MF                %1.\MF   >NUL

@GOTO END
:ERROR
@ECHO.
@ECHO. * Release a copy of current Common Forth system *
@ECHO  Syntax:
@ECHO      RELEASE [PATH]
@ECHO.
:END

