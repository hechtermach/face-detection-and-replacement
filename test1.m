% Read in image
filename = 'img/clip1.mp4';
videoFileReader = vision.VideoFileReader(filename);
videoFrame      = step(videoFileReader);
imageA = videoFrame;

% Detect face
[faceA, oldBbox] = detect_face_with_user_input(imageA);
[ faceA, newBbox ] = expand_face(videoFrame, oldBbox);
width = newBbox(3);
height = newBbox(4);

% Set up replacement library of faces
[ replacementFaces, rX, rY, rHulls, rFeatures ] = set_up_replacement_library(width, height);

v = VideoWriter('output_video','MPEG-4');
open(v);

i = 1;

oldBbox = newBbox;
while ~isDone(videoFileReader)
%for k = 1:15
    % get the next frame
    videoFrame = step(videoFileReader);
    disp(strcat('Frame ',num2str(i)));
    i = i + 1;
    
    % Detect new bounding box for face within ROI REGION OF INTEREST
    roi_x1 = oldBbox(1) - 30;
    roi_y1 = oldBbox(2) - 30;
    roi_x2 = oldBbox(1) + oldBbox(3) + 30;
    roi_y2 = oldBbox(2) + oldBbox(4) + 30;
    actual_region = videoFrame(roi_y1:roi_y2, roi_x1:roi_x2);
    [ newFace, newBbox ]= detect_face(actual_region);
    % remember these are offset, let's undo the offset
    newBbox = [roi_x1 + newBbox(1), roi_y1 + newBbox(2), newBbox(3), newBbox(4)];
    % expand newFace and newBox
    [ currentFace, newBbox ] = expand_face(videoFrame, newBbox);
    
    %% REPLACE DA FACE
    % Extract face from image
    x1 = newBbox(1);
    x2 = newBbox(3);
    y1 = newBbox(2);
    y2 = newBbox(4);
    %currentFace = videoFrame(y1:(y1+y2), x1:(x1+x2),:);
    blendedFace = replace_face(currentFace, replacementFaces, rX, rY, rHulls, rFeatures);
    videoFrame(y1:(y1+y2), x1:(x1+x2),:) = blendedFace;

    % Draw the returned bounding box around the detected face.
    % videoFrame = insertShape(videoFrame, 'Rectangle', newBbox);
    
    writeVideo(v,videoFrame);
    oldBbox = newBbox;

end
 
% Clean up
release(videoFileReader);

close(v);

