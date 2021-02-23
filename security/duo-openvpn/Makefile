# New ports collection makefile for:   duo-openvpn
# Version required:    2.4
# Date created:        23 February 2021
# Whom:                kalw
#
# $FreeBSD$
#
		
PORTNAME= duo-openvpn
PORTVERSION=    2.4
CATEGORIES=    security
MASTER_SITES=  GHC/releases/download/${PORTVERSION}/
GH_ACCOUNT= duosecurity
GH_PROJECT= duo_openvpn
		
MAINTAINER=    rdespres@indolore.net

USES=           compiler:c++11-lang gmake python37 py37-pip \
                openvpn
		
.include <bsd.port.mk>