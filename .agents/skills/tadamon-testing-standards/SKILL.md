---
name: tadamon-testing-standards
description: >-
  Strict automated testing standards for Tadamon Offline Attendance (Flutter & Laravel).
  Mandates writing and running Unit Tests, Functional/Integration Tests, BLoC Tests,
  Database Migration Tests, and Widget Tests for every code change or addition.
---

# المعايير الصارمة للاختبارات البرمجية والتحقق الآلي (Automated Testing Standards)
**تطبيق نادي تضامن حضرموت الميداني ولوحة تحكم MONAZ**

تُلزم هذه المهارة المساعد البرمجي (Agent) والمطور بكتابة وتشغيل اختبارات آلية شاملة تغطي كل وظيفة جديدة، تعديل برمجي، أو إصلاح لأي خلل، وضمان اجتيازها بنجاح تام (`100% Tests Passing`) قبل اعتبار المهمة منتهية.

---

## 1. هرم الاختبارات المعتمد في المشروع (Testing Pyramid)

```
        ▲
       / \         [ E2E / Flow Integration Tests ]
      /───\        (محاكاة جلسة تمرين كاملة + ترحيل Drift)
     /     \
    /───────\      [ Widget & Component Tests ]
   /         \     (أزرار الإبهام 48dp + دعم RTL + بطاقات اللاعبين)
  /───────────\
 /             \   [ Unit & BLoC Tests (Core Engine) ]
/───────────────\  (UseCases, BLoCs, Security/Ed25519, High-Watermark, Actions)
```

---

## 2. اختبارات تطبيق Flutter الميداني

### أ. اختبارات الوحدة لمنطق العمل (Domain & UseCases Unit Tests):
* **المسار:** `test/features/<feature_name>/domain/usecases/`
* **المطلوب:**
  * اختبار منطق حساب الاستحقاق الرياضي ونسب الغياب والحضور بدون أي أخطاء حسابية.
  * عزل المستودعات باستخدام مكتبة المحاكاة `mocktail`، واختبار ردود الفعل على حالات الفشل والنجاح (`Either<Failure, T>`).

### ب. اختبارات الـ MVVM وحالات الـ BLoC (Bloc Tests):
* **المسار:** `test/features/<feature_name>/presentation/bloc/`
* **المكتبة الإلزامية:** `bloc_test` مع `test`.
* **الحالات الواجب تغطيتها:**
  * اختبار حدث `StartTodaySessionEvent`: التأكد من انبعاث حالة التحضير المجهزة تلقائياً ببيانات افتراضية ذكية.
  * اختبار حدث `MarkAllPresentEvent`: التأكد من تحويل جميع بطاقات اللاعبين إلى "حاضر" بلحظة واحدة.
  * اختبار حدث `UpdatePlayerStatusEvent`: التأكد من تعديل حالة اللاعب (غائب بعذر/بدون عذر) وتحديث العدادات الرياضية فوراً.
  * اختبار حدث `SaveDraftEvent`: التأكد من حفظ المسودة تلقائياً في الخلفية.
  * **اختبار حدث `DispatchSessionEvent` (القفل الميداني):** التأكد من تحول الجلسة إلى حالة `Dispatched & Locked`، وتعيين `is_locked = 1` و `is_dispatched = 1`، وتعطيل كافة أزرار التعديل والحفظ في الواجهة.

### ج. اختبارات محرك المزامنة وقفل الترحيل (Offline Sync Engine Tests):
* **المسار:** `test/features/sync/`
* **المطلوب:**
  * **اختبار توليد وتوقيع حزمة الـ QR (Air-Gap QR Payload):** التأكد من توليد حزمة مضغوطة وموقعة بـ `HMAC-SHA256` تحتوي فقط على التغييرات (`Delta`) بحجم أقل من 350 بايت.
  * **اختبار استيراد وفك تشفير الجلسة (QR Import Test):** محاكاة قراءة كود الـ QR من جهاز الإدارة والتحقق من التوقيع ودمج الجلسة بحالة `pending_approval`.
  * **اختبار منع التكرار (Idempotency Test):** محاكاة استيراد نفس الجلسة بـ `session_uuid` متطابق مرتين والتأكد من عدم تكرار التمارين أو مضاعفة سجلات الحضور.
  * **اختبار الربط اللاسلكي المحلي (Local Wi-Fi / Hotspot Sync):** اختبار تبادل البيانات المرجعية (قوائم اللاعبين) عبر `HttpServer` المدمج دون اتصال بالإنترنت.

