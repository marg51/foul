#!/bin/bash

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

../mapping_user.sh
../mapping_session.sh
../mapping_error.sh
../mapping_acquisition.sh
../mapping_event.sh
../mapping_route.sh
../mapping_timing.sh
../mapping_device.sh

token="key_private_40186f96-ec3b-46d7-ba61-374dd7bccbbe2707d1b0-f28a-11e4-a7e0-f3137f432671"

x="curl http://localhost:9200"

cookie=$(curl -i 'http://localhost/foul/create-session' -H 'Cookie: foulLastErrorUID=AUzbnOm5iK_-ftvT9JT1; foulLastRouteUID=AUzcZlOziK_-ftvT9JVY,foulLastErrorUID=AUzcZlOziK_-ftvT9JVa; foulDeviceUID=device_c35fdf3a-6b71-4531-a8ea-1f052219a497; foulDeviceUI=device_c35fdf3a-6b71-4531-a8ea-1f052219a497; foulSessionUID=session_3070e2b5-f193-46a5-a27d-0cda66c69320; _ga=GA1.1.1988261901.1421946404; _hp2_id.3355741622=4787467213289859.3654090576.3384308703; ajs_anonymous_id=%222772a212-e560-49c4-8ef7-245fd8f75adc%22; ajs_group_id=null; ajs_user_id=7; mp_adb00fa2108839dd75903222cb2ccfda_mixpanel=%7B%22distinct_id%22%3A%207%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22laurent%40tailster.com%22%2C%22UserStatusID%22%3A%203%2C%22IsProfessional%22%3A%20false%2C%22Badges%22%3A%20%22%22%2C%22id%22%3A%207%2C%22%24email%22%3A%20%22laurent%40tailster.com%22%2C%22%24first_name%22%3A%20%22Laurent%22%2C%22%24last_name%22%3A%20%22M%22%2C%22%24name%22%3A%20%22Laurent%20M%22%2C%22Mob%22%3A%20%2298765449%22%2C%22utm_source%22%3A%20%22facebook%22%2C%22utm_medium%22%3A%20%22InviteBox%22%2C%22utm_campaign%22%3A%20%22Campaign%20%231%3A%20Goal-based%20rewards%22%7D; _hp2_id.442105264=1031140033701898.1358007772.3610642698' -H 'Origin: http://localhost' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' -H 'Cache-Control: max-age=0' -H 'Referer: http://localhost/dev/foul-tracker/examples/' -H 'Connection: keep-alive' --data-binary '{"app":{"name":"FoulExample","version":"0.0.3","env":"local","hash":"0.0.3","features":{"name":"button","acquisition":true}}}' --compressed -s | grep "Set-Cookie: foulSessionUID=" | sed "s/^.*=\(.*\)/\1/")


for i in `seq 6 10`
do
    $x/foul/user/user_$i -XPUT -d"{\"signup\": $(node -e "console.log(Date.now())"), \"user\": {\"id\":$i, \"username\":\"utopik\", \"token\": 123}}"
done

echo -e "\n"

coffee bulk.json.coffee 7 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
coffee bulk.json.coffee 8 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
coffee bulk.json.coffee 6 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
sudo date $(date -v+1d -v+1M "+%m%d%H%M%Y")
coffee bulk.json.coffee 7 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
coffee bulk.json.coffee 7 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
coffee bulk.json.coffee 6 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed
sudo date $(date -v+1d -v+1M "+%m%d%H%M%Y")
coffee bulk.json.coffee 7 | curl 'http://localhost:3003/foul/bulk' -H "Cookie: foulSessionUID=$cookie" -H 'Origin: http://localhost:3003' -H 'Accept-Encoding: gzip, deflate' -H "X-Foul-Token: $token" -H 'Accept-Language: en-US,en;q=0.8,fr;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2376.0 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept: application/json, text/plain, */*' --data-binary '@-' --compressed

sudo ntpdate -u $(sudo systemsetup -getnetworktimeserver|awk '{print $4}')

if [ "$(coffee cohort.coffee  | jq '.value.buckets[].value.buckets[].value.buckets | length')" == "3
2
1
0
0
0
0" ]; then echo -e ${green}"############## ok #######";else echo -e ${red}"############## fail #######\ncoffee cohort.coffee  | jq '.value.buckets[].value.buckets[].value.buckets | length"; fi
