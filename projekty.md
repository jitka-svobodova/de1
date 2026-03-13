# Zadání semestrálních projektů VHDL (Nexys A7-50T)

Tento dokument slouží jako podklad pro týmové projekty v jazyce VHDL. Projekty jsou navrženy pro skupiny **2–4 studentů** s celkovou časovou dotací **10 hodin** (5 cvičení po 2 hodinách).

## 1. Souhrnná tabulka projektů


| Projekt | Studenti | Koncept | VHDL | Čas | Periferie (Nexys A7) | Potřebný modul |
| :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **1. PWM Breathing LED** | 1–2 | 2 | 2 | 2 | 16x LED, 1x Switch | Čítač |
| **2. Waveform Gen (Základ)** | 2–4 | 3 | 3 | 4 | 16x LED, Tlačítka | Čítač, Debouncer |
| **3. Digitální stopky (Lap)** | 2–3 | 2 | 3 | 3 | 8x 7-seg, Tlačítka | Debouncer |
| **4. Audio Visualizer (PDM)** | 2–3 | 5 | 3 | 4 | MEMS Mikrofon, 16x LED | Čítač |
| **5. Multi-mode Counter** | 2–3 | 2 | 4 | 3 | 8x 7-seg, Switche | Čítač |
| **6. RGB Mood Lamp** | 1–2 | 3 | 2 | 2 | RGB LED, Tlačítka | Debouncer |
| **7. Digitální Trezor** | 2–3 | 4 | 3 | 4 | Switche, 7-seg, Tlačítka | Debouncer |
| **8. LED Ping-Pong** | 3–4 | 3 | 4 | 5 | 16x LED, Tlačítka | Debouncer |
| **9. I2C Termostat** | 3–4 | 4 | 4 | 4 | ADT7420 (I2C), 7-seg | I2C, Debouncer |
| **10. I2C Vodováha** | 2–3 | 4 | 3 | 3 | ADXL362 (I2C), RGB LED | I2C Driver |
| **11. Konfig. Waveform Gen** | 3–4 | 3 | 5 | 5 | 7-seg (Menu), Tlačítka | Čítač, Debouncer |
| **12. 7-segment Snake** | 3–4 | 4 | 4 | 5 | 8x 7-seg, Tlačítka | Debouncer, Čítač |

*Hodnocení: 0 = nejnižší, 5 = nejvyšší náročnost.*

---

## 2. Harmonogram realizace (5x 2 hodiny)

1.  **Cvičení 1: Architektura.** Návrh blokového schématu, rozdělení rolí, inicializace Gitu, příprava `.xdc` souboru.
2.  **Cvičení 2: Unit Design.** Vývoj dílčích modulů ve vlastních větvích (Git branch), simulace v testbenchi.
3.  **Cvičení 3: Integrace.** Spojení modulů do Top-level entity, syntéza a první testy na HW.
4.  **Cvičení 4: Tuning.** Debugging, ošetření zákmitů (debouncing), optimalizace kódu a dokumentace.
5.  **Cvičení 5: Obhajoba.** Předvedení funkčního zařízení a revize kódu.

---

## 3. Detailní popisy projektů a rozdělení úloh

### A. 7-segment Snake (3–4 studenti)
Hra, kde "had" (segment) obíhá po obvodu osmi 7-segmentových displejů.
*   **Student A (Mapper):** Vytvoří logiku mapující lineární pozici (0–47) na fyzické anody a katody (A-G).
*   **Student B (Logika):** Řeší pohyb hada, změnu směru tlačítky a detekci kolize s "jídlem".
*   **Student C (Generátor):** Implementuje náhodné generování pozice jídla (LFSR) a čítač skóre.
*   **Student D (Mux):** Upravuje multiplexer pro zobrazení více segmentů (tělo hada) současně.

### B. Audio Visualizer - PDM (2–3 studenti)
LED řada funguje jako VU metr reagující na digitální MEMS mikrofon.
*   **Student A (PDM):** Implementuje PDM demodulátor a generuje hodiny (clock) pro mikrofon.
*   **Student B (DSP):** Škálování dat a průměrování signálu (vyhlazení pohybu LED).
*   **Student C (Visuals):** Integrace, funkce "peak hold" a doplňkové efekty na RGB LED.

### C. I2C Termostat (3–4 studenti)
Měření teploty čipem ADT7420 s regulací a zobrazením na displeji.
*   **Student A (I2C):** Konfigurace driveru a sekvenční čtení dat ze senzoru.
*   **Student B (Converter):** Převod 2’s complement dat na stupně Celsia a BCD formát.
*   **Student C (Control):** Logika termostatu (hystereze, nastavení limitů přepínači).
*   **Student D (UI):** Multiplexovaný driver pro zobrazení teploty na všech 8 pozicích 7-segmentu.

---

## 4. Požadavky na dokumentaci (README.md)

Každý projekt musí v repozitáři obsahovat:
*   **Blokové schéma:** Grafické znázornění hierarchie modulů a toků signálů.
*   **Git Flow:** Historie commitů prokazující aktivitu všech členů týmu.
*   **Simulace:** Screenshot z Vivado simulátoru (Waveform) prokazující funkčnost modulů.
*   **Resource Report:** Tabulka využití prostředků (LUT, FF) po syntéze.
