# برومبت تصميم واجهات وتجربة المستخدم للجوال (Mobile UI/UX Prompt for Stitch AI & AI UI Generators)
**المشروع:** تطبيق تحضير اللاعبين والانضباط - نادي تضامن حضرموت (MONAZ)  
**المنصة المستهدفة:** هواتف ذكية (Mobile Smartphone Portrait: 390x844 / 412x915)  
**النمط المطلوب:** تصميم فاتح (Light Mode) عالي التباين للميدان تحت أشعة الشمس، بشري واحترافي 100%، خالٍ تماماً من كليشيهات الذكاء الاصطناعي  
**الهوية المعتمدة:** الأزرق الملكي التضامني والأبيض المستوحى من شعار النادي الرسمي (1959)  

---

## 📋 إرشادات الاستخدام المباشر
انسخ النص أدناه والصقه مباشرة في **Google Stitch AI**, **v0.dev**, **Claude 3.5 Sonnet**, أو أدوات **Figma AI**. تم تصميم هذا البرومبت هندسياً لإنتاج شاشات **تطبيق جوال أصيل (Native Mobile App)** مخصص للاستخدام الميداني بيد واحدة.

---

```markdown
# Role & Context
Act as a world-class Principal Mobile Product Designer. Design a complete, high-contrast, human-centered Mobile UI/UX system and 7 core smartphone screens for "تطبيق تحضير اللاعبين والانضباط - نادي تضامن حضرموت" (Tadamon Hadramout Club Mobile Offline Attendance App), developed by MONAZ.

# Target Device & Mobile Ergonomics
- Viewport: Mobile Smartphone Portrait (390x844pt / 412x915dp).
- One-Handed Field Operation: The club administrator operates the phone with one hand while walking on the grass pitch. Every primary action button MUST reside strictly within the bottom "Thumb Zone" (bottom 25% of viewport).
- Touch Targets: Minimum 48x48dp, with primary CTA buttons at 56dp height.
- Sunlight Readability: High-contrast pure Light Mode (WCAG AAA compliant), bold dark text (#0F172A) on crisp white and soft slate canvas.

# Strict Design Philosophy & Anti-AI Rules
1. ZERO AI TROPES: No purple/cyan neon gradients, no blurry glassmorphism, no card-in-card nesting clutter, no washed-out #888 gray text.
2. SPORTS IDENTITY: Inspired by Tadamon Hadramout Club official crest (founded 1959, featuring the white jumping Arabian Ibex/الوعل). Primary Color is Royal Athletic Blue (#0E4B94) with pure white (#FFFFFF), slate neutrals, and high-visibility status semantics.
3. ICONOGRAPHY: Strict exclusive use of Lucide Icons (1.75px uniform stroke) inside rounded squircle containers (border-radius 10-12px) with a 10% semantic color tint.
4. LANGUAGE & DIRECTION: Native Arabic (RTL - Right to Left) with modern typography (Cairo or Tajawal font). Authentic sports administration copywriting only.

---

# Global Mobile Design System Tokens (Light Mode)

### Color Palette:
- Brand Primary: Deep Royal Blue `#0E4B94` (Top headers, active bottom nav, primary CTAs)
- Brand Secondary / Accent: Deep Blue `#1E60B5` (Interactive highlights, borders)
- Background Canvas: Crisp Cool Slate `#F8FAFC`
- Surface / Cards: Pure White `#FFFFFF`
- Card Borders: Subtle Slate Line `#E2E8F0` (1px solid)
- Primary Text: Midnight Slate `#0F172A` (Bold, highly legible)
- Secondary Text: Balanced Slate `#475569`
- Status Semantics (Clear Field Indicators):
  * Present (حاضر): Field Emerald Green `#15803D` (Bg tint: `#DCFCE7`)
  * Excused Absence (غائب بعذر): Amber Gold `#B45309` (Bg tint: `#FEF3C7`)
  * Unexcused Absence (غائب بدون عذر): Crimson Red `#B91C1C` (Bg tint: `#FEE2E2`)
  * Late / Session: Royal Indigo `#4338CA` (Bg tint: `#EEF2FF`)

