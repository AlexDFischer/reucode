%% constants
MAX_INTENSITY = 4095;
WINDOW_SIZE = [10 10 5];
SCORES_RADIUS = [3 3 2];
Z_SCALE_FACTOR = 2; % how much larger 1 unit in the z direction is
GHOST_WINDOW_FACTOR = 0;
STRETCH_FACTOR = 2; % the amount by which we stretch the covariance matrix in the direction of the largest eigenvector
THRESHOLD = 0.02;
%% load a subset of the volume
subset = 'cntfsmall';
if strcmp(subset, 'cntfsmall')
    addpath /home/alex/rosecrans/REU/
    offset = [180 3300];
    subset_size = [100 150];
    Vol = imgstack_3DVol('/home/alex/axondata/denoised3/z%03d.tif', 0, 20, offset, subset_size);
elseif strcmp(subset, 'largecntf')
    addpath /home/afis/REU/
    offset = [1 2500];
    subset_size = [789 1363];
    Vol = imgstack_3DVol('/home/afis/nerves/denoised3/z%03d.tif', 0, 75, offset, subset_size);
elseif strcmp(subset, 'largeinjury20x')
    addpath /home/afis/REU/
    offset = [250 200];
    subset_size = [600 1500];
    Vol = imgstack_3DVol('/home/afis/REU/20x_injury_site/20x injury site_Z%03d.tif', 0, 75, offset, subset_size);
else
    fprintf('error: subset is %s\n', subset);
    return;
end




% offset = [100 2500];
% subset_size = [520 1000];
% Vol = imgstack_3DVol('/home/alex/rosecrans/nerves/denoised3/z%03d.tif', 0, 70, offset, subset_size);

Vol=Vol/MAX_INTENSITY;
%%
% create array of coordinates, used for calculating centroid
[ycoord, xcoord, zcoord] = ndgrid(1:WINDOW_SIZE(1), 1:WINDOW_SIZE(2), 1:WINDOW_SIZE(3));
centroid_plot = zeros(size(Vol, 1) - WINDOW_SIZE(1), size(Vol, 2) - WINDOW_SIZE(2), size(Vol, 3) - WINDOW_SIZE(3));
all_eigenvalue_ratios = zeros(size(Vol, 1), size(Vol, 2), size(Vol, 3));
%all_eigenvalues =       zeros(size(Vol, 1) - WINDOW_SIZE(1), size(Vol, 2) - WINDOW_SIZE(2), size(Vol, 3) - WINDOW_SIZE(3), 3);
%all_eigenvalues(:,:,:) = 1;
scores = zeros(size(Vol));
window = zeros(WINDOW_SIZE);
covariance_mat = zeros(3, 3);
for row = 1:size(Vol,1) - WINDOW_SIZE(1) - 1
    fprintf('\ron row %03d out of %d', row, size(Vol, 1) - WINDOW_SIZE(1) - 1);
    for col = 1:size(Vol,2) - WINDOW_SIZE(2) - 1
        for z = 1:size(Vol,3) - WINDOW_SIZE(3) - 1
            window = Vol(row:row + WINDOW_SIZE(1) - 1, ...
                         col:col + WINDOW_SIZE(2) - 1, ...
                         z:z     + WINDOW_SIZE(3) - 1);
            % try subtracting away background noise
            window_mean = mean(window(:));
            window = max(0, window - window_mean);
            % compute centroid of the window
            sum_window = sum(window(:));
            if sum_window == 0
                continue;
            end
            centroidy = dot(ycoord(:), window(:)) / sum_window;
            centroidx = dot(xcoord(:), window(:)) / sum_window;
            centroidz = dot(zcoord(:), window(:)) / sum_window;
            % only count this window if the centroid is in the center of
            % the window
