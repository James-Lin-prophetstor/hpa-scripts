source ./0_settings.sh
app=${appDeployconfig#*=}
# login oc
echo ' '
echo '# login oc'
oc login -u $ocAdmin -p $ocPassword > /dev/null

# stop k8s HPA
echo ' '
echo '# stop k8s HPA'
oc -n $appNanespace delete hpa $app


# reset app replicas
echo ' '
echo '# reset app replicas'
oc -n $appNanespace scale dc $app --replicas=0
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Termina' | wc -l` -eq 0 ]
do
    sleep 2
done
sleep 2
oc -n $appNanespace scale dc $app --replicas=10
until [ `oc -n $appNanespace get pod  -l $appDeployconfig | grep 'Running' | wc -l` -eq 10 ]
do
    sleep 2
done