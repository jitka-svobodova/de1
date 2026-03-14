# Zadání semestrálních projektů VHDL (Nexys A7-50T)

Tento dokument slouží jako podklad pro týmové projekty v jazyce VHDL. Projekty jsou navrženy pro skupiny **2–4 studentů** s celkovou časovou dotací **10 hodin** (5 cvičení po 2 hodinách).

## 1. Souhrnná tabulka projektů (včetně témat 2024/25)


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
| **10. I2C Vodováha** | 2–3 | 4 | 3 | 3 | ADXL362 (SPI/I2C), RGB LED | SPI/I2C Driver |
| **11. Konfig. Waveform Gen** | 3–4 | 3 | 5 | 5 | 7-seg (Menu), Tlačítka | Čítač, Debouncer |
| **12. 7-segment Snake** | 3–4 | 4 | 4 | 5 | 8x 7-seg, Tlačítka | Debouncer, Čítač |
| **13. Hodiny s budíkem**| 2–3 | 2 | 3 | 4 | 7-seg, Tlačítka, Buzzer | Debouncer |
| **14. UART Tx/Rx s FIFO** | 3–4 | 4 | 4 | 5 | USB-UART Bridge | Čítač |
| **15. Multi-channel PWM/Servo** | 2–3 | 3 | 3 | 3 | Serva (Pmod), LED | Čítač |
| **16. Ultrazvuk HS-SR04** | 2–3 | 3 | 3 | 4 | HS-SR04 (Pmod), 7-seg | Debouncer |
| **17. ADC & filtrace signálu** | 3–4 | 5 | 4 | 5 | XADC, 7-seg/LED | Čítač |
| **18. Custom I2C/SPI Design** | 3–4 | 5 | 5 | 5 | Pmod senzory | - |

*Hodnocení: 0 = nejnižší, 5 = nejvyšší náročnost.*

---

## 2. Harmonogram realizace (5x 2 hodiny)

1.  **Cvičení 1: Architektura.** Návrh blokového schématu, rozdělení rolí, inicializace Gitu, příprava `.xdc` souboru.
2.  **Cvičení 2: Unit Design.** Vývoj dílčích modulů ve vlastních větvích (Git branch), simulace v testbenchi.
3.  **Cvičení 3: Integrace.** Spojení modulů do Top-level entity, syntéza a první testy na HW.
4.  **Cvičení 4: Tuning.** Debugging, ošetření zákmitů (debouncing), optimalizace kódu a dokumentace.
5.  **Cvičení 5: Obhajoba.** Předvedení funkčního zařízení a revize kódu.

---

## 3. Detailní popisy vybraných projektů

### 3.1. PWM Breathing LED (1-2 studenti)
Místo pouhého blikání studenti vytvoří modul, který plynule mění jas. 
Úkol: Implementovat PWM s nastavitelnou střídou, kterou řídí čítač (trojúhelníkový průběh pro "nádech" a "výdech"). https://vhdlwhiz.com/pwm-controller/
*   **Student A (PWM Modul):** Vytvoří PWM modul.
*   **Student B (Logika + TB):** Řeší logiku pro řízení jasu a testbench.

### 3.2. Waveform Generator (2–4 studenti)
Tento projekt je ideální pro 4 studenty, protože je skvěle modulární. Každý student odpovídá za jeden typ průběhu a jeden "šéf" zastřešuje integraci.
*   **Student A:** PWM a Rectangle (nastavitelná střída). https://vhdlwhiz.com/pwm-controller/
*   **Student B:** Sawtooth a Triangle (lineární inkrementace čítače).
*   **Student C:** Sine wave (využití Look-Up Table – ROM paměti). https://vhdlwhiz.com/breathing-led-using-sine-wave-stored-in-block-ram/
*   **Student D (Integrátor):** Top modul, multiplexer, debouncing tlačítek a synchronizace.

### 3.3. Digitální stopky s "Lap" funkcí (2–3 studenti)
Měření času na setiny sekundy, výstup na 7-segmentový displej.
*   **Student A:** dělička frekvence
*   **Student B:** BCD čítače
*   **Student C:** dekodér pro displej

### 3.4. Audio "Breathing" Visualizer (2–3 studenti)
LED pásek nebo řada LED reaguje na intenzitu vstupu (jednoduchý komparátor s pilovým průběhem).

### 3.5. Multi-Mode Counter (2–3 studenti)
8místný čítač, který umí různé režimy: Decimální, Hexadecimální a "Běžící text" (např. HELLO). 8 segmentovek, přepínače pro volbu módu (Hex/Dec), tlačítka pro Reset/Stop.
*   **Student A:** Modul pro multiplexování displeje (rychlé přepínání anod s frekvencí cca 100 Hz).
*   **Student B:** Čítač s volitelnou bází (Dec/Hex).
*   **Student C:** Dekodér znaků (0-F, H, E, L, O).

