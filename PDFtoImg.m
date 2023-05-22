function [imgs] = PDFtoImg(file,path)

import org.apache.pdfbox.*
import java.io.*



if isa(file,'cell')==1
nF = length(file);
elseif isa(file,'char')==1
nF=1;
a=file;
clear file
file{1}=a;
end

for i=1:nF

if isa(file,'cell')==1
filename = strcat(path,file{i});

jFile = File(filename);
document = pdmodel.PDDocument.load(jFile);
pdfRenderer = rendering.PDFRenderer(document);
count = document.getNumberOfPages();
images = [];
    for j = 1:count
        bim = pdfRenderer.renderImageWithDPI(j-1, 200, rendering.ImageType.RGB);
        images = [images (filename + "-" +"Page" + j + ".png")];
        tools.imageio.ImageIOUtil.writeImage(bim, filename + "-" +"Page" + j + ".png", 200);
        imgs{i,j} = imread(strcat(path,file{i},sprintf('-Page%d.png',j)));
        delete(strcat(path,file{i},sprintf('-Page%d.png',j)));
    end


elseif isa(file,'char')==1
filename = strcat(path,file);

jFile = File(filename);
document = pdmodel.PDDocument.load(jFile);
pdfRenderer = rendering.PDFRenderer(document);
count = document.getNumberOfPages();
images = [];
    for j = 1:count
        bim = pdfRenderer.renderImageWithDPI(j-1, 200, rendering.ImageType.RGB);
        images = [images (filename + "-" +"Page" + j + ".png")];
        tools.imageio.ImageIOUtil.writeImage(bim, filename + "-" +"Page" + j + ".png", 200);
        imgs{i,j} = imread(strcat(path,file{i},sprintf('-Page%d.png',j)));
        delete(strcat(path,file{i},sprintf('-Page%d.png',j)));
    end
end



end
fclose('all');
end





