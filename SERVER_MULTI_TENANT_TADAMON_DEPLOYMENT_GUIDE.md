# دليل نشر وتشغيل مشروع تضامن حضرموت على خادم الإنتاج (VPS Deployment Guide)
**نظام إدارة التحضير الرياضي الميداني وتوليد التراخيص (MONAZ Tadamon)**
**خادم Contabo VPS (`80.241.208.214`) — بيئة Docker Multi-Tenant المشتركة**

---

## 1. بيانات النشر وحجز المنافذ (Deployment Specification)

| البند | القيمة المعتمدة |
| :--- | :--- |
| **اسم المشروع على السيرفر** | `monaz-tadamon` |
| **المسار الكامل على الخادم** | `/home/hasan/apps/monaz-tadamon` |
| **المنفذ الداخلي المعزول (Host Port)** | **`127.0.0.1:8004:80`** (المنفذ الشاغر المخصص) |
| **اسم الحاوية (Container Name)** | `tadamon_portal_app` |
| **شبكة الدوكر (Docker Network)** | `tadamon_network` (معزولة بالكامل) |
| **مستخدم السيرفر** | `hasan` (صلاحيات `sudo` و `docker`) |
| **عنوان السيرفر (IP)** | `80.241.208.214` |
| **نطاق النشر المقترح (Domain)** | `attendance.yourdomain.com` (أو أي نطاق فرعي من اختيارك) |

---

## 2. جدول توزيع المنافذ على الخادم (Port Allocation Table)

| المنفذ الداخلي (Localhost) | اسم التطبيق | المسار على السيرفر | الرابط (Domain) | الحالة |
| :--- | :--- | :--- | :--- | :--- |
| `127.0.0.1:8001:80` | **WINNER GYM** | `/home/hasan/apps/winner-gym` | `winnergym1.com` | ✅ نشط |
| `127.0.0.1:8002:80` | **GOBAN API** | `/home/hasan/apps/goban-system` | `api.gobanpharma.com` | ✅ نشط |
| `127.0.0.1:8003:80` | **GOBAN Admin Web** | `/home/hasan/apps/goban-system` | `gobanpharma.com` | ✅ نشط |
| **`127.0.0.1:8004:80`** | **MONAZ Tadamon Portal & API** | **`/home/hasan/apps/monaz-tadamon`** | **`attendance.yourdomain.com`** | 🚀 **جاهز للنشر الآن** |
| `127.0.0.1:8005:80` | مشروع إضافي مستقبلي | `/home/hasan/apps/<app5>` | `app5.yourdomain.com` | ⚪ شاغر |

---

## 3. ما يقدمه هذا المشروع على السيرفر (Production Services Provided)

بمجرد تشغيل الحاوية، سيوفر السيرفر الخدمات المركزية التالية:
1. **بوابة التراخيص الرسمية المشفرة (Ed25519 Web Portal):**
   * إدخال بصمة الجهاز العتادية واستخراج كود تفعيل معتمد مشفر بالمفتاح الخاص للنادي.
   * دعم التفعيل المفرد (Single Device) أو المزدوج لجهازي الإدارة والميدان (Dual Master & Field Pairing).
2. **مركز التوزيع والتحميل المباشر للأجهزة (Distribution Hub):**
   * رابط مباشر لتحميل تطبيق الأندرويد الميداني الرسمي: `https://attendance.yourdomain.com/download/apk`
   * رابط مباشر لتحميل أداة التفعيل المستقلة دون إنترنت: `https://attendance.yourdomain.com/download/offline-tool`
3. **واجهات المزامنة السحابية (Dispatched Sessions Cloud Sync API):**
   * استقبال الحصص الرياضية بعد انتهاء تمرين الميدان عبر الـ Endpoints المؤمنة: `/api/sync/dispatch`.

---

## 4. خطوات النشر والتشغيل خطوة بخطوة (Step-by-Step Deployment)

