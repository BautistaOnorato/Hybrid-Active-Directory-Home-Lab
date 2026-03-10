var params = JSON.parse(value);

var client_id = params.client_id;
var client_secret = params.client_secret;
var tenant_id = params.tenant_id;
var from_address = params.from_address;
var to = params.to;
var subject = params.subject;
var message = params.message;

if (!to || to === '{ALERT.SENDTO}') {
    throw 'Recipient address is empty or not resolved.';
}

var tokenRequest = new HttpRequest();
tokenRequest.addHeader('Content-Type: application/x-www-form-urlencoded');

var tokenBody = 'client_id=' + encodeURIComponent(client_id) +
    '&client_secret=' + encodeURIComponent(client_secret) +
    '&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default' +
    '&grant_type=client_credentials';

var tokenResponse = tokenRequest.post(
    'https://login.microsoftonline.com/' + tenant_id + '/oauth2/v2.0/token',
    tokenBody
);

var tokenData = JSON.parse(tokenResponse);
var token = tokenData.access_token;

if (!token) {
    throw 'Failed to obtain access token. Response: ' + tokenResponse;
}

var mailRequest = new HttpRequest();
mailRequest.addHeader('Content-Type: application/json');
mailRequest.addHeader('Authorization: Bearer ' + token);

var mailBody = JSON.stringify({
    message: {
        subject: subject,
        body: {
            contentType: 'Text',
            content: message
        },
        toRecipients: [{
            emailAddress: {
                address: to
            }
        }]
    }
});

var mailResponse = mailRequest.post(
    'https://graph.microsoft.com/v1.0/users/' + from_address + '/sendMail',
    mailBody
);

return mailResponse ? mailResponse : 'OK';