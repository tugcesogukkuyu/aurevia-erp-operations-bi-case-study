---

# 8. SATIŞ SİPARİŞİ DOĞRULAMA VE GÜVENLİ HATA YÖNETİMİ

## 8.1 Amaç

Bu gereksinim; satış siparişlerinin ERP sistemine aktarılmadan önce stok, müşteri kredi limiti, lot uygunluğu, raf ömrü ve kalite blokajı kontrollerinden geçirilmesini ve teknik hata durumlarında siparişin güvenli biçimde durdurulmasını tanımlar.

Kontrol sonucu alınamayan hiçbir satış siparişi otomatik olarak onaylanamaz veya ERP sistemine aktarılamaz.

---

## 8.2 Kapsam

Bu gereksinim aşağıdaki işlem zincirini kapsar:

```text
Web Application
      ↓
Node.js / Express API
      ↓
Sales Order Validation Service
      ↓
SQL Stored Procedure
      ↓
ERP Sales Order Transfer
      ↓
Stock Reservation and Warehouse Processing
```

Kapsamdaki temel kontroller:

- Kullanılabilir stok kontrolü
- Müşteri kredi limiti kontrolü
- Lot uygunluk kontrolü
- Raf ömrü kontrolü
- Kalite blokajı kontrolü
- Sipariş tekrar kontrolü
- API ve veri tabanı hata yönetimi
- ERP aktarım öncesi doğrulama kapısı

---

# 9. İŞ KURALLARI

| Kural No | İş Kuralı |
|---|---|
| BR-01 | Satış siparişi yalnızca bütün zorunlu kontroller başarılı olduğunda onaylanabilir. |
| BR-02 | Kullanılabilir stok miktarı sipariş miktarından düşükse sipariş otomatik olarak onaylanamaz. |
| BR-03 | Müşteri kullanılabilir kredi limiti sipariş toplamını karşılamıyorsa sipariş finans incelemesine yönlendirilmelidir. |
| BR-04 | Kalite blokajında bulunan lotlar satış siparişine rezerve edilemez. |
| BR-05 | Raf ömrü sevkiyat kriterini karşılamayan lotlar satış ve rezervasyon işlemine kapatılmalıdır. |
| BR-06 | Stored Procedure yanıtı alınamazsa sipariş onaylanmamalıdır. |
| BR-07 | Timeout, bağlantı hatası veya beklenmeyen sistem hatası başarı sonucu olarak değerlendirilemez. |
| BR-08 | Teknik hata oluşan sipariş `PENDING_REVIEW` durumuna alınmalıdır. |
| BR-09 | Eksik doğrulama sonucu bulunan sipariş ERP sistemine aktarılamaz. |
| BR-10 | Her kontrol sonucu ayrı ve denetlenebilir biçimde saklanmalıdır. |
| BR-11 | Aynı sipariş isteği tekrar gönderildiğinde mükerrer ERP siparişi oluşturulmamalıdır. |
| BR-12 | Sipariş ERP sistemine aktarılmadan önce zorunlu doğrulama kapısı çalıştırılmalıdır. |

---

# 10. DOĞRULAMA KONTROLLERİ

## 10.1 Stok Kontrolü

Sistem aşağıdaki stok değerlerini dikkate almalıdır:

```text
Kullanılabilir Stok =
Fiziksel Stok
- Rezerve Edilmiş Stok
- Kalite Blokajlı Stok
- Sevkiyata Kapalı Stok
- Raf Ömrü Uygun Olmayan Stok
```

### Kabul koşulu

```text
Kullanılabilir Stok ≥ Sipariş Miktarı
```

Koşul sağlanmıyorsa:

```text
validation_status = REJECTED
validation_code   = INSUFFICIENT_STOCK
order_status      = STOCK_REVIEW
```

---

## 10.2 Kredi Limiti Kontrolü

### Kabul koşulu

```text
Kullanılabilir Kredi Limiti ≥ Sipariş Toplam Tutarı
```

Koşul sağlanmıyorsa:

```text
validation_status = REJECTED
validation_code   = CREDIT_LIMIT_EXCEEDED
order_status      = FINANCE_REVIEW
```

Kredi kontrol sonucu alınamıyorsa sipariş otomatik olarak reddedilmiş kabul edilmez; manuel incelemeye yönlendirilir.

```text
validation_status = ERROR
validation_code   = CREDIT_CHECK_UNAVAILABLE
order_status      = PENDING_REVIEW
```

---

## 10.3 Lot Uygunluk Kontrolü

Siparişe bağlanacak lot aşağıdaki koşulların tamamını sağlamalıdır:

- Lot aktif durumda olmalıdır.
- Kalite blokajında bulunmamalıdır.
- Sevkiyata kapalı olmamalıdır.
- İlgili ürün koduyla eşleşmelidir.
- Yeterli kullanılabilir miktara sahip olmalıdır.
- Raf ömrü kriterini karşılamalıdır.

