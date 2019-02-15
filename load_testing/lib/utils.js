const PROTOCOLS = ['hls', 'mpd', 'mpd_wv', 'mpd_pr']
const LOREM_WORDS = [
    'quas',
    'fuga',
    'consequuntur',
    'perferendis',
    'aut',
    'consequatur',
    'alias',
    'est',
    'voluptates',
    'ipsum'
]

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

export function randomArrayElement(array) {
    return array[getRandomNumber(array.length)]
}

export function randomCodec() {
    return randomArrayElement(PROTOCOLS)
}

export function randomLoremWord() {
    return randomArrayElement(LOREM_WORDS)
}

export function randomEpg(maxNumber) {
    return `epg_${getRandomNumber(maxNumber)}`;
}

export function randomProgramEpg(maxNumber) {
    return `p_epg_${getRandomNumber(maxNumber)}`;
}

export function randomVodPath() {
    return `${randomLoremWord()}/${randomLoremWord()}/${randomLoremWord()}`;
}
