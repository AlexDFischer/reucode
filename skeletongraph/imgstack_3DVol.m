function Vol = imgstack_3DVol(fname, image_num1, image_num2, offset, subset_size)

%     A = double(imread(sprintf(fname, 0)));
    
    Vol = zeros(subset_size(1), subset_size(2), image_num2 - image_num1 + 1);
    %% loops through the image stack
    for z = image_num1:image_num2
        
        %% for each index in the image stack we need to create the file name
        A = double(imread(sprintf(fname, z)));
%         if (z < 10)
%             %% read in the image file
%             A = double(imread([path fname '00' num2str(z) '.tif']));
%         elseif ( z < 100)
%             A = double(imread([path fname '0' num2str(z) '.tif']));
%         else
%             A = double(imread([path fname '' num2str(z) '.tif']));
%         end
        
        Vol(:, :, z - image_num1 + 1) = A(offset(1):offset(1) + subset_size(1) - 1, offset(2):offset(2) + subset_size(2) - 1);
        fprintf('\rdone with slice %03d', z);
    end
    fprintf('\n');
return
