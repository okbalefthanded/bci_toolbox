function SharedMemory_install
% function SharedMemory_install
% Installation by building the C-mex files for SharedMemory_install package
%
% Copied of Bruno Luong InplaceArray FEX submission
% update: 28-Jun-2009 built inplace functions
% Last update: 22-Jul-2018 added BOOST_LIB (Okba BEKHELIFI)

arch=computer('arch');
if(~exist('mexbin','dir'))
    mkdir('mexbin');
end
outdir = sprintf('%s', pwd, '\mexbin');
mexopts = sprintf('mex -outdir ''%s'' ', outdir);
mexopts = sprintf('%s -v -O -%s', mexopts, arch);
% 64-bit platform
if ~isempty(strfind(computer(),'64'))
    mexopts = sprintf('%s -largeArrayDims ', mexopts);
end

%include boost
if ~isempty(strfind(computer(),'WIN'))                 
    BOOST_dir = 'C:\Program Files\boost_1_67_0';    
    BOOST_LIB_DIR = [BOOST_dir,'\lib64-msvc-12.0'];    
else
    % on Ubuntu: sudo aptitude install libboost-all-dev libboost-doc
    BOOST_dir = '/usr/include/';
end

if ~exist(fullfile(BOOST_dir,'boost','interprocess','windows_shared_memory.hpp'), 'file')
    error('%s\n%s\n', ...
        'Could not find the BOOST library. Please edit this file to include the BOOST location', ...
        '<BOOST_dir>\boost\interprocess\windows_shared_memory.hpp must exist');
end

mexopts = sprintf('%s -I''%s'' ', mexopts, BOOST_dir);
mexopts = sprintf('%s -L''%s'' ', mexopts, BOOST_LIB_DIR);

eval([mexopts, 'SharedMemory.cpp']);

