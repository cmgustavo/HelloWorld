
MAINDIR=/helloworld
LOCALES_DEVEL=pt_BR es_ES  es_AR
LOCALES=pt_BR es_AR es_ES en_GB
TT=${MAINDIR}/tt
STATICS=${MAINDIR}/htdocs
BUILD='./compile-templates.pl' 
VER=$(shell git show |head -n 1 | cut -c38-50)
LST_TT=$(shell cd ${TT} ; find . -not -path \*build\* -not -path \*gettext\*  -iname \*tt)


all: devel

po:
	@$(foreach locale, ${LOCALES}, \
		make -C ${TT}/gettext/${locale}.utf8/LC_MESSAGES/; \
		)
	
devel: po
	@sudo rm -rf /tmp/ttc/*
	@echo "BUILDING TT for $@ "
	@$(foreach locale, ${LOCALES_DEVEL}, \
		${BUILD} --home $(TT) --out build --locale $(locale).UTF-8 --devel 2 $(LST_TT); \
		)
	@cp -pv  ${MAINDIR}/etc/$@/*  ${MAINDIR}/etc/

clean:
	@find ${TT} -iname \*mo -exec rm -f {} \;
	@find ${TT}/build -iname \*tt -type f -exec rm -f {} \;
