*
*  Program ClfServ ( Chapter 9 )
*
Clear

Fn = 'c:config.sys'
Lf = FileSize(Fn)
La = FileAttr(Fn)
? 'File: ', Fn, '  Length: ' , Lf, '  Attribute: ', La

Fn = 'c:MsDos.sys'
Lf = FileSize(Fn)
La = FileAttr(Fn)
? 'File: ', Fn, '  Length: ' , Lf, '  Attribute: ', La

Fn = 'c:IBMDos.com'
Lf = FileSize(Fn)
La = FileAttr(Fn)
? 'File: ', Fn, '  Length: ' , Lf, '  Attribute: ', La

