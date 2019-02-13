import http from "k6/http"
import { getEnvironmentHost, getEnvironmentPort, randomCodec, randomProgramEpg } from './lib/utils.js'

const host = getEnvironmentHost();
const port = getEnvironmentPort();

function sendRequest() {
    const requestUrl = `http://${host}:${port}/btv/catchup/${randomCodec()}/${randomProgramEpg()}`;
    const response = http.get(requestUrl);
    return response;
}

// To run test install k6 and simply run its file with appropriate options from the root project folder
// k6 run --vus 300 --rps 200 --duration 300s load_testing/test_catchup.js
// Where:
// --rps - requests per second number. By specification it must be at most 5000
// --duration - could be any. Must specify measure - minutes(m) seconds(s). For example 5s, 120s, 1m, 1m30s
// --vus - users count. Basically does not matter. But should be more than 5 because in that
// case number of requests per second must be closer to specified in --rps number

export default function() {
    sendRequest();
    return true;
}
