const { Ollama } = require('ollama');
const fs = require('fs');
const path = require('path');

const ollama = new Ollama();
const historyPath = path.join(__dirname, 'history.json');
const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

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
            content: "You are Auseaia, a helpful AI assistant running locally via Llama3. You help with coding, analysis, and terminal tasks. Be concise and direct." 
        });
    }

    messages.push({ role: 'user', content: userInput });

    let i = 0;
    const loader = setInterval(() => {
        process.stdout.write(`\r${frames[i++ % frames.length]} Thinking...`);
    }, 80);
    
    try {
        const response = await ollama.chat({ 
            model: 'llama3', 
            messages: messages, 
            stream: true 
        });

        let reply = '';
        let firstChunk = true;
        
        for await (const part of response) {
            if (firstChunk) {
                clearInterval(loader);
                process.stdout.write('\r\x1b[K');
                firstChunk = false;
            }
            process.stdout.write(part.message.content);
            reply += part.message.content;
        }
        console.log('\n');

        messages.push({ role: 'assistant', content: reply });
        fs.writeFileSync(historyPath, JSON.stringify(messages, null, 2));

    } catch (error) {
        clearInterval(loader);
        console.error("\n❌ Error: Unable to connect to Ollama. Make sure it's running with 'ollama serve'\n");
    }
}

const input = process.argv.slice(2).join(" ");
if (input) { chat(input); }
