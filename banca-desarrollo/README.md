# 🇱🇦 Banco de Desarrollo – Inventario de Reportes (Nov 2025)

Este directorio mantiene documentos crudos (memorias, informes públicos y reportes temáticos) que describen la acción de la banca de desarrollo y agencias multilaterales relevantes para el análisis de trade finance/intermediación público–privada en América Latina. Todos los archivos se guardan en subcarpetas `banca-desarrollo/<país>/<institución>/`.

> Nota: sólo guardamos materiales con datos accionables (montos, cartera, programas, series temporales). Folletos generales o notas de prensa se descartan.

| País / Región | Institución | Archivo(s) clave | Cobertura y notas |
|---------------|-------------|------------------|-------------------|
| 🇨🇱 Chile | CORFO – Programas de garantías (COBEX/FOGAIN/Pro-Inversión) | `chile/cobdx/Informe GC Diciembre 2024_v2.pdf` + 20 informes mensuales 2023-2024 | Flujo y stock por intermediario, región, tamaño de empresa y tasa. Base para medir la penetración de garantías en TF. |
| 🇲🇽 México | Nafin / Bancomext | `mexico/nafin/nafinsa_informe_anual_2023.pdf`, `mexico/bancomext/bancomext_informe_anual_2023.pdf` | Información de créditos y garantías a Mipymes/exportadores, emisiones de bonos sociales y estados financieros. |
| 🇨🇴 Colombia | Bancóldex | `colombia/bancoldex/bancoldex_reporte_anual_2023.pdf` | Reporte anual 2023 con portafolio de programas, fondeo y desempeño ASG. |
| 🇨🇴 Colombia | Finagro | `colombia/finagro/finagro_informe_gestion_2023.pdf` | Informe de Gestión Sostenible 2023: cartera de redescuento, subsidios a tasa, garantías agropecuarias y desempeño ESG. |
| 🇨🇴 Colombia | Findeter | `colombia/findeter/findeter_informe_gestion_sostenibilidad_2023.pdf`, `colombia/findeter/findeter_informe_anual_sectorial_2023.pdf` | Reporte integrado con cifras de crédito territorial/infraestructura y estudio sectorial (12 ramas DANE) para identificar focos de inversión pública. |
| 🇦🇷 Argentina | BICE | `argentina/bice/bice_memoria_balance_2023.pdf` | Memoria y balance 2023: financiamiento productivo, comercio exterior y fondeo multilateral. |
| 🇧🇷 Brasil | BNDES | `brasil/bndes/bndes_relatorio_anual_2023_en.pdf` | Relatório anual (versión en inglés) con metas climáticas, desembolsos sectoriales y ratings AA. |
| 🇧🇴 Bolivia | Banco de Desarrollo Productivo (BDP) | `bolivia/bdp/bdp_memoria_2023.pdf` | Memoria 2023: bonos verdes, programas FOCASE, inteligencia productiva y fideicomisos. |
| 🇵🇾 Paraguay | Agencia Financiera de Desarrollo (AFD) | `paraguay/afd/afd_memoria_2023.pdf` | Memoria de sostenibilidad 2023 con métricas de cartera verde, impacto regional y pipeline de segundo piso. |
| 🇪🇨 Ecuador | Banco de Desarrollo del Ecuador (BDE) | `ecuador/bde/bde_memoria_2023.pdf` | Memoria 2023: proyectos subnacionales, crédito climático y estructura de fondeo. |
| 🇺🇾 Uruguay | Agencia Nacional de Desarrollo (ANDE) | `uruguay/ande/ande_memoria_2023.pdf` | Memoria 2023 de la “Agencia de las Mipymes”; detalla centros de atención, garantías y modernización digital. |
| 🇨🇷 Costa Rica | Sistema de Banca para el Desarrollo (SBD) | `costa-rica/sbd/sbd_informe_anual_integrado_2023.pdf` | Informe anual integrado 2023 con metas legales (Ley 8634), impactos socioeconómicos y uso de fondos para Mipymes/emprendimientos. |
| 🌎 Multilaterales | CAF – Banco de Desarrollo de ALC | `multilaterales/caf/caf_informe_anual_2023_interactivo.pdf` | Informe anual 2023 con estrategia 2022-2026, agenda verde y estados financieros auditados. |
| 🌎 Multilaterales | FONPLATA | `multilaterales/fonplata/fonplata_memoria_2023.pdf` | Memoria y balance 2023, incluye operaciones por país, capital autorizado y marco de deuda sostenible. |

