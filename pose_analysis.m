clear;

vid_src = "rally_videos/rally_1.mp4";
vid = VideoReader(vid_src);

idx = round(vid.NumFrames/3);
img = vid.read(idx);

figure(1)
clf;
imshow(img);

dataDir = fullfile(tempdir,'OpenPose');
trainedOpenPoseNet_url = 'https://ssd.mathworks.com/supportfiles/vision/data/human-pose-estimation.zip';
downloadTrainedOpenPoseNet(trainedOpenPoseNet_url,dataDir)

unzip(fullfile(dataDir,'human-pose-estimation.zip'),dataDir);

modelfile = fullfile(dataDir,'human-pose-estimation.onnx');
layers = importONNXLayers(modelfile,"ImportWeights",true);

% layers = removeLayers(layers,layers.OutputNames);
placeholder_output_layers = findPlaceholderLayers(layers);
for i = 1:length(placeholder_output_layers)
    layers = removeLayers(layers, placeholder_output_layers(i).Name);
end
net = dlnetwork(layers);

%%
% img = vid.read(500);
img = imread('test_pose.jpg');
% for i = 1:30:vid.NumFrames
%     img = vid.read(i);
    netInput = im2single(img)-0.5;
    netInput = netInput(:,:,[3 2 1]);
    netInput = dlarray(netInput,"SSC");
    [heatmaps,pafs] = predict(net,netInput);
    
    heatmaps = extractdata(heatmaps);
    % montage(rescale(heatmaps),"BackgroundColor","b","BorderSize",3)
    idx = 1;
    hmap = heatmaps(:,:,idx);
    hmap = imresize(hmap,size(img,[1 2]));
    % imshowpair(hmap,img);
    
    heatmaps = heatmaps(:,:,1:end-1);
    pafs = extractdata(pafs);
    % montage(rescale(pafs),"Size",[19 2],"BackgroundColor","b","BorderSize",3)
    
    % idx = 1;
    % impair = horzcat(img,img);
    % pafpair = horzcat(pafs(:,:,2*idx-1),pafs(:,:,2*idx));
    % pafpair = imresize(pafpair,size(impair,[1 2]));
    % imshowpair(pafpair,impair);
    
    params = getBodyPoseParameters;
    poses = getBodyPoses(heatmaps,pafs,params);
    figure(1)
    renderBodyPoses(img,poses,size(heatmaps,1),size(heatmaps,2),params);
% end




