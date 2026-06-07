const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (prompt) => new Promise(resolve => rl.question(prompt, resolve));

async function configureDatabase() {
  console.log('\n🔧 Honkai Star Retail - Database Configuration\n');
  console.log('Mari kita konfigurasi koneksi MySQL Anda.\n');

  try {
    // Check existing .env
    const envPath = path.join(__dirname, '.env');
    let currentEnv = '';
    if (fs.existsSync(envPath)) {
      currentEnv = fs.readFileSync(envPath, 'utf8');
    }

    // Get user inputs
    const host = await question('📍 MySQL Host (default: localhost): ') || 'localhost';
    const user = await question('👤 MySQL User (default: root): ') || 'root';
    const password = await question('🔐 MySQL Password (press Enter jika kosong): ') || '';
    const port = await question('⚡ MySQL Port (default: 3306): ') || '3306';
    const dbname = await question('📊 Database Name (default: honkai_star_retail): ') || 'honkai_star_retail';

    console.log('\n✅ Konfigurasi diterima!\n');
    console.log('📝 Configuration:');
    console.log(`   Host: ${host}`);
    console.log(`   User: ${user}`);
    console.log(`   Password: ${password ? '***' : '(kosong)'}`);
    console.log(`   Port: ${port}`);
    console.log(`   Database: ${dbname}\n`);

    const proceed = await question('Lanjutkan setup? (y/n): ');
    
    if (proceed.toLowerCase() !== 'y') {
      console.log('\n❌ Setup dibatalkan');
      process.exit(0);
    }

    // Update .env
    let envContent = currentEnv;
    envContent = envContent.replace(/DB_HOST=.*/g, `DB_HOST=${host}`);
    envContent = envContent.replace(/DB_USER=.*/g, `DB_USER=${user}`);
    envContent = envContent.replace(/DB_PASSWORD=.*/g, `DB_PASSWORD=${password}`);
    envContent = envContent.replace(/DB_PORT=.*/g, `DB_PORT=${port}`);
    envContent = envContent.replace(/DB_NAME=.*/g, `DB_NAME=${dbname}`);

    fs.writeFileSync(envPath, envContent);
    console.log('\n✅ .env file updated\n');

    // Now run the actual setup
    console.log('🚀 Starting database setup...\n');
    const setupScript = require('./setup-db');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  } finally {
    rl.close();
  }
}

configureDatabase();
