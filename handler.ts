const randomBytes = require('crypto').randomBytes;

const fleet = [
    {
        Name: 'Bucephalus',
        Color: 'Golden',
        Gender: 'Male',
    },
    {
        Name: 'Shadowfax',
        Color: 'White',
        Gender: 'Male',
    },
    {
        Name: 'Rocinante',
        Color: 'Yellow',
        Gender: 'Female',
    },
];

exports.RequestUnicorn = function (body: string, Username: string): string {
    const rideId = toUrlString(randomBytes(16));
    const requestBody = JSON.parse(body);
    // console.log("file::::: ",requestBody)
    const pickupLocation = requestBody.PickupLocation;
    let unicorn = findUnicorn(pickupLocation);
    let RequestTime = new Date().toISOString();
    return JSON.stringify({ RideId: rideId, Rider: Username,RequestTime: RequestTime, unicorn: unicorn});
};


function findUnicorn(pickupLocation) {
    console.log('Finding unicorn for ', pickupLocation.Latitude, ', ', pickupLocation.Longitude);
    return fleet[Math.floor(Math.random() * fleet.length)];
}

function toUrlString(buffer) {
    return buffer.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}


// function errorResponse(errorMessage, awsRequestId, callback) {
//   callback(null, {
//     statusCode: 500,
//     body: JSON.stringify({
//       Error: errorMessage,
//       Reference: awsRequestId,
//     }),
//     headers: {
//       'Access-Control-Allow-Origin': '*',
//     },
//   });
// }