for c in 'sofa' 'living-room' 'dining-room' 'bedroom' 'media-room' 'home-office' 'kitchen' 'laundry-room'; 
do mkdir $c; 
for i in `python crawl_houzz_images.py $c`; 
do wget -P $c $i; 
done; 
done
