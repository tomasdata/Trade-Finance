# 📋 TODO - MEJORAS INCREMENTALES OCR
## Plan de Acción Recursivo para Fortalecer Extracción de Datos FCIB

---

## 🎯 **OBJETIVO PRINCIPAL**
Transformar el script OCR actual de 4 métricas a 12-15 métricas por país, incrementando la cobertura del 60% al 85-90% del contenido de los PDFs FCIB.

---

## 📅 **CRONOGRAMA DETALLADO**

### **SEMANA 1: FUNDAMENTOS DE ROBUSTEZ**
- [ ] **DÍA 1-2**: Implementar logging estructurado
- [ ] **DÍA 3-4**: Agregar manejo de errores con fallback
- [ ] **DÍA 5**: Implementar validación de completitud
- [ ] **DÍA 6-7**: Testing con PDFs existentes

### **SEMANA 2: EXTENSIÓN DE MÉTRICAS**
- [ ] **DÍA 1-2**: Implementar `parse_payment_methods()`
- [ ] **DÍA 3-4**: Implementar `parse_terms_types()`
- [ ] **DÍA 5**: Extender dataclass con nuevos campos
- [ ] **DÍA 6-7**: Integrar nuevas métricas al flujo principal

### **SEMANA 3: OPTIMIZACIÓN**
- [ ] **DÍA 1-2**: Implementar caching de resultados
- [ ] **DÍA 3-4**: Agregar procesamiento paralelo
- [ ] **DÍA 5**: Optimizar detección de países con aliases
- [ ] **DÍA 6-7**: Testing de rendimiento

### **SEMANA 4: VALIDACIÓN FINAL**
- [ ] **DÍA 1-3**: Probar con todos los 33 PDFs
- [ ] **DÍA 4-5**: Comparar resultados vs extracción manual
- [ ] **DÍA 6**: Documentar mejoras y limitaciones
- [ ] **DÍA 7**: Deploy y monitoreo inicial

---

## 🔧 **TAREAS ESPECÍFICAS POR IMPLEMENTAR**

### **1. MEJORAS DE ROBUSTEZ (Semana 1)**

#### **📝 Logging Estructurado**
```python
# TAREA: Agregar al inicio del script
import logging
from pathlib import Path

def setup_logging(log_dir: Path):
    """Configurar logging detallado para diagnóstico"""
    log_dir.mkdir(exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_dir / 'fcib_extraction.log'),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)
```

#### **🛡️ Manejo de Errores con Fallback**
```python
# TAREA: Reemplazar extracción actual con esta función
def extract_with_fallback(pdf_path: Path, logger) -> CountryMetrics:
    """Intentar múltiples estrategias de extracción"""
    
    strategies = [
        ("Método actual", extract_current_method),
        ("Coordenadas fijas", extract_by_coordinates),
        ("Extracción manual", extract_partial_manual),
        ("OCR alternativo", extract_with_tesseract)
    ]
    
    for strategy_name, strategy_func in strategies:
        try:
            logger.info(f"Intentando estrategia: {strategy_name}")
            metrics = strategy_func(pdf_path)
            if validate_metrics_completeness(metrics, logger):
                logger.info(f"Éxito con estrategia: {strategy_name}")
                return metrics
        except Exception as e:
            logger.warning(f"Fallo estrategia {strategy_name}: {e}")
            continue
    
    raise RuntimeError(f"Todas las estrategias fallaron para {pdf_path.name}")
```

#### **✅ Validación de Completitud**
```python
# TAREA: Agregar función de validación mejorada
def validate_metrics_completeness(metrics: CountryMetrics, logger) -> bool:
    """Validar calidad y completitud de métricas extraídas"""
    
    # Validar campos requeridos
    required_fields = ['sales_existing_pct', 'sales_new_pct']
    missing_required = [f for f in required_fields if getattr(metrics, f) is None]
    if missing_required:
        logger.warning(f"Campos requeridos faltantes: {missing_required}")
        return False
    
    # Validar rangos lógicos
    if metrics.sales_existing_pct and metrics.sales_new_pct:
        total = metrics.sales_existing_pct + metrics.sales_new_pct
        if not (95 <= total <= 105):  # Allow 5% tolerance
            logger.warning(f"Suma de ventas inválida: {total}%")
            return False
    
    # Validar porcentajes
    for field_name in metrics.__dataclass_fields__:
        value = getattr(metrics, field_name)
        if field_name.endswith('_pct') and value is not None:
            if not (0 <= value <= 100):
                logger.warning(f"Porcentaje inválido en {field_name}: {value}")
                return False
    
    logger.info("Validación de métricas completada exitosamente")
    return True
```

