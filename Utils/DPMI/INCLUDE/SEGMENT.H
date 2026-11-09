//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// segment.h - header file for AbstractSegment classes
//
//
// The class hierarchy is 
//
//
//	  Block			AbstractSegment
//	    |				|
//	---------    --------------------------------------------
//	|	|    |  	|		|		|
//	|	| Segment   HugeSegment	      DOSMemory	   CommonRealSegment
//	|	|    |		|
//	|	------		|
//	|	   |		|
//	|     MemorySegment	|
//	|			|
//	-------------------------
//		    |
//	      HugeMemorySegment


#include <dos.h>
#include "dpmi.h"

#ifndef __SEGMENT__
#define __SEGMENT__


//
// Segment Properties
//
// The members of the SegmentProperty enumeration correspond to the 
// fields of the machine descriptor.  The enumeration is used to provide
// an abstraction for manipulating descriptor attributes.
//
typedef enum SegmentProperty
{
	present,
	executable,
	readable,
	writable,
	big,
	expandDown
} SegmentProp_t;


//
// Class Block
//
// A Block corresponds to raw memory allocated from DPMI via service
// 0501h.  The class holds the DPMI memory handle, the block base address,
// and its size.  The allowable operations on raw blocks are querying its
// parameters, and resizing.  The destructor releases the block to the
// DPMI host.
//
// A Block may be used directly, but more commonly is used to
// derive a MemorySegment or HugeMemorySegment object (see below).

class Block
{
public:
	Block(uLong size);			// constructor
	~Block(void);				// destructor
	boolean setSize(uLong);			// resize function
	uLong blockHandle(void){return handle;};// query block handle
	uLong blockSize(void){return size;};	// query block size
	uLong blockBase(void){return base;};	// query block base
		
protected:
	uLong handle;
	uLong base;
	uLong size;
};


//
// Class AbstractSegment
//
// An AbstractSegment corresponds to a descriptor. The class is used to
// derive the three types of descriptors available from DPMI: (1) generic
// descriptors, which correspond to class Segment (including specific
// descriptors, (2) Common real descriptors (DPMI function 0002h), which
// correspond to class CommonRealSegment, and (3) DOS memory descriptors,
// which correspond to class DOSMemory.
//
// The only state information maintained in the object is the selector of
// the descriptor.  All methods exchange data with the descriptor itself
// via DPMI services.  
//
// The ptrTo method yields a far pointer that can be used to access 
// the address space mapped by the descriptor.  If for any reason the DPMI
// fails to create the descriptor, ptrTo returns a NULL pointer.
//
class AbstractSegment
{
public:
	virtual	uLong	segmentSize(void);	   // query segment size
	virtual	uLong	segmentBase(void);	   // query segment base
	virtual boolean resize(uShort)=0;	   // resize function
	virtual boolean move(uLong)=0;		   // set segment base
	virtual boolean	operator+(SegmentProp_t)=0;// add a property
	virtual boolean	operator-(SegmentProp_t)=0;// remove a property
	virtual boolean	queryProp(SegmentProp_t);  // query property

	void far *ptrTo(void)			   // return pointer
		{ return MK_FP(selector, 0);};

protected:
	selector_t selector;

};


// Class Segment
//
// A Segment corresponds to a fully modifiable LDT descriptor created by
// either DPMI function 0000h (Allocate Descriptor), DPMI function
// 000Ah (Create Alias Descriptor), or DPMI function 000Dh (Allocate
// Specific Descriptor).  The DPMI service invoked depends on which
// constructor is used.
//
// The default properties are present and writable.  New Segments have
// a base of zero and a size of one.
//
// The argument for the resize method is in bytes, and size==0
// specifies a size of 64 KB.
//
// Specific descriptors must be in the range 04h to 0FFh.
//
class Segment : public AbstractSegment
{
public:
	Segment(void);				// generic descriptor
	Segment(selector_t specific);		// specific descriptor
	Segment(AbstractSegment& segment);	// alias existing descriptor
	~Segment(void);				// release descriptor to DPMI

	virtual boolean operator+(SegmentProp_t);//add property
	virtual boolean operator-(SegmentProp_t);//remove property
	virtual boolean resize(uShort);		 //resize
	virtual boolean move(uLong);		 //set base
};