### 3.6. RGB Mood Lamp (1-2 studenti)
Plynulé přechody barev (Rainbow effect). Pětisměrné tlačítko ovládá rychlost nebo jas. RGB LED (vyžaduje 3 nezávislá PWM na jednu LED), 16 přepínačů pro "míchání" vlastní barvy v manuálním módu.
*   **Student A:** Trojité PWM a řízení barvy pomocí složek R, G, B.
*   **Student B:** FSM (stavový automat), který cykluje mezi barvami duhy

### 3.7. Digitální trezor/kombinační zámek (2–3 studenti)
Uživatel musí zadat 4místný kód pomocí přepínačů a středového tlačítka. Přepínače (vstup kódu), 7-segment (zobrazuje "----" nebo "OPEN"/"ERR"), LEDky (indikace pokusů).
*   **Student A:** Debouncer pro tlačítka.
*   **Student B:** Hlavní FSM (stavy: IDLE, ENTER_1, ENTER_2, ..., UNLOCKED, ALARM).
*   **Student C:** Správa displeje a indikace.

### 3.8. "Ping-Pong" na 16 LEDkách (3-4 studenti)
"Míček" (svítící LED) kmitá zleva doprava. Hráč musí včas stisknout levé/pravé tlačítko, aby ho odrazil. Pokud mine, LEDky zablikají (prohra).
*   **Student A:** Posuvný registr/logika pohybu LED.
*   **Student B:** Detekce stisku tlačítka v "nárazové zóně".
*   **Student C:** Čítač skóre a zobrazení na displeji.
*   **Student D:** Generátor zrychlování (hustota tiků hodin se zvyšuje s každým odrazem).

### 3.9. Digitální Teploměr (I2C + 7-segment) (3-4 studenti)
Vyčítat teplotu ze senzoru a zobrazovat ji na 7-segmentovém displeji ve stupních Celsia. Přepínače nastavují "cílovou teplotu" a LED indikují topení/chlazení. ADT7420 (přes I2C), 8x 7-segment, LED (stav), 16x Switch (limit).
*   **Student A:** Integrátor I2C: Nastavení registru senzoru a čtení dat.
*   **Student B:** Datový procesor: Převod surových dat ze senzoru na stupně (binární na BCD).
*   **Student C:** Čítač skóre a zobrazení na displeji.

### 3.10. Vodováha (SPI + RGB LED) (2-3 studenti)
Využití akcelerometru ADXL362 (ten bývá na SPI, ale pokud máte I2C bridge nebo jiný I2C senzor na Pmodu, princip je stejný). Detekovat náklon desky. Podle toho, na jakou stranu se deska nakloní, se rozsvítí odpovídající LED nebo se "přelévá" světlo na řadě 16 LED. Akcelerometr, 16x LED, RGB LED.
*   **Student A:** I2C Driver: Čtení os X a Y z registru senzoru.
*   **Student B:** Mapping: Převod hodnoty náklonu na pozici svítící LED (škálování dat).
*   **Student C:** Visuals: Driver pro LED a RGB efekty.

### 3.11. Konfigurovatelný Waveform Generator (3-4 studenti)
Generátor (zadání č. 2), ale parametry (amplituda, frekvence, typ průběhu) se nastavují pomocí pětisměrného tlačítka a zobrazují se na displeji jako "menu". Tlačítka (menu), 7-segment (status), 16x LED (vizualizace amplitudy/PWM).
*   **Student A:** Menu Controller: FSM přepínající mezi módy (Set Freq, Set Type).
*   **Student B:** Signal Engine: Generátory (Sine, Tri, Saw).
*   **Student C:** Output Logic: PWM výstup a škálování amplitudy. 
*   **Student D:** Zobrazení aktuálních hodnot na 7-segmentu. 

### 3.12. 7-segment Snake (3–4 studenti)
Had obíhá dokola po vnějších segmentech (a, b, c, d, e, f). Pětisměrné tlačítko (středové nebo směrová) slouží k ovládání směru (ve směru / proti směru hodinových ručiček) nebo ke skoku na vnitřní segment (segment g). Na náhodném segmentu se objeví "potrava" (segment bliká). Hráč ji musí "sníst", čímž se had prodlouží (svítí více segmentů za sebou) nebo se zvýší skóre. 8x 7-segmentový displej, pětisměrné tlačítko, 16x LED (zobrazení délky hada nebo binární skóre).
*   **Student A (Mapper):** Mapování indexů (Student A): Musí vytvořit logiku, která mapuje lineární pozici hada (0–47, protože 8 displejů × 6 obvodových segmentů) na konkrétní anodu a segmenty.
*   **Student B (Logika):** Herní logika a FSM (Student B): Řeší směr pohybu, kolize a náhodné generování "potravy" (pomocí jednoduchého LFSR registru).
*   **Student C (Generátor):** Implementuje náhodné generování pozice jídla (LFSR) a čítač skóre. (Pokud jsou 4, tak tento úkol přebere od studenta B)
*   **Student D (Mux):** Upravuje multiplexer pro zobrazení více segmentů (tělo hada) současně.

