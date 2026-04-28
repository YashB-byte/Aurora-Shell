const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const https = require('https');
const { execSync } = require('child_process');

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const CLIENT_ID = '1fec8e78-bce4-4aaf-ab1b-5451cc387264';
const TENANT = 'common';
const SCOPES = 'https://graph.microsoft.com/Chat.ReadWrite https://graph.microsoft.com/Team.ReadBasic.All https://graph.microsoft.com/User.Read offline_access';
const TOKEN_FILE = path.join(require('os').homedir(), '.aurora-shell_files', 'teams-token.json');

async function post(url, body) {
    const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(body).toString()
    });
    return res.json();
}

async function getToken() {
    // Try cached token
    if (fs.existsSync(TOKEN_FILE)) {
        const cached = JSON.parse(fs.readFileSync(TOKEN_FILE, 'utf8'));
        if (cached.expires_at > Date.now()) return cached.access_token;
        // Refresh
        if (cached.refresh_token) {
            const data = await post(`https://login.microsoftonline.com/${TENANT}/oauth2/v2.0/token`, {
                client_id: CLIENT_ID,
                grant_type: 'refresh_token',
                refresh_token: cached.refresh_token,
                scope: SCOPES
            });
            if (data.access_token) {
                saveToken(data);
                return data.access_token;
            }
        }
    }
    return null;
}

function saveToken(data) {
    fs.mkdirSync(path.dirname(TOKEN_FILE), { recursive: true });
    fs.writeFileSync(TOKEN_FILE, JSON.stringify({
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at: Date.now() + (data.expires_in * 1000)
    }));
}

async function login() {
    // Step 1: Get device code
    const deviceData = await post(`https://login.microsoftonline.com/${TENANT}/oauth2/v2.0/devicecode`, {
        client_id: CLIENT_ID,
        scope: SCOPES
    });

    if (!deviceData.user_code) {
        throw new Error('Failed to get device code: ' + JSON.stringify(deviceData));
    }

    console.log(chalk.cyan('\n🔐 Teams Login'));
    console.log(chalk.white(`Go to: ${chalk.bold('https://microsoft.com/devicelogin')}`));
    console.log(chalk.white(`Enter code: ${chalk.bold.yellow(deviceData.user_code)}`));
    console.log(chalk.gray('Waiting for authentication...\n'));
    try { execSync(`open "https://microsoft.com/devicelogin"`); } catch(e) {}

    // Step 2: Poll for token
    const interval = (deviceData.interval || 5) * 1000;
    while (true) {
        await new Promise(r => setTimeout(r, interval));
        const tokenData = await post(`https://login.microsoftonline.com/${TENANT}/oauth2/v2.0/token`, {
            client_id: CLIENT_ID,
            grant_type: 'urn:ietf:params:oauth:grant-type:device_code',
            device_code: deviceData.device_code
        });
        if (tokenData.access_token) {
            saveToken(tokenData);
            return tokenData.access_token;
        }
        if (tokenData.error === 'authorization_declined' || tokenData.error === 'expired_token') {
            throw new Error(tokenData.error);
        }
        // authorization_pending - keep polling
    }
}

async function ensureToken() {
    const token = await getToken();
    if (token) return token;
    return login();
}

async function logout() {
    if (fs.existsSync(TOKEN_FILE)) {
        fs.unlinkSync(TOKEN_FILE);
        console.log(chalk.green('✅ Logged out'));
    } else {
        console.log(chalk.yellow('Not logged in'));
    }
}

async function whoami() {
    const token = await ensureToken();
    const res = await fetch('https://graph.microsoft.com/v1.0/me', {
        headers: { Authorization: `Bearer ${token}` }
    });
    return res.json();
}

module.exports = { ensureToken, login, logout, whoami };
