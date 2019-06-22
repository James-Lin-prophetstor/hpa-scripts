# Shell Script test Array: test=(<caseName1> <caseName2>)
# alameda: alameda-<date>-
# k8s HPA: k8shpa-<cpuRate>-<date>-
# base line: nonhpa-<date>-
# For Example, run 4 cases: test=(alameda-0620-1 k8shpa-80-0620-1 k8shpa-80-0620-2 nonhpa-0620-1)
test=(alameda-0622-2 k8shpa-80-0622-2 k8shpa-80-0622-3 k8shpa-80-0622-4)

config='0_settings.sh'
for (( i=0;i<${#test[@]};i++ )) ; do
  sed -i "/caseName=/d" $config
  sed -i "3a caseName=${test[$i]}" $config
  source ./0_settings.sh
  echo $caseName

  c=${caseName%%-*}
  case $c in
    k8shpa)
        Percentage=`echo $caseName | awk -F- '{print $2}'`
        case $Percentage in
          50|80)
            echo " "
            echo " "
            echo "Start k8shpa test with $Percentage % CPU"
            echo " "
            echo " "
            sed -i "/cpuPercent/d" $config
            sed -i "9a cpuPercent=$Percentage" $config
            sh 4_start_k8s_hpa.sh
          ;;
          *)
            echo "please use case name as 'k8shpa-50-<date>-<other words>'"
            echo "or k8shpa-80-<date>-<other words>'"
            exit
        esac
    ;;
    alameda)
      echo " "
      echo "Start Alameda HPA test"
      sh 0_start_alameda_test.sh
    ;;
    nonhpa)
      echo " "
      echo "Start Base Line test without HPA."
      sh 6_start_nonhpa.sh
    ;;
    *)
      echo "please use 'alameda-', 'k8shpa-50-' or 'nonhpa-' as prifix test name."
      exit
  esac

done