#!/bin/sh


export APP_HOME=..


export JVM_ARGS=" "
export CLASSPATH="$APP_HOME/lib/wf-cdr-processor.jar"
for i in `ls $APP_HOME/lib/dependency/*.jar`; do
	CLASSPATH=$i:$CLASSPATH
done


echo "***********************************************************************************"
echo "java $JVM_ARGS -classpath $CLASSPATH -jar wf-cdr-processor.jar"
echo "***********************************************************************************"

java $JVM_ARGS -cp "$CLASSPATH" com.imi.workflow.cdr.processor.WorkflowCDRProcessor $APP_HOME/config/workflow-cdr-processor.properties &
