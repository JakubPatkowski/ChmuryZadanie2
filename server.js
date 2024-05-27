const http = require('http');
const os = require('os');
const fs = require('fs');
// Dane 
const author = "Jakub Patkowski"
const PORT = 8080
const APIKEY = fs.readFileSync('./APIKEY.txt', 'utf8').trim();


// Logowanie informacji o uruchomieniu serweraa
const logServerStart = () => {
    const startDate = new Date();
    console.log(`Serwer uruchomiony: ${startDate}`);
    console.log(`Autor: ${author}`);
    console.log(`Port: ${PORT}`);
};

// Funkcja wysyłająca zapytanie do api
// zwracająca obiekt Date z lokalnym czasem klienta
async function getDate(){ 
    const response = await fetch(
        `https://api-bdc.net/data/timezone-by-ip?ip=${clientIp}&key=${APIKEY}`)
    const data = await response.json();
    const timeZone = data.ianaTimeId;
    return new Date().toLocaleString("en", {timeZone: timeZone}) + " " + timeZone;
}

const server = http.createServer(async (req, res) => {
    clientIp = req.socket.remoteAddress;
    clientDate = new Date;
    //jeżeli ip z localhost to nie wysyłaj żądania do api
    if (clientIp == "::1" || clientIp=="::ffff:172.17.0.1") { 
        clientDate = new Date;
    } else {
        clientDate = await getDate();
    }
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.write(`Adres IP klienta: ${clientIp}\n Data i godzina: ${clientDate}\n`);
    res.end();
});

server.listen(PORT, () => {
    logServerStart();
});