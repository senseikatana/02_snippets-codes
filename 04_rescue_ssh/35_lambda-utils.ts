/**
 * ARCHIVO: Lambda.ts (Final Class Version)
 * "The Ultimate Excel-Style Toolbox for TypeScript"
 * 
 * Requisitos: 
 * - npm install @js-temporal/polyfill
 * - npm install axios (Opcional, solo si usas AXIOS)
 */

import { Temporal } from '@js-temporal/polyfill';
// import axios from 'axios'; // Descomentar si usas AXIOS

export default class Lambda {

  // ============================================================
  // A - Z PUBLIC METHODS
  // ============================================================

  /**
   * MATH: Valor Absoluto.
   */
  public ABS(value: number): number {
    return Math.abs(value);
  }

  /**
   * MATH: Promedio (Excel: AVERAGE).
   */
  public AVERAGE(numbers: number[]): number {
    if (numbers.length === 0) return 0;
    return numbers.reduce((acc, curr) => acc + curr, 0) / numbers.length;
  }

  /**
   * HTTP: Axios con Tipado Dinámico (Fallback a Fetch si no hay librería).
   */
  public async AXIOS<T>(config: { 
    url: string; 
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE'; 
    data?: unknown; 
    headers?: Record<string, string> 
  }): Promise<T | null> {
    try {
      /*
      // IMPLEMENTACIÓN REAL CON AXIOS (Descomentar si tienes la librería)
      const response = await axios.request<T>({
        url: config.url,
        method: config.method || 'GET',
        data: config.data,
        headers: config.headers
      });
      return response.data;
      */

      // FALLBACK CON FETCH
      console.warn("Lambda: Usando fallback Fetch (instala axios para funcionalidad completa).");
      const response = await fetch(config.url, {
        method: config.method || 'GET',
        headers: config.headers,
        body: config.data ? JSON.stringify(config.data) : undefined
      });

      if (!response.ok) return null;
      return await response.json() as T;

    } catch (error) {
      console.error("Lambda AXIOS Error:", error);
      return null;
    }
  }

