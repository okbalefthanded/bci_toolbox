// CStrCatStr.c
// Join strings and cell strings [Mex]
// Fast concatenation of 2 or 3 strings and cell strings.
//
// R = CStrCatStr(A, B, C)
// INPUT:
//   A, B, C: Strings or cell strings. At least one input must be a cell string
//      of any size. C is optional. The number of elements of cell strings must
//      be equal, if more than one input is a cell.
// OUTPUT:
//   R: Cell string with the same size as the input cell. If more than 1 input is
//      a cell, the size of the first cell is used. If any input is an empty
//      cell, the empty cell is replied. R contains the concatenated strings.
//
// NOTES:
// - CStrCatStr accepts 2 or 3 inputs only and at least one must be a cell
//   string, but Matlab's STRCAT can process arbitrary inputs.
// - CStrCatStr conserves marginal spaces, STRCAT removes them for strings.
// - STRCAT('A', {}) replies: {'A'}.
//   CStrCatStr('A', {}) replies: {}, because the cell string rules.
// - The compiled MEX version is about 90% faster than STRCAT!
// - In the MEX verion, CHAR arrays are treated as string with linear index:
//   ['ac'; 'bd'] is processed as 'abcd'.
// - There is no need to accept 3 strings! CAT is faster in this case.
//
// EXAMPLES:
//   CStrCatStr('a', {'a', 'b', 'c'})       % ==>  {'aa', 'ab', 'ac'}
//   CStrCatStr({'a'; 'b'; 'c'}, '-')       % ==>  {'a-'; 'b-'; 'c-'}
//   CStrCatStr({' ', ''}, 'a', {' ', ''})  % ==>  {' a ', 'a'}
//   CStrCatStr('ba', {'di', 'du'}, 'm')    % ==>  {'badim', 'badum'}
//   CStrCatStr('a', 'b', 'c', 'd')         % ==>  error, just 3 inputs
//   CStrCatStr({'a', 'b'}, {'c'})          % ==>  error, cells need same size
//
//   Get file names with absolute path:
//     FileDir      = dir(PathName);
//     AbsoluteName = CStrCatStr(PathName, filesep, {FileDir.name});
//
// NOTE: STRCAT({'asd'}, {'bsd'}) is faster than STRCAT('asd', {'bsd'}).
//
// Compile with:
//   mex -O CStrCatStr.c
// On Linux the C99 comments must be considered (thanks Sebastiaan Breedveld):
//   mex -O CFLAGS="\$CFLAGS -std=C99" CalcMD5.c
// Pre-compiled MEX files: http:\\www.n-simon.de\mex
//
// Tested: Matlab 6.5, 7.7, 7.8, BCC5.5, LCC2.4/3.8, WinXP
// Author: Jan Simon, Heidelberg, (C) 2009-2010 matlab.THISYEAR(a)nMINUSsimon.de

/*
% $JRev: R0z V:035 Sum:5xHUleBhp3Y/ Date:11-Feb-2010 01:28:40 $
% $License: BSD (see Docs\BSD_License.txt) $
% $File: Published\CStrCatStr\CStrCatStr.c $
% History:
% 030: 12-Sep-2009 15:41, Crashed for not initialized cell elements in Matlab 6.
% 035: 11-Feb-2010 01:02, Work with 32 and 64 bit systems.
*/

#include "mex.h"
#include <string.h>

// Assume 32 bit array dimensions for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

enum STATUS {OK = 0, BAD_TYPE_INPUT, BAD_SIZE_INPUT};

// Prototypes: =================================================================
void TwoStrings(mxArray *plhs[], const mxArray *prhs[]);
void Str_Cell(mxChar *A, mwSize nA, const mxArray *B, mwSize nR, mxArray *R);
void Cell_Str(const mxArray *C, mxChar *B, mwSize nB, mwSize nR, mxArray *R);
void Cell_Cell(const mxArray *A, const mxArray *B, mwSize nR, mxArray *R);

void ThreeStrings(mxArray *plhs[], const mxArray *prhs[]);
void Cell_Cell_Cell(const mxArray *A, const mxArray *B, const mxArray *C,
                    mwSize nR, mxArray *R);
void Cell_Cell_Str(const mxArray *A, const mxArray *B, mxChar *C, mwSize nC,
                   mwSize nR, mxArray *R);
