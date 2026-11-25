import { loadConfig, getStatus } from './config.js';
import { createAgentServer } from './http_server.js';

const config = loadConfig();
const server = createAgentServer(config);
server.listen(config.port, '127.0.0.1', () => {
  console.log(`Agents SDK bridge: http://127.0.0.1:${config.port}`);
  console.log(getStatus(config).message);
});

for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.once(signal, () => {
    server.close(() => process.exit(0));
    server.closeIdleConnections();
  });
}
