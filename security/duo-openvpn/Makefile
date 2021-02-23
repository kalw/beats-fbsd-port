# New ports collection makefile for:   duo-openvpn
# Version required:    2.4
# Date created:        23 February 2021
# Whom:                kalw
#
# $FreeBSD$
#

PORTEPOCH=	2021022401
PORTNAME= duo-openvpn
PORTVERSION=    2.4
CATEGORIES=    security
USE_GITHUB= yes
MASTER_SITES=  GHC/releases/download/${PORTVERSION}/
GH_ACCOUNT= duosecurity
GH_PROJECT= duo_openvpn

MAINTAINER=    rdespres@indolore.net

.include <bsd.port.options.mk>


BUILD_DEPENDS= /usr/local/bin/gmake:${PORTSDIR}/devel/gmake

USES= gmake
PLIST_FILES= /usr/local/lib/${PORTNAME}/duo_openvpn.so

do-install:
	${MKDIR} ${STAGEDIR}/usr/local/lib/${PORTNAME}
	${INSTALL_PROGRAM} ${WRKSRC}/duo_openvpn.so ${STAGEDIR}/usr/local/lib/${PORTNAME}/


.include <bsd.port.mk>
