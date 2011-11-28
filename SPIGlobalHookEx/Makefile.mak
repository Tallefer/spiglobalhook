CC=@cl
LINK=@link
RC=@rc

CFLAGS=/nologo /MD
CPPFLAGS=/nologo /MD /D "_USRDLL" /D "_WINDOWS" /D "_WINDLL" /D "NDEBUG" /GL /Gd user32.lib /DEF:"SPIGlobalHookEx.def"
LDFLAGS=/nologo /DLL 
RCFLAGS=/nologo

EXE=\
SPIGlobalHookEx.dll

all:$(EXE)

$(EXE): $*.obj
	$(LINK) /OUT:$@ $** $(LDFLAGS)

clean:
	-@del *.ilk 2> nul
	-@del *.pdb 2> nul
	-@del *.obj 2> nul
	-@del *.lib 2> nul
	-@del *.exp 2> nul
	-@del *.dll 2> nul
	-@del *.exe 2> nul
	-@del *.res 2> nul
