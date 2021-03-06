function Main()
% Setup Image Acquisition
hCamera = webcam;

hShow1 = imshow(zeros(480,640));title('Gesture Recognition');
frames = 30;

for i = 1:frames

% Acquire an image from the webcam
    vid_img = snapshot(hCamera);

% Call the live segmentation function
    [skin,bin] = generate_skinmap(vid_img);
    img=imfill(bin,'holes'); 
    img_final=bwareaopen(img,300);
    set(hShow1,'CData',img_final);
    drawnow;
end
%  Update the imshow handle with a new image 
    se=strel('square',70);
    ae=imerode(img_final,se);
    ad=imdilate(ae,se);
    BW0=imsubtract(img_final,ad);
    se2=strel('square',40);
    ae2=imerode(BW0,se2);
    ad2=imdilate(ae2,se2);
    BW1=imsubtract(BW0,ad2);
    BW=bwareaopen(BW1,1300);
    %BW=imfill(BW1,'holes');
    figure,imshow(BW);
    st = regionprops(BW, 'ALL');
    fprintf(1,'Area #    Area\n');
    count=0;
    for k = 1 : length(st)
        thisBB = st(k).BoundingBox;
        hold on
        rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        'EdgeColor','r','LineWidth',1 );
        hold off
        fprintf(1,'#%2d %16.1f\n',k,st(k).MajorAxisLength);
        if(st(k).MajorAxisLength>100&&st(k).MajorAxisLength<230)
            count=count+1;
        end
    end

    %Sort the areas
    allAreas = [st.Area];
    [sortedAreas, sortingIndexes] = sort(allAreas, 'descend');

    %Count the areas and label them on the binary image
    for k = 1 : length(st)
       centerX = st(sortingIndexes(k)).Centroid(1);
       centerY = st(sortingIndexes(k)).Centroid(2);
       text(centerX,centerY,num2str(k),'Color', 'b', 'FontSize', 14)
    end


    %Now we can detect what is on the picture
    if sortingIndexes > 0
        if count >= 5
            title('FIVE');
        elseif count==4
            title('FOUR');
        elseif count==3
            title('THREE');
        elseif count==2
            title('TWO');
        elseif count==1
            title('ONE');
        elseif count==1
            title('ZERO');
        end
    else
        title('ZERO');
    end
    pause(0.01);
%end
delete(hCamera);