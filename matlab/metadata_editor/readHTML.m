function metadata_editor(masterHTML, csvfilename)

    [id2, req_fields2, fields2] = parseCSV2(csvfilename);
    htmlID = fopen(masterHTML);
    s = textscan(htmlID,'%s','Delimiter','\n');
    s = s{1};
    newS = s;
    fclose(htmlID);
    fields_findstring = "other_field = ";
    fields_array_index = find(contains(s, fields_findstring));
    [fields_field_split, unused] = strsplit(s{fields_array_index}, "[");
    fields_array_string = "";
    for u = 1:length(fields2)
        if u == 1,
            fields_array_string = strcat("[", '"', fields2{u}, '"');
        else
            if u < length(fields2),
                if isempty(fields2{u})
                    fields_array_string = strcat(fields_array_string, " ", ",", '""');
                else
                    if fields2{u}(1) == '"' && fields2{u}(end) == '"'
                         fields_array_string = strcat(fields_array_string, " ", ",", "'", fields2{u}, "'");
                    else
                        fields_array_string = strcat(fields_array_string, " ", ",",  '"', fields2{u}, '"' );
                    end
                end
            else
                if isempty(fields2{u}),
                     fields_array_string = strcat(fields_array_string, " ", ",", '""', "]");
                else
                    if fields2{u}(1) == '"' && fields2{u}(end) == '"'
                         fields_array_string = strcat(fields_array_string, " ", ",", "'", fields2{u}, "'", "]");
                    else
                        fields_array_string = strcat(fields_array_string, " ", ",", '"', fields2{u},'"', "]");
                    end
                end
            end
        end
    end
   newS{fields_array_index} = strcat(fields_field_split{1}, " ", fields_array_string);
   csv_findstring = "csv_fields = ";
   csv_array_index = find(contains(s, csv_findstring));
   [csv_field_split, unused] = strsplit(s{csv_array_index}, "[");
    csv_array_string = "";
    for u = 1:length(id2)
        if u == 1,
            csv_array_string = strcat("[", '"', id2{u}, '"');
        else
            if u ~= length(id2),
                csv_array_string = strcat(csv_array_string, " ", ",",  '"', id2{u}, '"' );
            else
               csv_array_string = strcat(csv_array_string, " ", ",", '"', id2{u},'"', "]");
            end
        end
    end
     newS{csv_array_index} = strcat(csv_field_split{1}, " ", csv_array_string);
    req_findstring = "req_field = ";
    req_array_index = find(contains(s, req_findstring));
   [req_field_split, unused] = strsplit(s{req_array_index}, "[");
    req_array_string = "";
    for u = 1:length(req_fields2)
        if u == 1,
            req_array_string = strcat("[", req_fields2{u});
        else
            if u ~= length(req_fields2),
                req_array_string = strcat(req_array_string, " ", ",",  req_fields2{u} );
            else
               req_array_string = strcat(req_array_string, " ", ",", req_fields2{u},"]");
            end
        end
    end
     newS{req_array_index} = strcat(req_field_split{1}, " ", req_array_string);
    [id,fields] = parseCSV(csvfilename);
    c = containers.Map;
    indices = [];
    for i = 1:length(id)
        findstring = strcat('id=','"',id(i),'"');
        index = find(contains(s, findstring));
        if ~isempty(index)
            c(char(id(i))) = index;
            indices = [indices; i];
        end
    end


    for n = 1:length(indices)
        if strcmp(id(indices(n)), "dephist.device.regset")
            continue;
        end
        if strcmp(id(indices(n)), "udm.export")
            [C,~] = strsplit(s{c(char(id(indices(n))))}, '" />');
            tempcell = C{2};
            if fields{indices(n)} == '1'
                C{2} = '" checked />';
            else
                C{2} = '" />';
            end
            C{3} = tempcell;
            newS{c(char(id(indices(n))))} = [C{1} C{2} C{3}];
        end
        if ~strcmp(id(indices(n)), "dephist.device.tzone") 
            [C,matches] = strsplit( s{c(char(id(indices(n))))},'value = ""');
            if ~isempty(matches)
                tempcell = C{2};
                if isempty(fields{indices(n)})
                    C{2} = ' value= "NA" ';
                else
                    if fields{indices(n)}(1) ~= '"' && fields{indices(n)}(length(fields{indices(n)})) ~= '"'
                        C{2} = strcat(' value=','"',fields{indices(n)},'"',' ');
                    else
                         C{2} = strcat(' value=',fields{indices(n)},' ');
                    end
                end
                C{3} = tempcell;
                newS{c(char(id(indices(n))))} = [C{1} C{2} C{3}];
            end
        end
        if strcmp(id(indices(n)), "dephist.device.tzone")
            f_str = strcat("value=",'"',fields{indices(n)},'"');
            for m = (c(char(id(indices(n))))+ 1): (c(char(id(indices(n))))+82)
                if ~isempty(strfind(s{m}, f_str))
                     [C,~] = strsplit( s{m},'>(');
                     tempcell = C{2};
                      C{2} = " selected >(";
                      C{3} = tempcell;
                      newS{m} = strcat(C{1},C{2},C{3});
                    break;
                end
            end
        end
    end
    
    clear_index = find(contains(s, "<script>"));
    newS = [newS(1:clear_index); {"window.localStorage.clear()"}; newS(clear_index+1:end) ];

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
         if strcmp(token,"dephist.device.datetime.start") || strcmp(token,"dephist.deploy.datetime.start")
            change_token = token(1:end);
            token0 = strcat(change_token, '0');
            id{end+1} = token0;
            token1 = strcat(change_token, '1');
            id{end+1} = token1;
         else
             id{end+1} = token;
         end  
         [remain_token, field] = strtok(remain1, ',');
         field = field(2:end);
        if strcmp(token,"dephist.device.datetime.start") || strcmp(token,"dephist.deploy.datetime.start") 
            date_time = strsplit(field);
            ret_field{end+1} = strcat(date_time{1});
            ret_field{end+1} =  strcat(date_time{2});
         else
             ret_field{end+1} = field;
         end   
        tline = fgetl(fid);
    end
    id = id(2:end);
    ret_field = ret_field(2:end);
    fclose(fid);
end
function [id2, req_field2, ret_field2] = parseCSV2(csvfilename)
    ret_field2 = {};
    id2 = {};
    req_field2 = {};
    fid = fopen(csvfilename, 'r');
    tline = fgetl(fid);
    while ischar(tline)
        [token,remain1] = strtok(tline, ',');
        id2{end+1} = token;
        [remain_token, field2] = strtok(remain1, ',');
        req_field2{end + 1} = remain_token;
         field2 = field2(2:end);
        ret_field2{end+1} = field2;
         tline = fgetl(fid);
    end
    id2 = id2(2:end);
    req_field2 = req_field2(2:end);
    ret_field2 = ret_field2(2:end);
    fclose(fid);
end
    
  