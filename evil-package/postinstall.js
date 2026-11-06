// This file is not imported by anything. It runs because `npm install` runs it,
// before a single line of your own code has executed and before you have read
// anything. A real one would look for credentials; this one leaves a note.
const { writeFileSync } = require('node:fs');
const credentialish = Object.keys(process.env).filter((k) => /KEY|TOKEN|SECRET|PASS/i.test(k));
writeFileSync('/tmp/package-lab-proof.txt',
  `it ran, before any of your own code did\n` +
  `environment variables it could read that look like credentials: ${credentialish.length}\n` +
  (credentialish.length ? `  ${credentialish.join(', ')}\n` : '') +
  `it also had the network, the file system, and your shell\n`);
