function [Bins_MEAN_z,Bins_STD_z,Bins_STD_fz] = plotVST_check(fz_rls,z_rls,bins)

[M_fz N_fz rls_fz] = size(fz_rls);
[M_z N_z rls_z] = size(z_rls);
Bins_STD_fz = [];
Bins_STD_z = [];
Bins_MEAN_z = [];

if rls_fz == 1
    disp('ERROR: "fz_rls" needs to be a volumetric variable')
elseif rls_z==1
    disp('ERROR: "z_rls" needs to be a volumetric variable')
else
    GT = double(uint16(mean(z_rls,3)));
    ValMin = min(GT(:));
    ValMax = max(GT(:));
    range = linspace(ValMin,ValMax,bins);
    STD_fz = std(fz_rls,[],3);
    STD_z = std(z_rls,[],3);
    for i =1:bins-1
        
        indx = find(GT>=range(i) & GT<=range(i+1));
        if numel(indx) > numel(nonzeros(GT(:)))*0.01
            
            Bins_STD_fz = [Bins_STD_fz mean2(STD_fz(indx))];
            
            Bins_STD_z = [Bins_STD_z mean2(STD_z(indx))];
            Bins_MEAN_z = [Bins_MEAN_z mean2(GT(indx))];
        else
            
        end
        
        
        
        
    end
    figure,
    
    subplot(2,2,1),
    title1 = string('Desvio padrão');
    title2 = string('antes da VST');
    title3 = string('depois da VST');
    imshow(STD_z,[]),colormap(gca,hot), colorbar,title({title1,title2});%,caxis([round(min(Bins_STD_z(:))) round(max(Bins_STD_z(:))).*1])
    
    subplot(2,2,2),
    imshow(STD_fz,[]),colormap(gca,jet), colorbar,title({title1,title3}),caxis([0 2])
    
    subplot(2,2,[3 4]),
    yyaxis left
    plot(Bins_MEAN_z,Bins_STD_z,'-o'),hold on;
    axis([ min(Bins_MEAN_z(:))*0.95 [max(Bins_MEAN_z(:))+min(Bins_MEAN_z(:))*0.05] floor(min(Bins_STD_z(:))*0.8) [ceil(max(Bins_STD_z(:)))+  ceil(min(Bins_STD_z(:)*0.2))]]), grid on
    ylabel({title1,title2})
    
    yyaxis right
    plot(Bins_MEAN_z,Bins_STD_fz,'--*'),hold off;
    axis([  min(Bins_MEAN_z(:))*0.95 [max(Bins_MEAN_z(:))+min(Bins_MEAN_z(:))*0.05] 0.5 1.5]), grid on
    ylabel({title1,title3})
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',-90,'VerticalAlignment','bottom')%,'Position',[2260 1 -1])
    xlabel('Valor médio de nível de cinza')
    
    
end



end

