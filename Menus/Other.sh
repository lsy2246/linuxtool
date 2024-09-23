declare path_script=$1
declare file_name=$(basename $0)
echo "========Other========"
declare print_number=0
declare -a print_arr
declare pick
for i in "${path_script}/Config/${file_name}"/* ; do
  print_number=$(( print_number+1 ))
  print_arr[$print_number]=$(basename $i)
  echo "${print_number}.${i}"
done
echo "输入其他任意返回主页"
echo "========Other========"
read -p "请输入：" pick

if [[ $pick =~ [1-$print_number] ]]; then
    bash "${path_script}/Config/${file_name}/${print_arr[$pick]}.sh"
fi