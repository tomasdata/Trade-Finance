# FCIB Credit & Collections Survey ETL

Este directorio contiene el script `fcib_pdf_extract.py` encargado de extraer, de manera incremental, los datos tabulares de los reportes **FCIB Credit & Collections Survey** (PDF) que viven en `documents/`.

## Flujo actual

1. **Fuente de entrada:** PDFs renombrados con el patrón `YYYY-MM_FCIB_Credit_Collections_Survey*.pdf` (la combinación año-mes se infiere del nombre).
2. **Extractor (`fcib_pdf_extract.py`):**
   - Usa `pdfplumber` en modo `layout=True`.
   - Identifica la lista de países que aparece en la portada (se asume formato “Country1, Country2, ...”).
   - Extrae tres bloques:
     - **Mix de clientes** (“Are your sales primarily to new or existing customers?”). Busca la tabla “Existing/New” y mapea cada columna a su país correspondiente.
     - **Average days beyond terms** (“What is the average number of days beyond terms...”). Lee la fila con países y la fila con los valores numéricos.
      - **Payment terms** (“On average, what payment terms are you granting?”). Se detecta el slide correspondiente, se localiza el bounding box del país y se extraen las cinco barras (% sin crédito, 1‑30, 31‑60, 61‑90, 90+ días).
      - **Payment delays trend** (“Are payment delays increasing, decreasing, or staying the same?”). Se identifica la posición horizontal de cada etiqueta (Staying / Not Experiencing / Decreasing / Increasing) y se asigna a cada país el porcentaje impreso sobre cada barra.
   - Genera registros con los campos:
     - `survey_year`, `survey_month`
     - `country`
     - `sales_existing_pct`, `sales_new_pct`
     - `avg_days_beyond_terms`
     - `payment_terms_no_credit_pct`, `payment_terms_1_30_pct`,
       `payment_terms_31_60_pct`, `payment_terms_61_90_pct`,
       `payment_terms_90_plus_pct`
     - `payment_delays_staying_pct`, `payment_delays_no_delay_pct`,
       `payment_delays_decreasing_pct`, `payment_delays_increasing_pct`
3. **Salida:** `data/fcib_credit_collections_panel.csv` (append). Cada corrida vuelve a procesar los PDFs existentes para mantener un panel único.

### Cómo ejecutar

```bash
# Procesar un PDF puntual (útil para probar):
python3 Scripts/fcib_pdf_extract.py documents/2024-04_FCIB_Credit_Collections_Survey_Results.pdf

# Regenerar el panel completo (se recomienda borrar el CSV antes):
rm data/fcib_credit_collections_panel.csv
for pdf in documents/*.pdf; do
  python3 Scripts/fcib_pdf_extract.py "$pdf"
done
```

Si se usa `--print`, sólo muestra los resultados (sin escribir el CSV).

## Avances y pendientes

- ✅ PDFs de 2024–2025: extraen correctamente mix Existing/New y días promedio.
- ✅ PDFs de 2023 hacia atrás: sólo se obtiene `avg_days_beyond_terms` (el layout no expone “Existing/New” en texto).
- ✅ **Payment terms:** slide detectado por la frase “On average, what payment terms…”. Para cada país, se toma su `bbox`, se arma una ventana de 250 px a cada lado y se agrupan los porcentajes en 5 clusters horizontales. En algunos PDFs (ej. Singapore abr/2024) no hay valores impresos y quedan `None`.
- ✅ **Payment delays trend:** se infiere la posición media de cada etiqueta (“Staying…”, “Not Experiencing…”, etc.) en todas las páginas con ese slide; luego, para cada país se busca el porcentaje más cercano a esos ejes y se asigna a las columnas correspondientes. Si una página no trae dicha slide, los campos quedan `None`.
- ◻️ **Causes y métodos de pago:** cada slide trae entre 3‑6 barras; se necesita un parser que identifique los labels (“Customer Payment Policy”, “Wire transfer”, etc.) y sus porcentajes.
- ◻️ **OCR/Layout robust:** para los PDFs antiguos es probable que necesitemos OCR zonal (p.ej. `pdfplumber` + bounding boxes o `pytesseract`) para capturar las etiquetas del mix.

## Recomendaciones

1. **Mantener un único panel (`fcib_credit_collections_panel.csv`)**: tras cada mejora, reejecutar el script sobre todo `documents/` para que las nuevas columnas se rellenen en bloque.
2. **Documentar versiones:** si cambia la lógica (por ejemplo, para soportar OCR), anotar en este README qué columnas se completan desde qué versión.
3. **Validar con muestras**: antes de automatizar otro bloque, contrastar 1‑2 PDFs manualmente para asegurar que el parser detecta todos los valores (y que no queda un país desfasado).