### Mobile Typography Hierarchy (Arabic Cairo / Tajawal):
- Screen Title: 20sp / 26px, Bold (w700), `#0F172A`
- Section Heading: 16sp / 22px, SemiBold (w600), `#0F172A`
- Player Name / Key Counter: 16sp - 17sp, Bold (w700), `#0F172A`
- Body Text: 14sp / 18px, Regular (w400), `#475569`
- Subtext / Badge: 12sp / 16px, Medium (w500)

### Shapes & Shadows:
- Card Radius: 14px - 16px
- Squircle Icon Container Radius: 10px - 12px
- Button Radius: 12px
- Elevation: Clean drop-shadow `0 2px 6px rgba(15, 23, 42, 0.05)`

---

# Screen-by-Screen Detailed Mobile Specifications

## SCREEN 1: شاشة تفعيل وترخيص الجهاز (Mobile Hardware Activation)
- Viewport: Mobile Portrait (390x844)
- Layout: Clean vertical single-column card layout.
- Header (Top 25%):
  * Official Tadamon Hadramout Club Shield Logo (centered, 72x72px, blue shield with white jumping Ibex).
  * App Title: "نظام تحضير اللاعبين والانضباط" (18sp bold).
  * Subtitle: "النسخة الميدانية المستقلة (100% Offline)".
