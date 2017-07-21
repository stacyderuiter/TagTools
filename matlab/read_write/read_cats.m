% CATS
datapath='C:\Users\DTag-Builder\Dropbox\MATLAB-TOOLS\tagTools\io\CATS\mn160727-11\raw';
fbase='20160730-091117-Froback-11';
suffix='.csv';
filename=[datapath '\' fbase '.csv'];

%% Get number of lines in file
message='Calculating number of lines in file!';
disp(message);
tic
fid = fopen(filename, 'r');
chunksize = 1e6; % read chuncks of 1MB at a time
numlines = 0;
while ~feof(fid)
    ch = fread(fid, chunksize, '*uchar');
    if isempty(ch)
        break
    end
    numlines = numlines + sum(ch == sprintf('\n'));
end
fclose(fid);
toc
message=['File contains: ' num2str(numlines) ' lines'];
disp(message)

bsize=chunksize;
blocks=ceil(numlines/bsize);

%% Get header
fid=fopen(filename,'r');
fheader=textscan(fid,'%s',1,'Delimiter','\n');
[nrows, nfields]=size(cell2mat(regexp(fheader{1},',')));
fclose(fid);

%% CATS Sensor names & metadata from txt file
% sensvocab

fid=fopen([datapath '\' fbase '.txt'],'r');
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};


%% Get line numbers for keywords (block identifiers)
keywrd={'device','logging','duty','camera','available','activated'};
blockid=zeros(length(keywrd),1);
for k=1:length(keywrd)
    blockid(k) = find(~cellfun(@isempty, strfind(lines,keywrd(k))));
end

%% Get line numbers for block spacers (blank lines)
blanks= find(cellfun('isempty', lines));

%% Block info
dinf=lines(blockid(1)+1:blanks(find(blanks>blockid(1),1,'first'))-1);
dlog=lines(blockid(2)+1:blanks(find(blanks>blockid(2),1,'first'))-1);
dduty=lines(blockid(3)+1:blanks(find(blanks>blockid(3),1,'first'))-1);
camera=lines(blockid(4)+1:blanks(find(blanks>blockid(4),1,'first'))-1);
sens1=lines(blockid(5)+1:blanks(find(blanks>blockid(5),1,'first'))-1);
sens2=lines(blockid(6)+1:blanks(find(blanks>blockid(6),1,'first'))-1);

%% Get device information
sn=char(dinf(find(~cellfun(@isempty,strfind(dinf,'sn')),1,'first')));
sn=(sn(regexp(sn,'=')+1:end));
id=char(dinf(find(~cellfun(@isempty,strfind(dinf,'id')),1,'first')));
id=(id(regexp(id,'=')+1:end));
tzone=char(dinf(find(~cellfun(@isempty,strfind(dinf,'utc')),1,'first')));
tzone=(tzone(regexp(tzone,'=')+1:end));

%% Get logger information
sdt=char(dlog(find(~cellfun(@isempty,strfind(dlog,'UTC')),1,'first')));
sdt=(sdt(regexp(sdt,'=')+1:end));
edt=char(dlog(find(~cellfun(@isempty,strfind(dlog,'UTC')),1,'last')));
edt=(edt(regexp(edt,'=')+1:end));

%% Dutycycle
dcycle=cell(length(dduty),2);
for k=1:length(dduty)
    cyc=char(dduty(k));
    dcycle(k,1)=cellstr(cyc(regexp(cyc,'_')+1:(regexp(cyc,'_')+2)));
    dcycle(k,2)=cellstr(cyc(regexp(cyc,'=')+1:end));
end

%% Camera
cv=char(camera(find(~cellfun(@isempty,strfind(camera,'version')),1,'first')));
cv=(cv(regexp(cv,'=')+1:end));
cmode=char(camera(find(~cellfun(@isempty,strfind(camera,'mode')),1,'last')));
cmode=(cmode(regexp(cmode,'=')+1:end));
[~,~]=size(camera);

%% Generate a table of available sensors
[r,c]=size(sens1);
sblocks = find(~cellfun(@isempty, strfind(sens1,'unid')));
unid=cell(r/3, 1);

for k=1:r/3
    unid(k,1)={k};
    sid=char(sens1(sblocks(k)));
    unid(k,2)=cellstr(sid(regexp(sid,'=')+1:end));
    sname=char(sens1(sblocks(k)+1));
    unid(k,3)=cellstr(sname(regexp(sname,'=')+1:end));
    nchns=char(sens1(sblocks(k)+2));
    unid(k,4)=cellstr(nchns(regexp(nchns,'=')+1:end));
end
clear k

%% Populate table with sensor information if used
keywrd={'interval','offset','factor','coefficient'};
for k=1:length(keywrd)
    sblocks = find(~cellfun(@isempty, strfind(sens2,keywrd(k))));
    [nr,nc]=size(unid);
    [r,c]=size(sblocks);
    for kk=1:r
        sinfo=char(sens2(sblocks(kk)));
        sid=str2double(sinfo(1:2));
        sval=(sinfo(regexp(sinfo,'=')+1:end));
        if strcmp(keywrd(k),'interval')==1
            unid(sid,nc+1)={1};  %Sensor used (binary)
            unid(sid,nc+2)=cellstr(sval); %Sensor sample rate
        else
            unid(sid,nc+1)=cellstr(sval);
        end
    end
end

%%
vid=find(~cellfun(@isempty,unid(:,5)));
avocab={'Date','Time','System','BATT','Camera','Flags','LED'}';
svocab=unid(vid,3);
tvocab=[avocab(1:2); svocab; avocab(3:end)];
fid=fopen([datapath '\' fbase '.csv'],'r');
header= textscan(fid, '%s',1, 'Delimiter', '\n');
fclose(fid);

%%
delim=regexp(char(header{1}),',');
fcol=cell(length(tvocab),3);
for k=1:length(tvocab)
    fcol(k,1)={k};
    fcol(k,2)=cellstr(tvocab{k});
    col=(strfind(char(header{1}),tvocab(k)));
    fcol(k,3)={col};
end

%% Read in big file
%% Read in big file
spos=[1 delim+1];
epos=[delim-1 length(char(header{1}))];

tablespec={1};
for k=1:length(spos)
    
    fheader=char(header{1});
    colname=fheader(spos(k):epos(k));
    units=colname(regexp(colname,'[')+1:end-1);
    wsp=regexp(colname,'\s');
    if iscell(wsp)
        wsp=cell2mat(wsp);
    end
    if wsp(1,1)==1
        wsp=wsp(1,2);
    else
        wsp=wsp(1,1);
    end
    keywrd=(colname(1:wsp-1));
   
   switch keywrd
        case {'Date'}
            fmtspec='%s';
        case {'Time'}
            fmtspec='%s';
        case {'Accelerometer'}
            fmtspec='%f';
        case {'Gyroscope'}
            fmtspec='%f';
        case {'Magnetometer'}
            fmtspec='%f';
        case {'Temperature'}
            fmtspec='%f';
        case {'GPS'}
            gpscol=colname(regexp(colname,'\d'));
            if gpscol<3 && gpscol>4
                fmtspec='%s';
            else
                fmtspec='%f';
            end
        case {'Depth'}
            fmtspec='%f';
        case {'Light'}
            fmtspec='%d';
        case {'Barometer'}
            fmtspec='%f';
        case {'Pitot'}
            fmtspec='%f';
        case {'BATT'}
            fmtspec='%f';
        case {'Camera'}
            fmtspec='%d';
        case {'Flags'}
            fmtspec='%s';
        case {'LED'}
            fmtspec='%d';
        case {'System'}
            fmtspec='%s';
        otherwise
            fmtspec='%s';
    end
    
    tablespec{k,1}=colname;
    tablespec{k,2}=units;
    tablespec{k,3}=fmtspec;
    
end

fmtspec=cell2mat(tablespec(:,3)');

%% Read in data
fclose('all');
tstart=tic;
% fid=fopen([datapath '\' fbase '.csv'],'r');
data=[];
% fmtspec='%*s%*s%f%f%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s';
for k=1:blocks
    fid=fopen([datapath '\' fbase '.csv'],'r');
        message=['Processing block:' num2str(k) ' of ' num2str(blocks) ' blocks'];
        disp(message)
    if k==1
        C = textscan(fid,fmtspec,bsize,'Delimiter',',','HeaderLines',1);
        fclose(fid);
    else
        C = textscan(fid,fmtspec,bsize,'Delimiter',',','HeaderLines',(k-1)*bsize);
        fclose(fid);
    end
    if k<10
    savename=[datapath '\' 'A00' num2str(k).mat]
    end
    if k<100
        savename=[datapath '\' 'A0' num2str(k).mat]
    end
    if k<100
        savename=[datapath '\' 'A' num2str(k).mat]
    end
    A=cell2mat(C);
    save(savename,'A');
    data=[data,A];
 
end

fclose(fid);
toc(tstart)
%%

toc(tstart)

savename=[datapath '\' fbase '.mat'];
save(savename,'cats');



