       org 0
       nop
       mov p1,#0feh
       mov tcon,#40h
       mov tmod,#20h
       mov th1,#-26  ;1000000/16= 62500/1200=52.083333333
       mov scon,#40h
       mov a,pcon
       clr acc.7
       mov pcon,a
       mov dptr,#6000h
       mov sbuf,#55h
       jmp c1
c2:
       movx a,@dptr
       mov sbuf,a
       inc dptr
       mov a,dph
       cjne a,#80h,c1
       jmp c3
c1:
       jnb ti,c1
       clr ti
       jmp c2
c3:
       mov a,#20h
       jmp c3
       end
