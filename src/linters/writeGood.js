const args = process.argv.slice(2)

if (args.length < 1) {
  throw new Error('Unexepected arguments. Usage: node writeGood.js <text>')
}

const writeGood = require('write-good')
const suggestions = writeGood(args[0])

process.stdout.write(JSON.stringify(suggestions))