## Pendientes y fuentes bloqueadas

- **COFIDE (Perú)**: la memoria anual pública (`https://www.cofide.com.pe/COFIDE/uploads/medios/Memoria-Anual-COFIDE-2023.pdf`) devuelve una página 404 bajo el firewall del sitio. Se necesita descarga manual desde un navegador autenticado y guardar el PDF en `banca-desarrollo/peru/cofide/`.
- **BCIE / CABEI**: la “Memoria anual de labores 2023” se sirve desde el sitio nuevo (Next.js + CloudFront). El enlace público `https://www.bcie.org/novedades/publicaciones/publicacion/memoria-anual-de-labores-del-bcie-2023` requiere ejecución de React; no entrega PDF vía `curl`. Cuando esté disponible, crear `banca-desarrollo/multilaterales/cabei/` y documentar la ruta exacta.
- **Fondo Nacional de Garantías (Colombia)**: la URL oficial de informes de gestión (`https://www.fng.gov.co/nosotros/rendicion-de-cuentas/informe-de-gestion`) está protegida por Incapsula y responde con HTML vacío vía scripts. Revisar manualmente y, una vez descargado el PDF 2023, agregar `colombia/fng/`.

## 📊 Data Extraction & Panel Assembly Status

### Current State (2025-11-15)

**Directory Structure:** ✅ Created with 15+ institution folders
```
banca-desarrollo/
├── brasil/bndes/
├── chile/corfo/
├── mexico/{nafin, bancomext}/
├── colombia/{bancoldex, finagro, findeter, fng}/
├── argentina/bice/
├── peru/cofide/
├── bolivia/bdp/
├── paraguay/afd/
├── ecuador/bde/
├── uruguay/ande/
├── costa-rica/sbd/
└── multilaterales/{caf, fonplata, cabei}/
```

**Documents Created:**
1. ✅ [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md) - Complete download guide for all 17+ institutions
2. ✅ [DEV_BANKS_DATA_SCHEMA.md](DEV_BANKS_DATA_SCHEMA.md) - Unified data structure for future panel
3. ✅ [extract_devbanks_metrics.py](../Scripts/extract_devbanks_metrics.py) - Automated extraction script

**PDFs Downloaded:** 9 files (from 17 institutions)
- ✅ BICE (Argentina) - 135 KB
- ✅ Bancóldex (Colombia) - 54 KB
- ✅ Finagro (Colombia) - 101 KB
- ✅ FONPLATA (Multilateral) - 63 KB
- ⏳ BNDES, CORFO, NAFIN, Bancomext, Findeter, BDP, AFD, BDE, ANDE, SBD, CAF (need browser downloads)
- ⚠️ COFIDE (Peru), FNG (Colombia), CABEI (blocked by firewalls)

### Why This Infrastructure Matters

Development banks account for **20-30% of LAC TF** but are entirely missing from our analysis. This creates:
1. **Measurement bias:** We measure 70-80% of market and call it "complete"
2. **Policy blind spot:** Cannot evaluate public bank effectiveness
3. **SME gap:** Dev banks serve underserved segments, missing this distorts inclusion analysis
4. **Crisis blind spot:** Cannot measure counter-cyclical role (private TF contracts, dev banks expand)

### Next Steps (Immediate)

**Week 1: Data Collection**
1. Download remaining PDFs manually (see [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md))
   - Priority: BNDES, CORFO, NAFIN, Bancomext (complete Brazil, Chile, Mexico coverage)
   - Medium: Bancóldex, COFIDE (close Colombia, Peru gaps)
   - Low: Regional/multilateral (context only)