### **2. EXTENSIÓN DE MÉTRICAS (Semana 2)**

#### **💳 Nuevas Métricas de Pago**
```python
# TAREA: Extender dataclass CountryMetrics
@dataclass
class ExtendedCountryMetrics(CountryMetrics):
    # Métodos de pago
    electronic_payment_pct: float = None         # Pagos electrónicos
    wire_transfer_pct: float = None              # Transferencias bancarias
    check_payment_pct: float = None               # Cheques
    other_payment_pct: float = None               # Otros métodos
    
    # Tipos de términos comerciales
    open_account_terms_pct: float = None          # Cuenta abierta
    documentary_terms_pct: float = None           # Documentarios
    other_terms_pct: float = None                  # Otros términos
    
    # Tendencias (si disponibles)
    vs_previous_year_pct: float = None           # vs año anterior
    vs_previous_quarter_pct: float = None         # vs trimestre anterior
    
    # Datos cualitativos codificados
    top_challenge_code: int = None               # Principal desafío
    opportunity_code: int = None                  # Principal oportunidad
```

#### **🔍 Extracción de Métodos de Pago**
```python
# TAREA: Implementar nueva función
def parse_payment_methods(pdf: pdfplumber.PDF, countries: Sequence[str]) -> Dict[str, Dict[str, float]]:
    """Extraer distribución de métodos de pago por país"""
    result: Dict[str, Dict[str, float]] = {}
    
    for page in pdf.pages:
        text = page.extract_text(layout=True) or ""
        normalized = " ".join(text.lower().split())
        
        # Buscar sección de métodos de pago
        if not any(marker in normalized for marker in ["payment methods", "collection methods"]):
            continue
        
        words = page.extract_words()
        
        for country in countries:
            if country in result:
                continue
                
            boxes = page.search(country, case=False)
            if not boxes:
                continue
                
            bbox = boxes[0]
            values = extract_payment_methods_from_box(page, words, bbox)
            if values:
                result[country] = values
    
    return result

def extract_payment_methods_from_box(page, words, bbox) -> Dict[str, float] | None:
    """Extraer valores de métodos de pago desde caja delimitada"""
    margin_x = 150
    margin_y = 200
    x_min = max(0.0, bbox["x0"] - margin_x)
    x_max = min(page.width, bbox["x1"] + margin_x)
    y_min = bbox["bottom"]
    y_max = y_min + margin_y
    
    percents: List[Tuple[float, float]] = []
    for w in words:
        text = w["text"]
        if not text.endswith("%"):
            continue
        x_center = (w["x0"] + w["x1"]) / 2
        y_center = (w["top"] + w["bottom"]) / 2
        if not (x_min <= x_center <= x_max and (y_min + 20) <= y_center <= y_max):
            continue
        try:
            value = float(text.replace("%", ""))
            percents.append((x_center, value))
        except ValueError:
            continue
    
    if not percents:
        return None
    
    # Agrupar por proximidad horizontal
    percents.sort(key=lambda item: item[0])
    clusters = cluster_by_proximity(percents, threshold=30)
    
    if len(clusters) < 3:
        return None
    
    # Asignar etiquetas basadas en posición y contexto
    methods = assign_method_labels(clusters, page)
    total = sum(methods.values())
    
    if not (90 <= total <= 110):
        return None
    
    return methods
```

