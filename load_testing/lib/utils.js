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
