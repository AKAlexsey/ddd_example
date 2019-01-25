const PROTOCOLS = ['hls', 'mpd', 'mpd_wv', 'mpd_pr']

export function getEnvironmentHost() {
    const host = __ENV.HOST;
    return (host ? host : 'localhost');
}

export function getEnvironmentPort() {
    const port = __ENV.PORT;
    return (port ? port : 4001);
}

export function getRandomNumber(maxNumber) {
    return Math.floor(Math.random() * maxNumber);
}

export function randomCodec() {
    return PROTOCOLS[getRandomNumber(PROTOCOLS.length)]
}

export function randomEpg() {
    return `epg_${getRandomNumber(249)}`;
}
