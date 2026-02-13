import pandas as pd
import requests

API_KEY = "  # Replace with your actual API key "
INPUT_CSV = "The pool token addresses"
OUTPUT_CSV = "your_csv_name"

df = pd.read_csv(INPUT_CSV)
results = []
total = len(df)

print(f"Fetching historical prices for {total} tokens...")

for i, token_address in enumerate(df["token"], 1):
    try:
        response = requests.post(
            f"https://api.g.alchemy.com/prices/v1/{API_KEY}/tokens/historical",
            json={
                "network": "eth-mainnet",
                "address": token_address,
                "startTime": "2025-12-25T00:00:00.000Z",
                "endTime": "2026-01-29T23:59:59.000Z",
                "interval": "1d"
            }
        )
        
        data = response.json()
        
        if "data" in data:
            for price_point in data["data"]:
                results.append({
                    "token": token_address,
                    "timestamp": price_point.get("timestamp"),
                    "price": price_point.get("value")
                })
        
        print(f"[{i}/{total}]  {token_address}")
        
    except Exception as e:
        print(f"[{i}/{total}]  {token_address}: {e}")

out_df = pd.DataFrame(results)
if not out_df.empty:
    out_df = out_df.sort_values(by=["timestamp", "token"])
out_df.to_csv(OUTPUT_CSV, index=False)
print(f"\nSaved {len(results)} price records to {OUTPUT_CSV}")