- Content Card (Pure White, radius 16px, border 1px #E2E8F0, padding 16px):
  1. Device ID Box:
     - Label: "معرّف الجهاز (Device ID):" (13sp slate).
     - Row: Monospace code pill `TD-7A39-E410` + IconButton `[نسخ]` (`Lucide.copy`, blue tint).
     - Explanatory note: "أرسل هذا المعرّف لفريق موناز (MONAZ) للحصول على كود التفعيل".
  2. Activation Key Input:
     - Label: "كود التفعيل المشفر:" (13sp slate).
     - Modern segmented text field: `TDMN - XXXX - XXXX - XXXX`.
  3. Action CTA (Thumb Zone):
     - Full-width Royal Blue Button: `تفعيل النظام` (height 52dp, `Lucide.keyRound`, white text).
- Bottom Safe Area Note:
  - Small lock icon + "تفعيل عتادي مشفر Ed25519 | يعمل بدون إنترنت نهائياً".

---

## SCREEN 2: الشاشة الرئيسية (Mobile Home Dashboard)
- Viewport: Mobile Portrait (390x844)
- Top App Bar:
  * Right: Tadamon Club Shield Logo (32x32px) + "نادي تضامن حضرموت" + Team Badge ("الفريق الأول").
  * Left: Active Package Pill: "باقة الموسم | 140 يوماً" (`Lucide.shieldCheck`, green badge).
- Scrollable Content:
  1. Hero Today's Session Card (Crisp White, 16px radius, blue right-border 4px solid #0E4B94):
     - Row: Badge `حصة تمرين اليوم` (`Lucide.calendarClock`) + Time `الفترة المسائية`.
     - Date: "الثلاثاء، 6 أكتوبر 2026".
     - Location: "ملعب منشأة الفقيد بارادم".
     - Huge Thumb Button:
       `[بدء تحضير تمرين اليوم]` (Royal Blue #0E4B94, height 54dp, bold white text, `Lucide.playCircle`).
     - Subtext link: `[تعديل بيانات الحصة (اختياري)]`.
  2. Quick Counters Row (3 compact square cards side-by-side):
     - Card 1: `0 / 27` (Large 20sp bold green) -> "حاضر".
     - Card 2: `0` (Large 20sp bold red) -> "غائب".
     - Card 3: `27` (Large 20sp bold slate) -> "لم يُسجل".
  3. Quick Actions Grid (2 clean outline cards):
     - `[+ إضافة تمرين استثنائي]` (`Lucide.plusCircle`).
     - `[سجل الكشوفات السابقة]` (`Lucide.history`).
     - In Master Admin Mode: Prominent Action Button: `[📷 استقبال تمرين مرحّل عبر QR]` (`Lucide.scanLine`, Blue tint, 48dp).
- Persistent Mobile Bottom Navigation Bar (Height 64dp, white, border-top 1px #E2E8F0):
  * Master Mode (5 Items): [الرئيسية] | [التحضير] | [اللاعبون] | [التقارير] | [الإعدادات]
  * Field Attendance Mode (2 Items): [الرئيسية] | [التحضير الميداني] (Minimalist distraction-free layout).

---

## SCREEN 3: شاشة التحضير الميداني السريع للجوال (Fast 1-Click Mobile Attendance)
- Viewport: Mobile Portrait (390x844)
- Fixed Header Bar:
  * Compact Search Bar: `ابحث باسم اللاعب أو رقمه...` (`Lucide.search`).
  * Horizontal Filter Chips: `[الكل 27]` | `[الحاضرون 24]` | `[الغائبون 2]` | `[المعذورون 1]`.
- 1-Click Field Accelerator Banner (Directly under search):
  * Full-width Emerald Green Action Button:
    `[⚡ تحديد الجميع حاضر (27 لاعب)]` (height 48dp, white text, `Lucide.checkCheck`).
- Player Attendance List (Smooth vertical scroll, height 74dp per row):
  * Compact Player Card Anatomy (White, radius 12px, border 1px #E2E8F0, margin-bottom 8px):
    - Right side: Squircle badge `[10]` (Blue #0E4B94) + Player Name "سالم مبارك النهدي" (Bold 16sp) + Position "وسط".
    - Left side: 3 Thumb-Friendly Toggle Pills (Size 38x34dp each, grouped):
      * `حاضر` (Green #15803D when selected, white text).
      * `بعذر` (Amber #B45309 when selected, white text).
      * `غائب` (Red #B91C1C when selected, white text).
    - Tapping "بعذر" pops a bottom mini-sheet for rapid reason pick (إصابة، عذر عمل، سفر، دراسة).
- Floating Sticky Bottom Action Bar (Fixed over list, blur background with white surface):
  * Status: "تم رصد 27 من 27 لاعب | مسودة محفوظة تلقائياً ✅" (12sp).
  * Primary Button: `إنهاء ومراجعة الكشف` (Royal Blue #0E4B94, height 52dp, full width, `Lucide.arrowLeft`).

---

## SCREEN 4: شاشة المراجعة وقفل الترحيل والمزامنة (Review, Dispatch Lock & Sync)
- Viewport: Mobile Portrait (390x844)
- Screen Title: "مراجعة كشف تمرين اليوم" (الثلاثاء 6 أكتوبر 2026).
- Summary Badge Banner (3 compact pill statistics):
  * `حاضر: 24` (Green) | `غائب بعذر: 2` (Amber) | `غائب بدون عذر: 1` (Red).
- Validation Engine Card:
  * Case A (Incomplete): Warning Card in Amber `#FEF3C7`:
    "تنبيه: يوجد لاعب لم ترصد حالته بعد!" -> Displays the unrecorded player cards with 1-tap toggles right on the screen to resolve instantly.
  * Case B (Complete): Green Success Card `#DCFCE7`:
    "اكتمل رصد جميع اللاعبين (27/27). الكشف جاهز للترحيل أو الاعتماد."

### وضعان تفاعليان للشاشة (Dual Device Modes):
1. **في جهاز الميدان (Field Attendance Device):**
   - Bottom Thumb CTA:
     * Primary Full-Width Button: `[🔒 ترحيل التمرين إلى الإدارة]` (Royal Blue #0E4B94, height 54dp, `Lucide.send`).
   - بمجرد النقر والترحيل (Instant Lock State):
     * يتحول التمرين فوراً إلى وضع القراءة فقط وتُعطل كافة أزرار التعديل مع ظهور شارة `[مرحّل ومقفل إدارياً 🔒]`.
     * تنبثق بطاقة كود الاستجابة السريعة الديناميكي (Air-Gap QR Code Card):
       - رمز QR بدقة عالية في منتصف الشاشة يمثل الحزمة المشفرة الموقعة بـ HMAC.
       - نص إرشادي: "وجّه كاميرا جهاز الإدارة لمسح هذا الرمز واستيراد الكشف فوراً دون إنترنت".

2. **في جهاز الإدارة والاعتماد (Master Admin Device):**
   - عرض كشف التمرين المستلم من الميدان أو المحضر إدارياً.
   - Bottom Thumb CTA:
     * زر الاعتماد النهائي: `[اعتماد الكشف نهائياً]` (`Lucide.shieldCheck`, Royal Blue #0E4B94, 54dp height).
     * زر التعديل الاستثنائي: `[تعديل استثنائي (يتطلب تدوين السبب)]` (`Lucide.edit3`, Outline button).

---

## SCREEN 5: شاشة اللاعبين وملفاتهم للجوال (Mobile Players Directory)
- Viewport: Mobile Portrait (390x844)
- Top Bar:
  * Search field + Filter Dropdown `[الفريق الأول ▾]`.
- Floating Action Button (FAB) at bottom-left:
  * Circular Royal Blue FAB `[+]` with `Lucide.userPlus` (56x56dp).
- Player Feed Items (White cards, radius 14px):
  * Row:
    - Avatar placeholder / Jersey Number `#7`.
    - Player Info: Name "عمر أحمد باسويد" (Bold 16sp) | Team "الفريق الأول" | Position "مهاجم".
    - Enrollment: "انضم: 1 سبتمبر 2026".
    - Attendance Pill: "حضور: 95% (19 من 20)" (Green pill).
    - 3-Dot Menu / Action: `[فتح السجل]` / `[أرشفة]`.
- Bottom Sheet (Add New Player):
  * Clean bottom sheet containing only essential fields: الاسم الكامل، الفريق، تاريخ الانضمام، رقم القميص، المركز.

---

## SCREEN 6: شاشة السجل والتقارير وتصدير النموذجين للجوال (Mobile Reports & Export)
- Viewport: Mobile Portrait (390x844)
- Top Filter: "الشهر: أكتوبر 2026" + "الفريق: الفريق الأول".
- Tab Segment Control (Full Width):
  * `[حافظة التحضير (شهري)]` | `[خلاصة الإداري (تجميعي)]`.
- Mobile Tab 1: «حافظة التحضير مفتوحة»:
  * Card preview showing month stats + Swipe indicator: "اسحب أفقياً لاستعراض شبكة أيام الشهر (1 إلى 31)".
  * Export Action Buttons (Stack in bottom zone):
    - Button 1: `[📄 تصدير كشف الحافظة PDF للطباعة والمشاركة]` (Primary Blue, 50dp height).
    - Button 2: `[📊 تصدير ملف Excel]` (Clean outline button, 46dp height).
- Mobile Tab 2: «كشف التحضير مع خلاصة الإداري»:
  * Summary Cards List: Each card displays:
    اسم اللاعب | إجمالي التمارين: 24 | الحضور: 22 | الغياب بعذر: 2 | الاستحقاق الرياضي: 24 حصة | الملاحظات.
  * Preview of Official Signatures: "إداري الفريق: ......." | "مدير النادي: .......".
  * Export Action Buttons:
    - Button 1: `[📄 تصدير خلاصة الإداري PDF جاهز للطباعة]` (Primary Blue, 50dp height).
    - Button 2: `[📊 تصدير خلاصة الإداري Excel]` (Clean outline, 46dp height).

---

## SCREEN 7: شاشة الإعدادات والنسخ الاحتياطي للجوال (Mobile PIN-Protected Settings)
- Viewport: Mobile Portrait (390x844)
- Security Gate: Sleek 4-digit numeric keypad lock screen if PIN is enabled.
- Settings List:
  1. بطاقة النادي (Club Card):
     - Shield Logo + "نادي تضامن حضرموت" | الموسم "2026 - 2027" | اسم الإداري والمدير للتوقيعات.
  2. قسم النسخ الاحتياطي وسلامة البيانات (Data Safety Card):
     - Card: `النسخ الاحتياطي المحلي لقاعدة البيانات (SQLite)`
     - Button: `[تصدير نسخة احتياطية إلى USB / مجلد خارجي]` (`Lucide.hardDriveDownload`).
     - Button: `[استعادة نسخة سابقة]` with confirmation modal (`Lucide.refreshCw`).
     - System Note: "نظام الترقية التلقائي مفعل (Drift Migrations) - لا خوف من فقد البيانات عند التحديث".
  3. بطاقة الترخيص والجهاز (License Card):
     - Device ID: `TD-7A39-E410` (with copy icon).
     - Package: `موسم رياضي كامل (سارٍ حتى 6 أكتوبر 2027) ✅`.
```
