const http = require('http');

const nBytes = parseInt(process.env.NBYTES, 10);
const validNBytes = !isNaN(nBytes) && nBytes > 0;

let randomData = "  ";
if (validNBytes) {
    console.log(`Assigning ${nBytes} to buffer`);
    // Assign the buffer to the variable in the outer scope
    randomData = Buffer.alloc(nBytes);
    for (let i = 0; i < nBytes; i++) {
        randomData[i] = Math.floor(Math.random() * 256);
    }
}

const handler = function (request, response) {
    console.log(`Received request for ${request.url} from ${request.connection.remoteAddress} is validByes ${validNBytes}`);

    const path = request.url.length > 1 && request.url.endsWith('/')
        ? request.url.slice(0, -1)
        : request.url;

    if (path === '/data' && validNBytes) {
        response.writeHead(200, {
            // Note: Content-Type for random bytes is typically application/octet-stream
            'Content-Type': 'application/octet-stream',
            'Content-Length': randomData.length
        });
        response.end(randomData);
        return;
    }

    // Default response for all other cases
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('Server is running. Set NBytes and call /data for a random payload.');
};

const www = http.createServer(handler);
www.listen(8080, () => {
    console.log('Server listening on port 8080...');
    if (validNBytes) {
        console.log(`Configuration: NBytes is set to ${nBytes}.`);
    } else {
        console.log('Configuration: NBytes is not set or is invalid.');
    }
});