### د. اختبارات التشفير ومكافحة التلاعب (Security & Anti-Tamper Tests):
* **المسار:** `test/core/security/`
* **الحالات الصارمة:**
  * **اختبار Ed25519:** التأكد من قبول التوقيع الرقمي الصحيح المشتق من المفتاح الخاص، والرفض الفوري لأي كود تم التلاعب بمحتواه ولو بحرف واحد.
  * **اختبار High-Watermark:** محاكاة محاولة تراجع في ساعة النظام، والتأكد من رمي استثناء `ClockTamperedException` وقفل التطبيق في حالة `ClockTamperedState`.
  * **اختبار بصمة العتاد HMAC-SHA256:** التأكد من أن كود تفعيل مشتق لجهاز (A) يفشل تماماً ولا يمكن تفعيله على جهاز (B).
  * **اختبار رمز الـ PIN:** التأكد من مقارنة الرمز بوقت ثابت (`Constant-Time`) وعدم وجوده كنص صريح.

### هـ. اختبارات قاعدة بيانات Drift وترحيل الـ Schema (Database & Migration Tests):
* **المسار:** `test/core/database/`
* **التشغيل المنفصل:** استخدام قاعدة بيانات في الذاكرة حصراً:
  ```dart
  LazyDatabase(() async => NativeDatabase.memory());
  ```
* **فحص الترحيل (Schema Migrations):**
  * فحص كل انتقال بين إصدارات `schemaVersion` (مثلاً من v1 إلى v2) والتأكد من بقاء سجلات اللاعبين وحصص التحضير السابقة سليمة 100% دون أي حذف.

### و. اختبارات ودجات الواجهة المشتركة (Widget Tests):
* **المسار:** `test/core/widgets/`
* **المعايير المفحوصة:**
  * التأكد من استجابة ودجات `AppButton` و `AttendanceBadge` للنقر.
  * التأكد من أن مساحة النقر لا تقل عن `48x48dp` (اختبار بيئة الملاعب).
  * التأكد من سلامة العرض باللغة العربية (RTL) وعدم حدوث تجاوزات بصرية (Overflows).

---

## 3. اختبارات لوحة تحكم المزود (Laravel 12 / Pest / PHPUnit)

### أ. اختبارات كلاسات الأفعال المنفردة (Action Unit Tests):
* **المسار:** `tests/Unit/Actions/`
* **المطلوب:**
  * اختبار `GenerateLicenseCodeAction`: التأكد من توليد كود التفعيل بالترتيب الصارم للحقول (`Deterministic Canonical Ordering`).
  * اختبار `CalculatePackageDurationAction`: التأكد من حساب تواريخ انتهاء الباقة بدقة متناهية.
  * اختبار خدمة التوقيع الرقمي `Ed25519SignerService` والتأكد من صحة التوقيع بالمفتاح السري.

### ب. اختبارات الميزات والتحقق (Feature Tests):
* **المسار:** `tests/Feature/`
* **المطلوب:**
  * اختبار كلاسات الـ `FormRequest`: التأكد من رفض أي مدخلات لا تطابق نمط معرف العتاد (Regex: `^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$`).
  * اختبار صلاحيات الوصول وعزل شاشات التوليد عن المستخدمين غير المخولين.

---

## 4. أوامر التشغيل والتحقق الإلزامية

### لتطبيق Flutter:
```powershell
# تشغيل جميع الاختبارات
flutter test

# تشغيل اختبارات ميزة معينة
flutter test test/features/attendance/

# فحص نسبة التغطية
flutter test --coverage
```

### للوحة تحكم Laravel:
```powershell
# تشغيل كافة اختبارات Pest / PHPUnit
php artisan test
```

---

## 5. مصفوفة قواعد القبول الصارمة (Acceptance Rules)
1. **قاعدة الـ Green Suite الدائمة:** يُمنع تسليم أو دمج أي كود إذا كان هناك اختبار واحد فاشل (`Red`).
2. **قاعدة حظر الكود غير المغطى:** أي ميزة أو خوارزمية منطقية جديدة يجب أن ترافقها اختبارات وحدتها في نفس التعديل.
3. **قاعدة محاكاة الأجهزة دون شبكة:** جميع اختبارات Flutter تجري دون طلب أي خادم أو اتصال بالإنترنت وتعتمد على `NativeDatabase.memory()`.