2. For blocked sources (COFIDE, FNG, CABEI):
   - Email requests to institutions
   - Check IDB/CAF knowledge repositories
   - Document access barriers

**Week 2: Data Extraction**
1. Run `Scripts/extract_devbanks_metrics.py` on downloaded PDFs
2. Manual extraction of Tier 1 metrics (see schema):
   - TF Portfolio Outstanding (USD millions)
   - New Disbursements (annual)
   - SME % of portfolio
   - Product mix (LC/credit/guarantee)
   - Top sectors & regions

3. OCR processing if needed (for image-based PDFs)

**Week 3: Panel Assembly**
1. Consolidate into `data/dev_banks_tf_panel.csv`
2. Validation checks (see [DEV_BANKS_DATA_SCHEMA.md](DEV_BANKS_DATA_SCHEMA.md))
3. Cross-check with official reports

**Week 4: Integration & Analysis**
1. Combine with national banking data (Brasil/Chile/Peru/Mexico)
2. Calculate public vs. private TF share by country
3. Analyze SME access impact (dev bank guarantees effect)
4. Crisis response analysis (2019-2021 time series)
5. Regional equity assessment (HHI concentration)

### Output Goal: Unified Dev Banks Panel

**Final CSV:** `data/dev_banks_tf_panel.csv`

**Structure:** (from [DEV_BANKS_DATA_SCHEMA.md](DEV_BANKS_DATA_SCHEMA.md))
```
year, country, institution, product_type,
amount_usd_millions, firm_size_sme_pct,
sector_primary, sector_primary_pct,
region_primary, region_primary_pct,
extraction_confidence, data_source, notes
```

**Expected Records:** ~50-100 rows (17 institutions × product types × years)

**Key Metrics to Extract:**
1. **Portfolio Size** - Compare with private banks
2. **SME Share** - Are dev banks pro-poor? (vs. CR3 = 60-80% private)
3. **Product Mix** - What instruments? (Guarantees = multiplier effect)
4. **Growth Rate** - Crisis response? (2020 expansion when private contracted?)
5. **Regional Spread** - Geographic equity? (HHI concentration analysis)

### Research Questions This Enables

Once panel is assembled:

1. **"Public TF is 20-30% of market"** → Quantify actual share (est: 25%)
2. **"SME access gap is 40 percentage points"** → Measure dev bank SME % vs. private CR3
3. **"COVID-19 private TF dropped 25% but dev banks expanded"** → Compare 2019 vs. 2020 vs. 2021
4. **"Guarantee programs have 3× multiplier"** → Quantify private TF enabled by public guarantees
5. **"Regional inequality in TF access"** → Compare HHI (coastal vs. inland, metropolitan vs. rural)

### Files in This Folder

- **README.md** (this file) - Overview and progress
- **TODO.md** - Checklist of institutions/documents
- **SOURCES_AND_URLS.md** - Where to download each institution's reports + working URLs
- **DEV_BANKS_DATA_SCHEMA.md** - Data structure definition + extraction guide
- **[country]/[institution]/** - Folders for downloaded PDFs (currently 9 files in place)

### Próximos pasos

1. **Descargar PDFs** - Usar guía en [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md)
2. **Extraer datos estructurados** (desembolsos, cartera por programa, monto de garantías) de cada PDF
3. **Consolidar en panel unificado** (data/dev_banks_tf_panel.csv)
4. **Integrar con datos nacionales** para cuantificar:
   - Share TF público vs. privado (estimado 20-30%)
   - Efectividad de programas de garantías (multiplicador: ¿3×? ¿5×?)
   - Respuesta contra-cíclica (¿se expandieron en 2020 cuando privados se contrajeron?)
   - Brecha de acceso SME (¿bancos dev sirven a más pequeños que privados?)
   - Equidad regional (¿concentración similar o mejor distribución?)