void Cell_Str_Cell(const mxArray *A, mxChar *B, mwSize nB, const mxArray *C,
                   mwSize nR, mxArray *R);
void Str_Cell_Cell(mxChar *A, mwSize nA, const mxArray *B, const mxArray *C,
                   mwSize nR, mxArray *R);
void Cell_Str_Str(const mxArray *A, mxChar *B, mwSize nB, mxChar *C, mwSize nC,
                  mwSize nR, mxArray *R);
void Str_Cell_Str(mxChar *A, mwSize nA, const mxArray *B, mxChar *C, mwSize nC,
                  mwSize nR, mxArray *R);
void Str_Str_Cell(mxChar *A, mwSize nA, mxChar *B, mwSize nB, const mxArray *C,
                  mwSize nR, mxArray *R);
void CopyCell(const mxArray *A, mwSize nR, mxArray *R);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // Check for proper number of arguments:
  if (nlhs > 1) {
    mexErrMsgIdAndTxt("JSim:CStrCatStr:BadNArgout", "1 output allowed.");
  }
  
  if (nrhs == 2) {
    TwoStrings(plhs, prhs);
  } else if (nrhs == 3) {
    ThreeStrings(plhs, prhs);
  } else {
    mexErrMsgIdAndTxt("JSim:CStrCatStr:BadNArgin", "2 or 3 inputs required.");
  }
  
  return;
}

// =============================================================================
void TwoStrings(mxArray *plhs[], const mxArray *prhs[])
{
  // Process 2 inputs:
  const mxArray *A, *B;
  mwSize        nA, nB;
  
  // Create a pointer to the input arrays:
  A = prhs[0];
  B = prhs[1];

  // Get number of dimensions of the input cells:
  nA = mxGetNumberOfElements(A);
  nB = mxGetNumberOfElements(B);
  
  // Call different subroutines for the type of inputs:
  if (mxIsCell(A)) {
    if (mxIsChar(B)) {                      // Cell + String
      plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                  mxGetDimensions(A));
      Cell_Str(A, (mxChar *)mxGetData(B), nB, nA, plhs[0]);
    
    } else if (mxIsCell(B)) {               // Cell + Cell:
      if (nA == nB) {
        plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                    mxGetDimensions(A));
        Cell_Cell(A, B, nA, plhs[0]);
      } else if (nA == 0 || nB == 0) {      // Any input is an empty cell
        plhs[0] = mxCreateCellMatrix(0, 0);
      } else {
        mexErrMsgIdAndTxt("JSim:CStrCatStr:BadInput",
                          "Inputs must be cells of same size.");
      }
    } else {
        mexErrMsgIdAndTxt("JSim:CStrCatStr:BadInput",
                          "Inputs must be strings or cell strings.");
    }

  } else if (mxIsChar(A) && mxIsCell(B)) {  // String + Cell
    plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(B), mxGetDimensions(B));
    Str_Cell((mxChar *)mxGetData(A), nA, B, nB, plhs[0]);
  
  } else {
    mexErrMsgIdAndTxt("JSim:CStrCatStr:BadInput",
                      "Inputs must be strings and cell strings.");
  }
  
  return;
}

// =============================================================================
void Str_Cell(mxChar *A, mwSize nA, const mxArray *B, mwSize nR, mxArray *R)
{
  // Add string in front of elements of cell string:
  mwSize  nB, dim[2] = {1, 0}, *dim2, nA2;
  mwIndex iR;
  mxArray *aB, *aR;
  mxChar  *aRp;
  
  dim2  = dim + 1;
  nA2   = nA * sizeof(mxChar);
  
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aB = mxGetCell(B, iR)) == NULL) {  // Get current cell
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element is not a string.");
    }
    if (mxIsChar(aB)) {                     // Accept only strings
      nB   = mxGetNumberOfElements(aB);
      *dim = (*dim2 = nA + nB) ? 1 : 0;     // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);     // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp, A, nA2);                  // Copy string, then cell element:
      memcpy(aRp + nA, mxGetData(aB), nB * sizeof(mxChar));
      mxSetCell(R, iR, aR);                 // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element is not a string.");
    }
  }
    
  return;
}

