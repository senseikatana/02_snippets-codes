/**
 * Password Generator Utility & Service (TypeScript Version)
 * 
 * Generates passwords of various types:
 *   - matricula/license: 4 digits + 3 consonants (e.g. 1234BCD), vowels are excluded to avoid offensive words.
 *   - secure: alphanumeric + safe special characters (ensures at least one of each: upper, lower, digit, symbol).
 *   - alphanumeric: lowercase + uppercase + digits (ensures at least one of each).
 *   - numeric: digits only.
 *   - memorable/xkcd: random dictionary words joined by hyphens.
 * 
 * Modes:
 *   - CLI: On-demand generation via command line arguments.
 *   - HTTP Daemon: Runs as a service (e.g., for systemd) to serve passwords over HTTP.
 */

import * as crypto from 'crypto';
import * as fs from 'fs';
import * as http from 'http';
import * as path from 'path';
import * as url from 'url';

export type PasswordType = 'matricula' | 'secure' | 'alphanumeric' | 'numeric' | 'memorable';

// Common words fallback for memorable passwords (Spanish and English mixed)
const FALLBACK_WORDS: string[] = [
  // Spanish
  "agua", "arbol", "arena", "barco", "brisa", "cielo", "cueva", "disco", "duna", "fuego",
  "gato", "globo", "hoja", "humo", "isla", "lago", "lluvia", "luna", "mapa", "monte",
  "nieve", "nube", "onda", "papel", "piedra", "pino", "pluma", "rayo", "rio", "roca",
  "selva", "sol", "suelo", "tierra", "torre", "viento", "vuelo", "valle", "verde", "vida",
  "azul", "rojo", "claro", "oscuro", "fuerte", "suave", "rapido", "lento", "alto", "bajo",
  // English
  "acid", "apex", "atom", "bark", "beam", "bolt", "brisk", "calm", "clay", "coal",
  "dawn", "deep", "dusk", "echo", "fade", "flow", "flux", "glen", "glow", "halo",
  "haze", "iron", "jade", "lava", "leaf", "lime", "mist", "neon", "nova", "opal",
  "path", "pure", "rain", "reef", "rift", "rust", "sand", "shadow", "silk", "silt",
  "snow", "star", "surf", "tide", "vale", "vast", "wave", "wild", "wind", "zinc"
];

/**
 * Tries to load words from system dictionary paths, falls back to hardcoded words if not found.
 * Filters for clean, short alphabetic words (length 4-8, lowercase).
 */
export function getWordsList(): string[] {
  const dictionaryPaths = ['/usr/share/dict/words', '/etc/dictionaries-common/words', '/usr/dict/words'];
  
  for (const dictPath of dictionaryPaths) {
    if (fs.existsSync(dictPath)) {
      try {
        const data = fs.readFileSync(dictPath, 'utf8');
        const words = data
          .split('\n')
          .map(w => w.trim())
          .filter(w => /^[a-z]{4,8}$/.test(w));
        
        if (words.length > 0) {
          return words;
        }
      } catch (err) {
        // Suppress and try next path
      }
    }
  }
  return FALLBACK_WORDS;
}

/**
 * Returns a cryptographically secure random element from the given array.
 */
function randomChoice<T>(arr: T[]): T {
  const randIndex = crypto.randomInt(0, arr.length);
  return arr[randIndex];
}

/**
 * Returns K cryptographically secure random elements (with replacement) from the given array.
 */
function randomChoices<T>(arr: T[], k: number): T[] {
  const result: T[] = [];
  for (let i = 0; i < k; i++) {
    result.push(randomChoice(arr));
  }
  return result;
}

/**
 * Returns K cryptographically secure random elements (without replacement) from the given array.
 * If the array has fewer elements than K, it falls back to choices with replacement.
 */
function randomSample<T>(arr: T[], k: number): T[] {
  if (arr.length < k) {
    return randomChoices(arr, k);
  }
  const pool = [...arr];
  const result: T[] = [];
  for (let i = 0; i < k; i++) {
    const randIndex = crypto.randomInt(0, pool.length);
    result.push(pool.splice(randIndex, 1)[0]);
  }
  return result;
}

/**
 * Generates a password based on type, length, and block quantity.
 * 
 * @param pwType Type of the password: 'matricula', 'secure', 'alphanumeric', 'numeric', 'memorable'
 * @param length Length of the password (for secure, alphanumeric, numeric; defaults to 16)
 * @param qty Number of blocks/words (for matricula, memorable; defaults to 1 for matricula, 4 for memorable)
 * @returns The generated password string.
 */