### الخطوة 1: توجيه النطاق في مزود الـ DNS
في لوحة تحكم الدومين الخاص بك (Cloudflare / Namecheap / GoDaddy):
* أنشئ سجل **A Record**:
  * **Type:** `A`
  * **Name:** `attendance` (أو النطاق الفرعي المطلوب)
  * **IPv4 address:** `80.241.208.214`
  * **Proxy status:** DNS Only (رمادي) مؤقتاً لتسهيل التحقق من شهادة SSL.

---

### الخطوة 2: الدخول إلى الخادم وسحب المشروع
افتح الطرفية (Terminal / PowerShell) واتصل بالسيرفر عبر SSH:
```bash
ssh hasan@80.241.208.214
```

انتقل إلى مجلد التطبيقات واسحب مستودع المشروع:
```bash
cd /home/hasan/apps
git clone git@github.com:7assan-3li/monaz-tadamon-offline-attendance.git monaz-tadamon
cd monaz-tadamon
```

---

### الخطوة 3: بناء وتشغيل حاوية Docker
من داخل مجلد `/home/hasan/apps/monaz-tadamon`، شغّل الأمر التالي:
```bash
docker compose up -d --build
```

تحقق من حالة الحاوية والتأكد من أنها تعمل بنجاح:
```bash
docker compose ps
docker logs tadamon_portal_app -n 25
```
*(ستظهر رسالة: `MONAZ Tadamon Attendance Portal & Sync API Started!` وتعمل على المنفذ `127.0.0.1:8004`).*

---

### الخطوة 4: إعداد التوجيه العكسي في Host Nginx
أنشئ ملف إعداد Nginx الخاص بالمشروع:
```bash
sudo nano /etc/nginx/sites-available/tadamon.conf
```

ألصق الإعداد المعياري التالي (مع استبدال `attendance.yourdomain.com` برابط نطاقك الفعلي):
```nginx
server {
    listen 80;
    server_name attendance.yourdomain.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://127.0.0.1:8004;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
}
```
*(احفظ الملف بالضغط على `Ctrl+O` ثم `Enter`، ثم اخرج بـ `Ctrl+X`).*

فعّل ملف الإعداد وافحص Nginx ثم أعد تحميله:
```bash
sudo ln -s /etc/nginx/sites-available/tadamon.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### الخطوة 5: استخراج وتفعيل شهادة الحماية SSL مجاناً (Certbot)
استخرج شهادة HTTPS التلقائية للأمان العالي:
```bash
sudo certbot --nginx -d attendance.yourdomain.com
```

بذلك يصبح النظام حياً ومؤمناً برابط مشفر: `https://attendance.yourdomain.com` 🔒

---

## 5. التحقق من صحة وجاهزية النظام (Verification & Health Checks)

1. **فحص بوابة التراخيص في المتصفح:**
   افتح الرابط: `https://attendance.yourdomain.com`
   تأكد من ظهور واجهة «بوابة التراخيص الرسمية - نادي تضامن حضرموت» وشعار التشفير Ed25519.
2. **فحص تحميل تطبيق الميدان APK:**
   اضغط على زر «تحميل التطبيق (APK)» من رأس الصفحة، أو توجه مباشرة إلى:
   `https://attendance.yourdomain.com/download/apk`
3. **فحص أداة التفعيل دون إنترنت HTML:**
   `https://attendance.yourdomain.com/download/offline-tool`
4. **فحص واجهة المزامنة السحابية (API Health):**
   ```bash
   curl -I https://attendance.yourdomain.com/api/sync/sessions
   ```
   *(يجب أن يُرجع كود الاستجابة HTTP 200 OK).*

---

## 6. أوامر الصيانة والتحديث اليومية السريعة

```bash
# قراءة سجلات وأخطاء البوابة الحية
docker logs -f tadamon_portal_app

# إعادة تشغيل البوابة
cd /home/hasan/apps/monaz-tadamon
docker compose restart

# سحب أي تحديثات كود جديدة وتطبيقها دون توقف طويل
cd /home/hasan/apps/monaz-tadamon
git pull origin main
docker compose up -d --build
```