// =============================================================================
void Cell_Str(const mxArray *A, mxChar *B, mwSize nB, mwSize nR, mxArray *R)
{
  // Append string behind of elements of cell string:
  mwSize  nA, dim[2] = {1, 0}, *dim2, nB2;
  mwIndex iR;
  mxArray *aA, *aR;
  mxChar  *aRp;
  
  dim2 = dim + 1;
  nB2  = nB * sizeof(mxChar);
  
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aA = mxGetCell(A, iR)) == NULL) {  // Get current cell
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element is not a string.");
    }
    if (mxIsChar(aA)) {                     // Accept only strings
      nA   = mxGetNumberOfElements(aA);
      *dim = (*dim2 = nA + nB) ? 1 : 0;     // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);     // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp, mxGetData(aA), nA * sizeof(mxChar)); // Copy input cell
      memcpy(aRp + nA, B, nB2);             // Copy string
      mxSetCell(R, iR, aR);                 // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element is not a string.");
    }
  }
  
  return;
}

// =============================================================================
void Cell_Cell(const mxArray *A, const mxArray *B, mwSize nR, mxArray *R)
{
  // Join cell strings.
  mwSize  na, nb, dim[2] = {1, 0}, *dim2;
  mwIndex iR;
  mxArray *a, *b, *r;
  mxChar  *rp;
  
  dim2 = dim + 1;
  
  for (iR = 0; iR < nR; iR++) {            // Loop over cell string
    if ((a = mxGetCell(A, iR)) == NULL) {  // Get element of A
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element of A is not a string.");
    }
    if ((b = mxGetCell(B, iR)) == NULL) {  // Get element of B
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element of B is not a string.");
    }
    if (mxIsChar(a) && mxIsChar(b)) {      // Accept only strings
      na   = mxGetNumberOfElements(a);
      nb   = mxGetNumberOfElements(b);
      *dim = (*dim2 = na + nb) ? 1 : 0;    // No [1 x 0] chars
      r    = mxCreateCharArray(2, dim);    // Create output string
      rp   = (mxChar *)mxGetData(r);
      memcpy(rp,      mxGetData(a), na * sizeof(mxChar));  // Copy string from A
      memcpy(rp + na, mxGetData(b), nb * sizeof(mxChar));  // Copy string from B
      mxSetCell(R, iR, r);                                 // New string to output
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cell element is not a string.");
    }
  }
  
  return;
}

