source ./0_settings.sh
app=${appDeployconfig#*=}
# enable executor
echo ' '
 echo '# enable executor'
oc -n $alamedaNamespace get configmap alameda-executor-config -o yaml | sed '/resourceVersion/d' | sed 's/enable: false/enable: true/' - |oc apply -f -
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-executor -o name`