#### **📄 Extracción de Tipos de Términos**
```python
# TAREA: Implementar función para términos comerciales
def parse_terms_types(pdf: pdfplumber.PDF, countries: Sequence[str]) -> Dict[str, Dict[str, float]]:
    """Extraer tipos de términos comerciales por país"""
    result: Dict[str, Dict[str, float]] = {}
    
    for page in pdf.pages:
        text = page.extract_text(layout=True) or ""
        normalized = " ".join(text.lower().split())
        
        # Buscar sección de términos
        if not any(marker in normalized for marker in ["open account", "documentary", "terms"]):
            continue
        
        words = page.extract_words()
        
        for country in countries:
            if country in result:
                continue
                
            boxes = page.search(country, case=False)
            if not boxes:
                continue
                
            bbox = boxes[0]
            values = extract_terms_from_box(page, words, bbox)
            if values:
                result[country] = values
    
    return result

def extract_terms_from_box(page, words, bbox) -> Dict[str, float] | None:
    """Extraer valores de tipos de términos desde caja delimitada"""
    # Implementación similar a extract_payment_methods_from_box
    # pero buscando patrones de "open account", "documentary", etc.
    pass
```

### **3. OPTIMIZACIÓN (Semana 3)**

#### **⚡ Caching de Resultados**
```python
# TAREA: Agregar sistema de caché
import pickle
import hashlib
from pathlib import Path

class ExtractionCache:
    def __init__(self, cache_dir: Path):
        self.cache_dir = cache_dir
        self.cache_dir.mkdir(exist_ok=True)
    
    def get_cache_key(self, pdf_path: Path) -> str:
        """Generar clave única para caché basada en contenido"""
        with open(pdf_path, 'rb') as f:
            file_hash = hashlib.md5(f.read()).hexdigest()
        return f"{pdf_path.stem}_{file_hash}"
    
    def get(self, pdf_path: Path) -> CountryMetrics | None:
        """Obtener resultados cacheados"""
        cache_key = self.get_cache_key(pdf_path)
        cache_file = self.cache_dir / f"{cache_key}.pkl"
        
        if cache_file.exists():
            # Verificar que el PDF no sea más reciente que el caché
            if cache_file.stat().st_mtime > pdf_path.stat().st_mtime:
                with cache_file.open('rb') as f:
                    return pickle.load(f)
        return None
    
    def set(self, pdf_path: Path, metrics: CountryMetrics):
        """Guardar resultados en caché"""
        cache_key = self.get_cache_key(pdf_path)
        cache_file = self.cache_dir / f"{cache_key}.pkl"
        
        with cache_file.open('wb') as f:
            pickle.dump(metrics, f)
```

#### **🔄 Procesamiento Paralelo**
```python
# TAREA: Modificar función main para procesamiento paralelo
from concurrent.futures import ThreadPoolExecutor, as_completed
import multiprocessing

def process_all_pdfs_parallel(pdf_dir: Path, output_path: Path, cache_dir: Path):
    """Procesar múltiples PDFs en paralelo"""
    pdf_files = list(pdf_dir.glob("*.pdf"))
    cache = ExtractionCache(cache_dir)
    logger = setup_logging(cache_dir)
    
    def process_single_pdf(pdf_path: Path) -> Tuple[Path, CountryMetrics | Exception]:
        try:
            # Intentar obtener del caché primero
            cached_metrics = cache.get(pdf_path)
            if cached_metrics:
                logger.info(f"Usando caché para {pdf_path.name}")
                return pdf_path, cached_metrics
            
            # Extraer fresh
            metrics = extract_with_fallback(pdf_path, logger)
            cache.set(pdf_path, metrics)
            logger.info(f"Procesado exitoso: {pdf_path.name}")
            return pdf_path, metrics
            
        except Exception as e:
            logger.error(f"Error procesando {pdf_path.name}: {e}")
            return pdf_path, e
    
    # Procesar en paralelo
    max_workers = min(multiprocessing.cpu_count(), len(pdf_files))
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_pdf = {executor.submit(process_single_pdf, pdf): pdf 
                          for pdf in pdf_files}
        
        results = []
        for future in as_completed(future_to_pdf):
            pdf_path, result = future.result()
            results.append((pdf_path, result))
    
    # Escribir resultados exitosos a CSV
    successful_results = [(pdf, metrics) for pdf, metrics in results 
                         if not isinstance(metrics, Exception)]
    write_results_to_csv(successful_results, output_path)
    
    # Reportar errores
    failed_results = [(pdf, error) for pdf, error in results 
                      if isinstance(error, Exception)]
    if failed_results:
        logger.warning(f"Fallaron {len(failed_results)} PDFs")
        for pdf, error in failed_results:
            logger.error(f"{pdf.name}: {error}")
```

