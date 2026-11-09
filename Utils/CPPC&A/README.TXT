M & T Publishing
411 Borel Ave
San Mateo, CA 94402 
copyright 1992
C++ Components & Algorithms
Scott Robert Ladd
ISBN #1-55851-227-6
-------
READ.ME
-------


Hello!

Thank you for purchasing C++ COMPONENTS AND ALGORITHMS. This disk contains
the complete source code for the book. The book's appendix A contains the 
complete source code for these files as well.

All of this code has been tested using Microsoft C/C++ 7.00 and Borland
C++ version 3.00. Please note the following:

    - When compiling with Borland C++'s optimizer, do NOT use
      the -Z switch (which is implied by -O2). A bug in Borland's
      compiler generates bad code when -Z is used. Borland's next
      release will fix this problem. Also, Borland C++ produces a
      slow program when using the buffer stream functions (fopen,
      fwrite, etc.) Converting the DataFile and PageFile classes
      to the use of UNIX-style, unbuffered I/O improves the speed
      of programs by a factor of three or four. This change, however,
      will make the classes less portable, since the UNIX I/O
      functions are not a part of the ANSI standard.

    - This book was originally intended to be compatible with 
      Zortech C++. That support was removed after I encountered 
      several major bugs in Zortech C++ version 3.0. In particular,
      Zortech has trouble linking with external data items, and
      passes an invalid "this" pointer to user defined conversion
      functions. Thus, Zortech's BLINK could not find NULL_BLOCK and 
      PFP_NULL, and it failed to compile working conversions of 
      objects to DataBlocks or char *s. Zortech/Symantec promises 
      that their next release will fix this problem.

    - Microsoft C++ reports spurious warnings when optimizing. The
      "unreachable code" and "conditional expression is constant"
      warnings are an artifact of Microsoft's optimization, and they
      can safely be ignored.

    - You will find minor difference between the code on this disk
      and the code presented in the book. In particular, the BTree
      library has been enhanced with better root page handling and
      minor improvements in the algorithms.

This code should be portable to operating systems other than MS-DOS, 
since I did not use any DOS-specific language or library extensions.
If you move this code to Windows, the DataFile classes will need to
be modified to use the file functions provided by Windows.

I hope that this source code is useful to you. What you're seeing is
actual production code, developed for real-world applications. If you
have any questions, please feel free to contact me via M&T Books.
Suggestions are always welcome.

Scott Robert Ladd
Colorado Springs
April 22, 1992


A:\
³   READ.ME
³   
ÃÄÄÄTOOLS
³       ERR_RPTR.CXX    Chapter  2: ErrorReporter class
³       ERR_RPTR.H
³
³       RANDGEN.CXX     Chapter  2: RandGen class
³       RANDGEN.H
³
³       STR.CXX         Chapter  3: String class
³       STR.H
³
³       BOOLEAN.H       Chapter  2: Boolean type
³
³       SWITCH.H        Chapter  2: Switch type
³       
ÃÄÄÄARRAYS
³       ARRAY.CXX       Chapter  5: Array and ArrayPtr classes
³       ARRAY.H
³
³       DARRAY.CXX      Chapter  8: DblArray and DblArrayPtr class
³       DARRAY.H
³
³       DSARRAY.CXX     Chapter  9: DblStatArray class
³       DSARRAY.H
³
³       IARRAY.CXX      Chapter  7: IntArray and IntArrayPtr class
³       IARRAY.H
³
³       INDEX.CXX       Chapter  4: Index class
³       INDEX.H
³
³       RANGE.CXX       Chapter  4: Range class
³       RANGE.H
³
³       SRTARRAY.CXX    Chapter  6: SortableArray class
³       SRTARRAY.H
³       
ÀÄÄÄPERSIST
        BINTREE.CXX     Chapter 13: BinaryTree and TreeNode classes
        BINTREE.H

        BTREE.CXX       Chapter 14: BTree, Page, PageKey, & PageFile classes
        BTREE.H

        DATAFILE.CXX    Chapter 10: DataFileInput, DataFileOutput, & DataFile 
        DATAFILE.H                  classes

        HASH.CXX        Chapter 11: HashEntryBase, HashBucket, HashTableBase,
        HASH.H                      HashEntryStrDB, & HashTableStrDB classes

        HASHFILE.CXX    Chapter 12: HashFileEntry, HashFileBucket, 
        HASHFILE.H                  HashFileTable, and HashFile classes

        PERSIST.CXX     Chapter 10: Persistent, DataBlock, & Signature classes
        PERSIST.H

        
