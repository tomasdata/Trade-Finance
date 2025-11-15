# ✅ TODO – Banca de Desarrollo (Updated 2025-11-15)

## 📋 Setup & Infrastructure (COMPLETED)

1. [x] Organizar estructura de directorios para 17+ instituciones
2. [x] Crear [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md) con URLs descarga + guía
3. [x] Crear [DEV_BANKS_DATA_SCHEMA.md](DEV_BANKS_DATA_SCHEMA.md) con estructura panel futuro
4. [x] Crear script Python para extracción automática (`Scripts/extract_devbanks_metrics.py`)

---

## 📥 Data Collection (IMMEDIATE - This Week)

### Priority 1: Complete Core 4 Countries (CRITICAL)

- [ ] **Brasil - BNDES**
  - URL: https://www.bndes.gov.br/wps/portal/site/home/relatorios-anuais
  - Status: ⏳ Needs browser download (JavaScript-protected)
  - Key Metrics: TF portfolio, Export finance lines, SME %, Regional data
  - Expected: ~5-15 MB PDF

- [ ] **Chile - CORFO**
  - URL: https://www.corfo.cl/web/guest/descargas
  - Status: ⏳ Needs monthly reports (2023-2024)
  - Key Metrics: Guarantee volumes by bank/region, SME distribution
  - Expected: ~20 monthly reports × 200-500 KB

- [ ] **México - NAFIN**
  - URL: https://www.nafin.gob.mx/portalnf/paginas/publicaciones/reportes
  - Status: ⏳ Needs browser download
  - Key Metrics: Export credit lines, Guarantees, Factoring volume
  - Expected: ~3-8 MB PDF

- [ ] **México - Bancomext**
  - URL: https://www.bancomext.gob.mx/sitiogenerales/publicaciones/informes-anuales
  - Status: ⏳ Needs browser download
  - Key Metrics: Export financing, Guarantee programs, Regional data
  - Expected: ~2-6 MB PDF

### Priority 2: Close Gaps in Survey Countries (HIGH)

- [ ] **Colombia - Findeter**
  - URL: https://www.findeter.gov.co/publicaciones-e-informes
  - Status: ⏳ Needs browser download
  - Key Metrics: Trade infrastructure finance, Regional support
  - Expected: ~500 KB PDF

- [ ] **Perú - COFIDE**
  - URL: https://www.cofide.com.pe (requires authentication)
  - Status: ⚠️ BLOCKED - Firewall/404 error
  - Action: Email contacto@cofide.com.pe for report
  - Key Metrics: Export finance, Guarantees, SME TF insurance
  - Expected: ~3-5 MB PDF

### Priority 3: Regional/Multilateral Context (MEDIUM)

- [ ] **Bolivia - BDP**, **Paraguay - AFD**, **Ecuador - BDE**, **Uruguay - ANDE**, **Costa Rica - SBD**
  - Status: ⏳ Each needs browser download from institution websites
  - Expected: ~500 KB each
  - See [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md) for direct links

- [ ] **Multilaterales - CAF**
  - URL: https://scioteca.caf.com (digital repository)
  - Status: ⏳ Needs repository search for 2023 annual report
  - Expected: ~10 MB PDF

- [ ] **Multilaterales - CABEI**
  - URL: https://www.bcie.org/publicaciones
  - Status: ⚠️ BLOCKED - React-based website + CloudFront
  - Action: Try from browser or request via info@bcie.org
  - Expected: ~5 MB PDF

---

## 🔍 Data Extraction (WEEK 2)

Once all PDFs are downloaded:

- [ ] Run `python3 Scripts/extract_devbanks_metrics.py` on downloaded PDFs
- [ ] Manually extract Tier 1 metrics from each institution:
  - [ ] TF Portfolio Outstanding (USD millions)
  - [ ] New Disbursements (annual)
  - [ ] SME % of total TF portfolio
  - [ ] Product breakdown: LC %, Export Credit %, Guarantee %, Insurance %
  - [ ] Top 3 sectors + %
  - [ ] Top 3 regions + %

- [ ] For complex/image-based PDFs:
  - [ ] Apply OCR (tesseract or similar)
  - [ ] Manual verification of extracted numbers

- [ ] Quality assurance:
  - [ ] Cross-check extracted numbers with official reports
  - [ ] Document data confidence (LOW/MEDIUM/HIGH)
  - [ ] Flag any missing/suspicious values

---

## 🔗 Panel Assembly (WEEK 3)

