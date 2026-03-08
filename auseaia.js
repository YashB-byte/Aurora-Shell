const { Ollama } = require('ollama');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const ollama = new Ollama();
const historyPath = path.join(__dirname, 'history.json');

let messages = [];
if (fs.existsSync(historyPath)) {
    try { messages = JSON.parse(fs.readFileSync(historyPath, 'utf-8')); } catch (e) { messages = []; }
}

async function chat(userInput) {
    if (userInput === '/reset') {
        fs.writeFileSync(historyPath, JSON.stringify([]));
        console.log("\n✨ Conversation history cleared.\n");
        return;
    }

    if (messages.length === 0) {
        messages.push({ 
            role: 'system', 
            content: "You are Auseaia, a helpful AI assistant running locally via Llama3. You help with coding, analysis, and terminal tasks. Be concise and direct. If asked to execute commands, provide the command but explain what it does." 
        });
    }

    messages.push({ role: 'user', content: userInput });

    try {
        const response = await ollama.chat({ 
            model: 'llama3', 
            messages: messages, 
            stream: true 
        });

        let reply = '';
        for await (const part of response) {
            process.stdout.write(part.message.content);
            reply += part.message.content;
        }
        console.log('\n');

        messages.push({ role: 'assistant', content: reply });
        fs.writeFileSync(historyPath, JSON.stringify(messages, null, 2));

    } catch (error) {
        console.error("\n❌ Error: Unable to connect to Ollama. Make sure it's running.\n");
    }
}

const input = process.argv.slice(2).join(" ");
if (input) { chat(input); }
