function ImgExtractor(file,path,ExtractPath)

 
XLeftRatio = 0.0886739218;
XRightRatio = 0.980249899;
GesamTopRatio = 0.00826446281;
NiveauRatio = 0.00684053014;
NiveauBugRatio = 0.0183839247;
PageBotBorderRatio = 0.9482684908;
HencoTopRatio = 0.02727272727;
HencoBotRatio = 0.01;
WarmtebalansRatio = 0.042753;
UstKirpmaToNiveauRatio = 0.15861479;
ocrCropLeftRatio = 0.084694494;
ocrCropRightRatio = 0.26013309;

YwideRatio = 0.0129259940;

imgs = PDFtoImg(file,path);


if isa(file,'cell')==1
nF = length(file);
elseif isa(file,'char')==1
nF=1;
a=file;
clear file
file{1}=a;
end



nfPDF = length(file); %PDF Dosya sayýsý

SayfaSayilari = sum((cellfun('isempty',imgs)==0),2); % Her PDF teki Sayfa sayýsý (Resim dosyalarýnýn sayýsý)

for k = 1:nfPDF
clear images WBSayac ans biggest Bolunmus BWComplement BWPage CC col CropBot CropLeft CropRight CropTop currentimage currentimagegray idx1 idx2 index1 index1max index1min index2 index2max index2min index3 index3a index3b indexr1 indexr2 j lvl numPixels ocrResults ocrResults1 ocrResults2 Rollen RollenSayac row sayacAB TabloBolundu Warmtebalans WB WBSayac Words Words1 Words2 


for i=1:SayfaSayilari(k)
   currentimage = imgs{k,i};
   currentimagegray = rgb2gray(currentimage);
   images{i} = currentimagegray;
end



WBSayac = 1;
TabloBolundu=0;

for i = 1:SayfaSayilari(k)
    
lvl = graythresh(images{i});
BWPage = imbinarize(images{i},lvl-0.15);


BWComplement = ~BWPage;
CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);




[~,idx1] = max(numPixels);

if i == 1
[row,col] = ind2sub([size(images{1},1) size(images{1},2)],CC.PixelIdxList{idx1}); % Convert linear indeces to X Y
end

BWComplement(CC.PixelIdxList{idx1}) = 0;


CropLeft = round(ocrCropLeftRatio*size(BWComplement,2));
CropRight = round(ocrCropRightRatio*size(BWComplement,2));


ocrResults = ocr(BWComplement(:,CropLeft:CropRight));

Words = ocrResults.Words(:,1);

index1 = find(cellfun('isempty',strfind(Words,'Niveau' ))==0);
index2 = find(cellfun('isempty',strfind(Words,'Gesa' ))==0);
index3a = find(cellfun('isempty',strfind(Words,'Warmtebalans' ))==0);
index3b = find(cellfun('isempty',strfind(Words,'Bilan' ))==0);

if isempty(index3a)==1
    index3 = index3b;
elseif isempty(index3b)==1
    index3 = index3a;
end

if isempty(index1) == 0 || isempty(index2) == 0;

if i == 1
    CropTop = ocrResults.WordBoundingBoxes(index3,2) -1;
    CropBot = ocrResults.WordBoundingBoxes(index3,2) + WarmtebalansRatio*size(images{i},1);
    CropLeft = min(col);
    CropRight = max(col);
    
    Warmtebalans = images{i}(CropTop:CropBot,CropLeft:CropRight);
end

