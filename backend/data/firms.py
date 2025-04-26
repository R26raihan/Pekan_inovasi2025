import requests
import pandas as pd
import json

# --- Parameter ---
TOKEN = "d7ca96d80e3c0627b87956ff55a3a89d"  # MAP_KEY Anda
COUNTRY_CODE = "IDN"  # Indonesia
SATELLITE = "VIIRS_SNPP_NRT"  # Sumber data
DAYS = 1  # Rentang hari
DATE = "2025-04-23"  # Tanggal spesifik (sesuai screenshot)

# URL API (format CSV dengan tanggal spesifik)
url = f"https://firms.modaps.eosdis.nasa.gov/api/country/csv/{TOKEN}/{SATELLITE}/{COUNTRY_CODE}/{DAYS}/{DATE}"

# Tambahkan header untuk memastikan permintaan diterima
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# Request data
try:
    response = requests.get(url, headers=headers)
    response.raise_for_status()  # Lempar error jika status code bukan 200

    # Cek status
    if response.status_code == 200:
        print("Berhasil ambil data!")

        # Cetak respons mentah untuk debugging
        print("Respons mentah dari server:")
        print(response.text)

        # Simpan data sebagai file CSV
        with open("fire_data.csv", "wb") as file:
            file.write(response.content)
        print("Data disimpan sebagai 'fire_data.csv'.")

        # Baca file CSV menggunakan pandas
        try:
            df = pd.read_csv("fire_data.csv")

            # Cek apakah file CSV kosong (hanya header tanpa data)
            if df.empty:
                print("File CSV kosong: Tidak ada data hotspot kebakaran untuk parameter ini.")
            else:
                # Konversi DataFrame ke list of dictionaries (format JSON)
                data = df.to_dict(orient="records")

                # Simpan sebagai file JSON
                with open("fire_data.json", "w", encoding="utf-8") as file:
                    json.dump(data, file, ensure_ascii=False, indent=2)
                print("Data berhasil dikonversi dan disimpan sebagai 'fire_data.json'.")

                # Tampilkan jumlah entri
                print(f"Jumlah hotspot kebakaran: {len(data)}")
        except pd.errors.EmptyDataError:
            print("File CSV kosong atau tidak valid: Tidak ada data untuk dikonversi ke JSON.")
        except Exception as e:
            print(f"Error saat membaca CSV: {e}")

    else:
        print(f"Gagal ambil data. Status: {response.status_code}")
        print(response.text)

except requests.exceptions.HTTPError as http_err:
    print(f"HTTP error terjadi: {http_err}")
    print(response.text)
except requests.exceptions.RequestException as err:
    print(f"Error terjadi: {err}")