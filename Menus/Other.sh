declare path_script=$1
declare file_name=$(basename $0 .sh)
echo "========Other========"
declare print_number=0
declare -a print_arr
declare pick
for i in "${path_script}/Config/${file_name}"/* ; do
  print_number=$(( print_number+1 ))
  print_arr[$print_number]=$(basename $i .sh)
  echo "${print_number}.${print_arr[$print_number]}"
done
echo "输入其他任意返回主页"
echo "========Other========"
read -p "请输入：" pick

if [[ $pick =~ [1-$print_number] ]]; then
    bash "${path_script}/Config/${file_name}/${print_arr[$pick]}.sh"
fi