### 3.13. Hodiny s budíkem (2-3 studenti)
Realizace hodin v 24hodinovém formátu (HH:MM:SS) s možností nastavení času a času buzení (alarmu).
*   **Student A (Timekeeper):** Implementace hlavního čítače času (sekundy, minuty, hodiny) s děličkou z 100MHz kmitočtu desky. Musí ošetřit přetečení (např. po 23:59:59 skok na 00:00:00).
*   **Student B*** (Control & Alarm): Logika pro nastavení času pomocí tlačítek (přepínání módů: běh/nastavení času/nastavení budíku). Porovnávání aktuálního času s uloženým časem budíku a spouštění bzučáku (PWM signál pro zvuk).
*   **Student C (Display Driver):** Multiplexované zobrazení času na 8místném sedmisegmentovém displeji (např. HH-MM-SS) včetně blikání oddělovacích segmentů.

### 3.14 UART Controller s FIFO (3–4 studenti)
Kompletní řadič pro komunikaci s PC přes RS232.
*   **Student A (Baudrate/Sampling):** Generátor vzorkovacích hodin a detekce start bitu.
*   **Student B (Rx/Tx FSM):** Stavové automaty pro příjem a vysílání datového rámce.
*   **Student C (FIFO):** Implementace vyrovnávací paměti pro plynulý tok dat.
*   **Student D (UI/App):** Logika pro echo-back nebo ovládání LED přes terminál.

### 3.15 Multi-channel PWM / Servo Controller (2–3 studenti)
Návrh vícekanálového generátoru PWM signálů, který umožňuje nezávislé ovládání jasu LED a pozice servomotorů (úhel 0° až 180°).
*   **Student A (PWM Core):** Implementace generického PWM modulu s nastavitelným rozlišením. Musí zajistit pevnou periodu 20 ms (50 Hz) vyžadovanou servomotory a přesně definovanou šířku pulzu v rozmezí 1 ms (0°) až 2 ms (180°).
*   **Student B (Control & Mapping):** Logika pro ovládání parametrů. Přepínače (Switches) volí, které servo/LED se právě ovládá, a tlačítka (Up/Down) plynule mění střídu (duty cycle). Musí implementovat „saturovaný čítač“, aby servo nenaráželo do mechanických dorazů.
*   **Student C (Multi-channel Interface):** Integrace více instancí PWM modulů do jednoho celku. Zajištění výstupu na Pmod konektory (pro serva) a na RGB LED (pro vizualizaci náklonu/jasu). Zobrazení aktuální střídy nebo úhlu v procentech na 7-segmentovém displeji.

### 3.16 Ultrazvukový dálkoměr HS-SR04 (2–3 studenti)
Měření vzdálenosti pomocí ultrazvukového senzoru a zobrazení v cm.
*   **Student A (Trigger):** Generování 10us pulzů pro aktivaci senzoru.
*   **Student B (Echo):** Měření délky pulzu Echo a výpočet vzdálenosti (převod času na cm).
*   **Student C (Zobrazení):** Převod binární hodnoty na BCD a zobrazení na 7-segmentovém displeji.

### 3.17 ADC & filtrace signálu (3–4 studenti)
Digitalizace analogového napětí (např. z potenciometru na Pmod nebo interního senzoru) a následné digitální zpracování pro stabilizaci naměřených hodnot. XADC na Nexys A7 standardně měří v rozsahu 0V až 1V. Pokud budou studenti připojovat externí napětí na piny JXADC, je nutné je upozornit na toto omezení, aby nedošlo k poškození FPGA (při 3.3V).
*   **Student A (XADC Interface):** Konfigurace a instancování IP jádra XADC v režimu "Sequencer" nebo "Single Channel". Zajištění správného vyčítání 12bitových dat přes rozhraní DRP (Dynamic Reconfiguration Port) nebo AXI4-Lite.
*   **Student B (Digital Filter):** Implementace digitálního filtru pro odstranění šumu. Ideální je klouzavý průměr (Moving Average) nebo jednoduchý jednopólový IIR filtr (exponenciální vyhlazování). Musí pracovat s pevnou řádovou čárkou (fixed-point).
*   **Student C (Data Scaler & BCD):** Převod surových dat z ADC (0–4095) na reálné napětí (0.0V – 1.0V) nebo procenta. Převod výsledku do BCD formátu pro zobrazení.
*   **Student D (Visualizer & Alarm):** Zobrazení hodnoty na 7-segmentovém displeji a vizualizace úrovně signálu na řadě 16 LED (bargraph). Implementace alarmu (blikání LED při překročení nastaveného limitu).

---

## 4. Požadavky na dokumentaci (README.md)

Každý projekt musí v repozitáři obsahovat:
*   **Blokové schéma:** Grafické znázornění hierarchie modulů a toků signálů.
*   **Git Flow:** Historie commitů prokazující aktivitu všech členů týmu.
*   **Simulace:** Screenshot z Vivado simulátoru (Waveform) prokazující funkčnost modulů.
*   **Resource Report:** Tabulka využití prostředků (LUT, FF) po syntéze.