// Class CommonRealSegment
//
// CommonRealSegments correspond to descriptors created by DPMI function
// 0002h (Segment to Descriptor).  DPMI restricts these segments from
// being modified or deleted. Thus, the move, resize, add and remove 
// property methods are degenerate, and there is no destructor defined 
// to free the descriptor.
//
class CommonRealSegment : public AbstractSegment
{
public:
	CommonRealSegment(uShort paragraph);	 // Create descriptor for para

	virtual boolean operator+(SegmentProp_t) // add property returns FALSE
		{return FALSE;};
	virtual boolean operator-(SegmentProp_t) // rem property returns FALSE
		{return FALSE;};
	virtual boolean resize(uShort) 		 // returns FALSE
		{return FALSE;};
	virtual boolean move(uLong) 		 // returns FALSE
		{return FALSE;};
};

// Class DOSMemory
//
// A DOSMemory object corresponds to segments allocated via DPMI function
// 0100h.  The class requires a special destructor which calls DPMI function
// 0101h.  DPMI restricts DOSMemory descriptors from being modified, so
// the add property, remove property, and move methods are degenerate.  The
// resize method maps to DPMI function 0102h.
//
// Note that the argument to the constructor is the number of paragraphs to
// allocate.  DOSMemory objects are present and writable.
//
class DOSMemory : public AbstractSegment
{
public:
	DOSMemory(uShort nParagraphs);		  // constructor
	~DOSMemory(void);			  // destructor
	virtual boolean resize(uShort);		  // arg is paragraph count
	virtual boolean operator+(SegmentProp_t)  // returns FALSE
		{return FALSE;};
	virtual boolean operator-(SegmentProp_t)  // returns FALSE
		{return FALSE;};
	virtual boolean move(uLong)		  // returns FALSE
		{return FALSE;};

};

// Class HugeSegment
//
// A HugeSegment corresponds to a set of consecutive descriptors, which 
// are set up to span a memory region of arbitrary size.  Operations on
// a HugeSegment, such as add or remove property, affect all of its
// component descriptors.  The difference between the bases of consecutive
// descriptors is 64 KB.  The destructor deletes all component descriptors.
//
class HugeSegment : public AbstractSegment
{
public:
	HugeSegment(uLong size);		  // constructor
	~HugeSegment(void);			  // destructor
	virtual boolean operator+(SegmentProp_t); // add property to all descs
	virtual boolean operator-(SegmentProp_t); // rem property
	virtual boolean resize(uShort);		  // resize
	virtual boolean move(uLong);		  // set base
	virtual	uLong	segmentSize(void)	  // query segment size
		{return abstractSize;};
	virtual boolean	resize(uLong);		  // resize

protected:
	int nDescriptors;
	uLong abstractSize;
};

//
// Class MemorySegment
//
// A MemorySegment is a generic descriptor mapped to a block of
// DPMI memory of size 64 KB or less.  The constructors 
// allow the descriptor to be created by either DPMI function 0000h
// (Allocate Descriptor) or DPMI function 000Dh (Allocate Specific
// Descriptor). The move method is degenerate, as there is no way
// to move a DPMI memory block.  
//
// The size arguments to the constructors are in bytes, and size==0
// specifies a size of 64 KB.
//
class MemorySegment : public Segment, public Block
{
public:
	MemorySegment(uShort size);		// constructor
	MemorySegment(uShort size, selector_t specific);
	virtual boolean resize(uShort);		// resize
	virtual boolean move(uLong)		// returns FALSE
		{return FALSE;};
	virtual uLong segmentSize(void);	// return block size
};

//
// Class HugeMemorySegment
//
// A HugeMemorySegment is a Block whose linear space is mapped by 
// a HugeSegment.  The move method is degenerate.
//
class HugeMemorySegment : public HugeSegment, public Block
{
public:
	HugeMemorySegment(uLong size);		// constructor
	virtual boolean resize(uShort);		// resize
	virtual boolean resize(uLong);		// resize
	virtual boolean move(uLong)		// returns FALSE
		{return FALSE;};
};

#endif
