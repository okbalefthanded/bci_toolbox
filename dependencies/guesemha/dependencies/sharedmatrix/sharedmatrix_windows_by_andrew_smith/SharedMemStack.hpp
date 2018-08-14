/* This header defines a class which acts as a container for windows_shared_memory objects (or rather *'s to them)  */ 


#ifndef SharedMemStack__hpp__
#define SharedMemStack__hpp__


#include "mex.h"
#include <boost/interprocess/mapped_region.hpp>
#include <boost/interprocess/windows_shared_memory.hpp>
#include <string.h>
#include <windows.h> 

using namespace boost::interprocess;

struct mem_segment{
	windows_shared_memory * pSegment;				/* pointer to a windows shared segment  */
	mapped_region * pRegion;						/* pointer to its file mapping */
	size_t refCount;								/* the number of matlab variables attached to the region */
};


/* a class which acts as a container for windows_shared_memory objects (or rather *'s to them)  */
class shared_mem_stack {
	

	/* member vars */
	mem_segment* pMemSegments;							/*  a list of the segments that need to be kept.   */
	int nSegs;											/*  the number that need to live... */
	int allocSegs;										/*  the number allocated */
	

	/* member funs */
	public:
		
		/*  Constructors / Destructors */
		shared_mem_stack(){pMemSegments = NULL; nSegs = 0; allocSegs = 0;} /* default constructor */
		~shared_mem_stack(){deallocBuffer();}							   /* default deconstructor */

		/*  Accessors  */
		windows_shared_memory * getSegmentByName(const char * name);    /* returns a pointer to the memory segment */
		windows_shared_memory * getSegmentByIndex(int index);			/* returns a pointer to the memory segment */
		mapped_region * getRegionByName(const char * name);				/* returns a pointer to the memory mapping */
		mapped_region * getRegionByIndex(int index);					/* returns a pointer to the memory mapping */

		int getRefCountByIndex(int index);								/* returns the number of variables attached to the memory */
		
		/*  Buffer allocation / deallocation */
		void deallocBuffer(void);										/* deallocates the buffer destorying all objects pointed to */
		int reallocBuffer(int size);									/* reallocates the buffer to the desired size (if smaller this will fail) */
		
		/*  Adding / Removing segments (Mutators) */
		int removeSegmentByName(const char * name);						/* removes the segement with the given name.  returns 0 if successful */
		int removeSegmentByIndex(int index);							/* removes the segement with the given index.  returns 0 if successful */
		int addSegmentToBuffer(windows_shared_memory 
			* pNewSegment, mapped_region * pNewRegion);					/* adds the segment (create by pNewSegment= new windows_shared_memory...) to the buffer.  Returns 0 if successful */

		/*  Adding / Removing references to segments */
		int addReferenceByName(const char * name);						/* tell the segement another variable is attached to it */
		int removeReferenceByName(const char * name);					/* tell the segement one less variable is attached to it */
		
		int addReferenceByIndex(int index);								/* tell the segement another variable is attached to it */
		int removeReferenceByIndex(int index);							/* tell the segement one less variable is attached to it */

		/*  Miscellaneous */
		int findSegmentByName(const char * name);						/* return the index of the segment with the given name.  returns -1 is none have the name */


};

/* function to deallocate the buffer */ 
void shared_mem_stack::deallocBuffer(void)
{
	int i;

	/* If its allocated */
	if (pMemSegments != NULL)
	{
		/* go through each segment */
		for (i = 0; i < nSegs; i++)
		{	
			/* remove the object */
			if  (pMemSegments[i].pRegion != NULL)
			{	delete pMemSegments[i].pRegion;		}
			if  (pMemSegments[i].pSegment != NULL)
			{	delete pMemSegments[i].pSegment;	}
			
		} 

		/* and free the memory */
		mxFree(pMemSegments);
	    nSegs = allocSegs = 0; 
		pMemSegments = NULL; 
	} 

}