// =============================================================================
void ThreeStrings(mxArray *plhs[], const mxArray *prhs[])
{
  const mxArray *A, *B, *C;
  mwSize        nA, nB, nC;
  enum STATUS Status = OK;
  
  // Create a pointer to the input arrays:
  A = prhs[0];
  B = prhs[1];
  C = prhs[2];

  // Get number of dimensions of the input cells:
  nA = mxGetNumberOfElements(A);
  nB = mxGetNumberOfElements(B);
  nC = mxGetNumberOfElements(C);
  
  // Check input arguments are cells:
  if (mxIsCell(A)) {
    if (mxIsChar(B)) {
      if (mxIsCell(C)) {
        if (nA == nC) {           // A: cell, B: string, C: cell
          plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                      mxGetDimensions(A));
          Cell_Str_Cell(A, mxGetData(B), nB, C, nA, plhs[0]);
        } else if (nA == 0 || nB == 0) {
          plhs[0] = mxCreateCellMatrix(0, 0);
        } else {
          Status = BAD_SIZE_INPUT;
        }
      } else if (mxIsChar(C)) {   // A: cell, B: string, C: string
        plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                    mxGetDimensions(A));
        Cell_Str_Str(A, (mxChar *)mxGetData(B), nB, (mxChar *)mxGetData(C), nC,
                     nA, plhs[0]);
      } else {
        Status = BAD_TYPE_INPUT;
      }
    
    } else if (mxIsCell(B)) {
      if (nA == 0 || nB == 0) {    // Don't care about C!
        plhs[0] = mxCreateCellMatrix(0, 0);
      } else if (nA == nB) {
        if (mxIsChar(C)) {         // A: cell, B: cell, C: string
          plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                      mxGetDimensions(A));
          Cell_Cell_Str(A, B, (mxChar *)mxGetData(C), nC, nA, plhs[0]);
        } else if (mxIsCell(C)) {  // A: cell, B: cell, C: cell
          if (nB == nC) {
            plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(A),
                                        mxGetDimensions(A));
            Cell_Cell_Cell(A, B, C, nA, plhs[0]);
          } else if (nC == 0) {
            plhs[0] = mxCreateCellMatrix(0, 0);
          }
        } else {
          Status = BAD_TYPE_INPUT;
        }
      } else {
        Status = BAD_SIZE_INPUT;
      }
    } else {
      Status = BAD_TYPE_INPUT;
    }

  } else if (mxIsChar(A)) {
    if (mxIsCell(B)) {
      if (mxIsCell(C)) {         // A: string, B: cell, C: cell
        if (nB == 0 || nC == 0) {
          plhs[0] = mxCreateCellMatrix(0, 0);
        } else if (nB == nC) {
          plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(B),
                                      mxGetDimensions(B));
          Str_Cell_Cell((mxChar *)mxGetData(A), nA, B, C, nB, plhs[0]);
        } else {
          Status = BAD_SIZE_INPUT;
        }
      } else if (mxIsChar(C)) {  // A: string, B: cell, C: string
        if (nB == 0) {
          plhs[0] = mxCreateCellMatrix(0, 0);
        } else {
          plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(B),
                                      mxGetDimensions(B));
          Str_Cell_Str((mxChar *)mxGetData(A), nA, B,
                       (mxChar *)mxGetData(C), nC, nB, plhs[0]);
        }
      }
    } else if (mxIsChar(B)) {
      if (mxIsCell(C)) {         // A: string, B: string, C: cell
        if (nC == 0) {
          plhs[0] = mxCreateCellMatrix(0, 0);
        } else {
          plhs[0] = mxCreateCellArray(mxGetNumberOfDimensions(C),
                                      mxGetDimensions(C));
          Str_Str_Cell((mxChar *)mxGetData(A), nA, (mxChar *)mxGetData(B), nB,
                        C, nC, plhs[0]);
        }
      } else {                   // A: string, B: string, C: string
        Status = BAD_TYPE_INPUT;
      }
    } else {
      Status = BAD_TYPE_INPUT;
    }
  } else {
    Status = BAD_TYPE_INPUT;
  }
  
  // Handle errors:
  if (Status != 0) {
    switch (Status) {
    case BAD_SIZE_INPUT:
      mexErrMsgIdAndTxt("JSim:CStrCatStr:BadInputSize",
                        "Input cells need equal sizes.");
    case BAD_TYPE_INPUT:
      mexErrMsgIdAndTxt("JSim:CStrCatStr:BadInputType",
                        "Inputs must be strings or cell strings.");
    default:
      mexErrMsgIdAndTxt("JSim:CStrCatStr:BadSwitch",
                        "Bad switch expression.");
    }
  }
  
  return;
}

