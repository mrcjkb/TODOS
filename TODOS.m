function TODOS(tag, name, option)
%TODOS: Similar to Matlab's TODO/FIXME report generator. Audits a
%file, folder, folder + subdirectories or the Matlab search path for tags
%created in code by commenting and displays them (as links to the matlab
%files) in the command window.
%
%Syntax:
%
%   TODOS; searches the current directory and its subdirectories for TODO
%          tags.
%
%   TODOS(TAG) searches the current directory and its subdirectories for
%              tags specified by TAG. TAG can be a string or a cell array
%              of strings.
%
%   TODOS(TAG, DIRNAME) scans the specified folder and its subdirectories.
%
%   TODOS(TAG, FILENAME, 'file') scans the matlab file FILENAME.
%
%
%   TODOS(TAG, DIRNAME, OPTION) specifies where to scan:
%           OPTION == 'file'    -> treats DIRNAME as a FILENAME
%           OPTION == 'dir'     -> scans the folder without subdirectories
%           OPTION == 'all'     -> scans the entire Matlab search path
%           OPTION == 'subdirs' -> scans DIRNAME and its subdirectories
%
%
%   See also DOFIXRPT, CHECKCODE
%
%
%Author: Marc Jakobi, 14.10.2016

%% Check inputs
if nargin < 1
    tag = 'TODO';
end
if nargin < 2
    name = cd;
end
if nargin < 3
    option = 'subdirs';
end
if ~iscell(tag) % cast to cell array to avoid indexing problems
    tag = {tag};
end
% check for correct option input
validatestring(option, {'dir', 'file', 'subdirs', 'all'});
if strcmpi(option,'dir')
    if isdir(name)
        dir = name;
        fileList = mfiles(dir);
    else
        error([name, ' is not a directory.']);
    end
elseif strcmpi(option,'file')
    [dir,fname] = fileparts(name);
    if isempty(dir)
        dir = cd;
    end %in case the file is in the current folder
    name = fullfile(dir,[fname '.m']);
    if exist(name,'file') %make sure the file is valid
        fileList = {[fname '.m']};
    else
        error('File not found.')
    end
elseif strcmpi(option,'all') %search entire matlab search path
    dir = '';
    p = path;
    ind = [0, strfind(p,';')];
    P = cell(length(ind),1);
    for i = 2:length(ind)
        P{i-1} = p(ind(i-1)+1:ind(i)-1);
    end
    P{end} = p(ind(i)+1:end);
    fileList = [];
    for i = 1:length(P)
        w = what(P{i});
        for j = 1:length(w)
            fileList = [fileList; fullfile(w.path, w(j).m)];
        end
    end
elseif strcmpi(option,'subdirs') %include all files in subdirectories
    dir = '';
    fileList = subdirfiles(name, '.m');
end

%% Gather all of the data
if isempty(fileList)
    tagData = [];
else
    tagData(length(fileList)).filename = '';
end
try % some files in search path can't be opened
    for n = 1:length(fileList)
        filename = fileList{n};
        file = strsplit(matlab.internal.getCode(fullfile(dir,filename)), {'\r\n','\n', '\r'}, 'CollapseDelimiters', false)';
        tagData(n).filename = filename; %#ok<*AGROW>
        tagData(n).linenumber = [];
        tagData(n).linecode = {};
        tagData(n).tag = {};
        for i = 1:length(tag)
            for m = 1:length(file)
                if ~isempty(file{m}) && ~isempty(regexpi(file{m},['%.*',tag{i}]))
                    ln = file{m};
                    ln = regexprep(ln,'^\s*%\s*','');
                    tagData(n).linenumber(end+1) = m;
                    tagData(n).linecode{end+1} = ln;
                    tagData(n).tag{end+1} = tag{i};
                end
            end
        end
    end
catch
end
%% Display tags in workspace
if ~isempty(tagData)
    % Loop over all the files in the structure
    for n = 1:length(tagData)
        reportComponent = sprintf('%s', tagData(n).filename);
        if ~isempty(tagData(n).linenumber)
            name = fullfile(dir, tagData(n).filename);
            openInEditor = sprintf('edit(''%s'')',name);
            disp(' ')
            [~, fname, ~] = fileparts(reportComponent);
            disp(['<a href="matlab:' openInEditor '">',fname,'</a>']);
            for m = 1:length(tagData(n).linenumber)
                openToLine = sprintf('opentoline(''%s'',%d)',name,tagData(n).linenumber(m));
                lineNumber = sprintf('Line %d', tagData(n).linenumber(m));
                tagIdx = strfind(tagData(n).linecode{m}, tagData(n).tag{m});
                lineTODO = tagData(n).linecode{m}(tagIdx:end);
                disp(['<a href="matlab:' openToLine '">',lineNumber,'</a> ', lineTODO])
            end
        end
    end
end

end %main function

function fileList = subdirfiles(path, filetype)
dirData = dir(path);
dirData = dirData(3:end);
if isempty(dirData)
    fileList = [];
    return;
end
fileList = mfiles(path);
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(path,x), ...
        fileList, 'UniformOutput', false);
end % if empty
tf = cellfun(@(x) x, {dirData.isdir}); % directories = true
dirList = {dirData.name};
dirList = dirList(tf);
for i = 1:length(dirList)
    fileList = [fileList; subdirfiles(fullfile(path, dirList{i}), filetype)];
end
end %subdirfiles

function fileList = mfiles(dir)
fileList = [];
if isdir(dir)
    dirFileList = what(dir);
    fileList = [dirFileList.m];
    if (isfield(dirFileList, 'mlx'))
        fileList = [fileList; dirFileList.mlx];
    end
else
    return
end
end %mfiles