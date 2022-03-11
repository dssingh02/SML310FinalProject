clear;

vid = VideoReader('rally_videos\rally_2.mp4');

num_train_frames = 300;
detector = vision.ForegroundDetector(...
    'NumTrainingFrames', num_train_frames, ...
    'InitialVariance', 30*30);

blob = vision.BlobAnalysis(...
    'CentroidOutputPort', false, 'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', true, ...
    'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 250);

shapeInserter = vision.ShapeInserter('BorderColor','White');

% training
train_frame_idx = round(linspace(1,vid.NumFrames,num_train_frames));
img = vid.read(1);
bg_sum = zeros(size(img));
bg_count = zeros(size(img));
bg_average = zeros(size(img));
for i = train_frame_idx
    frame = vid.read(i);
    fg_mask = detector(frame);
    %     figure(1)
    %     subplot(2,2,1)
    %     imshow(frame)
    %     subplot(2,2,2)
    %     imshow(fg_mask)
    %     subplot(2,2,3)
    %     imshow(uint8(bg_average))
    
    fprintf('training frame: %i of %i\n', i, vid.NumFrames);
    
    bg_mask = ~fg_mask;
    bg_mask = cat(3, bg_mask, bg_mask, bg_mask);
    bg_sum(bg_mask) = bg_sum(bg_mask) + double(frame(bg_mask));
    bg_count(bg_mask) = bg_count(bg_mask) + 1;
    
    sel = bg_count > 0;
    bg_average(sel) = bg_sum(sel)./bg_count(sel);
end

figure(1)
clf;
imshow(uint8(bg_average))

%%
% subtracting background
videoPlayer = vision.VideoPlayer();
vid.read(1);
se1 = strel('disk', 20);
se2 = strel('disk', 5);
se3 = strel('disk', 50);
while hasFrame(vid)
     frame  = readFrame(vid);
     frame = double(frame);
     img_diff = abs(frame - bg_average);
     img_diff = mean(img_diff,3);
     sel = img_diff>50;
     sel = imclose(sel, se1);
     sel = imerode(sel, se2);
     sel = imdilate(sel, se3);
     sel3 = cat(3, sel, sel, sel);
     frame(~sel3) = 0;
     videoPlayer(uint8(frame));
     pause(0.1);
end

release(videoPlayer);


%%

detector = peopleDetectorACF;

vid.read(1);
videoPlayer = vision.VideoPlayer();
while hasFrame(vid)
    I = vid.readFrame();
    [bboxes,scores] = detect(detector,I);
    
    [scores, idx] = sort(-scores);
    bboxes = bboxes(idx,:);
    
    bboxes = bboxes(1:2,:);
    scores = -scores(1:2);
    
    I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
    videoPlayer(I);
%     figure(1)
%     clf;
%     imshow(I)
%     title('Detected People and Detection Scores')
end
release(videoPlayer);




