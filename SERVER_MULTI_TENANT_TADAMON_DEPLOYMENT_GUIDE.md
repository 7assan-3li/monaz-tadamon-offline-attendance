# دليل نشر وتشغيل نظام الحضور على خادم الإنتاج (VPS Deployment Guide)
**نظام إدارة التحضير الرياضي الميداني وتوليد التراخيص (MONAZ Tadamon Attendance)**
**خادم Contabo VPS (`80.241.208.214`) — بيئة Docker Multi-Tenant المشتركة**

---

## 1. بيانات النشر المعتمدة (Deployment Specification)

| البند | القيمة المعتمدة |
| :--- | :--- |
| **اسم المشروع / المجلد** | **`attendance`** |
| **المسار الكامل على الخادم** | **`/home/hasan/apps/attendance`** |
| **النطاق الرسمي (Domain)** | **`attendance.monaz.dev`** |
| **المنفذ الداخلي المعزول (Host Port)** | **`127.0.0.1:8004:80`** |
| **اسم الحاوية (Container Name)** | `attendance_app` |
| **شبكة الدوكر (Docker Network)** | `attendance_network` |
| **مستخدم السيرفر** | `hasan` (صلاحيات `sudo` و `docker`) |
| **عنوان السيرفر (IP)** | `80.241.208.214` |
| **ملف إعداد Nginx** | `/etc/nginx/sites-available/attendance.conf` |

---

## 2. جدول المنافذ المحدث على الخادم (Port Allocation Table)

| المنفذ الداخلي (Localhost) | اسم التطبيق | المسار على السيرفر | الرابط (Domain) | الحالة |
| :--- | :--- | :--- | :--- | :--- |
| `127.0.0.1:8001:80` | **WINNER GYM** | `/home/hasan/apps/winner-gym` | `winnergym1.com` | ✅ نشط |
| `127.0.0.1:8002:80` | **GOBAN API** | `/home/hasan/apps/goban-system` | `api.gobanpharma.com` | ✅ نشط |
| `127.0.0.1:8003:80` | **GOBAN Admin Web** | `/home/hasan/apps/goban-system` | `gobanpharma.com` | ✅ نشط |
| **`127.0.0.1:8004:80`** | **Attendance Portal & Sync** | **`/home/hasan/apps/attendance`** | **`attendance.monaz.dev`** | 🚀 **قيد التشغيل الآن** |
| `127.0.0.1:8005:80` | مشروع إضافي مستقبلي | `/home/hasan/apps/<app5>` | `app5.yourdomain.com` | ⚪ شاغر |

---

## 3. خطوات النشر والتشغيل التفصيلية خطوة بخطوة

### 🔹 الخطوة 1: ضبط سجل DNS لنطاق `attendance.monaz.dev`
في لوحة تحكم مزود الدومين الخاص بنطاق **`monaz.dev`** (سواء Cloudflare أو غيره):
* أنشئ سجل **A Record** جديد:
  * **Type:** `A`
  * **Name:** `attendance`
  * **IPv4 address:** `80.241.208.214`
  * **TTL:** Auto (أو 1 min)
  * **Proxy status:** DNS Only (سحابة رمادية مؤقتاً لتسهيل التحقق من شهادة SSL من قِبل Certbot).

---

### 🔹 الخطوة 2: الدخول إلى الخادم وسحب المشروع
افتح Terminal (أو PowerShell) على جهازك واتصل بالسيرفر:
```bash
ssh hasan@80.241.208.214
```

انتقل إلى المجلد المركزي للمشاريع واسحب مستودع المشروع باسم مجلد **`attendance`**:
```bash
cd /home/hasan/apps
git clone git@github.com:7assan-3li/monaz-tadamon-offline-attendance.git attendance
cd attendance
```

---

### 🔹 الخطوة 3: بناء وتشغيل حاوية Docker
من داخل مجلد `/home/hasan/apps/attendance`:
```bash
docker compose up -d --build
```

تحقق من أن الحاوية انطلقت بنجاح وبدون أي أخطاء:
```bash
docker compose ps
docker logs attendance_app -n 25
```
*(ستظهر رسالة النجاح: `MONAZ Tadamon Attendance Portal & Sync API Started!` وتعمل داخلياً على `127.0.0.1:8004`).*

---

### 🔹 الخطوة 4: إنشاء وضبط التوجيه في Host Nginx
أنشئ ملف الإعداد للنطاق:
```bash
sudo nano /etc/nginx/sites-available/attendance.conf
```

ألصق الإعداد التالي بداخله:
```nginx
server {
    listen 80;
    server_name attendance.monaz.dev;

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
*(احفظ الملف بالضغط على `Ctrl+O` ثم `Enter`، واخرج بـ `Ctrl+X`).*

فعّل ملف الموقع واختبر سلامة إعدادات Nginx ثم أعد تحميله:
```bash
sudo ln -s /etc/nginx/sites-available/attendance.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### 🔹 الخطوة 5: استخراج وتفعيل شهادة SSL مجاناً (Let's Encrypt)
نفّذ الأمر التالي:
```bash
sudo certbot --nginx -d attendance.monaz.dev
```
*(سيقوم Certbot بالتحقق من الدومين وتعديل ملف Nginx تلقائياً لفرض التشفير الآمن `HTTPS`).*

---

## 4. التحقق واختبار النظام المباشر (Health Checks)

بعد اكتمال الخطوات، افتح الروابط التالية للتأكد من الجاهزية التامة:

1. **بوابة التراخيص والمزامنة الرسمية:**
   * الرابط: [https://attendance.monaz.dev](https://attendance.monaz.dev)
   * تأكد من ظهور شارة: «تشفير Ed25519 نشط».
2. **تحميل تطبيق الأندرويد الميداني المعتمد (APK):**
   * الرابط المباشر: [https://attendance.monaz.dev/download/apk](https://attendance.monaz.dev/download/apk)
3. **تحميل أداة التفعيل المستقلة دون إنترنت (HTML):**
   * الرابط المباشر: [https://attendance.monaz.dev/download/offline-tool](https://attendance.monaz.dev/download/offline-tool)
4. **فحص جاهزية واجهة المزامنة السحابية (Cloud Sync API):**
   ```bash
   curl -I https://attendance.monaz.dev/api/sync/sessions
   ```
   *(يجب أن تُعيد استجابة `HTTP/2 200`).*

---

## 5. أوامر الصيانة والتحديث المستقبلية السريعة

```bash
# عرض سجلات وأخطاء البوابة لحظياً
docker logs -f attendance_app

# إعادة تشغيل التطبيق
cd /home/hasan/apps/attendance
docker compose restart

# سحب أي تعديلات كود جديدة وإعادة البناء
cd /home/hasan/apps/attendance
git pull origin main
docker compose up -d --build
```
