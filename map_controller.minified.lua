b=screen;r=input;t=output;I=math;J=map;aj=property;
--yyy--
y=5;g=5;n=1;k=1;j=1;z=2;O=z^-3;P=z^4;h=99999;Q=false;c={}function c.new()return{first=0,last=-1}end;function c.pushright(a,F)local u=a.last+1;a.last=u;a[u]=F end;function c.popleft(a)local A=a.first;if A>a.last then return nil end;local F=a[A]a[A]=nil;a.first=A+1;return F end;function c.peekleft(a)if a.first>a.last then return nil end;return a[a.first]end;function c.peekright(a)if a.first>a.last then return nil end;return a[a.last]end;function c.window2(a,a0)local v=a.first;local l=v+1;while l<=a.last do a0(a[v],a[l])v=l;l=l+1 end end;function c.len(a)return a.last-a.first+1 end;e=c.new()function B(m,R,S)if m<R then m=R elseif m>S then m=S end;return m end;function T(G)if G==nil then G=0 end;return G end;function w()f=nil;o=nil end;function onTick()if U~=nil and V==nil then V=B(U/10,4,100)p=V/2 end;q=T(r.getNumber(1))s=T(r.getNumber(2))C=r.getNumber(5)if not Q and r.getBool(1)then f=r.getNumber(3)o=r.getNumber(4)else w()end;Q=r.getBool(1)a1()a2()end;function H(m,W,a3)X=I.rad(a3)Y=I.sin(X)Z=I.cos(X)local a4=m*Z-W*Y;local a5=W*Z+m*Y;return a4,a5 end;function a1()if f~=nil and o~=nil then if o>=h then if f>=d-g and f<d then j=B(j*z,O,P)w()elseif f>d and f<=d+g then j=B(j/z,O,P)w()end end end end;function _()e=c.new()for a6=2,5 do t.setNumber(a6,0)end end;function a2()local i=c.peekleft(e)if i~=nil then local a7=((i.x-q)^2+(i.y-s)^2)^0.5;if a7<aj.getNumber("wptRadius")then c.popleft(e)t.setBool(1,true)else t.setBool(1,false)end end;if r.getBool(2)or c.len(e)==0 then _()end;if f~=nil and o~=nil then if o>=h-1 and f<=g then _()w()elseif o<h or f<d-g or f>d+g then local a8,a9=J.screenToMap(q,s,j,n,k,f,o)c.pushright(e,{x=a8,y=a9})w()end end;t.setNumber(1,c.len(e))local i=c.peekleft(e)if i~=nil then t.setNumber(2,i.x)t.setNumber(3,i.y)end;local u=c.peekright(e)if u~=nil then t.setNumber(4,u.x)t.setNumber(5,u.y)end end;function aa()if q~=nil and s~=nil and p~=nil then b.setColor(0,0,0)b.drawCircleF(d,x,B(p/8,1,5))if C~=nil then D,E=H(0,-p,C)K,L=H(-p,p,C)M,N=H(p,p,C)D=D+d;E=E+x;K=K+d;L=L+x;M=M+d;N=N+x;b.drawLine(D,E,K,L)b.drawLine(D,E,M,N)end end end;function ab()h=k-y;b.setColor(0,0,0,200)b.drawRectF(d-g,h,g,y)b.drawRectF(d+1,h,g,y)b.setColor(255,255,255)b.drawText(d-g+1,h,"-")b.drawText(d+2,h,"+")end;function ac()if c.len(e)>0 then local i=c.peekleft(e)local ad,ae=J.mapToScreen(q,s,j,n,k,i.x,i.y)b.setColor(69,0,48,175)b.drawLine(d,x,ad,ae)b.setColor(96,96,96,175)c.window2(e,function(v,l)af,ag=J.mapToScreen(q,s,j,n,k,v.x,v.y)ah,ai=J.mapToScreen(q,s,j,n,k,l.x,l.y)b.drawLine(af,ag,ah,ai)end)b.setColor(0,0,0,200)b.drawRectF(0,h-1,g+1,y+2)b.setColor(255,0,0)b.drawText(1,h,"X")end end;function onDraw()n=b.getWidth()k=b.getHeight()d=n/2;x=k/2;U=I.min(n,k)b.drawMap(q,s,j)ac()aa()ab()end
