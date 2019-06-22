source ./0_settings.sh
app=${appDeployconfig#*=}
# login oc
echo " "
echo '# login oc'
oc login -u $ocAdmin -p $ocPassword > /dev/null

# disable executor
echo " "
 echo '# disable executor'
oc -n $alamedaNamespace get configmap alameda-executor-config -o yaml | sed '/resourceVersion/d' | sed 's/enable: true/enable: false/' - |oc apply -f -
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-recommender -o name` &
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-executor -o name`

# stop k8s HPA
echo " "
echo '# stop k8s HPA'
oc -n $appNanespace delete hpa $appDeployconfig

# reset app replicas
echo " "
echo '# reset app replicas'
oc -n $appNanespace scale dc $app --replicas=0
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Termina' | wc -l` -eq 0 ]
do
    sleep 1
done
sleep 1
oc -n $appNanespace scale dc $app --replicas=15
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Running' | wc -l` -eq 15 ]
do
    sleep 2
done
sleep 1

# start write log and data generator
echo " "
echo '# start write log and data generator'
python write_log.py $caseName 100 &
python generate_traffic1.py 72 &

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