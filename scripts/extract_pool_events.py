import csv
from web3 import Web3
from requests.adapters import HTTPAdapter
from requests import Session
import time
from concurrent.futures import ThreadPoolExecutor, as_completed


def normalize_hex(data):
    if isinstance(data, str):
        return data if data.startswith("0x") else ("0x" + data)
    return "0x" + data.hex()

rpc_url = "https://ethereum-rpc.publicnode.com"
input_csv = "csv_which_contains_pool_contract_addresses.csv"
start_block = 24085923  
end_block = 24329614   
output_csv = 'uniswap_pool_event_logs.csv'
block_chunk_size = 100  # Process 100 blocks at a time per address
max_workers = 10  # Number of concurrent requests
max_retries = 5
retry_delay = 2

# Read addresses from CSV
addresses = []
with open(input_csv, 'r') as f:
    reader = csv.reader(f)
    next(reader, None)
    for row in reader:
        if row:
            addr = row[0].strip()
            if not addr.startswith('0x'):
                addr = '0x' + addr
            addresses.append(Web3.to_checksum_address(addr))

print(f'Found {len(addresses)} addresses in CSV')


def fetch_logs_for_address_range(address, from_block, to_block):
    """Fetch logs for one address across a block range"""
    session = Session()
    adapter = HTTPAdapter(
        max_retries=0,
        pool_connections=1,
        pool_maxsize=1
    )
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    
    w3 = Web3(Web3.HTTPProvider(rpc_url, request_kwargs={'timeout': 60}, session=session))
    
    filter_params = {
        'fromBlock': from_block,
        'toBlock': to_block,
        'address': address,
    }
    
    try:
        for retry in range(max_retries):
            try:
                logs = w3.eth.get_logs(filter_params)
                return logs
            except Exception as e:
                if retry < max_retries - 1:
                    time.sleep(retry_delay * (retry + 1))
                else:
                    print(f'  ✗ Failed {address} blocks {from_block}-{to_block}: {str(e)[:100]}')
                    return []
    finally:
        session.close()  


all_logs = []
total_blocks = end_block - start_block + 1

current_chunk_start = start_block
while current_chunk_start <= end_block:
    current_chunk_end = min(current_chunk_start + block_chunk_size - 1, end_block)
    progress = ((current_chunk_start - start_block) / total_blocks) * 100
    
    print(f'\nProcessing blocks {current_chunk_start}-{current_chunk_end} ({progress:.1f}%, {len(all_logs)} logs so far)')
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(fetch_logs_for_address_range, addr, current_chunk_start, current_chunk_end): addr 
            for addr in addresses
        }
        
        completed = 0
        for future in as_completed(futures):
            logs = future.result()
            all_logs.extend(logs)
            completed += 1
            if logs:
                print(f'  [{completed}/{len(addresses)}] Found {len(logs)} logs')
    
    current_chunk_start = current_chunk_end + 1
    time.sleep(10)  

print(f'\nTotal: {len(all_logs)} logs')

with open(output_csv, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['contract_address', 'block_number', 'tx_hash', 'log_index', 'topic_0', 'topic_1', 'topic_2', 'topic_3', 'data'])
    
    for log in all_logs:
        writer.writerow([
            log['address'],
            log['blockNumber'],
            "0x" + log['transactionHash'].hex(),
            log['logIndex'],
            ("0x" + log['topics'][0].hex()) if len(log['topics']) > 0 else '',
            ("0x" + log['topics'][1].hex()) if len(log['topics']) > 1 else '',
            ("0x" + log['topics'][2].hex()) if len(log['topics']) > 2 else '',
            ("0x" + log['topics'][3].hex()) if len(log['topics']) > 3 else '',
            normalize_hex(log['data'])
        ])

print(f'Saved to {output_csv}')
