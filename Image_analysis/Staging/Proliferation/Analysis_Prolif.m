function [Objects] = Analysis_Prolif(InfoTableThis, DataPath, ch1, ch2, ch3)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

   %% image analysis

%% Segment nuclei
                  
                    NucChannelDoG = imfilter(ch1, fspecial('gaussian', 10, 2), 'symmetric')...
        - imfilter(ch1, fspecial('gaussian', 20, 6), 'symmetric'); %it(NucChannelDoG);
                     NucMask = NucChannelDoG > 15;
                     NucMask = bwareaopen(NucMask, 10); %it(NucMask); it(ch1);

                        
%% Segment TH
    
    THSegmentationIm = ch3; % 
    %vol(THSegmentationIm, 0,50)
    THSegmentationImGlobal = imfilter(THSegmentationIm, fspecial('gaussian', 1, 3), 'symmetric'); % it(THSegmentationImGlobal)
    THSegmentationImLocal = imfilter(THSegmentationIm, fspecial('gaussian', 1, 3), 'symmetric')...
        - imfilter(THSegmentationIm, fspecial('gaussian', 5, 6), 'symmetric'); % vol(THSegmentationImLocal,0,20) it(THSegmentationImLocal)
    THMaskGlobal = THSegmentationImGlobal > 100; % vol(THSegmentationImGlobal) % vol(THMaskGlobal) it(THMaskGlobal)
    THMaskLocal = THSegmentationImLocal > 5; % vol(THSegmentationImLocal) % vol(THMaskLocal) it(THMaskLocal)
    THMask = THMaskGlobal | THMaskLocal; % Fill gaps % vol(THMask)

    % Remove small objects which are certainly no TH neurons
    THMask = bwareaopen(THMask, 10); %it(THMask) it(ch3)
%% Segment Ki67
    ch2LP = imfilter(ch2, fspecial('gaussian', 10, 1), 'symmetric');%it(ch2LP) it(ch2)
    Ki67Mask = ch2LP > 60;
    Ki67Mask = bwareaopen(Ki67Mask, 150);%it(Ki67Mask)
    
    
        %% Collect data
        Objects = table();        
        InfoTableThisSample = InfoTableThis; 
        THinTHMask = ch3 .* uint16(THMask);
        Ki67inKi67Mask = ch2 .* uint16(Ki67Mask);
        Objects.THbyNucArea = sum(THinTHMask(:)) / sum(NucMask(:));
        Objects.THbyTHArea = sum(THinTHMask(:)) / sum(THMask(:)); % Average pixel value
        Objects.Ki67byNucArea = sum(Ki67inKi67Mask(:)) / sum(NucMask(:));
        Objects.Ki67AreaByNucArea = sum(Ki67Mask(:)) / sum(NucMask(:));
        Objects.THAreaByNucArea = sum(THMask(:)) / sum(NucMask(:));
        Objects.Ki67Area = sum(Ki67Mask(:)); % pixel count
        Objects.THArea = sum(THMask(:));
        Objects.NucArea = sum(NucMask(:));
        Objects = [InfoTableThisSample, Objects];
        
         %% save 2D previews
    
    PreviewPath = [DataPath, filesep, 'Previews'];
    Barcode = InfoTableThis.Barcode{:};
    Areaname = InfoTableThis.AreaName{:}; 
    row = InfoTableThis.Row;
    column = InfoTableThis.Column;
    field = InfoTableThis.field;
    
    % Scalebar
    imSize = [size(ch1, 1), size(ch1, 2)];
    [BarMask, ~] = f_barMask(50, 0.646, imSize, imSize(1)-50, 550, 10);
    %it(BarMask)
    
   
    Previewch2 = imadjust(max(ch2,[],3));
    Previewch1 = imadjust(max(ch1,[],3));
    Previewch3 = imadjust(max(ch3,[],3));
    %it(Previewch2)
    %it(Previewch1)
    %it(Previewch3)
    
    % Channels with Mask
    PreviewTH = imoverlay2(imadjust(max(ch3,[],3)), bwperim(max(THMask,[],3)), [1 0 0]);
    PreviewTH = imoverlay2(PreviewTH, BarMask, [1 1 1]);
    PreviewKi67 = imoverlay2(imadjust(max(ch2,[],3)), bwperim(max(Ki67Mask,[],3)), [0 1 0]);
    PreviewKi67 = imoverlay2(PreviewKi67, BarMask, [1 1 1]);
    PreviewNuc = imoverlay2(imadjust(max(ch1,[],3)), bwperim(max(NucMask,[],3)), [0 0 1]);
    PreviewNuc = imoverlay2(PreviewNuc, BarMask, [1 1 1]);
    %it(PreviewTH)
    %it(PreviewKi67)
    %it(PreviewNuc)
   
    filename_ch3_TH = sprintf('%s\\%s_%s_%03d%03d%03d_ch3_TH.png', PreviewPath, Barcode, Areaname, row, column, field);
    filename_ch1_Nuc = sprintf('%s\\%s_%s_%03d%03d%03d_ch1_Nuc.png', PreviewPath, Barcode, Areaname, row, column, field);
    filename_ch2_Ki67 = sprintf('%s\\%s_%s_%03d%03d%03d_ch2_Ki67.png', PreviewPath, Barcode, Areaname, row, column, field);
    filename_THMask = sprintf('%s\\%s_%s_%03d%03d%03d_THMask.png', PreviewPath, Barcode, Areaname, row, column, field);
    filename_Ki67Mask = sprintf('%s\\%s_%s_%03d%03d%03d_Ki67Mask.png', PreviewPath, Barcode, Areaname, row, column, field);
    filename_NucMask = sprintf('%s\\%s_%s_%03d%03d%03d_NucMask.png', PreviewPath, Barcode, Areaname, row, column, field);
    
      
    
    imwrite(Previewch3, filename_ch3_TH);
    imwrite(Previewch1, filename_ch1_Nuc);
    imwrite(Previewch2, filename_ch2_Ki67);
    imwrite(PreviewKi67, filename_Ki67Mask);
    imwrite(PreviewNuc, filename_NucMask);
    imwrite(PreviewTH, filename_THMask);
   
    
end

