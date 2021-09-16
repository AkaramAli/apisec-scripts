!/bin/bash
# Begin

FX_USER=$1
FX_PWD=$2
FX_JOBID=$3
REGION=$4
FX_ENVID=$5
FX_PROJECTID=$6

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' https://developer.apisec.ai/login | jq -r .token)

echo "generated token is:" $token

runId=$(curl --location --request POST "https://developer.apisec.ai/api/v1/runs/job/${FX_JOBID}?region=${REGION}&env=${FX_ENVID}&projectId=${FX_PROJECTID}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')

echo "runId =" $runId
if [ -z "$runId" ]
then
          echo "RunId = " "$runId"
          echo "Invalid runid"
          echo $(curl --location --request POST "https://developer.apisec.ai/api/v1/runs/job/${FX_JOBID}?region=${REGION}&env=${FX_ENVID}&projectId=${FX_PROJECTID}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
          exit 1
fi


taskStatus="WAITING"
echo "taskStatus = " $taskStatus



while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
         do
                sleep 5
                 echo "Checking Status...."

                passPercent=$(curl --location --request GET "https://developer.apisec.ai/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

                        IFS=':' read -r -a array <<< "$passPercent"

                        taskStatus="${array[0]}"

                        echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"



                if [ "$taskStatus" == "COMPLETED" ];then
            echo "------------------------------------------------"
                       # echo  "Run detail link https://developer.apisec.ai/${array[7]}"
                        echo  "Run detail link https://developer.apisec.ai${array[7]}"
                        echo "-----------------------------------------------"
                        echo "Job run successfully completed"
                        exit 0

                fi
        done

if [ "$taskStatus" == "TIMEOUT" ];then
echo "Task Status = " $taskStatus
 exit 1
fi

echo "$(curl --location --request GET "https://developer.apisec.ai/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
exit 1

return 0
