function I1=tool_resize_image(I, maxW, maxH)
% resize image to maximum width of w, and maximum height of h
w = size(I,1);
h = size(I,2);

ratiow = maxW/w;
ratioh = maxH/h;
if ratiow<ratioh
    ratio = ratiow;
else
    ratio = ratioh;
end

I1=imresize(I,ratio);
end