- [ ] Consolidate all extracted metrics into `data/dev_banks_tf_panel.csv`
- [ ] Apply validation rules:
  - [ ] All rows have year, country, institution
  - [ ] Amounts > 0 (no negative values)
  - [ ] Percentages sum to ~100% (or document exclusions)
  - [ ] Growth rates realistic (not >500% or <-100%)
- [ ] Create data quality summary (% complete by metric)
- [ ] Document all gaps and assumptions

---

## 📊 Integration & Analysis (WEEK 4)

- [ ] Combine `dev_banks_tf_panel.csv` + national banking data (Brasil/Chile/Peru/Mexico)
- [ ] Calculate key metrics:
  - [ ] Public vs. Private TF share by country
  - [ ] SME access gap (dev bank SME % - private bank SME %)
  - [ ] Crisis response (2019 vs. 2020 vs. 2021 growth rates)
  - [ ] Guarantee multiplier effect (private TF enabled / guarantee volume)
  - [ ] Regional concentration (HHI for dev banks vs. private)
- [ ] Generate analysis outputs:
  - [ ] Comparative TF charts (public vs. private by country)
  - [ ] SME access impact assessment
  - [ ] Crisis response timeline (2008 & 2020)
  - [ ] Regional equity analysis

---

## 📝 Documentation (Ongoing)

- [x] [README.md](README.md) - Overview & progress tracking
- [x] [SOURCES_AND_URLS.md](SOURCES_AND_URLS.md) - Complete download guide
- [x] [DEV_BANKS_DATA_SCHEMA.md](DEV_BANKS_DATA_SCHEMA.md) - Data structure definition
- [ ] Per-institution extraction notes (template in DEV_BANKS_DATA_SCHEMA.md)
- [ ] Final analysis report with key findings

---

## 🎯 Success Criteria

**Data Collection Phase:**
- ✅ Directories created (17 institutions across 12 countries + 3 multilateral)
- ✅ URLs identified for all institutions
- ⏳ 90%+ of accessible PDFs downloaded
- ✅ Extraction infrastructure ready

**Data Extraction Phase:**
- [ ] Tier 1 metrics (portfolio, disbursements, SME %) extracted for all institutions
- [ ] Extraction confidence >= MEDIUM for 80%+ of records
- [ ] PDFs reviewed in browser for validation

**Panel Assembly Phase:**
- [ ] `data/dev_banks_tf_panel.csv` created (50-100 rows)
- [ ] All validation rules passed
- [ ] Data completeness >= 70% (at least portfolio + SME + sector data)

**Integration Phase:**
- [ ] Public vs. Private TF share quantified by country
- [ ] SME access gap measured
- [ ] Crisis response analysis completed
- [ ] Report generated with key findings

---

## 🚨 Known Blockers & Solutions

### Firewall/Protection Issues

| Blocker | Solutions |
|---------|-----------|
| **COFIDE (Perú)** - 404/firewall | Email contacto@cofide.com.pe, check IDB databases |
| **FNG (Colombia)** - Incapsula protection | Try VPN, email fng, check World Bank databases |
| **CABEI** - React/CloudFront delivery | Manual browser access, email info@bcie.org |

### PDF Format Issues

| Issue | Solution |
|-------|----------|
| **Image-based PDFs** (scanned reports) | Use Tesseract OCR + manual verification |
| **Spanish-only metrics** | Translation + validation against number patterns |
| **Aggregated-only data** | Use as-is, document limitations |
| **Missing years** (e.g., only 2023) | Extract available years, note gaps |

---

## 📈 Expected Outcomes

Once complete, this effort enables:

1. **Quantify Public TF Role:** Is it really 20-30% of LAC market?
2. **SME Inclusion:** How much do dev bank guarantees enable private lending to SMEs?
3. **Crisis Response:** Did dev banks expand when private TF contracted (2020)?
4. **Regional Equity:** Are dev banks better distributed geographically?
5. **Policy Impact:** What's the ROI of guarantee programs vs. direct credit?

---

## 📅 Timeline Estimate

| Phase | Duration | Status |
|-------|----------|--------|
| Infrastructure Setup | 2 days | ✅ DONE |
| Data Collection (downloads) | 1 week | ⏳ IN PROGRESS |
| Data Extraction (manual) | 1 week | ⏳ PENDING |
| Panel Assembly | 2-3 days | ⏳ PENDING |
| Integration & Analysis | 1 week | ⏳ PENDING |
| **Total** | **~4 weeks** | - |

---

**Last Updated:** 2025-11-15
**Next Review:** After downloads complete (end of week 1)