Koşullardan biri sağlanmıyorsa lot rezerve edilemez.

---

## 10.4 Raf Ömrü Kontrolü

Raf ömrü kontrolü aşağıdaki hesaplamaya göre yapılmalıdır:

```text
Kalan Raf Ömrü Günü =
Son Kullanma Tarihi - Planlanan Sevkiyat Tarihi
```

### Kabul koşulu

```text
Kalan Raf Ömrü Günü ≥ Ürün İçin Tanımlı Minimum Sevkiyat Süresi
```

Koşul sağlanmıyorsa:

```text
validation_status = REJECTED
validation_code   = SHELF_LIFE_NOT_ELIGIBLE
order_status      = LOT_REVIEW
```

---

## 10.5 Kalite Blokajı Kontrolü

Aşağıdaki statülerde bulunan lotlar satışa ve rezervasyona kapalı olmalıdır:

```text
QUALITY_HOLD
QUARANTINE
REJECTED
EXPIRED
RECALL_BLOCK
```

Kalite statüsü uygun olmayan lot için:

```text
validation_status = REJECTED
validation_code   = QUALITY_BLOCKED_LOT
order_status      = LOT_REVIEW
```

---

# 11. SİPARİŞ DURUM YÖNETİMİ

| Sipariş Durumu | Açıklama |
|---|---|
| `DRAFT` | Sipariş oluşturulmuş ancak doğrulama başlatılmamıştır. |
| `VALIDATION_IN_PROGRESS` | Stok, kredi ve lot kontrolleri devam etmektedir. |
| `APPROVED` | Bütün zorunlu kontroller başarıyla tamamlanmıştır. |
| `REJECTED` | En az bir zorunlu iş kuralı başarısız olmuştur. |
| `PENDING_REVIEW` | Teknik hata, timeout veya eksik doğrulama nedeniyle manuel inceleme gerekmektedir. |
| `FINANCE_REVIEW` | Kredi limiti veya finansal onay kontrolü beklenmektedir. |
| `STOCK_REVIEW` | Kullanılabilir stok yetersizliği veya stok uyuşmazlığı bulunmaktadır. |
| `LOT_REVIEW` | Lot, raf ömrü veya kalite statüsü uygun değildir. |
| `ERP_TRANSFERRED` | Sipariş başarıyla ERP sistemine aktarılmıştır. |
| `TRANSFER_FAILED` | ERP aktarımı sırasında teknik hata oluşmuştur. |
| `CANCELLED` | Sipariş iptal edilmiştir. |

## Durum geçiş kuralı

`APPROVED` durumuna yalnızca aşağıdaki koşullar sağlandığında geçilebilir:

```text
stock_check_status       = PASSED
credit_check_status      = PASSED
lot_check_status         = PASSED
shelf_life_check_status  = PASSED
quality_check_status     = PASSED
technical_status         = SUCCESS
```

Bu koşullardan herhangi biri sağlanmıyorsa `APPROVED` durumuna geçiş engellenmelidir.

---

# 12. GÜVENLİ HATA YÖNETİMİ

## 12.1 Fail-Closed Kuralı

Aşağıdaki durumlarda sistem işlemi güvenli şekilde durdurmalıdır:

- Stored Procedure timeout
- Veri tabanı bağlantı hatası
- ERP servis erişim hatası
- Eksik doğrulama sonucu
- Beklenmeyen API hatası
- Yanıt formatı doğrulama hatası
- İşlem bütünlüğü hatası

Bu durumlarda:

```text
order_status      = PENDING_REVIEW
validation_status = ERROR
erp_transfer      = BLOCKED
stock_reservation = BLOCKED
```

Teknik hata hiçbir koşulda başarılı iş kuralı sonucu olarak yorumlanamaz.

---

## 12.2 Timeout Yönetimi

API zaman aşımı değeri ortam konfigürasyonundan yönetilmelidir.

```text
SALES_ORDER_VALIDATION_TIMEOUT_MS
```

Timeout oluştuğunda:

1. İşlem hata koduyla loglanmalıdır.
2. Sipariş `PENDING_REVIEW` durumuna alınmalıdır.
3. ERP aktarımı başlatılmamalıdır.
4. Stok rezervasyonu yapılmamalıdır.
5. Operasyon ekibi için alarm oluşturulmalıdır.
6. İşlem tekrar denenebilir durumda saklanmalıdır.

Örnek hata kodu:

```text
VALIDATION_TIMEOUT
```

---

## 12.3 Mükerrer İşlem Kontrolü

Her sipariş isteği benzersiz bir `idempotency_key` içermelidir.

Aynı anahtarla ikinci kez işlem yapılırsa sistem:

