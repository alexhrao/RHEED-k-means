function avg = avgIntense(img, mask)
avg = mean(img(mask), 'all');
end