index1min = min(ocrResults.WordBoundingBoxes(index1,2));
index1max = max(ocrResults.WordBoundingBoxes(index1,2));
index2min = min(ocrResults.WordBoundingBoxes(index2,2));
index2max = max(ocrResults.WordBoundingBoxes(index2,2));


      
      %Sayfada Bölünme Olmama Durumu
      if (sum(index1)>0 || sum(index2) >0) && length(index1) == length(index2) && index1min < index2min && TabloBolundu==0
       
        for j=1:length(index1)
        CropTop = ocrResults.WordBoundingBoxes(index1(j),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = ocrResults.WordBoundingBoxes(index2(j),2) - 1 - round(GesamTopRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;
        end
       
        
      %Sayfada Hem Alt Hem Üst Tarafta Bölünme Olma Durumu  
      elseif (sum(index1)>0 || sum(index2) >0) && length(index1) == length(index2) && index1min < index2min && TabloBolundu==0
         
        for j=1:(length(index1)-1)
        CropTop = ocrResults.WordBoundingBoxes(index1(j),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = ocrResults.WordBoundingBoxes(index2(j+1),2) - 1 - round(GesamTopRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;      
        end
        
        % Yukarý Doðru Kýrpma
        clear BWComplement row col BWPage 
        
        CropBot = ocrResults.WordBoundingBoxes(max(index2),2) - 1 - round(GesamTopRatio*size(images{i},1));
        YukariKirp = images{i}(1:CropBot,:);
        
        lvl = graythresh(YukariKirp);
        BWPage = imbinarize(YukariKirp,lvl);
        BWComplement = ~BWPage;
        CC = bwconncomp(BWComplement);
        [~,idx1] = max(numPixels);
        [row,col] = ind2sub([size(YukariKirp,1) size(YukariKirp,2)],CC.PixelIdxList{idx1}); % Convert linear indeces to X Y
        

        CropTop = min(row);
        CropBot = ocrResults.WordBoundingBoxes(min(index2),2) - 1 - round(GesamTopRatio*(size(YukariKirp,1)/size(images{i},1)));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = YukariKirp(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;
        
        
        
        %Aþaðý Doðru Kýrpma
        if ocrResults.WordBoundingBoxes(max(index1),2) +1 + (round(NiveauBugRatio*size(images{i},1))+20) <  round(PageBotBorderRatio*size(images{i},1))
        CropTop = ocrResults.WordBoundingBoxes(max(index1),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = max(row);
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayacAB(WBSayac)=1;
        
        WBSayac = WBSayac+1;
        
        end
        TabloBolundu=1;  
          
          
      %Tablonun yarýdan aþþaðýsýnýn tek taraflý olarak alt sayfada kalma durumu 
      elseif sum(index1)>0 && length(index1) > length(index2) 
         
        if isempty(index2)==0
        for j=1:length(index2)
        CropTop = ocrResults.WordBoundingBoxes(index1(j),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = ocrResults.WordBoundingBoxes(index2(j),2) - 1 - round(GesamTopRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;
        end
        end
        
        if ocrResults.WordBoundingBoxes(max(index1),2) +1 + round(UstKirpmaToNiveauRatio*size(images{i},1)) <  round(PageBotBorderRatio*size(images{i},1))
        CropTop = ocrResults.WordBoundingBoxes(max(index1),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = max(row);
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayacAB(WBSayac)=1;
        
        WBSayac = WBSayac+1;
        
        TabloBolundu=1;
        end
        
        
      %Tablonun yarýdan yukarýsý üst sayfada kalma durumu  
      elseif sum(index2)>0 && sum(index3) > 0 && TabloBolundu==1
            
        clear BWComplement row col BWPage
        
        CropBot = ocrResults.WordBoundingBoxes(max(index2),2) - 1 - round(GesamTopRatio*size(images{i},1));
        YukariKirp = images{i}(1:CropBot,:);
        
        lvl = graythresh(YukariKirp);
        BWPage = imbinarize(YukariKirp,lvl);
        BWComplement = ~BWPage;
        CC = bwconncomp(BWComplement);
        [~,idx1] = max(numPixels);
        [row,col] = ind2sub([size(YukariKirp,1) size(YukariKirp,2)],CC.PixelIdxList{idx1}); % Convert linear indeces to X Y
        

        CropTop = ocrResults.WordBoundingBoxes(min(index1),2)+round(UstKirpmaToNiveauRatio*size(images{i},1))+1;
        CropBot = ocrResults.WordBoundingBoxes(min(index2),2) - 1 - round(GesamTopRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = YukariKirp(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;
        
        
        if length(index2)>1
        for j=1:length(index1)
        CropTop = ocrResults.WordBoundingBoxes(index1(j),2) -1 - round(NiveauRatio*size(images{i},1));
        CropBot = ocrResults.WordBoundingBoxes(index2(j+1),2) - 1 - round(GesamTopRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        WB{WBSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        WBSayac = WBSayac+1;
        
        end
        end
            
            
      end
     
end

end

WB{1} = cat(1,Warmtebalans,WB{1});

%% Rollen table
RollenSayac = 1;

Bolunmus=2;

i=SayfaSayilari(k)-1;


%%Sondan bir önceki sayfa için kontrol
lvl = graythresh(images{i});  
BWPage = imbinarize(images{i},lvl);


BWComplement = ~BWPage;
CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);
[~,idx1] = max(numPixels);

BWComplement(CC.PixelIdxList{idx1}) = 0;


CropLeft = round(ocrCropLeftRatio*size(BWComplement,2));
CropRight = round(ocrCropRightRatio*size(BWComplement,2));

ocrResults1 = ocr(BWComplement(:,CropLeft:CropRight));

Words1 = ocrResults1.Words(:,1);


%%Son sayfa için kontrol
 
i=SayfaSayilari(k);
 
lvl = graythresh(images{i});  
BWPage = imbinarize(images{i},lvl);

 
BWComplement = ~BWPage;
CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);
[biggest,idx2] = max(numPixels);

BWComplement(CC.PixelIdxList{idx2}) = 0;


CropLeft = round(ocrCropLeftRatio*size(BWComplement,2));
CropRight = round(ocrCropRightRatio*size(BWComplement,2));



ocrResults2 = ocr(BWComplement(:,CropLeft:CropRight));

Words2 = ocrResults2.Words(:,1);

indexr1 = find(cellfun('isempty',strfind(Words1,'Hen' ))==0);
indexr2 = find(cellfun('isempty',strfind(Words2,'Hen' ))==0);



 
if isempty(indexr1)==0 && (isempty(indexr1)==0 && isempty(indexr2)==0)
        Bolunmus = 1;
    else 
        Bolunmus = 0;
end


for i=SayfaSayilari(k)-1:SayfaSayilari(k)

    if (isempty(indexr1)==0 && i==SayfaSayilari(k)-1)
    
        CropTop = ocrResults1.WordBoundingBoxes(min(indexr1),2) -1 - round(HencoTopRatio*size(images{i-1},1));
        CropBot = ocrResults1.WordBoundingBoxes(max(indexr1),2) + 1 + round(HencoBotRatio*size(images{i-1},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        Rollen{RollenSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);
        
        RollenSayac = RollenSayac+1;


    elseif (Bolunmus == 1 && isempty(indexr2)==0 && i==SayfaSayilari(k))
        
        CropTop = ocrResults2.WordBoundingBoxes(min(indexr2),2) -1;
        CropBot = ocrResults2.WordBoundingBoxes(max(indexr2),2) + 1 + round(HencoBotRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        Rollen{RollenSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);


        
    elseif (Bolunmus == 0 && isempty(indexr2)==0 && i==SayfaSayilari(k))
        
        CropTop = ocrResults2.WordBoundingBoxes(min(indexr2),2) -1 - round(HencoTopRatio*size(images{i},1));
        CropBot = ocrResults2.WordBoundingBoxes(max(indexr2),2) + 1 + round(HencoBotRatio*size(images{i},1));
        CropLeft = min(col);
        CropRight = max(col);
        
        Rollen{RollenSayac} = images{i}(CropTop:CropBot,CropLeft:CropRight);


    end
    
end



%%



ExtractPath = strcat(ExtractPath,'\');


if exist('WBSayacAB','var') == 1
WBSayacAB(numel(WB)+1) = 0;
end

sayacAB = 1;

i=1;

while i <= length(WB)
    
    ImgName = strcat(file{k}(1:length(file{k})-4),'-',sprintf('WB%d',sayacAB));
    
    if exist('WBSayacAB','var') == 1
        
        if WBSayacAB(i)==1 && WBSayacAB(i+1)==0
        
        imwrite(WB{i},strcat(ExtractPath,ImgName,'a.png'));
        
        imwrite(WB{i+1},strcat(ExtractPath,ImgName,'b.png'));
        
        sayacAB = sayacAB+1;
        i = i+2;
        
        else
        
        strcat(ExtractPath,ImgName,'.png');
        
        imwrite(WB{i},strcat(ExtractPath,ImgName,'.png'));
        
        sayacAB = sayacAB+1;
        
        i = i+1;
        
        end
    
    else
    
    
    imwrite(WB{i},strcat(ExtractPath,ImgName,'.png'));

    sayacAB = sayacAB+1;
    
    i = i+1;
        
    end
end

for i = 1:length(Rollen)
    
    ImgName = strcat(file{k}(1:length(file{k})-4),'-',sprintf('Rollen%d.png',i));
    strcat(ExtractPath,ImgName);
    
imwrite(Rollen{i},strcat(ExtractPath,ImgName));   
end
 
end

end