/* function to reallocate the buffer */
/* returns -1 on failure */
int shared_mem_stack::reallocBuffer(int new_size)
{
	/*  Hold this in case of failure */
	mem_segment* pOldSegment = pMemSegments;

	/*  Don't lose pointers to things that need destroying */
	if (new_size < allocSegs)
	{	return -1;  }

	/*  If its allocated */
	if (pMemSegments != NULL)
	{	pMemSegments = (mem_segment*)mxRealloc(pMemSegments, new_size * sizeof(mem_segment)); }
	else
	{   pMemSegments = (mem_segment*)mxCalloc(new_size, sizeof(mem_segment));		}
	
	/*  Did it work? */
	if (pMemSegments != NULL)
	{	allocSegs = new_size;
		mexMakeMemoryPersistent(pMemSegments);
		return 0;
	}
	else
	{	pMemSegments = pOldSegment;  
		return -1;
	}
}

/*  Function to find is a segment in the buffer has a given name */
/*	Returns the index, or -1 if not found    */
int shared_mem_stack::findSegmentByName(const char * name)
{
	const char* SegName;		/* The name of a segment */
	int index = -1;				/* default that it can't find one */
	int i;						/* counter */

	/* Go through them */
	for (i = 0; i < nSegs; i++)
	{	
		SegName = pMemSegments[i].pSegment->get_name();
		if (!strcmp(SegName, name))
		{	index = i; break; }
	}
	return index;
}

/*  Function to remove a segment from the buffer */
/*	Returns 0 if successful, -1 if the segment is not found, or the number of variables still attached to it        */
int shared_mem_stack::removeSegmentByName(const char * name)
{
	int index;					/* index of the segment */
	int i;						/* counter */

	/*  where is it? */
	index  = findSegmentByName(name);

	/*  was it found? */
	if (index < 0){ return -1; }

	/*  don't destroy the segment if variable are attached */
	if (pMemSegments[index].refCount != 0)      
		return (int)pMemSegments[index].refCount;

	/*  and remove it */
	delete pMemSegments[index].pRegion;      /*  destroy the mapping */
	delete pMemSegments[index].pSegment;     /*  destroy the memory segment */
	
	/*  move the rest forward */
	for (i = index + 1; i < nSegs; i++)
	{	pMemSegments[i-1].pSegment = pMemSegments[i].pSegment;
		pMemSegments[i-1].pRegion = pMemSegments[i].pRegion;
		pMemSegments[i-1].refCount = pMemSegments[i].refCount;
	}    
	nSegs--;

	return 0;
}

/*  Function to remove a segment from the buffer */
/*	Returns 0 if successful, -1 if the segment is not found, or the number of variables still attached to it        */
int shared_mem_stack::removeSegmentByIndex(int index)
{
	int i;						/* counter */

	/* Check validity */
	if ((index < 0) || (index >= nSegs))
	{	return -1;	}

	/*  don't destroy the segment if variable are attached */
	if (pMemSegments[index].refCount != 0)      
		return (int)pMemSegments[index].refCount;

	/*  and remove it */
	delete pMemSegments[index].pRegion;      /*  destroy the mapping */
	delete pMemSegments[index].pSegment;     /*  destroy the memory segment */
	
	/*  move the rest forward */
	for (i = index + 1; i < nSegs; i++)
	{	pMemSegments[i-1].pSegment = pMemSegments[i].pSegment;
		pMemSegments[i-1].pRegion = pMemSegments[i].pRegion;
		pMemSegments[i-1].refCount = pMemSegments[i].refCount;
	}    
	nSegs--;

	return 0;
}

/*  Function to add a segment to the buffer */
/*	Returns the index ( >= 0) if successful, -1 otherwise        */
int shared_mem_stack::addSegmentToBuffer(windows_shared_memory * pNewSegment, mapped_region * pNewRegion)
{
	/* make space */
	if (nSegs >= allocSegs)
	{	if (reallocBuffer(__max(allocSegs,0) + 50))
		{	return -1;		}
	}

	/* add it */
	pMemSegments[nSegs].pSegment = pNewSegment;
	pMemSegments[nSegs].pRegion = pNewRegion;
	pMemSegments[nSegs].refCount = 0;
	nSegs++;

	return nSegs - 1;
}