#### **🌍 Mejora Detección de Países**
```python
# TAREA: Expandir diccionario de países
COUNTRY_ALIASES = {
    # Países existentes + aliases
    "United States": ["USA", "US", "United States of America"],
    "United Kingdom": ["UK", "Great Britain", "England"],
    "Germany": ["Deutschland", "DE"],
    "France": ["FR"],
    "Italy": ["IT"],
    "Spain": ["ES"],
    "Netherlands": ["Holland", "NL"],
    "Belgium": ["BE"],
    "Austria": ["AT"],
    "Switzerland": ["CH"],
    "Sweden": ["SE"],
    "Norway": ["NO"],
    "Denmark": ["DK"],
    "Finland": ["FI"],
    
    # LATAM con variantes locales
    "Brazil": ["Brasil", "BR"],
    "Mexico": ["México", "MX"],
    "Argentina": ["AR"],
    "Chile": ["CL"],
    "Colombia": ["CO"],
    "Peru": ["Perú", "PE"],
    "Venezuela": ["VE"],
    "Ecuador": ["EC"],
    "Bolivia": ["BO"],
    "Uruguay": ["UY"],
    "Paraguay": ["PY"],
    "Costa Rica": ["CR"],
    "Panama": ["Panamá", "PA"],
    "Guatemala": ["GT"],
    
    # Asia-Pacífico
    "China": ["CN", "Mainland China"],
    "Japan": ["JP"],
    "South Korea": ["Korea", "KR"],
    "India": ["IN"],
    "Singapore": ["SG"],
    "Australia": ["AU"],
    "New Zealand": ["NZ"],
    "Indonesia": ["ID"],
    "Malaysia": ["MY"],
    "Thailand": ["TH"],
    "Philippines": ["PH"],
    "Hong Kong": ["HK"],
    "Taiwan": ["TW"],
    
    # Medio Oriente y África
    "United Arab Emirates": ["UAE", "Emirates"],
    "Saudi Arabia": ["KSA"],
    "South Africa": ["ZA"],
    "Egypt": ["EG"],
    "Nigeria": ["NG"],
    "Kenya": ["KE"],
    "Morocco": ["MA"],
}

def normalize_country_name(name: str) -> str:
    """Normalizar nombres de países con todos los aliases"""
    if not name or not name.strip():
        return name
    
    cleaned_name = name.strip()
    
    # Buscar coincidencia exacta primero
    for canonical, aliases in COUNTRY_ALIASES.items():
        if cleaned_name in [canonical] + aliases:
            return canonical
    
    # Buscar coincidencia parcial (para nombres compuestos)
    for canonical, aliases in COUNTRY_ALIASES.items():
        for alias in [canonical] + aliases:
            if alias.lower() in cleaned_name.lower() or cleaned_name.lower() in alias.lower():
                return canonical
    
    return cleaned_name
```

### **4. VALIDACIÓN FINAL (Semana 4)**

#### **🧪 Testing Completo**
```python
# TAREA: Script de testing exhaustivo
def test_all_pdfs_comprehensive(pdf_dir: Path, output_dir: Path):
    """Testing completo con todos los PDFs disponibles"""
    
    pdf_files = sorted(pdf_dir.glob("*.pdf"))
    results = {
        'total_pdfs': len(pdf_files),
        'successful': 0,
        'failed': 0,
        'partial': 0,
        'errors': [],
        'metrics_summary': {},
        'performance_times': []
    }
    
    for pdf_path in pdf_files:
        start_time = time.time()
        
        try:
            # Extraer con método mejorado
            metrics = extract_with_fallback(pdf_path, setup_logging(output_dir))
            
            # Validar completitud
            completeness = calculate_completeness(metrics)
            processing_time = time.time() - start_time
            
            if completeness >= 0.8:
                results['successful'] += 1
            elif completeness >= 0.5:
                results['partial'] += 1
            else:
                results['failed'] += 1
                results['errors'].append(f"{pdf_path.name}: Baja completitud ({completeness:.1%})")
            
            results['performance_times'].append(processing_time)
            
            # Acumular estadísticas de métricas
            for field_name in metrics.__dataclass_fields__:
                value = getattr(metrics, field_name)
                if value is not None:
                    if field_name not in results['metrics_summary']:
                        results['metrics_summary'][field_name] = []
                    results['metrics_summary'][field_name].append(value)
                    
        except Exception as e:
            results['failed'] += 1
            results['errors'].append(f"{pdf_path.name}: {str(e)}")
    
    # Generar reporte
    generate_test_report(results, output_dir)
    return results
```