// =============================================================================
void Cell_Cell_Cell(const mxArray *A, const mxArray *B, const mxArray *C,
                    mwSize nR, mxArray *R)
{
  // Join cell strings.
  mwSize  na, nb, nc, dim[2] = {1, 0}, *dim2;
  mwIndex iR;
  mxArray *a, *b, *c, *r;
  mxChar  *rp;
  
  dim2 = dim + 1;   // Pointer to 2nd dimension
  
  for (iR = 0; iR < nR; iR++) {            // Loop over cell string
    if ((a = mxGetCell(A, iR)) == NULL) {  // Get element of A
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of A is not a string.");
    }
    if ((b = mxGetCell(B, iR)) == NULL) {  // Get element of B
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of B is not a string.");
    }
    if ((c = mxGetCell(C, iR)) == NULL) {  // Get element of C
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of C is not a string.");
    }

    if (mxIsChar(a) && mxIsChar(b) && mxIsChar(c)) {  // Only strings
      na   = mxGetNumberOfElements(a);
      nb   = mxGetNumberOfElements(b);
      nc   = mxGetNumberOfElements(c);
      *dim = (*dim2 = na + nb + nc) ? 1 : 0;  // No [1 x 0] chars
      r    = mxCreateCharArray(2, dim);       // Create output string
      rp   = (mxChar *)mxGetData(r);
      memcpy(rp,           mxGetData(a), na * sizeof(mxChar));  // String from A
      memcpy(rp + na,      mxGetData(b), nb * sizeof(mxChar));  // String from B
      memcpy(rp + na + nb, mxGetData(c), nc * sizeof(mxChar));  // String from C
      mxSetCell(R, iR, r);                                      // To output
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
  
  return;
}

// =============================================================================
void Cell_Str_Cell(const mxArray *A, mxChar *B, mwSize nB, const mxArray *C,
                   mwSize nR, mxArray *R)
{
  // Cat: cell string, string, cell string
  mwSize  nA, nC, dim[2] = {1, 0}, *dim2, nB2;
  mwIndex iR;
  mxArray *aA, *aC, *aR;
  mxChar  *aRp;
  
  dim2 = dim + 1;
  nB2  = nB * sizeof(mxChar);
  
  for (iR = 0; iR < nR; iR++) {              // Loop over cell string
    if ((aA = mxGetCell(A, iR)) == NULL)  {  // Get current cell of A
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of A is not a string.");
    }
    if ((aC = mxGetCell(C, iR)) == NULL)  {  // Get current cell of C
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of C is not a string.");
    }

    if (mxIsChar(aA) && mxIsChar(aC)) {      // Accept only strings
      nA   = mxGetNumberOfElements(aA);
      nC   = mxGetNumberOfElements(aC);
      *dim = (*dim2 = nA + nB + nC) ? 1 : 0; // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);      // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp,           mxGetData(aA), nA * sizeof(mxChar));
      memcpy(aRp + nA,      B,             nB2);
      memcpy(aRp + nA + nB, mxGetData(aC), nC * sizeof(mxChar));
      mxSetCell(R, iR, aR);                  // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
    
  return;
}

// =============================================================================
void Cell_Cell_Str(const mxArray *A, const mxArray *B, mxChar *C, mwSize nC,
                   mwSize nR, mxArray *R)
{
  // Cat: cell string, string, cell string
  mwSize  nA, nB, dim[2] = {1, 0}, *dim2, nC2;
  mwIndex iR;
  mxArray *aA, *aB, *aR;
  mxChar  *aRp;
  
  dim2 = dim + 1;
  nC2  = nC * sizeof(mxChar);
  
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aA = mxGetCell(A, iR)) == NULL) {  // Get current cell of A
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of A is not a string.");
    }
    if ((aB = mxGetCell(B, iR)) == NULL) {  // Get current cell of B
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of B is not a string.");
    }

    if (mxIsChar(aA) && mxIsChar(aB)) {     // Accept only strings
      nA   = mxGetNumberOfElements(aA);
      nB   = mxGetNumberOfElements(aB);
      *dim = (*dim2 = nA + nB + nC) ? 1 : 0;  // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);  // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp,           mxGetData(aA), nA * sizeof(mxChar));
      memcpy(aRp + nA,      mxGetData(aB), nB * sizeof(mxChar));
      memcpy(aRp + nA + nB, C,             nC2);
      mxSetCell(R, iR, aR);              // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
  
  return;
}

// =============================================================================
void Str_Cell_Cell(mxChar *A, mwSize nA, const mxArray *B, const mxArray *C,
                   mwSize nR, mxArray *R)
{
  // Cat: cell string, string, cell string
  mwSize  nB, nC, dim[2] = {1, 0}, *dim2, nA2;
  mwIndex iR;
  mxArray *aB, *aC, *aR;
  mxChar  *aRp;
  
  dim2 = dim + 1;
  nA2  = nA * sizeof(mxChar);
  
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aB = mxGetCell(B, iR)) == NULL) {  // Get current cell of B
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of C is not a string.");
    }
    if ((aC = mxGetCell(C, iR)) == NULL) {  // Get current cell of C
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of C is not a string.");
    }
    
    if (mxIsChar(aB) && mxIsChar(aC)) {     // Accept only strings
      nB   = mxGetNumberOfElements(aB);
      nC   = mxGetNumberOfElements(aC);
      *dim = (*dim2 = nA + nB + nC) ? 1 : 0;  // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);     // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp,           A,             nA2);
      memcpy(aRp + nA,      mxGetData(aB), nB * sizeof(mxChar));
      memcpy(aRp + nA + nB, mxGetData(aC), nC * sizeof(mxChar));
      mxSetCell(R, iR, aR);              // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
    
  return;
}

// =============================================================================
void Cell_Str_Str(const mxArray *A, mxChar *B, mwSize nB, mxChar *C, mwSize nC,
                  mwSize nR, mxArray *R)
{
  mxChar *BC;
  mwSize nBC;
  
  // Concatenate B and C to one string and call the method for Cell+String:
  nBC = nB + nC;
  if (nBC != 0) {
    if ((BC = (mxChar *)mxMalloc(nBC * sizeof(mxChar))) == NULL) {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoMemory",
                        "No memory for CELL+STRING+STRING.");
    }
  
    memcpy(BC,      B, nB * sizeof(mxChar));
    memcpy(BC + nB, C, nC * sizeof(mxChar));
    
    // Call the method for 2 inputs:
    Cell_Str(A, BC, nBC, nR, R);
    
    // Release memory:
    mxFree(BC);
    
  } else {  // Empty strings - avoid problems with malloc and free:
    CopyCell(A, nR, R);
  }
  
  return;
}
                   
// =============================================================================
void Str_Cell_Str(mxChar *A, mwSize nA, const mxArray *B, mxChar *C, mwSize nC,
                  mwSize nR, mxArray *R)
{
  mwSize  nB, dim[2] = {1, 0}, *dim2, nA2, nC2, nAC;
  mwIndex iR;
  mxArray *aB, *aR;
  mxChar  *aRp;
  
  dim2 = dim + 1;
  nA2  = nA * sizeof(mxChar);
  nC2  = nC * sizeof(mxChar);
  nAC  = nA + nC;
  
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aB = mxGetCell(B, iR)) == NULL) {  // Get current cell of B
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of B is not a string.");
    }
    
    if (mxIsChar(aB)) {                     // Accept only strings
      nB   = mxGetNumberOfElements(aB);
      *dim = (*dim2 = nAC + nB) ? 1 : 0;    // No [1 x 0] chars
      aR   = mxCreateCharArray(2, dim);     // Create output string
      aRp  = (mxChar *)mxGetData(aR);
      
      memcpy(aRp,             A,  nA2);
      memcpy(aRp + nA,        mxGetData(aB), nB * sizeof(mxChar));
      memcpy(aRp + (nA + nB), C,  nC2);
      mxSetCell(R, iR, aR);              // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
    
  return;
}


