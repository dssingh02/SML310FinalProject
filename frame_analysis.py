import cv2
import numpy as np
import matplotlib.pyplot as plt

video_src = "E:/Google Drives/Personal Drive/00 Princeton/Spring 2022/SML310/Final Project/DataFiles/DenmarkOpen2021_KentoMomota_Viktor Axelsen_F.mp4"

vidObj = cv2.VideoCapture(video_src)

# Used as counter variable
count = 0

# checks whether frames were extracted
success = 1

while success:

    # vidObj object calls read
    # function extract frames
    success, image = vidObj.read()

    count += 1
    print(count)

    if count % 1000 == 0:
        plt.imshow(image)

