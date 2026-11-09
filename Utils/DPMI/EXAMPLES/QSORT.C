/* ----------------------------------------------------------------
 *				QSORT.C
 *
 *	QSORT is a demonstration program which reads data
 *	into memory, and sorts it using the Quicksort algorithm.
 *
 *	The data to be sorted is limited only by memory size.
 *
 *	Note: unlike DOS SORT, the QSORT is CASE-SENSITIVE.
 *
 *	QSORT may be built to use either real mode or protected
 *	mode.  The protected mode version uses DPMI to allocate
 *	extended memory from the DPMI host.  Assuming that sufficient
 *	extended memory is present, the protected mode version
 *	can sort much larger data sets than the real mode version,
 *	and even the real mode version outstrips the standard DOS
 *	sort command.
 *
 *	This program is intended to demonstrate how to access large
 *	data sets from within a small model C program.
 *
 * ----------------------------------------------------------------
 *	Program usage
 *	Each line in the input stream is one record to be sorted.
 *	Each line may be up to 254 characters long.
 *
 *	Arguments:
 *
 *		/R		reverse (descending) sort
 *		/+nnn		sort on column nnn
 *		< input 	input is always from standard in
 *		> output	output is always to standard out
 *
 *	Possible errors:	record not found
 *				input file error
 *				output file error
 *				bad argument
 *				input line too long (greater than 254 bytes)
 *
 *
 *
 * ----------------------------------------------------------------
 *	Implementation notes:
 *
 *	o  QSORT can be configured to run in real mode or
 *	   in protected mode, by defining the USEREAL symbol.
 *	   The program was developed and tested in real mode
 *	   in order to make debugging easy.
 *
 *	o  QSORT has been tested with Borland C version 2.0 and 3.0
 *	   and with Microsoft C version 6.0 and 7.0.
 *
 * ----------------------------------------------------------------
 *
 *	QSORT internals, data structures, theory of operation
 *
 *	The Quicksort algorithm is described by Donald Knuth in
 *	"The Art of Computer Programming Vol 3: Searching and Sorting"
 *
 *	o  Memory Management
 *
 *
 * Input record storage:
 *	Input records are stored in what we call "raw arrays" which
 *	are dynamically allocated 64K blocks.  No record crosses
 *	a 64K boundary.  The input records are stored as counted
 *	strings, which are also null terminated to make the sort
 *	comparisons more efficient.
 *
 * Pointer storage:
 *	We store and sort pointers to the input records.
 *	The pointers are also stored in dynamically allocated
 *	64K blocks.  Each pointer is 4 bytes, thus each 64K block
 *	holds 16K pointers.  Unlike the "huge" memory model, we
 *	do not assume that the blocks are referenced by contiguous
 *	selectors.  Instead, we maintain a master table (the Array
 *	of Arrays, or AA[n]) which is used to locate a pointer.
 *
 * Indices:
 *	An INDEX is essentially a pointer to a pointer.  The INDEX
 *	selects a memory block and a pointer within the block.
 *
 * Graphically, with 32K pointers (requiring 128K to hold pointers)
 *

 AA
  [0] ----------> PointerBlock0 		RawBlock0
  [1] ------+			[0] --------------->	DataString[0]
	    |			[1] ---------+
	    |			[2] ...      |
	    |			 .	     +----->	DataString[1]
	    |			 .
	    |			 .
	    |
	    +---> PointerBlock1
				[0] ----+
				[1] -+	|
				 .   |	|	   RawBlockN
				 .   |	+--------->	DataString[16K]
				 .   |
				     +------------>	DataString[16K+1]
 *
 *
 *   So, to get a data pointer from an index, e.g. Index[anum=1, aidx=0]
 *
 *	char **PointerToPointer = AA[anum]
 *	char  *PointerToData = PointerToPointer[aidx]
 *
 *
 */

/*
 * If USEREAL is defined, QSORT does not enter protected mode,
 * and uses real mode memory allocation for dynamic storage
 */