#### **📊 Generación de Reporte**
```python
# TAREA: Función de reporte detallado
def generate_test_report(results: Dict, output_dir: Path):
    """Generar reporte detallado de testing"""
    
    report_path = output_dir / f"ocr_test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    
    with report_path.open('w') as f:
        f.write("# 📊 Reporte de Testing OCR - FCIB\n\n")
        f.write(f"**Fecha**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        # Resumen de resultados
        f.write("## 📈 Resumen de Resultados\n\n")
        f.write(f"- **Total PDFs**: {results['total_pdfs']}\n")
        f.write(f"- **Exitosos**: {results['successful']} ({results['successful']/results['total_pdfs']*100:.1f}%)\n")
        f.write(f"- **Parciales**: {results['partial']} ({results['partial']/results['total_pdfs']*100:.1f}%)\n")
        f.write(f"- **Fallidos**: {results['failed']} ({results['failed']/results['total_pdfs']*100:.1f}%)\n\n")
        
        # Rendimiento
        if results['performance_times']:
            avg_time = sum(results['performance_times']) / len(results['performance_times'])
            f.write(f"**Tiempo promedio por PDF**: {avg_time:.2f} segundos\n\n")
        
        # Métricas extraídas
        f.write("## 📋 Métricas Extraídas\n\n")
        for field_name, values in results['metrics_summary'].items():
            if values:
                avg_val = sum(values) / len(values)
                f.write(f"- **{field_name}**: {len(values)} países, promedio {avg_val:.1f}\n")
        
        # Errores
        if results['errors']:
            f.write("\n## ❌ Errores Detectados\n\n")
            for error in results['errors']:
                f.write(f"- {error}\n")
```

---

## 🎯 **MÉTRICAS DE ÉXITO**

### **Indicadores de Progreso:**
- **Cobertura de extracción**: 60% → 85-90%
- **Número de métricas**: 4 → 12-15 por país
- **Tasa de éxito**: 80% → 95% de PDFs procesados
- **Tiempo de procesamiento**: Actual → 50% más rápido con caché
- **Robustez**: Frágil → Recuperación automática de errores

### **Entregables por Semana:**
- **Semana 1**: Script con logging y manejo de errores robusto
- **Semana 2**: Script extendido con 8-10 nuevas métricas
- **Semana 3**: Script optimizado con caché y paralelización
- **Semana 4**: Script validado y documentado con reporte completo

---

## 🚨 **RIESGOS Y MITIGACIÓN**

### **Riesgos Identificados:**
1. **Cambios en formato PDF**: Mitigado con múltiples estrategias de fallback
2. **Rendimiento con muchos PDFs**: Mitigado con caché y paralelización
3. **Falsos positivos en extracción**: Mitigado con validación robusta
4. **Complejidad de mantenimiento**: Mitigado con código modular y bien documentado

### **Plan de Contingencia:**
- Si una estrategia falla, automáticamente probar la siguiente
- Si el rendimiento es bajo, reducir paralelización dinámicamente
- Si la calidad es baja, generar alertas automáticas para revisión manual

---

## ✅ **CRITERIOS DE ACEPTACIÓN**

### **Mínimo Viable (Semana 2):**
- [ ] Extraer al menos 8 métricas por país
- [ ] Procesar 80% de PDFs sin errores críticos
- [ ] Implementar logging básico

### **Completo (Semana 4):**
- [ ] Extraer 12-15 métricas por país
- [ ] Procesar 95% de PDFs exitosamente
- [ ] Implementar todas las optimizaciones
- [ ] Generar reporte de validación completo
- [ ] Documentar todas las mejoras

---

*Este TODO guía el proceso recursivo de mejora del OCR, asegurando que cada paso se valide antes de continuar con el siguiente.*