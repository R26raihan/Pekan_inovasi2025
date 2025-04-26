import requests

url = 'https://data.bnpb.go.id/api/3/action/datastore_search'
params = {
    'resource_id': '9b41007e-c998-456b-8cbc-385b17986e46',
    'limit': 100  # Bisa disesuaikan
}

response = requests.get(url, params=params)
data = response.json()

# Cetak data dalam bentuk record JSON
records = data['result']['records']
for record in records:
    print(record)