/*  Function to attach a variable from the segment */
/*	Returns 0 if successful, -1 if the segment wasn't found        */
int shared_mem_stack::addReferenceByName(const char * name)
{
	int index;					/*  index of the segment */
	int ret_val = -1;
	
	/*  where is it? */
	index  = findSegmentByName(name);

	/*  was it found? */
	if (index >= 0)
	{	pMemSegments[index].refCount++; ret_val = 0;}	/*  remove the refence count */

	return ret_val;

}

/*  Function to attach a variable from the segment */
/*	Returns 0 if successful, -1 if it fails        */
int shared_mem_stack::addReferenceByIndex(int index)
{
	int ret_val = -1;
	
	/* Check validity */
	if ((index >= 0) && (index <= nSegs))
	{	pMemSegments[index].refCount++; ret_val = 0;}
	
	return ret_val; 

}

/*  Function to detach a variable from the segment			*/
/*	Returns 0 if successful, -1 if the segment wasn't found */
int shared_mem_stack::removeReferenceByName(const char * name)
{
	int index;					/*  index of the segment */
	int ret_val = -1;
	
	/*  where is it? */
	index  = findSegmentByName(name);

	/*  was it found? */
	if (index >= 0)
	{	pMemSegments[index].refCount--; ret_val = 0; } /*  remove the refence count */

	return ret_val;
	
}

/*  Function to attach a variable from the segment */
/*	Returns 0 if successful, -1 if it fails        */
int shared_mem_stack::removeReferenceByIndex(int index)
{
	int ret_val = -1;

	/* Check validity */
	if ((index >= 0) && (index <= nSegs))
	{	pMemSegments[index].refCount--; ret_val = 0;}
	
	return ret_val; 
}



/* returns a pointer to the memory segment, or NULL if unsuccessful */
windows_shared_memory * shared_mem_stack::getSegmentByName(const char * name)
{
	windows_shared_memory * pSegment = NULL;		/*  Segment pointer to return  */
	int		index;									/*  index of this segment */

	/*  find the segment */
	index  = findSegmentByName(name);

	/*  was it found? */
	if (index >= 0)
	{	pSegment = pMemSegments[index].pSegment; }

	return pSegment;

}

/* returns a pointer to the memory segment, or NULL if unsuccessful */
windows_shared_memory * shared_mem_stack::getSegmentByIndex(int index)
{
	windows_shared_memory * pSegment = NULL;		/*  Segment pointer to return */

	/* Check validity */
	if ((index >= 0) && (index <= nSegs))
	{	pSegment = pMemSegments[index].pSegment; }

	return pSegment;

}

/*  returns a pointer to the memory region, or NULL if unsuccessful */
mapped_region * shared_mem_stack::getRegionByName(const char * name)
{
	mapped_region * pRegion = NULL;			/*  Segment pointer to return  */
	int		index;							/*  index of this segment */

	/*  find the segment */
	index  = findSegmentByName(name);

	/*  was it found? */
	if (index >= 0)
	{	pRegion = pMemSegments[index].pRegion; }

	return pRegion;
}

/* returns a pointer to the memory region, or NULL if unsuccessful */
mapped_region * shared_mem_stack::getRegionByIndex(int index)
{
	mapped_region * pRegion = NULL;			/*  Segment pointer to return  */

	/* Check validity */
	if ((index >= 0) && (index <= nSegs))
	{	pRegion = pMemSegments[index].pRegion; }

	return pRegion;

}

/* returns the number of variabs attached to the segment */
/*  returns -1 if the segment is invalid */
int shared_mem_stack::getRefCountByIndex(int index)
{
	int refCount = -1;

	/* Check validity */
	if ((index >= 0) && (index <= nSegs))
	{	refCount = pMemSegments[index].refCount; }

	return refCount;


}


		

#endif
