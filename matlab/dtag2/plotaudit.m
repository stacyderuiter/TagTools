function H = plotaudit(tag,d3, varargin)
% H = plotaudit(tag,...)
%plot audit data for a dtag tag out.
%there must be a prh file.
%there must be an audit text file.
%matlab dtag path must be set.
%default is to plot all event types listed in the audit.
%to plot specific events only, specify the 'stype' of those events.
%for example, plotaudit(tag,'soc','eoc','buzz') 
%will plot start of clicking, end of clicking, and buzzes.
%H is a vector of handles to objects in the plot.

loadprh(tag);
R1 = loadaudit(tag);
%make sure audit data is in chronological order
[y,i] = sort(R1.cue(:,1));
R1.cue = R1.cue(i,:);
stold = R1.stype;
for j = 1:length(i)
    R1.stype{j} = stold{i(j)};
end

if nargin>1
    stypes = varargin;
else
    stypes = unique(R1.stype);
end

% figure(1); clf;
set(gca,'FontSize',14);
set(gcf,'Color','w');
%get time vector
if d3==0
    loadcal(tag);
    UTC2LOC = [];
else
    [CAL,DEPLOY,ufname] = d3loadcal(tag);
    TAGON = DEPLOY.SCUES.SSTART;
    if exist('GMT2LOC','var') %back compatibility with older cal files that use the field GMT2LOC instead of UTC2LOC
        UTC2LOC = GMT2LOC;
    else
        UTC2LOC = DEPLOY.UTC2LOC;
    end
end

t = cst2datenum(tag,(1:length(p))./fs,d3,TAGON,UTC2LOC);

%plot dive profile
plot(t,p,'k', 'LineWidth', 2); axis ij; axis tight;
ylim([-10,max(p)+0.1*max(p)]);
datetick('x',15,'keeplimits'); %change x labels from datenumbers to HH:MM
hold on;
if d3==0
 [ta,ts] = recordlength_sd(tag);
 end_acous = cst2datenum(tag,ta,d3,TAGON,UTC2LOC);
else
    end_acous=max(t);
end
 if end_acous < max(t)
     EA = plot(t(t>end_acous),p(t>end_acous),'Color',[0.6 0.6 0.6], 'LineWidth',2);
 else
     EA = [];
 end
H2 = 0;
%loop over sound types from the audit and plot them one by one
%colors to use for different sounds (in order they appear)
colorz = [ 0 0 1 % 1 BLUE
   0 1 0 % 2 GREEN (pale)
   1 0 0 % 3 RED
   0 1 1 % 4 CYAN
   1 0 1 % 5 MAGENTA (pale)
   1 1 0 % 6 YELLOW (pale)
   0 0 0 % 7 BLACK
   0 0.75 0.75 % 8 TURQUOISE
   0 0.5 0 % 9 GREEN (dark)
   0.75 0.75 0 % 10 YELLOW (dark)
   1 0.50 0.25 % 11 ORANGE
   0.75 0 0.75 % 12 MAGENTA (dark)
   0.7 0.7 0.7 % 13 GREY
   0.8 0.7 0.6 % 14 BROWN (pale)
   0.6 0.5 0.4 ]; % 15 BROWN (dark)
% symbolz = []; %could fill this in if you want to vary marker style
% instead of color...
stypes2 = {};
if ~isempty(EA)
    stypes2{end+1}='No acoustic data';
end
H1 = [];
for k = 1:length(stypes)
    s = stypes{k};
    if strncmpi('eoc',s,3)
        %do nothing for eoc, taken care of below in the soc case
    elseif strncmpi('soc',s,3) %special case for soc/eoc
        stypes2{end+1} = 'Clicking';
        clear ss ee kk ic
        ss = R1.cue(strncmpi(R1.stype,'soc',3));
        ee = R1.cue(strncmpi(R1.stype,'eoc',3));
        for kk = 1:length(ss)
            if kk > length(ee); continue;
            end
            ic = round(fs*ss(kk)):round(fs*ee(kk));
            if kk == 1 && ~isempty(ic)
               H1 = plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            elseif ~isempty(ic)
               plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            end
        end
    else
    stypes2{end+1} = s;
    cues = R1.cue(strncmpi(R1.stype,s,length(s)),:);
    if strcmp('pause',s)
        for kk = 1:size(cues,1)
            ic = round(fs*cues(kk,1)):round(fs*(cues(kk,1)+cues(kk,2)));
            if kk == 1 && ~isempty(ic)
               H1(end+1) = plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            elseif ~isempty(ic)
               plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            end
        end
    elseif strcmp('slowclicks',s)
        for kk = 1:size(cues,1)
            ic = round(fs*cues(kk,1)):round(fs*(cues(kk,1)+cues(kk,2)));
            if kk == 1 && ~isempty(ic)
               H1(end+1) = plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            elseif ~isempty(ic)
               plot(t(ic),p(ic),'Color',colorz(k,:),'LineWidth',3);
            end
        end
    else
    H1(end+1) = plot(t(round(cues(:,1)*fs)),p(round(cues(:,1)*fs)),'Color',colorz(k,:),'MarkerFaceColor',colorz(k,:),'Marker','*','LineStyle','none');
    end
    end
end
hold off
% title(tag,'interpreter','none');
ylabel('Depth [m]');
%xlabel('Local Time');
if ~isempty(EA)
    legend([EA,H1],stypes2 ,'Location','South','FontSize',16);
else
    legend([H1],stypes2 ,'Location','South','FontSize',16);
end