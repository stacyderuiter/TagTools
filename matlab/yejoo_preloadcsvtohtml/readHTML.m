function readHTML(masterHTML, csvfilename)


    [id2, fields2] = parseCSV2(csvfilename);
    htmlID = fopen(masterHTML);
    s = textscan(htmlID,'%s','Delimiter','\n');
    s = s{1};
    newS = s;
    fclose(htmlID);
    for p = 1:length(s)
        findstring = strcat("other_field = ");
        array_index = find(contains(s, findstring));
    end
    [field_split, unused] = strsplit(s{array_index}, "[");
    array_string = "";
    for u = 1:length(fields2)
        if u == 1,
            array_string = strcat("[", fields2{u});
        else
            if u ~= length(fields2),
                array_string = strcat(array_string, " ", ",",  fields2{u} );
            else
                 array_string = strcat(array_string, " ", ",", fields2{u}, "]");
            end
        end
    end
    [id,fields] = parseCSV(csvfilename);
    newS{array_index} = strcat(field_split{1}, " ", array_string);
    c = containers.Map;
    indices = [];
    for i = 1:length(id)
        findstring = strcat('id=',id(i));
        index = find(contains(s, findstring));
        if ~isempty(index)
            c(char(id(i))) = index;
            indices = [indices; i];
        end
    end


    for n = 1:length(indices)
        if strcmp(id(indices(n)), '"info.dephist.device.regset"')
            continue;
        end
        if strcmp(id(indices(n)), '"info.udm.export"')
            [C,matches] = strsplit(s{c(char(id(indices(n))))}, '" />');
            tempcell = C{2};
            if fields{indices(n)} == '1'
                C{2} = '" checked />';
            else
                C{2} = '" />';
            end
            C{3} = tempcell;
            newS{c(char(id(indices(n))))} = [C{1} C{2} C{3}];
        end
        if ~strcmp(id(indices(n)), '"info.dephist.device.tzone"') 
            [C,matches] = strsplit( s{c(char(id(indices(n))))},'value = ""');
            if ~isempty(matches)
                tempcell = C{2};
                C{2} = [' value=' fields{indices(n)} ' '];
                C{3} = tempcell;
                newS{c(char(id(indices(n))))} = [C{1} C{2} C{3}];
            end
        end
        if strcmp(id(indices(n)), '"info.dephist.device.tzone"')
            f_str = strcat("value=",'"',fields{indices(n)},'"');
            for m = (c(char(id(indices(n))))+ 1): (c(char(id(indices(n))))+82)
                if ~isempty(strfind(s{m}, f_str))
                     [C,matches] = strsplit( s{m},'>(');
                     tempcell = C{2};
                      C{2} = " selected >(";
                      C{3} = tempcell;
                      newS{m} = strcat(C{1},C{2},C{3});
                    break;
                end
            end
        end
    end
    % Write cell A into txt
    new_html_id = fopen('dynamic_tagmetadata.html', 'w');
    for i = 1:numel(newS)
       fprintf(new_html_id,'%s\n', newS{i});
    end
    fclose(new_html_id);
end



function [id, ret_field] = parseCSV(csvfilename)    
    ret_field = {};
    id = {};
    fid = fopen(csvfilename, 'r');
    tline = fgetl(fid);
    while ischar(tline),
        [token,remain1] = strtok(tline, ',');
         if strcmp(token,'"info.dephist.device.datetime.start"') || strcmp(token,'"info.dephist.deploy.datetime.start"') || strcmp(token,'"info.dephist.deploy.locality"')
            change_token = token(1:end-1);
            token0 = strcat(change_token, '0"');
            id{end+1} = token0;
            token1 = strcat(change_token, '1"');
            id{end+1} = token1;
         else
             id{end+1} = token;
         end  
         [remain_token, field] = strtok(remain1, ',');
         field = field(2:end);
        if strcmp(token,'"info.dephist.device.datetime.start"') || strcmp(token,'"info.dephist.deploy.datetime.start"') || strcmp(token,'"info.dephist.deploy.locality"')
            if strcmp(token, '"info.dephist.device.datetime.start"') || strcmp(token, '"info.dephist.deploy.datetime.start"')
                date_time = strsplit(field);
                ret_field{end+1} = strcat(date_time{1}, '"');
                ret_field{end+1} =  strcat('"',date_time{2});
            end
            if strcmp(token,'"info.dephist.deploy.locality"'),
                field = field(4:end-3);
                locality = strsplit(field, ', ');
                ret_field{end+1} = strcat('"',locality{1}, '"');
                ret_field{end+1} = strcat('"',locality{2}, '"');
            end
         else
             ret_field{end+1} = field;
         end   
        tline = fgetl(fid);
    end
    id = id(2:end);
    ret_field = ret_field(2:end);
    fclose(fid);
end
function [id2, ret_field2] = parseCSV2(csvfilename)
    ret_field2 = {};
    id2 = {};
    fid = fopen(csvfilename, 'r');
    tline = fgetl(fid);
    while ischar(tline)
        [token,remain1] = strtok(tline, ',');
        id2{end+1} = token;
        [remain_token, field2] = strtok(remain1, ',');
         field2 = field2(2:end);
        ret_field2{end+1} = field2;
         tline = fgetl(fid);
    end
    id2 = id2(2:end);
    ret_field2 = ret_field2(2:end);
    fclose(fid);
end
    
  