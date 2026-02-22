import fs from 'fs';
import path from 'path';

export function checkEnv() {
  const envExamplePath = path.join('.env.example');
  const envExampleContent = fs.readFileSync(envExamplePath, 'utf-8');

  const requiredEnvVars = envExampleContent
    .split('\n')
    .filter(line => line.trim() && !line.trim().startsWith('#'))
    .map(line => line.split('=')[0].trim())
    .filter(varName => varName);

  const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

  if (missingVars.length > 0) {
    console.error('❌ Missing required environment variables:');
    missingVars.forEach(varName => console.error(`   - ${varName}`));
    console.error('\n💡 Make sure all variables from .env.example are configured in Render Environment settings');
    process.exit(1);
  }
}