# for c in 'sofa' 'living-room' 'dining-room' 'bedroom' 'media-room' 'home-office' 'kitchen' 'laundry-room' 
for c in 'bed' 
do 
	mkdir $c 
	idx=0
	echo $c
	echo $idx
	while [ $idx -le 4000 ]
	do
		echo python crawl_houzz_images.py $c $idx
		for i in `python crawl_houzz_images.py $c $idx` 
		do 
			wget -P $c $i 
		done 
		idx=`expr $idx + 8`
	done
done
