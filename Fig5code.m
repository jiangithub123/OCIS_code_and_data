% Codes for processing Fig. 5.
load('Fig5results.mat'); % data frame stack. Each frame captures the whole speckle pattern when OCIS system sends one bit of information. 
load('img_dark.mat'); % dark frame
darkmean = mean(img_dark,3);
%%
img_cap = double(img_cap);
for ii=1:size(img_cap,3)
    img_cap(:,:,ii) = img_cap(:,:,ii)-darkmean; % remove the dark value
end
%% reshape the 2D image into a vector
img = imread('smileyface.tif');
xsize = 40;
ysize = 40;
newim = imresize(img,[xsize,ysize]);
num_pixel = numel(newim); % number of pixels in the image
img = newim>(200);
data2send = reshape(img,[1,size(img,1)*size(img,2)]); % convert image to a vector (by column)
%% permute the elements in the vector
rng(100);
data_0 = find(data2send<0.5);
randidx0 = randperm(length(data_0));
data_0perm = data_0(randidx0);
data_1 = find(data2send>0.5);
randidx1 = randperm(length(data_1));
data_1perm = data_1(randidx1);

randorder=zeros(1,length(data2send));
for ii = 1:length(data_0)
    randorder(data_0(ii)) = data_0perm(ii);
end
for ii = 1:length(data_1)
    randorder(data_1(ii)) = data_1perm(ii);
end  

img_reorder = reshape(data2send(randorder),[size(img,1),size(img,2)]);
%% target location
pixel_x = 274; % location of the target
pixel_y = 257;
ave_size = 10; % use ave_size pixels to average the signal
rec_img = zeros(xsize,ysize); % an empty array to save the sent bit information 
for idx = 1:num_pixel
    rec_img( mod(idx-1,ysize)+1, floor((idx-1)/ysize)+1 ) = ...
        mean2(img_cap(pixel_x:pixel_x+ave_size,pixel_y:pixel_y+ave_size,idx));
end

img_reorder_tgt = reshape(rec_img(randorder),[size(img,1),size(img,2)]); % reshape the permutated vector back to normal order
figure,imagesc(img_reorder_tgt), title('Target location'), colorbar; axis off equal;



%% the other location
pixel_x = 250; % location of the neighbor
pixel_y = 270;
ave_size = 10; % use ave_size pixels to average the signal
rec_img = zeros(xsize,ysize); % an empty array to save the sent bit information 
for idx = 1:num_pixel
    rec_img( mod(idx-1,ysize)+1, floor((idx-1)/ysize)+1 ) = ...
        mean2(img_cap(pixel_x:pixel_x+ave_size,pixel_y:pixel_y+ave_size,idx));
end


img_reorder_oth = reshape(rec_img(randorder),[size(img,1),size(img,2)]); % reshape the permutated vector back to normal order
figure,imagesc(img_reorder_oth), title('Neighbor location'), colorbar; axis off equal;

%% thresholding
threshold = 4.27;
img_tgt_bi = (img_reorder_tgt)>threshold;
img_oth_bi = (img_reorder_oth)>threshold;
figure,imagesc(img_tgt_bi),  title('Target location - binarized'), colorbar; axis off equal;
figure,imagesc(img_oth_bi), title('Neighbor location - binarized'), colorbar; axis off equal;


