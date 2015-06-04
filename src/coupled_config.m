% configuration file for coupled object interaction
cp.classInd=1;
% mode: '':normal, 'cs':cold start, 'dp':discard popular tags of each user
cp.mode = '';

% standard (0) or contextual (1) coupled similarity
cp.plus = 1;

cp.main_dir = '.';
cp.img_main_dir = fullfile(cp.main_dir, '../data/images/');
cp.figure_dir = sprintf(fullfile(cp.main_dir, '../figure%s/'),cp.mode);
categs = dir(cp.img_main_dir);
categ = categs(3:end);
cp.classname = cell(0);
for i=1:length(categ)
    cp.classname{i} = categ(i).name;
end

cp.result_path = fullfile(cp.main_dir, '../result');
cp.feature_path = fullfile(cp.main_dir, '../data/Loaded_feature/%s.mat');
cp.dict_path = fullfile(cp.main_dir, '../data/dictionary/dict_%s_%s.mat');
%cp.sim_file_path = ['../data/coupled_sim_bkg' cp.mode];
cp.sim_file_path = fullfile(cp.main_dir, ['../data/coupled_sim_' cp.mode]);
cp.tag_result_path = '%s/%s/tag_result.mat';
canSkip = 1;

cp.feature_names = {'cms','colorhist','LBP','SIFT_BOW'};
% tag, user, cms, ...
cp.feature_weight = [0.5 0.2 0.075 0.075 0.075 0.075];
%cp.feature_weight = [0.5 0.5 0.25 0.25 0.25 0.25];
cp.nnnum = 10;
cp.Ntimes = 6;   %1-5 for cold start, 6 for clustering
cp.trainRate = 0.8;    % 0.8
cp.minTagFreq = 5;   % 5
cp.maxSimImage = 0.95;
cp.minTagperImg = 2;
cp.nRecTag = 10;

cp.Ncluster = 5;
cp.Nmode = 10;

cp.friend_coefficient = 0.5;

cp.cs_user_rate = 0.3;
cp.cs_start_num = 2;   % num of tag when cold start
cp.evaluate_include_cs = 0;   % if 1, when evaluating, include the initial tags