export function generatePassword(pwType: PasswordType, length: number = 16, qty: number = 1): string {
  const digits = "0123456789".split("");
  const lowercase = "abcdefghijklmnopqrstuvwxyz".split("");
  const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

  if (pwType === "matricula") {
    const generated = new Set<string>();
    const results: string[] = [];
    const consonants = "BCDFGHJKLMNPQRSTVWXYZ".split("");

    while (results.length < qty) {
      const numPart = randomChoices(digits, 4).join("");
      const letPart = randomChoices(consonants, 3).join("");
      const plate = `${numPart}${letPart}`;
      if (!generated.has(plate)) {
        generated.add(plate);
        results.push(plate);
      }
    }
    return results.join("-");
  }

  if (pwType === "secure") {
    // Safe punctuation set to avoid shell escapes / SQL injection issues
    const symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?".split("");
    const allChars = [...lowercase, ...uppercase, ...digits, ...symbols];

    if (length < 4) {
      return randomChoices(allChars, length).join("");
    }

    // Ensure at least one lowercase, one uppercase, one digit, and one symbol
    while (true) {
      const pwd = randomChoices(allChars, length).join("");
      const hasLower = lowercase.some(c => pwd.includes(c));
      const hasUpper = uppercase.some(c => pwd.includes(c));
      const hasDigit = digits.some(c => pwd.includes(c));
      const hasSymbol = symbols.some(c => pwd.includes(c));

      if (hasLower && hasUpper && hasDigit && hasSymbol) {
        return pwd;
      }
    }
  }

  if (pwType === "alphanumeric") {
    const allChars = [...lowercase, ...uppercase, ...digits];

    if (length < 3) {
      return randomChoices(allChars, length).join("");
    }

    // Ensure at least one lowercase, one uppercase, and one digit
    while (true) {
      const pwd = randomChoices(allChars, length).join("");
      const hasLower = lowercase.some(c => pwd.includes(c));
      const hasUpper = uppercase.some(c => pwd.includes(c));
      const hasDigit = digits.some(c => pwd.includes(c));

      if (hasLower && hasUpper && hasDigit) {
        return pwd;
      }
    }
  }

  if (pwType === "numeric") {
    return randomChoices(digits, length).join("");
  }

  if (pwType === "memorable") {
    const words = getWordsList();
    const selected = randomSample(words, qty);
    return selected.join("-");
  }

  throw new Error(`Unknown password type: ${pwType}`);
}

/**
 * Handles HTTP requests for the password generation daemon.
 */
class PasswordRequestHandler {
  public static handle(req: http.IncomingMessage, res: http.ServerResponse): void {
    const parsedUrl = url.parse(req.url || '', true);
    const pathname = parsedUrl.pathname;

    // Only accept root and /generate endpoints
    if (pathname !== '/' && pathname !== '/generate') {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }

    const params = parsedUrl.query;
    const typeParam = (Array.isArray(params.type) ? params.type[0] : params.type) || 'secure';

    if (!['matricula', 'secure', 'alphanumeric', 'numeric', 'memorable'].includes(typeParam)) {
      res.writeHead(400, { 'Content-Type': 'text/plain' });
      res.end('Bad Request: type must be matricula, secure, alphanumeric, numeric, or memorable.');
      return;
    }

    const pwType = typeParam as PasswordType;

    // Handle defaults based on password type
    let defaultLen = 16;
    if (pwType === 'numeric') {
      defaultLen = 6;
    }

    let defaultQty = 1;
    if (pwType === 'memorable') {
      defaultQty = 4;
    }

    const lengthStr = Array.isArray(params.length) ? params.length[0] : params.length;
    const qtyStr = Array.isArray(params.qty) ? params.qty[0] : params.qty;
    const countStr = Array.isArray(params.count) ? params.count[0] : params.count;

    let length = defaultLen;
    let qty = defaultQty;
    let count = 1;

    try {
      if (lengthStr !== undefined) {
        length = parseInt(lengthStr, 10);
        if (isNaN(length) || length <= 0) throw new Error();
      }
      if (qtyStr !== undefined) {
        qty = parseInt(qtyStr, 10);
        if (isNaN(qty) || qty <= 0) throw new Error();
      }
      if (countStr !== undefined) {
        count = parseInt(countStr, 10);
        if (isNaN(count) || count <= 0) throw new Error();
      }
    } catch (e) {
      res.writeHead(400, { 'Content-Type': 'text/plain' });
      res.end('Bad Request: length, qty, and count must be positive integers.');
      return;
    }

    try {
      const passwords: string[] = [];
      for (let i = 0; i < count; i++) {
        passwords.push(generatePassword(pwType, length, qty));
      }

      const format = (Array.isArray(params.format) ? params.format[0] : params.format) || 'text';

      if (format === 'json') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: 'success',
          passwords: passwords,
          type: pwType,
          length: ['matricula', 'memorable'].includes(pwType) ? null : length,
          qty: ['matricula', 'memorable'].includes(pwType) ? qty : null,
          count: count
        }));
      } else {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(passwords.join('\n') + '\n');
      }

      // Log to stdout (makes journald logs cleaner)
      const remoteAddr = req.socket.remoteAddress || '-';
      const timestamp = new Date().toISOString();
      console.log(`${remoteAddr} - - [${timestamp}] "GET ${req.url} HTTP/${req.httpVersion}" 200`);
    } catch (err: any) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end(`Internal Error: ${err.message}`);
    }
  }
}

