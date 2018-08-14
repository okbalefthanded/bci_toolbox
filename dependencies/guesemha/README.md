# guesemha
A multiprocess MATLAB toolbox for parallel hyperparamater tuning for Machine Learning applications

## Installation

### Requirements
* [SharedMatrix](https://www.mathworks.com/matlabcentral/fileexchange/28572-sharedmatrix) Allows any Matlab object to be shared between Matlab sessions (w/o using file I/O). Used to share data accross Matlab workers.
* Instrument Control Toolbox, used for IPC.

A compiled 64-bit mex function of SharedMatrix is shipped with the toolbox.

```
-Download or clone the toolbox
-cd to guesemha folder
-in the MATLAB command window run:
>> setup
```

## Usage
see demo scripts in examples folder.

## Support
test on Windows 7 64bit on MATLAB releases:
- R2014a
- R2015a

for support, open an issue detailing the problem you encountered with the toolbox.

## Limitations
Works only on multicore systems with local memory

## Contributing 
Pull requests are welcome, open an issue first to discuss proposed changes.


## Licence
[MIT](https://choosealicense.com/licenses/mit/)

## Acknowledgement
I would like to thank the SharedMatrix developer Joshua Dillon and Andrew Smith for the windows version.
