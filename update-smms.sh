#!/bin/bash

#img-1.txt: 所有上傳的照片
#img-2.txt: 剩餘上傳的照片
#img-3.txt: 即時上傳的照片
#img-4.txt: 即時 ERROR

linn="#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------# ERROR"
wd="/home/qexo-hexo/source"
#pd="/root/shell-script/SVN_WEB_UPDATE/svnconfig/config-hexo/source/image"
pd="/home/qexo-hexo/source/image"
#comd="/root/shell-script/SVN_WEB_UPDATE/svnconfig/config-hexo/source/_posts"
comd="/home/qexo-hexo/source/_posts"

#cd /root/shell-script/SVN_WEB_UPDATE/svnconfig/config-hexo/source

cd $wd
echo -e "\n"
echo -ne "\e[34;1m是否上傳圖片:\e[0m (y/n):  "
read -e answer
echo -e "\n"
tpc=`ls -l $pd/|wc -l`

if [ "$answer" == "y" ] || [ "$answer" == "Y" ]
then
	#ls -l $pd/ |awk '{print $9}' > img-1.txt  #將圖片name 寫進去file
	echo -e "共 \e[34;1m$tpc\e[0m 張圖片上傳至 SM.MS"
	echo -e "\n"
	echo -ne "\e[34;1m要從第幾行圖片開始上傳:\e[0m Answer:  "
	read -e Answer

	sleep 1
	cat "img-1.txt" |head -n 597 |tail -n +${Answer} > img-2.txt  # 剩下沒上傳的圖片
	#exit 1
	pice=`cat "img-2.txt" |wc -l`
	timm1=`date +%Y-%m-%d.%H:%M:%S`
	echo -e "$linn - $timm1 - START" >> img-3.txt  # 即時上傳的紀錄
	
	for u in $(seq 1 $pice);
	do

		i=`cat "img-2.txt" |sed -n ${u}p`
		#echo $i
		#exit 1

		#cd /root/shell-script/SVN_WEB_UPDATE/svnconfig/config-hexo/source
		cd $wd
		./smpost.sh $pd/$i > img.tmp
		code3="$?"
		#echo $i >> img.tmp
		sleep 2

		#imgf=`echo $i |cut -d "/" -f 9`
		code1=`cat "img.tmp" |grep -E "Upload file frequency limit|No such file or directory"|wc -l`

		if [[ "$code1" == "0" ]]
		then
			imgh=`cat img.tmp |awk '{print $4}'|sed 's/\[//g' |sed 's/\]//g'`
			#echo "$img"

			imd=`echo $i |rev |cut -d "-" -f 2-50 |rev`
			#echo "$imd"

			imdc=`echo "$imd" |rev |cut -d "-" -f 1|grep "[0-9]" |wc -l`
			imdc2=`echo "$imd" |rev |cut -c 4`

			if [[ "$imdc" != "0" ]] && [[ "$imdc2" == "-" ]]
			then
				imd=`echo $imd |rev |cut -d "-" -f 2-50|rev`
			fi

			sleep 1
			sed -i "s#/image/${i}#${imgh}##g" $comd/${imd}.md
			code2="$?"

				if [[ "$code2" == "0" ]]
				then
					echo "" >> img-2.txt
					echo "已將 /image/${i} 替換為 ${imgh} - ${imd}.md" >> img-3.txt

					tp=`ls -l $pd/|grep -n "$u" |awk '{print $1}'|cut -d ":" -f 1`
					tpc=`cat "img-1.txt" |grep -n ${i}|cut -d ":" -f 1`
					echo "總共有 ${pice} 個  -  目前正在更換第 ${u} 個 - $i - 編號第 img-1.txt: ${tpc} 行"

					sleep 0.1
					#sed -i "/${i}/d" img-2.txt
				else
					tpc=`cat "img-1.txt" |grep -n ${i}|cut -d ":" -f 1`
					timm2=`date +%Y-%m-%d.%H:%M:%S`
					echo -e "\n"
					echo -e "$linn - $timm2 - STOP" >> img-3.txt
					echo -e "imd: ${imd}.md - ERROR - 請查看是否有這支檔案" > img-4.txt  # 即時上傳錯誤
					echo -e "\n" >> img-4.txt
					echo -e "sed: -i error s#/image/${i}#${imgh}##g" >> img-4.txt
					echo -e "上傳到 SM.MS 出錯了 - 目前上傳到第 ${tpc} 行: ${i}" >> img-3.txt
					echo -e "\e[35;1m上傳到 SM.MS 出錯了 目前上傳到第 ${tpc} 行: ${i} \e[0m"
					echo -e "\n"
					echo -e "\e[35;1m下次請從第 ${tpc} 行: ${i} 開始 \e[0m"
					echo -e "\n"
					exit 1
				fi
		else
			tpc=`cat "img-1.txt" |grep -n ${i}|cut -d ":" -f 1`
			timm=`date -d "1 hours" +%H:%M`
			echo -e "\n"
			echo -e "$linn" >> img-3.txt
			echo -e "上傳到 SM.MS 出錯了 目前上傳到第 ${tpc} 行: ${i}" >> img-3.txt
			echo -e "\e[35;1m上傳到 SM.MS 出錯了 目前上傳到第 ${tpc} 行: ${i} \e[0m"
			echo -e "\n"
			echo -e "\e[35;1m下次請從第 ${tpc} 行: ${i} 開始 \e[0m"
			echo -e "\n"
			echo -e "\e[35;1m若出現 You can only upload 100 images per hour 請於1小時候再開始上傳 - "$timm" \e[0m"
			echo -e "\n"
			cat img.tmp 
			exit 1
		fi
	done
else
	exit 1
fi

