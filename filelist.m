function list = filelist(file, basedir, ext)
% get list from the file and add the basedir befor each items
    switch nargin
      case 1
        basedir = '';
        ext = '';
      case 2
        ext = '';        
    end    
    list = {};
    fid = fopen(file);
    if (fid == -1)
        disp(fprintf('[Error] [Read FileList] %s', file));
        return;
    end
    items = textscan(fid, '%s', 'delimiter', '\n');
    subitems = items{1};

    for idx = 1:length(subitems)
        item = subitems{idx};
        if (~isempty(ext))
            item = strcat(item,'.',ext);
        end
        list{idx}.fullpath = strcat(basedir, '/', item);
        list{idx}.part = item;
        list{idx}.base = subitems{idx};
    end
    fclose(fid);
end
