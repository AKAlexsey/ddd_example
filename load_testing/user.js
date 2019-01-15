import http from "k6/http"
import { getEnvironmentHost, getEnvironmentPort, getRandomNumber } from './lib/utils.js'
// TODO удалил каналы в рамках ликвидации технического долга
const host = getEnvironmentHost();
const port = getEnvironmentPort();

function randomChannel() {
    return `channel${getRandomNumber(711)}`;
}

function sendRequest() {
    const channel = randomChannel();
    const requestUrl = `http://${host}:${port}/get_channel?channel=${channel}`;
    const response = http.get(requestUrl);
    return response;
}

// To run test install k6 and simply run its file with appropriate options
// k6 run --rps 5000 --duration 5s --vus 10 user.js
// Where:
// --rps - requests per second number. By specification it must be at most 5000
// --duration - could be any. Must specify measure - minutes(m) seconds(s). For example 5s, 120s, 1m, 1m30s
// --vus - users count. Basically does not matter. But should be more than 5 because in that
// case number of requests per second must be closer to specified in --rps number

export default function() {
    sendRequest();
    return true;
}