/**
 * Starts the HTTP server daemon.
 */
export function runServer(port: number, host: string = '127.0.0.1'): void {
  const server = http.createServer(PasswordRequestHandler.handle);
  
  server.listen(port, host, () => {
    console.log(`🚀 Password Generator Service listening on HTTP ${host}:${port}`);
  });

  process.on('SIGINT', () => {
    console.log('\nStopping service...');
    server.close(() => {
      process.exit(0);
    });
  });
  
  process.on('SIGTERM', () => {
    console.log('\nTerminating service...');
    server.close(() => {
      process.exit(0);
    });
  });
}

/**
 * Parses CLI arguments and runs on-demand generation or the service.
 */
function parseArgsAndRun(): void {
  const args = process.argv.slice(2);

  let pwType: PasswordType = 'secure';
  let length: number | undefined = undefined;
  let qty: number | undefined = undefined;
  let count = 1;
  let serve = false;
  let port = 7777;
  let host = '127.0.0.1';

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '-t' || arg === '--type') {
      const val = args[++i];
      if (['matricula', 'secure', 'alphanumeric', 'numeric', 'memorable'].includes(val)) {
        pwType = val as PasswordType;
      } else {
        console.error(`Error: Unknown password type: ${val}`);
        process.exit(1);
      }
    } else if (arg === '-l' || arg === '--length') {
      length = parseInt(args[++i], 10);
      if (isNaN(length) || length <= 0) {
        console.error("Error: length must be a positive integer.");
        process.exit(1);
      }
    } else if (arg === '-q' || arg === '--qty') {
      qty = parseInt(args[++i], 10);
      if (isNaN(qty) || qty <= 0) {
        console.error("Error: qty must be a positive integer.");
        process.exit(1);
      }
    } else if (arg === '-c' || arg === '--count') {
      count = parseInt(args[++i], 10);
      if (isNaN(count) || count <= 0) {
        console.error("Error: count must be a positive integer.");
        process.exit(1);
      }
    } else if (arg === '--serve') {
      serve = true;
    } else if (arg === '--port') {
      port = parseInt(args[++i], 10);
      if (isNaN(port) || port <= 0) {
        console.error("Error: port must be a positive integer.");
        process.exit(1);
      }
    } else if (arg === '--host') {
      host = args[++i];
    } else if (arg === '-h' || arg === '--help') {
      console.log(`Cryptographically Secure Password Generator & Daemon (TypeScript Node version)`);
      console.log(`Usage: pgen [options]`);
      console.log(`Options:`);
      console.log(`  -t, --type <type>      Password type: matricula, secure, alphanumeric, numeric, memorable (default: secure)`);
      console.log(`  -l, --length <len>     Length of password for secure/alphanumeric/numeric (default: 16, or 6 for numeric)`);
      console.log(`  -q, --qty <qty>        Number of blocks/words for matricula/memorable (default: 1 for matricula, 4 for memorable)`);
      console.log(`  -c, --count <count>    Number of passwords to generate (default: 1)`);
      console.log(`  --serve                Run as an HTTP service daemon instead of CLI`);
      console.log(`  --port <port>          HTTP service port (default: 7777)`);
      console.log(`  --host <host>          HTTP service listen address (default: 127.0.0.1)`);
      process.exit(0);
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(1);
    }
  }

  if (serve) {
    runServer(port, host);
    return;
  }

  // Set default values based on type if not explicitly set
  if (length === undefined) {
    length = pwType === 'numeric' ? 6 : 16;
  }
  if (qty === undefined) {
    qty = pwType === 'memorable' ? 4 : 1;
  }

  try {
    for (let i = 0; i < count; i++) {
      console.log(generatePassword(pwType, length, qty));
    }
  } catch (err: any) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }
}

// Check if running directly as a script (e.g., node pgen.js or ts-node pgen.ts)
const isMain = typeof require !== 'undefined' && require.main === module;
if (isMain) {
  parseArgsAndRun();
}
