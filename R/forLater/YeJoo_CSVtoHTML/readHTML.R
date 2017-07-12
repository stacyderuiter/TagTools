readHTML <- function(masterHTML, csvfilename){

csvFile <- parseCSV(csvfilename)
htmlFile <- scan(file = "tagmetadata.html", what = character(0), sep = "\n", quote = "")
id <- csvFile$id
field <- csvFile$field
c = containers.Map;
for (i in 1:length(id)){
  
}
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

% Write cell A into txt
new_html_id = fopen('dynamic_tagmetadata.html', 'w');
for i = 1:numel(newS)
fprintf(new_html_id,'%s\n', newS{i});
end
fclose(new_html_id);
end
}


parseCSV<-function(csvfilename){
  a1 <- readr::read_csv("~/TagTools/R/forLater/YeJoo_CSVtoHTML/a1.csv")
  return(list(id=a1$field, field=a1$params))
} 

