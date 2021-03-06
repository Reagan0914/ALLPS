set_params
load(ts_paramfile);
ndates=length(dates);

dn=[dates.dn];
bp=[dates.bp];
deltadn=repmat(dn,ndates,1)-repmat(dn',1,ndates);
deltabp=repmat(bp,ndates,1)-repmat(bp',1,ndates);


%Change doppler and baseline thresholds depending on satellite.
switch sat
    case {'ENVI', 'ERS'}
        dn_thresh = 400;
        bp_thresh = 300;
        [i1,i2]=find(and(and(deltadn>0,deltadn<dn_thresh),abs(deltabp)<bp_thresh));
        
    case 'ALOS'
        dn_thresh = 730;
        bp_thresh = 1500;
        [i1,i2]=find(and(and(deltadn>0,deltadn<dn_thresh),abs(deltabp)<bp_thresh));
end




% %sort so that first int has master date
% tmpid=find(i1==id);
% if(~isempty(tmpid))
%     i1=i1([tmpid(1) 1:tmpid(1)-1 tmpid(1)+1:end]);
%     i2=i2([tmpid(1) 1:tmpid(1)-1 tmpid(1)+1:end]);
% else
%     disp('need an interferogram that starts with the master date')
% end


% use only the best 2 ints off of each date (this could be cleaned up
% probably)
for i=1:length(i1)
    clear a;clear a1;clear a2;clear a3;clear a4;clear bad;clear rempair;
    
    
    if length(find(i1==i))>2
        a=find(i1==i);
        
        a3=i2(a);
        a1=sort(abs(deltabp(a3,i)));
        
        a2(1)=find(abs(deltabp(:,i))==a1(1));
        a2(2)=find(abs(deltabp(:,i))==a1(2));
        
        a4=a3(find(and(i2(a)~=a2(1),i2(a)~=a2(2))))  ;
        for j=1:length(a4)
            rempair(j,:)=[i,a4(j)];
        end
        bad=ismember([i1 i2],rempair,'rows');
        
        i1=i1(~bad);
        i2=i2(~bad);
    end
end
%remove pairs (by date index)
if(~isempty(removepairs))
    badid=ismember([i1 i2],removepairs,'rows');
    i1=i1(~badid);
    i2=i2(~badid);
end

% if(~isempty(rp))
%     badid=ismember([i1 i2],rp,'rows');
%     i1=i1(~badid);
%     i2=i2(~badid);
% end

%add others here
if(~isempty(addpairs))
    i1=[i1;addpairs(:,1)];
    i2=[i2;addpairs(:,2)];
end


i1=[ints.i1];
i2=[ints.i2];

if(plotflag)
    dnpair=[dates(i1).dn;dates(i2).dn];
    bppair=[dates(i1).bp;dates(i2).bp];
    
    figure
    text(dn,bp,num2str([1:ndates]')); hold on
    plot(dnpair,bppair);
    grid on
    datetick
    title(masterdir)
    xlabel('Years'); ylabel('Baseline (m)')
    kylestyle
end

%save int structure and params, build Gint for later inversion
clear ints
nints=length(i1);

for i=1:nints
    ints(i).i1=i1(i);
    ints(i).i2=i2(i);
    ints(i).dt=dates(i2(i)).dn-dates(i1(i)).dn;
    ints(i).name=[dates(i1(i)).name '-' dates(i2(i)).name];
    ints(i).int=[intdir ints(i).name '.int'];
    ints(i).flat=[intdir 'flat_' ints(i).name '.int'];
    for j=1:length(rlooks)
        ints(i).flatrlk{j}=[rlkdir{j} 'flat_' ints(i).name '_'  num2str(rlooks(j)) 'rlks.int'];
        ints(i).unwrlk{j}=[rlkdir{j} 'flat_' ints(i).name '_'  num2str(rlooks(j)) 'rlks.unw'];
        ints(i).unwmsk{j}=[rlkdir{j} 'ramp_' ints(i).name '_' num2str(rlooks(j)) 'rlks.unw'];
    end
    for j=1:7
        ints(i).bvec(j)=dates(i2(i)).bvec(j)-dates(i1(i)).bvec(j);
    end
    ints(i).bp=ints(i).bvec(7); %for convenience
end
save(ts_paramfile,'dates','ints');
[G,Gg,R,N]=build_Gint;

% clear input
% 
% reply = input('Want to add/remove pairs? Y/n [Y]: ', 's');
% if(isempty(reply))
%     reply='Y';
% end
% 
% switch reply
%     case {'Y','Yes','y','YES'}
%         disp('add or remove pairs in set_params file and rerun')
%     case {'No','n','NO','N'}
%         % Finds a good interferogram pair to make the primary interferogram, and
%         % makes the first date of that pair the primary date.
%         intid_o=intid;
%         id_o=id;
%         
%         baseline_sums=abs([ints.dt])+abs([ints.bp]); %sum each int's spatial and temporal baseline
%         [~,b]=sort(baseline_sums); %find the lowest value from above
%         intid=b(1); %make that the master int
%         id=ints(intid).i1; %make the master date the first date in the master int from above
% 
%         disp(['Making ' ints(intid).name ' the primary interferogram.']);
%         disp([num2str(ints(intid).i1) ' and ' num2str(ints(intid).i2)]);
%         disp(['Making ' dates(id).name ' the primary date/']);
%         disp(['Writing new primary date and int to set_params file']);
%         
%         % Write the new ids to set_params
%         file=[masterdir 'set_params.m'];
%         fid=fopen(file,'a+');
%         fprintf(fid,['id = ' num2str(id) ' ;\n']);
%         fprintf(fid,['intid = ' num2str(intid) ' ;\n']);
%         
%         
%         %check if ids changed
%         if(intid~=intid_o & id~=id_o)
%             disp('ids have changed.  Rerunning from setup_init')
%             setup_init
%             choose_ints_km
%         else
%             disp('ids have not changed. Continue to make_slcs')
%         end
% end
% 