  /**
   * CONVERTER: Bytes a Tamaño Legible.
   */
  public BYTES_TO_SIZE(bytes: number, decimals: number = 2): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(decimals)) + ' ' + sizes[i];
  }

  /**
   * TEXT: Capitalizar texto.
   */
  public CAPITALIZE(text: string): string {
    return text.toLowerCase().replace(/\b\w/g, char => char.toUpperCase());
  }

  /**
   * MATH: Redondeo hacia arriba (Excel: CEILING).
   */
  public CEIL(value: number): number {
    return Math.ceil(value);
  }

  /**
   * CONVERTER: Celsius a Fahrenheit (y viceversa).
   * Nota: 9/5 = 1.8
   */
  public CELSIUS_TO_FAHRENHEIT(value: number, reverse: boolean = false): number {
    if (reverse) {
      // Fahrenheit a Celsius
      return (value - 32) / 1.8;
    } else {
      // Celsius a Fahrenheit
      return (value * 1.8) + 32;
    }
  }

  /**
   * CONVERTER: Celsius a Kelvin (y viceversa).
   */
  public CELSIUS_TO_KELVIN(value: number, reverse: boolean = false): number {
    if (reverse) {
      // Kelvin a Celsius
      return value - 273.15;
    } else {
      // Celsius a Kelvin
      return value + 273.15;
    }
  }

  /**
   * CURRENCY: Formateo de Moneda (Soporta Stripe Centavos).
   */
  public CURRENCY_FORMAT(
    value: string | number, 
    locale: string = 'es-MX', 
    currency: string = 'MXN', 
    isCents: boolean = false
  ): string {
    let numericValue = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(numericValue)) return "$0.00";
    const finalValue = isCents ? numericValue / 100 : numericValue;
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: currency,
    }).format(finalValue);
  }

  /**
   * DATE: Diferencia en días entre dos fechas (Excel: DIAS).
   */
  public DATE_DIFF(start: string | Temporal.PlainDate, end: string | Temporal.PlainDate): number {
    const d1 = typeof start === 'string' ? Temporal.PlainDate.from(start) : start;
    const d2 = typeof end === 'string' ? Temporal.PlainDate.from(end) : end;
    return d1.until(d2).days;
  }

  /**
   * DATE: Formato de Fecha (API Temporal).
   */
  public DATE_FORMAT(
    dateInput: string | number | Temporal.PlainDate | Temporal.ZonedDateTime, 
    locale: string = 'es-MX', 
    options: Intl.DateTimeFormatOptions = { year: 'numeric', month: 'long', day: 'numeric' }
  ): string {
    let temporalDate: Temporal.PlainDate | Temporal.PlainDateTime | Temporal.ZonedDateTime;
    
    if (dateInput instanceof Temporal.PlainDate || dateInput instanceof Temporal.ZonedDateTime || dateInput instanceof Temporal.PlainDateTime) {
      temporalDate = dateInput;
    } else if (typeof dateInput === 'number') {
      temporalDate = Temporal.Instant.fromEpochMilliseconds(dateInput).toZonedDateTimeISO(Temporal.Now.timeZone());
    } else {
      try { temporalDate = Temporal.PlainDate.from(dateInput); } 
      catch (e) { temporalDate = Temporal.PlainDateTime.from(dateInput); }
    }
    return temporalDate.toLocaleString(locale, options);
  }

  /**
   * OBJECT: Clonación Profunda (API: structuredClone).
   */
  public DEEP_CLONE<T>(value: T): T {
    if (typeof structuredClone === 'function') return structuredClone(value);
    return JSON.parse(JSON.stringify(value)) as T;
  }

  /**
   * OBJECT: Combinación Profunda de Objetos.
   */
  public DEEP_MERGE<T extends object>(target: T, source: Partial<T>): T {
    const output = { ...target };
    if (this.IS_OBJECT(target) && this.IS_OBJECT(source)) {
      Object.keys(source).forEach(key => {
        const k = key as keyof T;
        if (this.IS_OBJECT(source[k])) {
          if (!(k in target)) {
            Object.assign(output, { [key]: source[k] });
          } else {
            (output as Record<string, unknown>)[key] = this.DEEP_MERGE((target as Record<string, unknown>)[key] as object, (source as Record<string, unknown>)[key] as object) as T[keyof T];
          }
        } else {
          Object.assign(output, { [key]: source[k] });
        }
      });
    }
    return output;
  }

  /**
   * HTTP: Fetch Nativo con Tipado.
   */
  public async FETCH<T>(url: string, options: RequestInit = {}): Promise<T | null> {
    try {
      const response = await fetch(url, options);
      if (!response.ok) {
        console.error(`Lambda FETCH Error: ${response.status}`);
        return null;
      }
      return await response.json() as T;
    } catch (error) {
      console.error("Lambda FETCH Network Error:", error);
      return null;
    }
  }

  /**
   * MATH: Redondeo hacia abajo (Excel: FLOOR).
   */
  public FLOOR(value: number): number {
    return Math.floor(value);
  }

  /**
   * JSON: Parseo Seguro.
   */
  public FROM_JSON<T>(jsonString: string): T | null {
    try {
      return JSON.parse(jsonString) as T;
    } catch (e) {
      console.error("Lambda Error: JSON inválido", e);
      return null;
    }
  }

  /**
   * ARRAY: Agrupar por propiedad (Excel: Tablas Dinámicas).
   */
  public GROUP_BY<T extends Record<string, unknown>>(array: T[], key: keyof T): Record<string, T[]> {
    return array.reduce((acc, item) => {
      const groupKey = String(item[key]);
      if (!acc[groupKey]) acc[groupKey] = [];
      acc[groupKey].push(item);
      return acc;
    }, {} as Record<string, T[]>);
  }

  /**
   * VALIDATOR: Verifica si un objeto tiene propiedades.
   */
  public HAS_PROPERTIES<T extends object, K extends keyof T>(obj: T, ...keys: K[]): obj is T & Record<K, NonNullable<T[K]>> {
    return keys.every(key => obj[key] !== undefined && obj[key] !== null);
  }

  /**
   * VALIDATOR: Validación de Email.
   */
  public IS_VALID_EMAIL(email: string): boolean {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
  }

  /**
   * CONVERTER: Kilogramos a Libras (y viceversa).
   */
  public KG_TO_LBS(value: number, reverse: boolean = false): number {
    const factor = 2.20462;
    if (reverse) {
      // Libras a Kilogramos
      return value / factor;
    } else {
      // Kilogramos a Libras
      return value * factor;
    }
  }

  /**
   * CONVERTER: Kilómetros a Millas (y viceversa).
   */
  public KM_TO_MILES(value: number, reverse: boolean = false): number {
    const factor = 1.60934;
    if (reverse) {
      // Millas a Kilómetros
      return value * factor;
    } else {
      // Kilómetros a Millas
      return value / factor;
    }
  }

  /**
   * MATH: Valor Máximo (Excel: MAX).
   */
  public MAX(numbers: number[]): number {
    return Math.max(...numbers);
  }

  /**
   * MATH: Valor Mínimo (Excel: MIN).
   */
  public MIN(numbers: number[]): number {
    return Math.min(...numbers);
  }

  /**
   * DATE: Fecha Actual en ISO.
   */
  public NOW(): string {
    return Temporal.Now.plainDateISO().toString();
  }

  /**
   * HTTP: POST Simplificado.
   */
  public async POST<TResponse, TBody>(url: string, body: TBody): Promise<TResponse | null> {
    return this.FETCH<TResponse>(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
  }

  /**
   * MATH: Potencia.
   */
  public POW(base: number, exponent: number): number {
    return Math.pow(base, exponent);
  }

  /**
   * UTIL: Número Aleatorio Entero.
   */
  public RANDOM_INT(min: number, max: number): number {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  /**
   * MATH: Redondeo Preciso.
   */
  public ROUND(value: string | number, decimals: number = 2): number {
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) return 0;
    const factor = Math.pow(10, decimals);
    return Math.round(num * factor) / factor;
  }

  /**
   * TEXT: Slugify para URLs.
   */
  public SLUGIFY(text: string): string {
    return text
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, '')
      .replace(/[\s_-]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  /**
   * ARRAY: Ordenamiento Inteligente.
   */
  public SORT_BY<T>(array: T[], keyOrDirection?: keyof T | 'asc' | 'desc', thirdArg?: 'asc' | 'desc'): T[] {
    const isKey = (val: unknown): val is keyof T => typeof val === 'string' && val !== 'asc' && val !== 'desc';
    let key: keyof T | undefined = undefined;
    let direction: 'asc' | 'desc' = 'asc';

    if (isKey(keyOrDirection)) {
      key = keyOrDirection;
      direction = thirdArg || 'asc';
    } else {
      direction = (keyOrDirection as 'asc' | 'desc') || 'asc';
    }

    return [...array].sort((a, b) => {
      const valA = key ? a[key] : a;
      const valB = key ? b[key] : b;

      if (typeof valA === 'string' && typeof valB === 'string') {
        return direction === 'asc' ? valA.localeCompare(valB) : valB.localeCompare(valA);
      }
      if (Number(valA) < Number(valB)) return direction === 'asc' ? -1 : 1;
      if (Number(valA) > Number(valB)) return direction === 'asc' ? 1 : -1;
      return 0;
    });
  }

  /**
   * MATH: Raíz Cuadrada.
   */
  public SQRT(value: number): number {
    return Math.sqrt(value);
  }

  /**
   * WEB API: Objeto a Query String.
   */
  public STRINGIFY_QUERY(params: Record<string, string | number | boolean>): string {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
      searchParams.append(key, String(value));
    });
    return searchParams.toString();
  }

  /**
   * MATH: Suma (Excel: SUM).
   */
  public SUM(values: number[]): number {
    return values.reduce((acc, curr) => acc + curr, 0);
  }

  /**
   * MATH: Resta (Resta secuencial: primer valor - suma del resto).
   */
  public SUBTRACT(values: number[]): number {
    if (values.length === 0) return 0;
    const [first, ...rest] = values;
    return rest.reduce((acc, curr) => acc - curr, first);
  }

  /**
   * MATH: Suma Producto (Excel: SUMAPRODUCTO).
   */
  public SUM_PRODUCT(arr1: number[], arr2: number[]): number {
    if (arr1.length !== arr2.length) throw new Error("Arrays deben tener igual longitud");
    return arr1.reduce((acc, val, i) => acc + (val * arr2[i]), 0);
  }

  /**
   * JSON: Convertir a JSON String.
   */
  public TO_JSON(data: unknown, indent: number = 2): string {
    return JSON.stringify(data, null, indent);
  }

  /**
   * TEXT: Limpiar espacios (Excel: TRIM).
   */
  public TRIM(text: string): string {
    return text.trim();
  }

  /**
   * UTIL: Generar UUID.
   */
  public UUID(): string {
    if (typeof crypto !== 'undefined' && crypto.randomUUID) return crypto.randomUUID();
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0; const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  private IS_OBJECT(item: unknown): item is Record<string, unknown> {
    return (item && typeof item === 'object' && !Array.isArray(item));
  }
}