from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import random
import json
import torch
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend
from fastapi_cache.decorator import cache
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os
import re
from datetime import datetime, timedelta  
from typing import List, Optional
import requests
import pandas as pd 


app = FastAPI()

# Setup FastAPI Cache
@app.on_event("startup")
async def startup():
    FastAPICache.init(InMemoryBackend())


# =========================================================
# BMKG API Integration
# =========================================================

def fetch_bmkg_gempa_data():
    url = "https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.exceptions.RequestException as e:
        return {"error": f"Gagal mengambil data dari BMKG: {str(e)}"}

class GempaItem(BaseModel):
    Tanggal: str
    Jam: str
    DateTime: str
    Coordinates: str
    Lintang: str
    Bujur: str
    Magnitude: str
    Kedalaman: str
    Wilayah: str
    Potensi: str

class BMKGGempaResponse(BaseModel):
    gempa: List[GempaItem]

@app.get("/bmkg/gempa-terkini", response_model=BMKGGempaResponse)
@cache(expire=300)
async def get_bmkg_gempa_terkini():
    data = fetch_bmkg_gempa_data()
    if "error" in data:
        raise HTTPException(status_code=500, detail=data["error"])
    
    if "Infogempa" not in data or "gempa" not in data["Infogempa"]:
        raise HTTPException(status_code=500, detail="Struktur data BMKG tidak valid")
    
    return {"gempa": data["Infogempa"]["gempa"]}

# =========================================================
# Model Pydantic untuk Data Banjir
# =========================================================

class BanjirItem(BaseModel):
    id: str
    nprop: str
    nkab: str
    kejadian: str
    tanggal: str
    lokasi: Optional[str]
    desa_terdampak: Optional[str]
    keterangan: Optional[str]
    penyebab: Optional[str]
    kronologis: Optional[str]
    sumber: Optional[str]
    mengungsi: Optional[str]
    rumah_terendam: Optional[str]
    longitude: Optional[str]
    latitude: Optional[str]

class BanjirResponse(BaseModel):
    banjir: List[BanjirItem]

# =========================================================
# Fungsi untuk Mengambil Data Banjir dari API DIBI BNPB
# =========================================================

def fetch_banjir_data():
    url = "https://dibi.bnpb.go.id/baru/get_markers?pr=&kb=&th=2025&bl=&jn=&lm=c&tg1=2025-23-01&tg2=2025-01-23"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.exceptions.RequestException as e:
        return {"error": f"Gagal mengambil data banjir dari DIBI BNPB: {str(e)}"}

# =========================================================
# Endpoint untuk Data Banjir
# =========================================================

@app.get("/BNPB", response_model=BanjirResponse)
@cache(expire=300)
async def get_banjir():
    data = fetch_banjir_data()
    if "error" in data:
        raise HTTPException(status_code=500, detail=data["error"])
    
    if not isinstance(data, list):
        raise HTTPException(status_code=500, detail="Struktur data banjir tidak valid")
    
    return {"banjir": data}

# =========================================================
# BMKG API Integration (Auto Gempa)
# =========================================================

class AutoGempaItem(BaseModel):
    Tanggal: str
    Jam: str
    DateTime: str
    Coordinates: str
    Lintang: str
    Bujur: str
    Magnitude: str
    Kedalaman: str
    Wilayah: str
    Potensi: str
    Dirasakan: str
    Shakemap: str

class AutoGempaResponse(BaseModel):
    gempa: AutoGempaItem

def fetch_auto_gempa_data():
    url = "https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.exceptions.RequestException as e:
        return {"error": f"Gagal mengambil data dari BMKG: {str(e)}"}

@app.get("/bmkg/Gempa-terbaru", response_model=AutoGempaResponse)
@cache(expire=300)
async def get_auto_gempa():
    data = fetch_auto_gempa_data()
    if "error" in data:
        raise HTTPException(status_code=500, detail=data["error"])
    
    if "Infogempa" not in data or "gempa" not in data["Infogempa"]:
        raise HTTPException(status_code=500, detail="Struktur data BMKG tidak valid")
    
    return {"gempa": data["Infogempa"]["gempa"]}

# =========================================================
# Model Pydantic untuk Data Pintu Air
# =========================================================

class PintuAirItem(BaseModel):
    nama_pintu: str
    latitude: str
    longitude: str
    record_status: int
    tinggi_air: int
    tinggi_air_sebelumnya: int
    tanggal: str
    status_siaga: str

class PintuAirResponse(BaseModel):
    pintu_air: List[PintuAirItem]

# =========================================================
# Fungsi untuk Mengambil Data Pintu Air
# =========================================================

def fetch_pintu_air_data():
    url = "https://poskobanjir.dsdadki.web.id/datatmalaststatus.json"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.exceptions.RequestException as e:
        return {"error": f"Gagal mengambil data pintu air: {str(e)}"}

# =========================================================
# Endpoint untuk Data Pintu Air
# =========================================================

@app.get("/pintu-air", response_model=PintuAirResponse)
@cache(expire=300)
async def get_pintu_air():
    data = fetch_pintu_air_data()
    if "error" in data:
        raise HTTPException(status_code=500, detail=data["error"])
    
    filtered_data = []
    for item in data:
        filtered_item = {
            "nama_pintu": item.get("NAMA_PINTU_AIR"),
            "latitude": item.get("LATITUDE"),
            "longitude": item.get("LONGITUDE"),
            "record_status": item.get("RECORD_STATUS"),
            "tinggi_air": item.get("TINGGI_AIR"),
            "tinggi_air_sebelumnya": item.get("TINGGI_AIR_SEBELUMNYA"),
            "tanggal": item.get("TANGGAL"),
            "status_siaga": item.get("STATUS_SIAGA")
        }
        filtered_data.append(filtered_item)
    
    return {"pintu_air": filtered_data}

# =========================================================
# Jalankan Server
# =========================================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)