// #define USEREAL 1

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include "dpmi.h"

#ifdef USEREAL
#include <alloc.h>
#endif

#define FARNULL ((void *) 0L)


/* ----------------------------------------------------------------
 *		Define Data Structures
 * ----------------------------------------------------------------
 */

/*	A record is a string of 1-254 bytes
 *	   byte 0	= len
 *	   byte 1-255	= null-terminated data
 *
 *	An Index refers to a string stored in far memory
 *	   anum 	= array number (lookup address in AddrPtrArrays)
 *	   aidx 	= index within array
 *
 *	We maintain aidx as an offset into array,
 *		i.e. aidx = 0, 4, 8, 12, ...
 *
 *	The real advantage is that therefore the index wraps automatically
 *	into the array number when it overflows, and we needn't check for
 *	overflow.  Remember that we are dereferencing the array each time
 *	we need to get a pointer from an index.
 *
 */

union Index_t
{
	unsigned long L;		// Use as long
	struct stag {			// so aidx overflows into anum.
		unsigned int aidx;	//
		unsigned int anum;	// Use as words for direct access.
	} W;
};

typedef union Index_t Index;		// Index  = long or two words
typedef char far *CFPTR;		// CFPTR  = far pointer to char
typedef CFPTR far *CFPTRP;		// CFPTRP = pointer to CFPTR

/* ----------------------------------------------------------------
 *		Global Data
 * ----------------------------------------------------------------
 */

//	The Raw Arrays hold the raw input data, converted into string records

int	Ascending;			// sort order
int	SortColumn;			// input column for sort key
Index	NumRecs;			// number of records read into database ( * 4)
uLong	NumComps = 0;			// Statistics: number of comparisons made
uLong	NumSwaps = 0;			// Statistics: number of swaps made

#define NumRawArrays 512		// 512 * 64K = 32Meg maximum data
CFPTR	AddrRawArrays[NumRawArrays];	// array of pointers raw data blocks
uShort	FreeRawArrays[NumRawArrays];	// Next free byte in each array
uShort	SizeRawArrays[NumRawArrays];	// Size in bytes of each array
int	CurrentRawArray = 0;		// current array

//	The AA (Address Array) is an array of pointers to 64K blocks.

#define NumAA 256			// maximum number of address arrays
CFPTRP	AA[NumAA];			// pointers to array of pointers
uShort	NextFreePtr = 0;		// next free in current array
uShort	CurrentAA = 0;			// current array being filled


/* ----------------------------------------------------------------
 *		Print usage info and exit
 * ----------------------------------------------------------------
*/
void PrintUsage() {
	fprintf(stderr, "QSORT [/R] [/+nnn] [< INFILE] [> OUTFILE]\n");
	fprintf(stderr, "      /R for reverse (descending) sort\n");
	fprintf(stderr, "      /+nnn to sort on column nnn\n");
	fprintf(stderr, "      < INFILE to specify input file\n");
	fprintf(stderr, "      > OUTFILE to specify output file\n");
	exit(1);
}

/* ----------------------------------------------------------------
 *		Parse Arguments from Command Line
 *  args:
 *	argc	number of args on command line
 *	argv	vector of argument strings
 *  res:
 *	Exit if cannot parse arguments
 *
 *	Load global data and flags
 * ----------------------------------------------------------------
*/
void ParseArgs(int argc, char *argv[])
{
	int i;

// defaults:
	SortColumn = 1;
	Ascending  = TRUE;

// parse command line
	if (argc == 1) return;		// no args, just program name
	if (argc > 3) {
		PrintUsage();
	}
	for (i=1; i<argc; i++) {
		if (stricmp (argv[i], "/R") == 0) {
			Ascending = FALSE;
			continue;
		}
		if ((argv[i][0] == '/') && argv[i][1] == '+') {
			SortColumn = atoi( argv[i] + 2);
			continue;
		}
		PrintUsage();
	}
	if (SortColumn < 1) PrintUsage();

}



