
#pact-mock-service stop

ps -ef | grep pact-mock-service | grep -v grep | awk '{print $2}' | xargs kill