// =============================================================================
void Str_Str_Cell(mxChar *A, mwSize nA, mxChar *B, mwSize nB, const mxArray *C,
                  mwSize nR, mxArray *R)
{
  mxChar *AB;
  mwSize nAB;
  
  // Concatenate A and B to one string and call method for String+Cell:
  nAB = nA + nB;
  if (nAB != 0) {
    if ((AB = (mxChar *)mxMalloc(nAB * sizeof(mxChar))) == NULL) {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoMemory",
                        "No memory for STRING+STRING+Cell.");
    }
    
    memcpy(AB,      A, nA * sizeof(mxChar));
    memcpy(AB + nA, B, nB * sizeof(mxChar));
  
    // Call the method for 2 inputs:
    Str_Cell(AB, nAB, C, nR, R);
  
    // Release memory:
    mxFree(AB);
    
  } else {  // Empty strings - avoid problems with malloc and free:
    CopyCell(C, nR, R);
  }
  
  return;
}

// =============================================================================
void CopyCell(const mxArray *A, mwSize nR, mxArray *R)
{
  // Copy input cell to output cell.
  // This is faster than mxDuplicateArray (to my surprise).
  mwSize  nA, dim[2] = {1, 0}, *dim2;
  mwIndex iR;
  mxArray *aA, *aR;
  
  dim2 = dim + 1;
  for (iR = 0; iR < nR; iR++) {             // Loop over cell string
    if ((aA = mxGetCell(A, iR)) == NULL) {  // Get current cell
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Element of cell is not a string.");
    }
      
    if (mxIsChar(aA)) {                     // Accept only strings
      nA    = mxGetNumberOfElements(aA);
      *dim  = (*dim2 = nA) ? 1 : 0;         // No [1 x 0] chars
      aR    = mxCreateCharArray(2, dim);    // Create output string
      
      memcpy(mxGetData(aR), mxGetData(aA), nA * sizeof(mxChar));
      mxSetCell(R, iR, aR);                 // Store new string in output cell
    } else {
      mexErrMsgIdAndTxt("JSim:CStrCatStr:NoString",
                        "Cells must contain strings.");
    }
  }
  
  return;
}
