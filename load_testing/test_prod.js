import http from "k6/http"
import { randomArrayElement, randomVodPath } from './lib/utils.js'

const port = 80;

const host = 'cdn.beetv.kz';
// In case you want to test servers themselves
// const serverHosts = [
//     '10.15.2.20',
//     '10.15.2.25',
// ]

function getHost() {
    return  host
    // In case you want to test servers themselves
    // return randomArrayElement(serverHosts)
}

const allowed_channel_epgs = [
    '000000025',
    'short_000000202',
    '000000202',
    '000000213',
    '000000022',
    '000000021',
    '000000198',
    '000000296'
]
function randomChannelEpg() {
    return randomArrayElement(allowed_channel_epgs)
}

const allowed_program_epgs = [
    '297190605151500',
    '120190605150500',
    '402190605144500',
    '297190606073500',
    '297190606105500',
    '297190606060500'
]
function randomProgramEpg() {
    return randomArrayElement(allowed_program_epgs)
}

function sendVodRequest() {
    const requestUrl = `http://${getHost()}:${port}/vod/${randomVodPath()}`;
    const response = http.get(requestUrl);
    return response;
}

const allowed_channel_codecs = ['hls', 'mpd']
function randomCodec() {
    return randomArrayElement(allowed_channel_codecs)
}
function sendLiveRequest() {
    const requestUrl = `http://${getHost()}:${port}/btv/live/${randomCodec()}/${randomChannelEpg()}`;
    const response = http.get(requestUrl);
    return response;
}

function sendCatchupRequest() {
    const requestUrl = `http://${getHost()}:${port}/btv/catchup/mpd/${randomProgramEpg()}`;
    const response = http.get(requestUrl);
    return response;
}

const requests = [sendLiveRequest, sendCatchupRequest, sendVodRequest];

function sendRequest() {
    const requestFunction = randomArrayElement(requests);
    return requestFunction()
}

// To run test install k6 and simply run its file with appropriate options from the root project folder
// k6 run --vus 300 --rps 200 --duration 300s load_testing/test_requests.js
// Where:
// --rps - requests per second number. By specification it must be at most 5000
// --duration - could be any. Must specify measure - minutes(m) seconds(s). For example 5s, 120s, 1m, 1m30s
// --vus - users count. Basically does not matter. But should be more than 5 because in that
// case number of requests per second must be closer to specified in --rps number

export default function() {
    sendRequest();
    return true;
}