- Yeni ERP siparişi oluşturmamalıdır.
- Yeni stok rezervasyonu yapmamalıdır.
- İlk işlem sonucunu döndürmelidir.
- Tekrar isteğini loglamalıdır.

---

# 13. ERP AKTARIM KONTROL KAPISI

ERP aktarımından hemen önce aşağıdaki kontroller yeniden doğrulanmalıdır:

| Kontrol | Zorunlu Sonuç |
|---|---|
| Stok kontrolü | `PASSED` |
| Kredi kontrolü | `PASSED` |
| Lot kontrolü | `PASSED` |
| Raf ömrü kontrolü | `PASSED` |
| Kalite blokaj kontrolü | `PASSED` |
| Teknik doğrulama | `SUCCESS` |
| Sipariş durumu | `APPROVED` |
| Mükerrer işlem kontrolü | `UNIQUE` |

Herhangi bir sonuç eksik veya başarısızsa:

```text
ERP_TRANSFER = BLOCKED
```

Kontrol kapısı atlanamaz veya manuel olarak devre dışı bırakılamaz.

---

# 14. VERİ KAYIT GEREKSİNİMLERİ

Her satış siparişi için aşağıdaki doğrulama bilgileri saklanmalıdır:

| Alan | Açıklama |
|---|---|
| `order_id` | Satış siparişi benzersiz kimliği |
| `validation_id` | Doğrulama işlem kimliği |
| `stock_check_status` | Stok kontrol sonucu |
| `credit_check_status` | Kredi kontrol sonucu |
| `lot_check_status` | Lot kontrol sonucu |
| `shelf_life_check_status` | Raf ömrü kontrol sonucu |
| `quality_check_status` | Kalite blokaj kontrol sonucu |
| `technical_status` | Teknik işlem sonucu |
| `validation_code` | Sonuç veya hata kodu |
| `validation_message` | Sonuç açıklaması |
| `validation_started_at` | Doğrulama başlangıç zamanı |
| `validation_completed_at` | Doğrulama bitiş zamanı |
| `processing_duration_ms` | Toplam işlem süresi |
| `idempotency_key` | Mükerrer işlem kontrol anahtarı |
| `erp_transfer_status` | ERP aktarım sonucu |
| `created_by` | İşlemi başlatan kullanıcı veya servis |
| `created_at` | Kayıt oluşturma tarihi |

---

# 15. API YANIT STANDARDI

## Başarılı doğrulama

```json
{
  "success": true,
  "orderStatus": "APPROVED",
  "validationStatus": "PASSED",
  "validationCode": "ALL_CHECKS_PASSED",
  "erpTransferAllowed": true
}
```

## İş kuralı reddi

```json
{
  "success": false,
  "orderStatus": "STOCK_REVIEW",
  "validationStatus": "REJECTED",
  "validationCode": "INSUFFICIENT_STOCK",
  "erpTransferAllowed": false
}
```

## Teknik hata

```json
{
  "success": false,
  "orderStatus": "PENDING_REVIEW",
  "validationStatus": "ERROR",
  "validationCode": "VALIDATION_TIMEOUT",
  "erpTransferAllowed": false
}
```

---

# 16. KABUL KRİTERLERİ

## AC-01 – Başarılı Sipariş Onayı

**Given:** Stok, kredi, lot, raf ömrü ve kalite kontrolleri başarılıdır.  
**When:** Satış siparişi doğrulama işlemi tamamlanır.  
**Then:** Sipariş `APPROVED` durumuna alınmalı ve ERP aktarımına izin verilmelidir.

---

## AC-02 – Timeout Durumu

**Given:** Satış siparişi doğrulama işlemi başlatılmıştır.  
**When:** Stored Procedure tanımlı süre içerisinde yanıt vermez.  
**Then:** Sipariş `PENDING_REVIEW` durumuna alınmalı, ERP aktarımı ve stok rezervasyonu engellenmelidir.

---

## AC-03 – Yetersiz Stok

**Given:** Kullanılabilir stok sipariş miktarından düşüktür.  
**When:** Stok kontrolü çalıştırılır.  
**Then:** Sipariş otomatik olarak onaylanmamalı ve `STOCK_REVIEW` durumuna alınmalıdır.

---

## AC-04 – Yetersiz Kredi Limiti

**Given:** Müşteri kullanılabilir kredi limiti sipariş toplamını karşılamamaktadır.  
**When:** Kredi kontrolü çalıştırılır.  
**Then:** Sipariş `FINANCE_REVIEW` durumuna alınmalı ve ERP aktarımı engellenmelidir.

---

## AC-05 – Kalite Blokajlı Lot

