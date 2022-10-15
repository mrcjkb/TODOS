> [![Maintenance](https://img.shields.io/badge/Maintained%3F-no-red.svg)](https://bitbucket.org/lbesson/ansi-colors)
>
> __NOTE:__
>
> Since I no longer use Matlab, I cannot actively maintain this model.
> I will gladly accept PRs, as long as I can review them without Matlab.

# TODOS
Matlab: Use tags in code comments to create notes/todos and display links to them in the command window.

TODOS: Similar to Matlab's TODO/FIXME report generator. Audits a
file, folder, folder + subdirectories or the Matlab search path for tags
created in code by commenting and displays them (as links to the matlab
files) in the command window.
Syntax:
   TODOS; searches the current directory and its subdirectories for TODO
          tags.

   TODOS(TAG) searches the current directory and its subdirectories for
              tags specified by TAG. TAG can be a string or a cell array
              of strings.

   TODOS(TAG, DIRNAME) scans the specified folder and its subdirectories.

   TODOS(TAG, FILENAME, 'file') scans the matlab file FILENAME.


   TODOS(TAG, DIRNAME, OPTION) specifies where to scan:
           OPTION == 'file'    -> treats DIRNAME as a FILENAME
           OPTION == 'dir'     -> scans the folder without subdirectories
           OPTION == 'all'     -> scans the entire Matlab search path
           OPTION == 'subdirs' -> scans DIRNAME and its subdirectories


   See also DOFIXRPT, CHECKCODE


Author: Marc Jakobi, 14.10.2016
