import os, json, requests, urllib.parse

# by default the redirect uri is used as the last element in 
# redirect uri's in client_credentials

# forming authentication url
def getAuthUrl(CREDENTIALS, SCOPES):

    scopes = "+".join(SCOPES)

    auth_params = {
        "redirect_uri": CREDENTIALS['redirect_uri'][-1],
        "prompt": "consent",
        "response_type": "code",
        "client_id": CREDENTIALS['client_id'],
        "access_type": "offline",
        "scope": scopes,
    }

    auth_url = CREDENTIALS["auth_uri"] + "?" + urllib.parse.urlencode(auth_params, quote_via=urllib.parse.quote)

    return auth_url

# getting auth code
def getAuthCode(url):
    queries = urllib.parse.urlparse(url).query
    queries = dict(urllib.parse.parse_qsl(queries))
    return queries['code']

# exchanging auth code for access token
def getToken(auth_code, CREDENTIALS):

    token_header = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    token_params = {
        "client_id": CREDENTIALS['client_id'],
        "client_secret": CREDENTIALS['client_secret'],
        "code": auth_code,
        "grant_type": "authorization_code",
        "redirect_uri": CREDENTIALS['redirect_uri'][-1]
    }

    token = requests.post(CREDENTIALS['token_uri'], data=token_params, headers=token_header).json()

    return token

# refreshing access token
def refreshToken(refresh_token, CREDENTIALS):
    
    token_header = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    token_params = {
        "client_id": CREDENTIALS['client_id'],
        "client_secret": CREDENTIALS["client_secret"],
        "refresh_token": refresh_token,
        "grant_type": "refresh_token",
    }

    token = requests.post(CREDENTIALS['token_uri'], data=token_params, headers=token_header).json()

    return token