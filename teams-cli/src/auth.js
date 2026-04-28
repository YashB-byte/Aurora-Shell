const { PublicClientApplication, InteractionRequiredAuthError } = require('@azure/msal-node');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

// Fix SSL cert issue
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const CLIENT_ID = '1fec8e78-bce4-4aaf-ab1b-5451cc387264'; // Microsoft Teams mobile/desktop
const SCOPES = ['https://graph.microsoft.com/Chat.ReadWrite', 'https://graph.microsoft.com/ChannelMessage.Send', 'https://graph.microsoft.com/Team.ReadBasic.All', 'https://graph.microsoft.com/Presence.ReadWrite', 'https://graph.microsoft.com/Calendars.ReadWrite', 'offline_access', 'https://graph.microsoft.com/User.Read'];
const TOKEN_FILE = path.join(require('os').homedir(), '.aurora-shell_files', 'teams-token.json');

const msalConfig = {
    auth: {
        clientId: CLIENT_ID,
        authority: 'https://login.microsoftonline.com/common'
    },
    cache: {
        cachePlugin: {
            beforeCacheAccess: async (ctx) => {
                if (fs.existsSync(TOKEN_FILE)) {
                    ctx.tokenCache.deserialize(fs.readFileSync(TOKEN_FILE, 'utf8'));
                }
            },
            afterCacheAccess: async (ctx) => {
                if (ctx.cacheHasChanged) {
                    fs.mkdirSync(path.dirname(TOKEN_FILE), { recursive: true });
                    fs.writeFileSync(TOKEN_FILE, ctx.tokenCache.serialize());
                }
            }
        }
    }
};

const pca = new PublicClientApplication(msalConfig);

async function getToken() {
    // Try silent first
    const accounts = await pca.getAllAccounts();
    if (accounts.length > 0) {
        try {
            const result = await pca.acquireTokenSilent({ scopes: SCOPES, account: accounts[0] });
            return result.accessToken;
        } catch (e) {
            if (!(e instanceof InteractionRequiredAuthError)) throw e;
        }
    }

    // Device code flow
    const result = await pca.acquireTokenByDeviceCode({
        scopes: SCOPES,
        deviceCodeCallback: (response) => {
            console.log(chalk.cyan('\n🔐 Teams Login'));
            console.log(chalk.white(`Go to: ${chalk.bold(response.verificationUri)}`));
            console.log(chalk.white(`Enter code: ${chalk.bold.yellow(response.userCode)}`));
            console.log(chalk.gray('Waiting for authentication...\n'));
            // Auto-open browser
            const { execSync } = require('child_process');
            try { execSync(`open "https://microsoft.com/devicelogin"`); } catch(e) {}
        }
    });
    return result.accessToken;
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
    const token = await getToken();
    const res = await fetch('https://graph.microsoft.com/v1.0/me', {
        headers: { Authorization: `Bearer ${token}` }
    });
    return res.json();
}

module.exports = { getToken, logout, whoami };