%             if centroidy <= GHOST_WINDOW_FACTOR * WINDOW_SIZE(1) || centroidy > (1 - GHOST_WINDOW_FACTOR) * WINDOW_SIZE(1) ...
%             || centroidx <= GHOST_WINDOW_FACTOR * WINDOW_SIZE(2) || centroidx > (1 - GHOST_WINDOW_FACTOR) * WINDOW_SIZE(2) ...
%             || centroidz <= GHOST_WINDOW_FACTOR * WINDOW_SIZE(3) || centroidz > (1 - GHOST_WINDOW_FACTOR) * WINDOW_SIZE(3)
%                 continue;
%             end
            % compute the covariance matrix
            weightedy = (ycoord(:) - centroidy);
            weightedx = (xcoord(:) - centroidx);
            weightedz = (zcoord(:) - centroidz) * Z_SCALE_FACTOR; % scale factor is to take into account that 1 unit in the z direction is larger than others
            yy = dot(weightedy.*window(:), weightedy);
            yx = dot(weightedy.*window(:), weightedx);
            yz = dot(weightedy.*window(:), weightedz);
            xy = dot(weightedx.*window(:), weightedy);
            xx = dot(weightedx.*window(:), weightedx);
            xz = dot(weightedx.*window(:), weightedz);
            zy = dot(weightedz.*window(:), weightedy);
            zx = dot(weightedz.*window(:), weightedx);
            zz = dot(weightedz.*window(:), weightedz);
            covariance_mat_orig = [yy yx yz; ...
                                   xy xx xz; ...
                                   zy zx zz];
            covariance_mat = covariance_mat_orig / sum_window;

            % determine eigenvalues and eigenvalue ratio
            [eigenvectors, eigenvalues] = eig(covariance_mat_orig);
            eigenvalues = diag(eigenvalues);
            %all_eigenvalues(row, col, z, :) = eigenvalues;
            [eigenvalue1, index1] = max(eigenvalues);
            eigenvalues(index1) = NaN;
            [eigenvalue2, index2] = max(eigenvalues);
            eigenvalues(index2) = NaN;
            [eigenvalue3, index3] = max(eigenvalues);
            eigenvalue_ratio = eigenvalue1 / eigenvalue2;

            % scale covariance matrix in direction of largest eigenvalue
            eigenvector1 = eigenvectors(:,index1);
            eigenvector2 = eigenvectors(:,index2);
            eigenvector3 = eigenvectors(:,index3);
            %covariance_mat = covariance_mat - 0.5 * eigenvalue2 * (eigenvector2 * eigenvector2.') ...
            %                                - 0.5 * eigenvalue3 * (eigenvector3 * eigenvector3.');
            %covariance_mat = covariance_mat + (STRETCH_FACTOR - 1) * eigenvalue1 * (largest_eigenvector * largest_eigenvector.');
            
            if (det(covariance_mat) < 10^-4) % if it happens to be singular
                continue
            end
            covariance_mat_inverse = covariance_mat^-1;
            covariance_mat_det_sqrt_inverse = det(covariance_mat)^-0.5;
            %all_eigenvalue_ratios(row, col, z) = eigenvalue_ratio;
            % following values are coordinates of centroid in Vol
            centroidy_ = round(row + centroidy - 1);
            centroidx_ = round(col + centroidx - 1);
            centroidz_ = round(z   + centroidz - 1);
            %all_eigenvalue_ratios(centroidy_, centroidx_, centroidz_) = max(all_eigenvalue_ratios(centroidy_, centroidx_, centroidz_), eigenvalue_ratio);

            for scores_row = max(1, centroidy_ - SCORES_RADIUS(1)):min(size(Vol, 1), centroidy_ + SCORES_RADIUS(1))
                for scores_col = max(1, centroidx_ - SCORES_RADIUS(2)):min(size(Vol, 2), centroidx_ + SCORES_RADIUS(2))
                    for scores_z = max(1, centroidz_ - SCORES_RADIUS(3)):min(size(Vol, 3), centroidz_ + SCORES_RADIUS(3))
                        diff_vector = [scores_row - centroidy_; scores_col - centroidx_; scores_z - centroidz_];
                        prod = diff_vector.' * covariance_mat_inverse * diff_vector;
                        pdf = covariance_mat_det_sqrt_inverse * exp(-0.5 * prod);
                        scores(scores_row, scores_col, scores_z) = scores(scores_row, scores_col, scores_z) + (eigenvalue_ratio - 1) * (Vol(scores_row, scores_col, scores_z)) * pdf;
                    end
                end
            end
        end
    end
end
fprintf('\n');
%%
% f1 = figure;
% f2 = figure;
%
% figure(1);
% imshow(mat2gray(Vol(:,:,13)));
%
% figure(2);
% imshow(mat2gray(scores(:,:,13)));
%% write out to vtk files
WriteToVTKGeneric(Vol, sprintf('%s_original.vtk', subset), 1);%Z_SCALE_FACTOR);
scores_normalized = scores / max(scores(:));
WriteToVTKGeneric(scores_normalized, sprintf('%s_scores_largescoreradius.vtk', subset), 1);%Z_SCALE_FACTOR);
%all_eigenvalue_ratios_normalized = double(all_eigenvalue_ratios) / max(all_eigenvalue_ratios(:));
%WriteToVTKGeneric(all_eigenvalue_ratios_normalized, sprintf('%s_evratios.vtk', subset), Z_SCALE_FACTOR);
% threshold scores
scores_threshold = scores_normalized > THRESHOLD;
WriteToVTKGeneric(scores_threshold, sprintf('%s_scoresthreshold%f.vtk', subset, THRESHOLD), 1);%Z_SCALE_FACTOR);
