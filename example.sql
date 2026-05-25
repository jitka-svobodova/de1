---------------------------------------------------------------------------------------
-- PRIKLAD 1
---------------------------------------------------------------------------------------
WITH zari AS (
    SELECT id_produkt, id_cena AS id_cena_09, cena AS cena_09
    FROM (
        SELECT *,
               ROW_NUMBER() OVER(PARTITION BY id_produkt ORDER BY platna_od DESC, id_cena DESC) AS poradi
        FROM fashion_training.cena_produktu
        WHERE platna_od <= '2025-09-01' AND ('2025-09-01' <= platna_do OR platna_do IS NULL)
    ) t
    WHERE t.poradi = 1
),
prosinec AS (
    SELECT id_produkt, id_cena AS id_cena_12, cena AS cena_12
    FROM (
        SELECT *,
               ROW_NUMBER() OVER(PARTITION BY id_produkt ORDER BY platna_od DESC, id_cena DESC) AS poradi
        FROM fashion_training.cena_produktu
        WHERE platna_od <= '2025-12-10' AND ('2025-12-10' <= platna_do OR platna_do IS NULL)
    ) t
    WHERE t.poradi = 1
)

SELECT 
    z.id_produkt,
    z.cena_09 AS cena_v_zari,
    p.cena_12 AS cena_v_prosinci,
    -- Výpočet absolutního rozdílu v penězích
    (z.cena_09 - p.cena_12) AS rozdil_v_penezich,
    -- Výpočet procentuální slevy
    ROUND(((z.cena_09 - p.cena_12) / z.cena_09) * 100, 2) AS rozdil_v_procentech
FROM zari z
-- Použijeme INNER JOIN, protože produkt musel mít cenu v obou obdobích
JOIN prosinec p ON z.id_produkt = p.id_produkt
-- Podmínka, že prosincová cena je nižší než zářijová (zboží zlevnilo)
WHERE p.cena_12 < z.cena_09
ORDER BY rozdil_v_procentech DESC;
---------------------------------------------------------------------------------------
-- PRIKLAD 2
---------------------------------------------------------------------------------------
SELECT 
    p.id_produkt,
    p.nazev,
    zari.cena AS cena_v_zari,
    prosinec.cena AS cena_v_prosinci,
    (zari.cena - prosinec.cena) AS rozdil_v_penezich,
    ROUND(((zari.cena - prosinec.cena) / zari.cena) * 100, 2) AS rozdil_v_procentech
FROM fashion_training.produkt p
-- Připojíme přesně váš funkční dotaz pro září
JOIN (
    SELECT id_produkt, cena FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY id_produkt ORDER BY platna_od DESC, id_cena DESC) AS poradi
        FROM fashion_training.cena_produktu WHERE platna_od <= '2025-09-01' AND ('2025-09-01' <= platna_do OR platna_do IS NULL)
    ) t WHERE t.poradi = 1
) zari ON p.id_produkt = zari.id_produkt
-- Připojíme přesně váš funkční dotaz pro prosinec
JOIN (
    SELECT id_produkt, cena FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY id_produkt ORDER BY platna_od DESC, id_cena DESC) AS poradi
        FROM fashion_training.cena_produktu WHERE platna_od <= '2025-12-10' AND ('2025-12-10' <= platna_do OR platna_do IS NULL)
    ) t WHERE t.poradi = 1
) prosinec ON p.id_produkt = prosinec.id_produkt
-- Finální porovnání cen
WHERE prosinec.cena < zari.cena
ORDER BY rozdil_v_procentech DESC;

