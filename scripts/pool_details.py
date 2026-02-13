# This script is used to extract each pool's details such as token0, token1 and fee)

import pandas as pd
from web3 import Web3

RPC_URL = "https://ethereum-rpc.publicnode.com"
INPUT_CSV = " csv_which_contains_pool_contract_addresses"
OUTPUT_CSV = "your_output_csv_name"

POOL_ABI = [
    {
        "name": "token0",
        "outputs": [{"type": "address"}],
        "stateMutability": "view",
        "type": "function",
        "inputs": []
    },
    {
        "name": "token1",
        "outputs": [{"type": "address"}],
        "stateMutability": "view",
        "type": "function",
        "inputs": []
    },
    {
        "name": "fee",
        "outputs": [{"type": "uint24"}],
        "stateMutability": "view",
        "type": "function",
        "inputs": []
    }
]

w3 = Web3(Web3.HTTPProvider(RPC_URL))

if not w3.is_connected():
    raise Exception("Web3 not connected")

df = pd.read_csv(INPUT_CSV)
total = len(df)

print(f"Processing {total} pools...")

results = []

for i, pool_addr in enumerate(df["pool_address"], 1):
    try:
        pool_addr = Web3.to_checksum_address(pool_addr)

        pool = w3.eth.contract(address=pool_addr, abi=POOL_ABI)

        token0 = pool.functions.token0().call()
        token1 = pool.functions.token1().call()
        fee = pool.functions.fee().call()

        results.append({
            "pool_address": pool_addr,
            "token0": token0,
            "token1": token1,
            "fee": fee
        })
        
        print(f"[{i}/{total}]  {pool_addr}")

    except Exception as e:
        results.append({
            "pool_address": pool_addr,
            "token0": None,
            "token1": None,
            "fee": None
        })
        print(f"[{i}/{total}]  {pool_addr}: {e}")

out_df = pd.DataFrame(results)
out_df.to_csv(OUTPUT_CSV, index=False)

print(f"\nSaved results to {OUTPUT_CSV}")

