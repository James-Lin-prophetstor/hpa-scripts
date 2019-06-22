source ./0_settings.sh
# login oc
echo '# login oc'
oc login -u $ocAdmin -p $ocPassword > /dev/null
app=${appDeployconfig#*=}

# disable executor
echo ' '
echo '# disable executor'
oc -n $alamedaNamespace get configmap alameda-executor-config -o yaml | sed '/resourceVersion/d' | sed 's/enable: true/enable: false/' - |oc apply -f -
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-recommender -o name` &
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-executor -o name`

# reset app replicas
echo ' '
echo '# reset app replicas'
oc -n $appNanespace scale dc $app --replicas=0
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Termina' | wc -l` -eq 0 ]
do
    sleep 1
done
sleep 1
oc -n $appNanespace scale dc $app --replicas=10
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Running' | wc -l` -eq 10 ]
do
    sleep 1
done
sleep 1

# start write log and data generator
echo ' '
echo '# start write log and data generator'
python write_log.py $caseName 100 &
python generate_traffic1.py 72 &

# enable alameda executor
echo ' '
echo "# enable alameda executor"
sleep $sleepTime
oc -n $alamedaNamespace get configmap alameda-executor-config -o yaml | sed '/resourceVersion/d' | sed 's/enable: false/enable: true/' - |oc apply -f -
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-executor -o name`

while ( ps -aux | grep python | grep generate_traffic1.py >/dev/null 2>&1 ) ; do
  echo "================== "
  echo "RUNNING"
  echo "================== "
  sleep 300
done
cp -r traffic traffic-$caseName
rm -rf traffic/*

while ( ps -aux | grep python | grep write_log.py >/dev/null 2>&1 ) ; do
  echo "================== "
  echo "RUNNING"
  echo "================== "
  sleep 60
done
sh 1_stop_alameda_hpa_executor.sh