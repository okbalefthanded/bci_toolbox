/*
 * SharedMemory.hpp
 *
 * This Matlab Mex program allows you to matlab variable between different
 * Matlab processes under Windows (e.g. for the parrellel toolbox).  It has four functions:
 *
 * 1) clone:
 *    Recursively place the contents of a matlab array into shared memory.  
 *    This is a "full" copy, so at this point there is a copy of the data in Matlab's memory and shared memory
 * 2) attach:
 *    "Reconstitute" the shared data into the appropriate Matlab object using
 *    shallow copying.  The process that attaches to the shared memory will make the memory 
 *    persistent until it is free'd by the attaching process or the attaching process ends.
 * 3) detach:
 *    Remove the shallow references and detach the shared memory from the
 *    Matlab data space.  Ensure this is done before the variable is cleared
 *    or else Matlab WILL crash.
 * 4) free:
 *    Mark the shared memory for destruction.  The shared memory will only be destroyed when all processes attached to it have called free.
 *
 *	  Notes:
 *    1) This is reliant on the BOOST interprocess library to compile
 *    2) Do not use pack after a variable is attached or Matlab WILL crash
 *    3) Do not call "clear mex" while there is data in the shared memory.  The handle to the shared 
 *       memory will be lost and the only way to free it will be to restart the system.
 *
 *
 * This code can be compiled from within Matlab or command-line, assuming the
 * system is appropriately setup.  To compile, invoke:
 *
 * For 32-bit machines:
 *     mex -O -v -I<BoostDir> SharedMemory.cpp
 * For 64-bit machines:
 *     mex -largeArrayDims -O -v -I<BoostDir> SharedMemory.cpp
 *
 * where <BoostDir> is the Boost directory, e.g. C:\Program Files\Boost\boost_1_45_0
 * The Boost library (or at least the InterProcess library) must be present for this to compile
 *
 *  Example usage:
 *
 * Create a crazy matlab array
 Cell = {eye(3), struct('a', 1, 'b', sparse(eye(3))), 'dummy'};										   %different data types
 X = struct('cat', [], 'happy', 'I am', 'guff', randn(2,3,4,5), 'mayhem', sparse(randn(3,2 > .5)));    %different data types
 X.cat = Cell;  %to check recursion
 
 % copy the contents of x into shared memory (x retains its copy)	 
 SharedMemory('clone','x_shared',X);

 % make a copy variable Y from the shared memory.  Y's data exists in the shared memory
 Y = SharedMemory('attach','x_shared');	       

 % detach Y making it safe to destroy (Y will retain its cell/structure structure however all numeric matrices will be empty)
 % this must be done before Y is cleared or Matlab will crash 
 SharedMemory('detach', 'x_shared', Y);	   

 %Free the shared memory.  It will no longer be possible to attach a variable to 'x_shared'
 SharedMemory('free','x_shared')            
 *
 */


/* ------------------------------------------------------------------------- */
/* --- SHAREDMEMORY.H ------------------------------------------------------ */
/* ------------------------------------------------------------------------- */

#ifndef shared_memory__hpp
#define shared_memory__hpp

/* Define this to test */
/* #define SAFEMODE    */			  /* This copies memory across, defeating the purpose of this function but useful for testing */ 
/* #define DEBUG					  /* Verbose outputs */


/* Possibily useful undocumented functions (see links at end for details): */
/* extern mxArray *mxCreateSharedDataCopy(const mxArray *pr);			   */
/* extern bool mxUnshareArray(const mxArray *pr, const bool noDeepCopy);   */
/* extern mxArray *mxUnreference(const mxArray *pr);					   */



#ifndef SAFEMODE
#define ARRAY_ACCESS_INLINING
typedef struct mxArray_tag Internal_mxArray;					/* mxArray_tag defined in "mex.h" */
#endif

/* standard mex include; */
#include "matrix.h"
#include "mex.h"

//added line
#define BOOST_DATE_TIME_NO_LIB 
/* inbuilt libs */
#include "SharedMemStack.hpp"


#include <boost/interprocess/shared_memory_object.hpp>			   /* Prefer this but get permission errors sadly */
#include <boost/interprocess/windows_shared_memory.hpp>			   /* Have to ensure one windows_shared_memory object is attached to the memory, or else the memory is free'd */
#include <boost/interprocess/mapped_region.hpp>
//
#include <string.h>
#include <windows.h> 
#include <memory.h> 


/* max length of directive string */
#define MAXDIRECTIVELEN 256

/* these are used for recording structure field names */
const char term_char = ';';		/*use this character to terminate a string containing the list of fields.  Do this because it can't be in a valid field name*/
const size_t  align_size = 8;   /*the pointer alignment size, so if pdata is a valid pointer then &pdata[i*align_size] will also be.  Ensure this is >= 4*/


/* 
 * The header_t object will be copied to shared memory in its entirety.
 *
 * Immediately after each copied header_t will be the matrix data values
 * [size array, field_names, pr, pi, ir, jc]
  *
 * The data_t objects will never be copied to shared memory and serve only 
 * to abstract away mex calls and simplify the deep traversals in matlab. 
 *
 */

typedef struct data data_t;
typedef struct header header_t;



