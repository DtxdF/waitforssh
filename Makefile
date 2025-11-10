MKDIR?=mkdir -p
INSTALL?=install
SED?=sed -i ''
RM?=rm -f
PREFIX?=/usr/local
MANDIR?=${PREFIX}/share/man

WAITFORSSH_VERSION?=0.0.1

all: install

install:
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man1"
	${INSTALL} -m 444 waitforssh.1 "${DESTDIR}${MANDIR}/man1"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/bin"
	${INSTALL} -m 555 waitforssh.sh "${DESTDIR}${PREFIX}/bin/waitforssh"
	${SED} -e 's|%%VERSION%%|${WAITFORSSH_VERSION}|' "${DESTDIR}${PREFIX}/bin/waitforssh"

uninstall:
	${RM} "${DESTDIR}${PREFIX}/bin/waitforssh"
	${RM} "${DESTDIR}${MANDIR}/man1/waitforssh.1"
