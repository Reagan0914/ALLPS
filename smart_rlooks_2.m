set_params
load(ts_paramfile)
% getstuff
win=ones(alooks,rlooks);
win=win/sum(win(:));
rangevec=[0:newnx-1]*rlooks+1;


for l=1:length(rlooks)
    parfor k=1:nints
        im=sqrt(-1);
        fid1    = fopen(gammafile,'r');
        fid2    = fopen(ints(k).flat,'r');
        fid3    = fopen(ints(k).flatrlk,'w');
        fid4    = fopen([ints(k).flatrlk '.cor'],'w');
        
        for j=1:newny(l)
            mask = zeros(alooks(l),nx);
            int  = zeros(alooks(l),nx);
            
            for i=1:alooks(l)
                gam  = fread(fid1,nx,'real*4');
                if(length(gam)==nx)
                    mask(i,:)=gam(1:nx);
                else
                    mask(i,:)=0;
                end
                mask(i,isnan(mask(i,:)))=0;
                tmp=fread(fid2,nx,'real*4');
                if(length(tmp)==nx)
                    int(i,:)=exp(im*tmp);
                else
                    int(i,:)=zeros(1,nx);
                end
            end
            
            rea=real(int);
            ima=imag(int);
            
            rea_filt0  = conv2(rea,win,'valid');
            ima_filt0  = conv2(ima,win,'valid');
            
            rea=rea.*mask;
            ima=ima.*mask;
            
            rea_filt  = conv2(rea,win,'valid');
            ima_filt  = conv2(ima,win,'valid');
            mag_filt  = conv2(mask,win,'valid');
            
            phs    = atan2(ima_filt(rangevec),rea_filt(rangevec));
            phscor = sqrt(ima_filt0(rangevec).^2+rea_filt0(rangevec).^2); %abs value of average phase vector.
            %phssig=sqrt(-2*log(phscor));
            
            fwrite(fid3,phs,'real*4');
            fwrite(fid4,phscor,'real*4');
        end
        fclose('all');
    end
end
