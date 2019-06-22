ocAdmin='admin'
ocPassword='password'
alamedaNamespace='alameda'
caseName='alameda-0622-1-tomcat'
alameExecutor='component=alameda-executor'
alamedaRecommender='component=alameda-alameda-recommender'
appNanespace='tomcat'
appDeployconfig='app=tomcat'
appApiversion='apps.openshift.io/v1'
maxReplicas=100
cpuPercent=80
memPercent=50
cpuLimit=200
appType="deploymentconfig"
memoryLimit=128
trafficRatio=20
warmUp=2
pictureXaxis=144
pictureYratio=1.5


##############################################
##                                          ##
##    Set up define.py                      ##
##                                          ##
##############################################
sleepTime=$[warmUp*60-10]
app=${appDeployconfig#*=}
rm -f define.pyc
cat <<EOF > define.py
openshift_login_username = "$ocAdmin"
openshift_login_password = "$ocPassword"
app_namespace = "$appNanespace"
app_name = "$app"
app_type = "$appType"
cpu_limit = $cpuLimit # mCore
memory_limit = $memoryLimit # MB
traffic_ratio = $trafficRatio
warm_up = $warmUp
picture_x_axis = $pictureXaxis
picture_y_ratio = $pictureYratio
EOF