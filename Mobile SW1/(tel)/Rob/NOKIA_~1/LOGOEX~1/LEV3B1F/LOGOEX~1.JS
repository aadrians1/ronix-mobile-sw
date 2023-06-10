var srcHTML;

srcHTML = "<DIV id=KBStatic style=position:absolute; left:600px; top:300px; width:42px; height:133px; z-index:25><DD>" +
"<table width=50 border=1 cellspacing=0 cellpadding=2 bgcolor=Silver bordercolor=Silver bordercolorlight=Gray bordercolordark=White><tr><td bgcolor=Gray align=center valign=MIDDLE><font color=#fffff>LogoExpress</font></td></tr>" +
"<tr><td align=CENTER valign=MIDDLE><A href=Readme.htm                target=_top class=txttool onMouseOver=this.className='txton' onMouseOut=this.className='txttool'>Home</a></td></tr>" +
"<tr><td align=CENTER valign=MIDDLE><A href=big5.htm                                      target=_top class=txttool onMouseOver=this.className='txton' onMouseOut=this.className='txttool'>BIG5 Code</a></td></tr>" +
"<tr><td align=CENTER valign=MIDDLE><A href=gb.htm                                        target=_top class=txttool onMouseOver=this.className='txton' onMouseOut=this.className='txttool'>GB Code</a></td></tr>" +
"<tr><td align=CENTER valign=MIDDLE><A href=http://communities.msn.com/logoexpress        target=_top class=txttool onMouseOver=this.className='txton' onMouseOut=this.className='txttool'>Community</a></td></tr>" +
"<tr><td align=CENTER valign=MIDDLE><a href=http://www.bizland.com/Guestbook.cmp?account=logoexpress&mode=view class=txttool onMouseOver=this.className='txton' onMouseOut=this.className='txttool'>View GuestBook</a></td></tr>" +
"</table></DD></DIV>";

var srcHTML2;

srcHTML2 = "<p><center> <a href=Readme.htm>Home</a> | "+
"<a href=big5.htm>Big5</a> | <a href=gb.htm>Gb</a> | "+
"<A href=http://communities.msn.com/logoexpress>Community</A> | "+
"<a href=http://www.bizland.com/Guestbook.cmp?account=logoexpress&mode=view>View GuestBook</A> <p> </center>";

function KB_keepItInIE(theName, theWantTop, theWantLeft) {
	theRealTop = parseInt(document.body.scrollTop);
	theTrueTop = theWantTop + theRealTop;
	document.all[theName].style.top = theTrueTop - 35;
	theRealLeft = parseInt(document.body.scrollLeft);
	theTrueLeft = theWantLeft + theRealLeft;
	document.all[theName].style.left = theTrueLeft + 16;
}

function KB_keepItInNN(theName, theWantX, theWantY) {
	theRealLay = document.layers[theName];
	theBadX = self.pageYOffset;
	theBadY = self.pageXOffset;
	theRealX = theBadX + theWantX - 65;
	theRealY = theBadY + theWantY + 15;
	theRealLay.moveTo(theRealY,theRealX);
}

function bookmark() {
	if (document.all) window.external.AddFavorite(document.location, "LogoExpress Homepage");
}

IE4 = (document.all)?1:0;
NN4 = (document.layers)?1:0;

if (IE4) setInterval('KB_keepItInIE("KBStatic",300,600)',1);
if (NN4) setInterval('KB_keepItInNN("KBStatic",300,600)',1);

document.write(srcHTML);
document.write(srcHTML2);