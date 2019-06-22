source ./0_settings.sh
app=${appDeployconfig#*=}

# disable executor
echo ' '
 echo '# disable executor'
oc -n $alamedaNamespace get configmap alameda-executor-config -o yaml | sed '/resourceVersion/d' | sed 's/enable: true/enable: false/' - |oc apply -f -
oc -n $alamedaNamespace delete `oc -n $alamedaNamespace get pod -l component=alameda-executor -o name`