/* ----------------------------------------------------------------
 *		AllocateRawArray
 * ----------------------------------------------------------------
 */
void AllocateRawArray(int which)
{
#ifndef USEREAL
	struct DPMImemory_t MemStruc;
#endif

	if (which >= NumRawArrays) {
		fprintf(stderr, "Allocate Raw Array: exceeded internal limit after %lu records, exiting\n", NumRecs.L/4);
		exit(1);
	}

// For now, we always allocate 64K-1 byte arrays

#define RAWSIZE ((uShort) 65535)

#ifdef USEREAL
	if ((AddrRawArrays[which] = farmalloc(RAWSIZE)) == 0) {
#else
	if ((AddrRawArrays[which] = DPMImalloc(RAWSIZE, &MemStruc)) == 0) {
#endif
		fprintf(stderr, "Allocate Raw Array: Out of room after %lu records, exiting\n", NumRecs.L/4);
		exit(1);
	}
	FreeRawArrays[which] = 0;
	SizeRawArrays[which] = RAWSIZE;
}


/* ----------------------------------------------------------------
 *		Initialize Arrays
 * ----------------------------------------------------------------
 */
void InitializeArrays()
{
	int	i;

	NumRecs.L = 0;

	for (i=0; i<NumAA; i++) AA[i] = FARNULL;

	for (i=0; i<NumRawArrays; i++) {
		SizeRawArrays[i] = 0;
		FreeRawArrays[i] = 0;
	}
	AllocateRawArray(0);
}


/* ----------------------------------------------------------------
 *		Store Pointer
 * ----------------------------------------------------------------
 */
void StorePointer(CFPTR ptr)
{
#ifndef USEREAL
	struct DPMImemory_t MemStruc;
#endif
	CFPTRP	PtrArray;

	PtrArray = AA[NumRecs.W.anum];
	if (PtrArray == FARNULL) {
#ifdef USEREAL
		PtrArray = farmalloc(65536);
#else
		PtrArray = DPMImalloc(0, &MemStruc);
#endif
		AA[NumRecs.W.anum] = PtrArray;
		if (PtrArray == FARNULL) {
			fprintf(stderr, "Store Pointer: Out of room after %ld records, exiting\n", NumRecs.L / 4);
			exit(1);
		}
	}

	/* store the pointer at index indicated by NumRecs */

	*((CFPTRP) ( ((CFPTR) AA[NumRecs.W.anum]) + NumRecs.W.aidx)) = ptr;
}


/* ----------------------------------------------------------------
 *		Read Next Record
 * args:
 *	none
 * ret:
 *	FALSE if end of file
 *	otherwise, new record is loaded with input data
 * ----------------------------------------------------------------
 */
int ReadNextRecord()
{
	char	far *ptr;		// pointer to store text
	char	far *lenptr;		// pointer to length field
	int	len = 0;		// accumulated length
	int	c;			// input character

	if (SizeRawArrays[CurrentRawArray] - FreeRawArrays[CurrentRawArray] < 256)
		AllocateRawArray(++CurrentRawArray);
	ptr = AddrRawArrays[CurrentRawArray] + FreeRawArrays[CurrentRawArray];

	lenptr = ptr++; 		// remember string start, and advance

	while (TRUE) {
		c = getchar();
		if (c == EOF) break;
		if (++len > 254) {
			fprintf(stderr, "Input line too long at %lu, exiting\n", NumRecs.L/4);
			exit(1);
		}
		*ptr++ = c;
		if (c == '\n') break;
	}

	*ptr++ = 0;				// terminate with null
	if (len != 0) {
		*ptr = 0;			// mark (len) next string empty
		*lenptr = len;			// record size of this string
		FreeRawArrays[CurrentRawArray] += (len + 3); // record number of bytes consumed
		StorePointer(lenptr);		// store the pointer in the database
		return TRUE;
	}
	else return FALSE;		// no string parsed
}



/* ----------------------------------------------------------------
 *		Read Data
 * ----------------------------------------------------------------
 */
void ReadData()
{
	while (!feof(stdin)) {
		if (ReadNextRecord()) NumRecs.L += 4;
	}
}




/* ----------------------------------------------------------------
 *		Write Data
 * ----------------------------------------------------------------
 */
void WriteData()
{
	Index	Idx;
	CFPTR	Ptr;
	int	len;

	for (Idx.L = 0; Idx.L < NumRecs.L; Idx.L += 4) {

		Ptr = *((CFPTRP) ( ((CFPTR) AA[Idx.W.anum]) + Idx.W.aidx));
		len = *Ptr++;
		while (len-- > 0) putchar(*Ptr++);	// write counted string
	}
	fflush(stdout); 				// because we don't go through cleanup code
}



#ifndef USEREAL
/* ----------------------------------------------------------------
 *		Enter protected mode
 * ----------------------------------------------------------------
 */
void DPMIGoProtectedMode()
{
	uShort	flags;
	uChar	processor;
	uChar	majorVersion;
	uChar	minorVersion;
	uShort	nPrivateDataParas;
	void (far* entryAddress)();

	int	Result;

	Result = DPMIObtainSwitchEntryPoint(&flags, &processor, &majorVersion,
			&minorVersion, &nPrivateDataParas, &entryAddress);
	if (Result != 0) {
		fprintf(stderr, "No DPMI host found, exiting\n");
		exit(Result);
	}

	Result = DPMIEnterProtectedMode(entryAddress, 0,
		nPrivateDataParas , 0 );
	if (Result != 0) {
		fprintf(stderr, "Error attempting to enter protected mode, exiting\n");
		exit(Result);
	}
}
#endif


/* ----------------------------------------------------------------
 *		Compare record referenced by idx1, idx2
 * ret:
 *	=0 if idx1 = idx2
 *	>0 if idx1 > idx2
 *	<0 if idx1 < idx2
 *
 *	Note: this comparison is CASE SENSITIVE!!!
 *
 * ----------------------------------------------------------------
 */
int CMP(Index idx1, Index idx2)
{
	CFPTR	ptr1;
	CFPTR	ptr2;
	int	len;
	int	result;

	NumComps++;
	ptr1 = *((CFPTRP) ( ((CFPTR) AA[idx1.W.anum]) + idx1.W.aidx));
	ptr2 = *((CFPTRP) ( ((CFPTR) AA[idx2.W.anum]) + idx2.W.aidx));

	len = min(*ptr1, *ptr2);
	ptr1 += min(*ptr1, SortColumn);
	ptr2 += min(*ptr2, SortColumn);

/*
 * Code the inner loop of this comparison in assembler for speed.
 * This is not strictly necessary, of course, but the performance
 * improvement is dramatic.
 */
_asm	mov dx, ds
_asm	les di, ptr1
_asm	lds si, ptr2
_asm	mov cx, len
_asm	cld
_asm	repe cmpsb
_asm	mov al, [si-1]
_asm	mov bl, es:[di-1]
_asm	xor ah, ah
_asm	mov bh, ah
_asm	sub ax, bx
_asm	mov ds, dx
_asm	mov result, ax

	return (Ascending ? -result : result);
}

void Swap(Index idx1, Index idx2)
{
	CFPTR	temp;			// temp string pointer
	CFPTRP	p1;			// point to idx1 string pointer
	CFPTRP	p2;			// point to idx2 string pointer

	NumSwaps++;

	p1 = (CFPTRP) (((CFPTR) AA[idx1.W.anum]) + idx1.W.aidx);
	p2 = (CFPTRP) (((CFPTR) AA[idx2.W.anum]) + idx2.W.aidx);

	temp = *p1;
	*p1 = *p2;
	*p2 = temp;
}



/* ----------------------------------------------------------------
 *
 * QuickSort works by picking a "pivot", then dividing the data
 * into records less than the pivot and records greater than the pivot.
 *
 * Then, call Quicksort recursively - once to sort the data below
 * the pivot, and once to sort the data above the pivot.
 *
 * If there are only 2 elements in the range, sort them and return
 * from the recursion.
 *
 * ----------------------------------------------------------------
 */
void Quicksort(Index Low, Index High)
{
    Index Up;		// Up starts at the bottom of the range and walks up
    Index Down; 	// Down starts at the top of the range and walks down
    Index Temp1, Temp2;

    /* called with bad argument? */
    if ( Low.L >= High.L) return;

    /* if only two elements, swap if needed to get them in order */
    if ( (High.L - Low.L) == 4 ) {
	    if ( CMP(Low, High) > 0 )
		    Swap(Low, High );
	    return;
    }

    /* if only three elements, swap as needed */
    if ( (High.L - Low.L) == 8 ) {
	    Temp1.L = Low.L + 4;
	    Temp2.L = Low.L + 8;

	    if ( CMP(Low, Temp1) > 0) Swap(Low, Temp1);
	    if ( CMP(Low, Temp2) > 0) Swap(Low, Temp2);
	    if ( CMP(Temp1, Temp2) > 0) Swap(Temp1, Temp2);
	    return;
    }

    /* if more than three elements, Quicksort them */
    do {
	/* Move in from both sides towards the pivot element */
	Up = Low;
	Down = High;

	while( (Up.L < Down.L) && (CMP(Up, High) <= 0))
			Up.L += 4;
	while( (Down.L > Up.L) && (CMP(Down, High) >= 0))
			Down.L -= 4;

	/* If we haven't reached the pivot, it means that two
	 * elements on either side are out of order, so swap them.
	 */

	if( Up.L < Down.L ) Swap( Up, Down );
     } while ( Up.L < Down.L );

     /* Move pivot element back to its proper place in the array. */
     Swap( Up, High );

     /* call for partitions above and below the pivot */
     /* UNLESS the partition in question contains < 2 elements */

     /* if lower partition contains 0 or 1 elements, just sort upper */
     if (Up.L <= Low.L+4) {
	     Up.L += 4;
	     Quicksort(Up, High);
	     return;
     }

     /* if higher partition contains 0 or 1 elements, just sort lower */
     if (Up.L >= High.L-4) {
	     Up.L -= 4;
	     Quicksort(Low, Up);
	     return;
     }

     /* Sort smaller partition first to conserve recursion stack */

     if( (Up.L - Low.L) < (High.L - Up.L) ) {
	     Up.L -= 4;
	     Quicksort( Low,  Up );
	     Up.L += 8;
	     Quicksort( Up , High );
     }
     else {
	     Up.L += 4;
	     Quicksort( Up, High );
	     Up.L -= 8;
	     Quicksort( Low, Up );
     }
}


/* ----------------------------------------------------------------
 *			Main
 * ----------------------------------------------------------------
 */
void main(int argc, char *argv[])
{
	Index zero;
	uLong secs;		// elapsed time in seconds

#ifndef USEREAL
	DPMIGoProtectedMode();
#endif

#ifdef USEREAL
	fprintf(stderr, "QSORT running in real mode\n");
#else
	fprintf(stderr, "QSORT running in protected mode\n");
#endif

	ParseArgs(argc, argv);
	InitializeArrays();
	ReadData();
  fprintf(stderr, "Sorting %lu records\n", NumRecs.L/4);
	if (NumRecs.L > 1) {
		NumRecs.L -= 4;
		zero.L = 0;
		Quicksort(zero, NumRecs);
		NumRecs.L += 4;
	}
	WriteData();
  fprintf(stderr, "Comps: %lu  Swaps: %lu\n", NumComps, NumSwaps);

}
