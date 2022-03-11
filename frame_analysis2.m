clear;

load 'DenmarkOpen2021_KentoMomota_Viktor Axelsen_F.mat';

vid_src = "E:/Google Drives/Personal Drive/00 Princeton/Spring 2022/"+...
    "SML310/Final Project/DataFiles/DenmarkOpen2021_KentoMomota_Viktor Axelsen_F.mp4";
vid = VideoReader(vid_src);

% Plot histograms
edges = [0:255];
r_counts = histcounts(stats.avgPixel(:,1), edges);
g_counts = histcounts(stats.avgPixel(:,2), edges);
b_counts = histcounts(stats.avgPixel(:,3), edges);
bins = edges(1:end-1);
figure(1)
clf;
h1 = bar(bins, r_counts, 1);
hold on;
h2 = bar(bins, g_counts, 1);
h3 = bar(bins, b_counts, 1);
hold off;
h1.LineStyle = 'none';
h2.LineStyle = 'none';
h3.LineStyle = 'none';
h1.FaceColor = 'r';
h2.FaceColor = 'g';
h3.FaceColor = 'b';
h1.FaceAlpha = 0.4;
h2.FaceAlpha = 0.4;
h3.FaceAlpha = 0.4;

t_std = 4;

r_pk = bins(r_counts == max(r_counts));
g_pk = bins(g_counts == max(g_counts));
b_pk = bins(b_counts == max(b_counts));

sel1 = [stats.avgPixel(:,1) > r_pk - t_std & stats.avgPixel(:,1) < r_pk + t_std];
sel2 = [stats.avgPixel(:,2) > g_pk - t_std & stats.avgPixel(:,2) < g_pk + t_std];
sel3 = [stats.avgPixel(:,3) > b_pk - t_std & stats.avgPixel(:,3) < b_pk + t_std];
sel = [sel1 & sel2 & sel3];

se_radius = 25;
se = strel("disk",se_radius);
sel_open = imerode(sel, se);
sel_open = imdilate(sel_open, se);

figure(2)
clf;
plot(stats.avgPixel(:,1), 'r');
hold on;
plot(stats.avgPixel(:,2), 'g');
plot(stats.avgPixel(:,3), 'b');
plot(sel*255,'k');
plot(sel_open*255,'y','LineWidth',1);
hold off;

CC = bwconncomp(sel_open);

temp_r = 0;
num_rallies = 114;
while(CC.NumObjects > num_rallies)
    temp_r = temp_r + 1;
    se = strel("disk",temp_r);
    sel_closed = imdilate(sel_open, se);
    sel_closed = imerode(sel_closed, se);
    CC = bwconncomp(sel_closed);
    fprintf('SE radius: %i\tNumber of rallies detected: %i\n', temp_r, CC.NumObjects);
end

figure(3)
clf;
for i = 1:CC.NumObjects
    frame_num = round(mean(CC.PixelIdxList{i}));
    img = vid.read(frame_num);
    nexttile;
    imshow(img);
    title(i);
    xlim([584.9850  764.5029])
    ylim([40.6680  141.6468])
end

%%
mkdir('rally_videos/')

parfor i = 1:CC.NumObjects
    start_frame = CC.PixelIdxList{i}(1);
    end_frame = CC.PixelIdxList{i}(end);
    
    temp_vid = VideoReader(vid_src);
    
    vidObj = VideoWriter(sprintf('rally_videos/rally_%i.mp4', i),'MPEG-4');
    vidObj.FrameRate = 29.97;
    open(vidObj);
    
    img = temp_vid.read(start_frame - 1);
    for frame_num = start_frame:end_frame
        img = temp_vid.readFrame();
        writeVideo(vidObj,img);
    end
    
    close(vidObj);
end






