function write_snaphu_conf(ntilerow,ntilecol,nproc)
% ntilerow: how many tiles rows
% ntilecol: how many tiles cols
% nproc: how many processors to split the tile processes on (Mongoose has
% 40 cores, and packrat has 32
set_params

for ii=1:nints
    
    conf =[char(ints(ii).unwrlk) '_snaphu.conf'];
    fid=fopen(conf,'w');
    
    fprintf(fid,['# Input                                                         \n']);
    fprintf(fid,['INFILE ' [ints(ii).flatrlk '_bell']                          '\n']);
%     fprintf(fid,['UNWRAPPED_IN TRUE                                               \n']);
    fprintf(fid,['# Input file line length                                        \n']);
    fprintf(fid,['LINELENGTH '    num2str(newnx)                                 '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Output file name                                              \n']);
    fprintf(fid,['OUTFILE ' [char(ints(ii).unwrlk)]                                  '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Correlation file name                                         \n']);
    fprintf(fid,['CORRFILE  '      maskfilerlk                                '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Statistical-cost mode (TOPO, DEFO, SMOOTH, or NOSTATCOSTS)    \n']);
    fprintf(fid,['STATCOSTMODE    SMOOTH                                          \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['INFILEFORMAT            FLOAT_DATA                              \n']);
    fprintf(fid,['UNWRAPPEDINFILEFORMAT   FLOAT_DATA                              \n']);
    fprintf(fid,['OUTFILEFORMAT           FLOAT_DATA                              \n']);
    fprintf(fid,['CORRFILEFORMAT          FLOAT_DATA                              \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['NTILEROW ' num2str(ntilerow) '                                  \n']);
    fprintf(fid,['NTILECOL ' num2str(ntilecol) '                                  \n']);
    fprintf(fid,['# Maximum number of child processes to start for parallel tile  \n']);
    fprintf(fid,['# unwrapping.                                                   \n']);
    fprintf(fid,['NPROC  '               num2str(nproc) '                         \n']);
    fprintf(fid,['ROWOVRLP 100                                                    \n']);
    fprintf(fid,['COLOVRLP 100                                                    \n']);
    fprintf(fid,['RMTMPTILE TRUE                                                  \n']);
    fclose(fid);
    
    
end

disp(['unwrapping on ' num2str(nproc) ' cores, with ' num2str(ntilerow) 'x' num2str(ntilecol) ' tiles'])