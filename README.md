# Crypto Payroll System — Quick Start Guide yay

## Step 1 — Setup environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your private key
# PRIVATE_KEY=your_wallet_private_key_here
```

## Step 2 — Install dependencies
```bash
npm install
```

## Step 3 — Compile contracts
```bash
npm run compile
```

## Step 4 — Run tests
```bash
npm test
```
Expected output: All 30+ tests should pass ✅

## Step 5 — Deploy to testnet
```bash
npm run deploy
```
This will:
- Deploy the Payroll contract to Core Testnet
- Show contract address (save this to `.env` as `CONTRACT_ADDRESS`)
- Display deployer address and balance

## Step 6 — Fund the contract
After deployment, send test ETH to the contract (MetaMask or ethers.js):
```javascript
// Using ethers.js
await signer.sendTransaction({
    to: 'YOUR_CONTRACT_ADDRESS',
    value: ethers.utils.parseEther('5.0')
});
```

## Available NPM scripts
| Command | Description |
|---|---|
| npm run compile | Compile smart contracts |
| npm test | Run test suite |
| npm run deploy | Deploy to Core Testnet |

Save the deployed contract address to `.env` as:
```
CONTRACT_ADDRESS=0x... 
```
