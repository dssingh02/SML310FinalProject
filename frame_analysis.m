clear;

vid_src = "E:/Google Drives/Personal Drive/00 Princeton/Spring 2022/"+...
    "SML310/Final Project/DataFiles/DenmarkOpen2021_KentoMomota_Viktor Axelsen_F.mp4";
vid = VideoReader(vid_src);

n = vid.NumberOfFrames;

avgPixel = zeros(n,3);
stdPixel = zeros(n,3);
avgDiff = zeros(n,3);
stdDiff = zeros(n,3);

tic
t = 0;
for i = 1:n
    img2 = double(vid.readFrame);
    r = img2(:,:,1);
    g = img2(:,:,2);
    b = img2(:,:,3);
    
    avgPixel(i,:) = [mean(r(:)), mean(g(:)), mean(b(:))];
    stdPixel(i,:) = [std(r(:)), std(g(:)), std(b(:))];
    
    if (i > 1)
        diff_img = img2 - img1;
        diff_r = diff_img(:,:,1);
        diff_g = diff_img(:,:,2);
        diff_b = diff_img(:,:,3);
        
        avgDiff(i,:) = [mean(diff_r(:)), mean(diff_g(:)), mean(diff_b(:))];
        stdDiff(i,:) = [std(diff_r(:)), std(diff_g(:)), std(diff_b(:))];
    end
    img1 = img2;
    
    if (mod(i,100) == 0)
        t = t + toc;
        fprintf('Finished up to frame %i in %.2f seconds\n', i, t);
        tic;
    end
end

stats.avgPixel = avgPixel;
stats.stdPixel = stdPixel;
stats.avgDiff = avgDiff;
stats.stdDiff = stdDiff;

save(vid.Name(1:end-4),'stats')