**Given:** Seçilen lot kalite blokajı durumundadır.  
**When:** Lot uygunluk kontrolü çalıştırılır.  
**Then:** Lot rezerve edilmemeli ve sipariş `LOT_REVIEW` durumuna alınmalıdır.

---

## AC-06 – Raf Ömrü Uygun Olmayan Lot

**Given:** Lotun kalan raf ömrü minimum sevkiyat süresinin altındadır.  
**When:** Raf ömrü kontrolü çalıştırılır.  
**Then:** Lot satışa kapatılmalı ve sipariş ERP sistemine aktarılmamalıdır.

---

## AC-07 – Eksik Doğrulama Sonucu

**Given:** Zorunlu kontrollerden en az birinin sonucu bulunmamaktadır.  
**When:** ERP aktarım kontrol kapısı çalıştırılır.  
**Then:** ERP aktarımı engellenmeli ve sipariş `PENDING_REVIEW` durumuna alınmalıdır.

---

## AC-08 – Mükerrer İstek

**Given:** Aynı `idempotency_key` ile daha önce sipariş işlenmiştir.  
**When:** Aynı sipariş isteği yeniden gönderilir.  
**Then:** Yeni ERP siparişi veya stok rezervasyonu oluşturulmamalıdır.

---

## AC-09 – Teknik Hata Kaydı

**Given:** API veya veri tabanı işlemi sırasında teknik hata oluşmuştur.  
**When:** Hata yönetimi çalıştırılır.  
**Then:** Hata kodu, açıklaması, işlem süresi ve sipariş kimliği loglanmalıdır.

---

## AC-10 – Başarılı Akış Regresyonu

**Given:** Bütün zorunlu kontroller başarılıdır.  
**When:** Yeni hata yönetimi kuralları aktifken sipariş oluşturulur.  
**Then:** Mevcut başarılı satış siparişi akışı kesintisiz biçimde tamamlanmalıdır.

---

# 17. İZLEME VE RAPORLAMA GEREKSİNİMLERİ

Aşağıdaki göstergeler sistem tarafından izlenmelidir:

| KPI | Hedef |
|---|---:|
| Kontrol sonucu olmadan onaylanan sipariş | 0 |
| Timeout sonrası ERP aktarımı | 0 |
| Kalite blokajlı lot rezervasyonu | 0 |
| Raf ömrü uygun olmayan lot rezervasyonu | 0 |
| Kredi kontrolü olmadan sipariş onayı | 0 |
| Mükerrer ERP siparişi | 0 |
| Kritik teknik hataların loglanma oranı | %100 |
| Timeout durumunda güvenli statüye alınma oranı | %100 |

Alarm oluşturulması gereken durumlar:

- API timeout sayısının belirlenen eşik değeri aşması
- Stored Procedure işlem süresinin belirlenen sınırı aşması
- `PENDING_REVIEW` sipariş sayısında ani artış
- Kalite blokajlı lot rezervasyon girişimi
- ERP aktarım hatası
- Mükerrer sipariş girişimi

---

# 18. İZLENEBİLİRLİK MATRİSİ

| Gereksinim | İlgili 8D Bulgusu | İlgili Kabul Kriteri |
|---|---|---|
| Fail-closed hata yönetimi | Oluşum kök nedeni | AC-02, AC-07 |
| ERP öncesi kontrol kapısı | Kaçış kök nedeni | AC-07 |
| Stored Procedure performans kontrolü | Teknik tetikleyici | AC-02 |
| Kontrol sonuçlarının ayrı saklanması | Veri modeli eksikliği | AC-01, AC-07 |
| Kalite blokajlı lot engeli | Lot uygunluk riski | AC-05 |
| Raf ömrü kontrolü | Raf ömrü riski | AC-06 |
| İdempotency kontrolü | Mükerrer işlem riski | AC-08 |
| Teknik hata loglama | İzleme eksikliği | AC-09 |
| Negatif senaryo testi | Test kapsamı eksikliği | AC-02–AC-09 |

---

# 19. İLGİLİ DOKÜMANLAR

| Doküman | Referans |
|---|---|
| 8D Problem Çözme Raporu | `11_customer_quality_8d_case/01_8d_problem_solving_report.md` |
| Balık Kılçığı Kök Neden Analizi | `11_customer_quality_8d_case/02_fishbone_root_cause_analysis.md` |
| Satış Siparişi Kontrol Gereksinimi | `sales_order_control_spec.md` |

---

# 20. REVİZYON GEÇMİŞİ

| Revizyon | Tarih | Değişiklik |
|---|---|---|
| 1.0 | Mevcut sürüm | İlk satış siparişi kontrol gereksinimleri oluşturuldu. |
| 1.1 | 02.08.2026 | Timeout, fail-closed, ERP kontrol kapısı, lot uygunluğu, raf ömrü, hata yönetimi ve negatif kabul kriterleri eklendi. |