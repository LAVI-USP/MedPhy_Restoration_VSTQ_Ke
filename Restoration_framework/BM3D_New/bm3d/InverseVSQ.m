function [z_posVSQ] = InverseVSQ(fz,Lambda,look_up_table,mAs)

parfor ii=1:size(Lambda,2)
    
    alpha_select = Lambda(:,ii);
    fz_VSQ_line = (fz(:,ii));
    if mAs==18
        %18 mAs
        [~, alpha_position] = min(abs(repmat(linspace(0.37,0.47,5*10^4), [2850 1]) - alpha_select),[],2);
    elseif mAs ==27
        %27mAs
        [~, alpha_position] = min(abs(repmat(linspace(0.34,0.48,5*10^4), [2850 1]) - alpha_select),[],2);
    else
        %36mAs
        [~, alpha_position] = min(abs(repmat(linspace(0.3605,0.4770,5*10^4), [2850 1]) - alpha_select),[],2);
        
    end
    P = cell2mat(look_up_table(alpha_position));
    z_posVSQ(:,ii) = P(:,1:3:end)'.*fz_VSQ_line.^2 + P(:,2:3:end)'.*fz_VSQ_line + P(:,3:3:end)';
    
end

end

