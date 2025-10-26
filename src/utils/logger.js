// Simple logger utility for the app.
// Prefixes messages with timestamp and level. Keep minimal and dependency-free.
const format = (level, message, meta) => {
  const ts = new Date().toISOString();
  let out = `[${ts}] [${level.toUpperCase()}] ${message}`;
  if (meta !== undefined) {
    try {
      out += ` | ${typeof meta === 'string' ? meta : JSON.stringify(meta)}`;
    } catch (e) {
      out += ` | [unserializable meta]`;
    }
  }
  return out;
};

const info = (message, meta) => console.info(format('info', message, meta));
const warn = (message, meta) => console.warn(format('warn', message, meta));
const error = (message, meta) => console.error(format('error', message, meta));
const debug = (message, meta) => console.debug(format('debug', message, meta));

const logger = {
  info,
  warn,
  error,
  debug,
};

export default logger;