/* structure used to record all of the data addresses */
struct data {
	mwSize    *pSize;			/* pointer to the size array */   
	void*      pr;				/* real data portion */
	union {
		void*      pi;			/* imaginary data portion */
		char*      field_str;   /* list of a structures fields, each field name will be seperated by a null character and terminated with a ";" */
	};
	mwIndex   *ir;				/* row indexes, for sparse */
	mwIndex   *jc;				/* cumulative column counts, for sparse */
	data_t    *child_dat;		/* array of children data structures, for cell */
	header_t  *child_hdr;		/* array of corresponding children header structures, for cell */
	
};

// added struct
struct mxArray_tag {
	void    *reserved;
	int      reserved1[2];
	void    *reserved2;
	size_t  number_of_dims;
	unsigned int reserved3;
	struct {
		unsigned int    flag0 : 1;
		unsigned int    flag1 : 1;
		unsigned int    flag2 : 1;
		unsigned int    flag3 : 1;
		unsigned int    flag4 : 1;
		unsigned int    flag5 : 1;
		unsigned int    flag6 : 1;
		unsigned int    flag7 : 1;
		unsigned int    flag7a: 1;
		unsigned int    flag8 : 1;
		unsigned int    flag9 : 1;
		unsigned int    flag10 : 1;
		unsigned int    flag11 : 4;
		unsigned int    flag12 : 8;
		unsigned int    flag13 : 8;
	}   flags;
	size_t reserved4[2];
	union {
		struct {
			void  *pdata;
			void  *pimag_data;
			void  *reserved5;
			size_t reserved6[3];			
		}   number_array;
	}   data;
};
//


/* captures fundamentals of the mxArray */
/* In the shared memory the storage order is [header, size array, field_names, real dat, image data, sparse index r, sparse index c]  */
struct header {
	bool       isCell;
	bool       isSparse;
	bool       isComplex;
	bool       isStruct;	  
	mxClassID  classid;       /* matlab class id */
	size_t     nDims;         /* dimensionality of the matrix.  The size array immediately follows the header */ 
	size_t     elemsiz;       /* size of each element in pr and pi */
	size_t     nzmax;         /* length of pr,pi */
	size_t     nFields;       /* the number of fields.  The field string immediately follows the size array */
	int 	   par_hdr_off;   /* offset to the parent's header, add this to help backwards searches (double linked... sort of)*/
	size_t     shmsiz;		  /* size of serialized object (header + size array + field names string) */
};

/* Remove shared memory references to input matrix (in-situ), recursively    */
/* if needed.                                                                */
void  deepdetach     (mxArray *mxInput);

/* Shallow copy matrix from shared memory into Matlab form.                  */
size_t shallowrestore (char *shm, mxArray** p_mxInput);

/* Recursively descend through Matlab matrix to assess how much space its    */
/* serialization will require.                                               */
size_t deepscan       (header_t *hdr, data_t *dat, const mxArray* mxInput, 
					   header_t*  par_hdr);

/* Descend through header and data structure and copy relevent data to       */
/* shared memory.                                                            */
void   deepcopy       (header_t *hdr, data_t *dat, char *shared_mem, 
					   header_t*  par_hdr);

/* Descend through header and data structure and free the memory.            */
void   deepfree       (data_t *dat);

/* Pads the size to something that guarantees pointer alignment.			*/
__inline size_t pad_to_align(size_t size)
{if (size % align_size){size += align_size - (size % align_size);} return size;}


/*Function to find the number of bytes required to store all of the			 */
/*field names of a structure */
int FieldNamesSize(const mxArray * mxStruct);

/*Function to copy all of the field names to a character array				*/
/*Use FieldNamesSize() to allocate the required size of the array			*/
/*returns the number of bytes used in pList									*/
int CopyFieldNames(const mxArray * mxStruct, char* pList);

/*This function finds the number of fields contained within in a string      */
/*the string is terminated by term_char, a character that can't be in a      */
/*field name.  pBytes is always an aligned number																 */
int NumFieldsFromString(const char* pString, size_t *pfields, size_t* pBytes);

/*Function to take point a each element of the char** array at a list of names contained in string */
/*ppCharArray must be allocated to length num_names							 */
/*names are seperated by null termination characters					     */
/*each name must start on an aligned address (see CopyFieldNames())			 */
/*e.g. pCharArray[0] = name_1, pCharArray[1] = name_2 ...					 */
/*returns 0 if successful													 */
int PointCharArrayAtString(char ** pCharArray, char* pString, int nFields);

/* Function to find the bytes in the string starting from the end of the string */
/* returns < 0 on error */
int BytesFromStringEnd(const char* pString, size_t* pBytes);

#ifdef SAFEMODE
/* A convenient function for safe assignment of memory to an mxArray */
void* safeCopy(void* pBuffer, mwSize Bytes)
{
	void* pSafeBuffer;
	
	/* ensure Matlab knows it */
	pSafeBuffer = mxMalloc(Bytes);
	if (pSafeBuffer != NULL)
		memcpy(pSafeBuffer, pBuffer, Bytes); /* and copy the data */

	return pSafeBuffer;
}
#endif

#endif
