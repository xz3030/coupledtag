%function paper_resize_image()
% compose a bigger image of first 5 images.
ind = [1 2 4 8 12 13];
%ind=1;
coupled_config;
sizeD = [240,320];
text1 = {'CP','mat'};
Nims = 4;

for tt=1:2
    for cc = ind
        cc
        result_all_path = sprintf('%s/%d_%s',cp.result_path,cc,text1{tt});
        for cn = 1:5
            bigI = ones(240,330*Nims-10,3);
            tmp=0;
            ind1 = 0;
            while tmp<Nims && ind1<10
                ind1 = ind1+1;
                im = sprintf('%s/%d_%d_%d.jpg',result_all_path,cc,cn,ind1);
                I = imread(im);
                w = size(I,1);
                h = size(I,2);
                %if w>=h
                %    continue;
                %end
                I1=imresize(I, sizeD);
                I1 = im2double(I1);
                bigI(:,330*tmp+1:330*tmp+320,:)=I1;
                tmp = tmp+1;
            end
            
            %imshow(bigI,[])
            outFName = sprintf('%s/%d_all_4.jpg',result_all_path,cn);
            imwrite(bigI,outFName);
        end
    end
end

%end
