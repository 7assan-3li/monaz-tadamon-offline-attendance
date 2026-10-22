<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>بوابة إدارة النادي وتراخيص الأجهزة | {{ $club->club_name ?? 'نادي تضامن حضرموت' }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        body {
            font-family: 'Cairo', system-ui, -apple-system, sans-serif;
            background-color: #080f1e;
            color: #f1f5f9;
        }
        .club-accent-border {
            border-color: {{ $club->primary_color_hex ?? '#0F48A2' }};
        }
        .club-accent-bg {
            background-color: {{ $club->primary_color_hex ?? '#0F48A2' }};
        }
        .club-accent-text {
            color: {{ $club->primary_color_hex ?? '#0F48A2' }};
        }
        textarea::-webkit-scrollbar {
            width: 6px;
        }
        textarea::-webkit-scrollbar-track {
            background: #081220;
        }
        textarea::-webkit-scrollbar-thumb {
            background: #1e293b;
            border-radius: 4px;
        }
        textarea::-webkit-scrollbar-thumb:hover {
            background: #334155;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between selection:bg-blue-600 selection:text-white">

    <!-- Top Navigation Bar with Multi-Club Switcher -->
    <header class="border-b border-slate-800/80 bg-[#060c18]/90 backdrop-blur sticky top-0 z-50 shadow-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex flex-wrap items-center justify-between gap-4">
            <div class="flex items-center space-x-3.5 space-x-reverse">
                <a href="{{ route('clubs.index') }}" title="العودة إلى دليل كافة الأندية" class="flex-shrink-0">
                    <div class="w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg border border-white/10 overflow-hidden hover:scale-105 transition"
                         style="background: linear-gradient(135deg, {{ $club->primary_color_hex ?? '#0F48A2' }}, #081220);">
                        @if($club->logo_url)
                            <img src="{{ $club->logo_url }}" alt="{{ $club->club_name }}" class="w-full h-full object-cover">
                        @else
                            <span class="text-white font-black text-xl tracking-tight">{{ mb_substr($club->club_name, 5, 1) ?: 'ت' }}</span>
                        @endif
                    </div>
                </a>
                <div>
                    <div class="flex items-center gap-2">
                        <h1 class="text-base sm:text-lg font-black text-white tracking-wide">
                            {{ $club->club_name ?? 'نادي تضامن حضرموت الرياضي' }}
                        </h1>
                        <span class="text-[11px] px-2 py-0.5 rounded-full font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20 font-mono">
                            {{ $club->club_code ?? 'TDMN' }}
                        </span>
                        <span class="text-[11px] px-2 py-0.5 rounded-full font-bold bg-blue-500/10 text-blue-400 border border-blue-500/20">
                            {{ $club->season ?? '2026/2027' }}
                        </span>
                    </div>
                    <p class="text-xs text-slate-400 flex items-center gap-1.5 mt-0.5">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                        بوابة التراخيص الرسمية والمزامنة الهجينة المعزولة (MONAZ)
                    </p>
                </div>
            </div>

            <!-- Quick Club Switcher & Navigation -->
            <div class="flex items-center gap-2 sm:gap-3">
                @if(isset($allClubs) && count($allClubs) > 1)
                    <div class="relative">
                        <select onchange="if(this.value) window.location.href='/clubs/' + this.value"
                                class="bg-[#081220] border border-slate-700 text-white text-xs font-bold rounded-xl px-3 py-2 focus:outline-none focus:border-blue-500 transition shadow-inner">
                            <option value="" disabled>التبديل إلى نادٍ آخر...</option>
                            @foreach($allClubs as $c)
                                <option value="{{ $c->id }}" {{ $c->id === $club->id ? 'selected' : '' }}>
                                    {{ $c->club_name }} ({{ $c->club_code ?? 'CLUB' }})
                                </option>
                            @endforeach
                        </select>
                    </div>
                @endif

                <a href="{{ route('clubs.index') }}"
                   class="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold text-slate-300 hover:text-white bg-[#0e1c33] hover:bg-[#132747] transition border border-slate-700">
                    <svg class="w-4 h-4 rtl:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                    </svg>
                    <span>دليل كافة الأندية</span>
                </a>

                <div class="relative inline-block text-right">
                    <button id="downloadApkDropdownBtn" type="button"
                       title="تحميل تطبيق الأندرويد الميداني المعتمد (APK)"
                       class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold text-white transition shadow-md border border-white/20"
                       style="background: linear-gradient(135deg, {{ $club->primary_color_hex ?? '#0F48A2' }}, #2563eb);">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                        </svg>
                        <span>تحميل APK</span>
                        <svg class="w-3.5 h-3.5 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                        </svg>
                    </button>
                    <div id="downloadApkMenu" class="hidden absolute left-0 mt-2 w-72 rounded-2xl bg-[#0b1424] border border-slate-700/80 shadow-2xl p-2 z-50 text-right space-y-1">
                        <a href="{{ route('download.apk') }}" class="flex items-start gap-2.5 p-2.5 rounded-xl hover:bg-slate-800 transition text-white">
                            <span class="text-lg">📦</span>
                            <div>
                                <div class="text-xs font-bold text-emerald-400">الحزمة الشاملة (Universal)</div>
                                <div class="text-[10px] text-slate-400">لكافة الأجهزة (Android 5+ حتى 15) • 72MB</div>
                            </div>
                        </a>
                        <a href="{{ route('download.apk.arm64') }}" class="flex items-start gap-2.5 p-2.5 rounded-xl hover:bg-slate-800 transition text-white">
                            <span class="text-lg">⚡</span>
                            <div>
                                <div class="text-xs font-bold text-blue-400">الأجهزة الحديثة (ARM64)</div>
                                <div class="text-[10px] text-slate-400">هواتف سامسونج وشاومي الحديثة (سريعة) • 25MB</div>
                            </div>
                        </a>
                        <a href="{{ route('download.apk.arm32') }}" class="flex items-start gap-2.5 p-2.5 rounded-xl hover:bg-slate-800 transition text-white">
                            <span class="text-lg">📱</span>
                            <div>
                                <div class="text-xs font-bold text-amber-400">الأجهزة الاقتصادية (ARM32)</div>
                                <div class="text-[10px] text-slate-400">الهواتف القديمة أو الاقتصادية • 24MB</div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Container -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8 flex-1 w-full space-y-8">

        <!-- Flash Notifications -->
        @if(session('error') || isset($error))
            <div class="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-3 shadow-lg">
                <svg class="w-5 h-5 flex-shrink-0 text-rose-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <span class="font-semibold">{{ session('error') ?? $error }}</span>
            </div>
        @endif

        @if(session('success') || isset($success))
            <div class="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-3 shadow-lg">
                <svg class="w-5 h-5 flex-shrink-0 text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 01-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                <span class="font-semibold">{{ session('success') ?? $success }}</span>
            </div>
        @endif

        <!-- Top Overview Banner -->
        <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#0d1a30] via-[#112444] to-[#0a1527] border border-slate-800 p-6 sm:p-8 shadow-2xl">
            <div class="absolute -left-12 -bottom-12 w-48 h-48 rounded-full opacity-20 blur-2xl"
                 style="background: {{ $club->primary_color_hex ?? '#0F48A2' }};"></div>
            <div class="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div>
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20 mb-3">
                        <span>⚡ مساحة عمل معزولة: {{ $club->club_name }} ({{ $club->club_code ?? 'TDMN' }})</span>
                    </div>
                    <h2 class="text-2xl sm:text-3xl font-black text-white leading-tight">
                        إدارة هوية النادي وتراخيص الأجهزة الميدانية
                    </h2>
                    <p class="text-slate-300 text-sm mt-2 max-w-2xl leading-relaxed">
                        حدد هوية النادي وثيمه المعتمد، وقم بتسجيل وتوليد أكواد التفعيل الموقّعة رقمياً (Ed25519) لأجهزة الإدارة وأجهزة المحضرين في الميدان لتعمل 100% دون إنترنت مع دعم القراءة عبر الـ QR المباشر.
                    </p>
                </div>
                <div class="flex items-center gap-3">
                    <div class="bg-[#081220]/80 border border-slate-700/60 rounded-2xl px-5 py-3 text-center min-w-[120px]">
                        <div class="text-2xl font-black text-white">{{ count($devices) }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">الأجهزة المسجلة</div>
                    </div>
                    <div class="bg-[#081220]/80 border border-slate-700/60 rounded-2xl px-5 py-3 text-center min-w-[120px]">
                        <div class="text-2xl font-black text-emerald-400">{{ $devices->where('role', 'master_admin')->count() }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">أجهزة إدارة</div>
                    </div>
                    <div class="bg-[#081220]/80 border border-slate-700/60 rounded-2xl px-5 py-3 text-center min-w-[120px]">
                        <div class="text-2xl font-black text-blue-400">{{ $devices->where('role', 'field_scout')->count() }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">أجهزة ميدان</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2-Column Grid: Club Profile (Right) + Device Generator (Left) -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

            <!-- Section 1: Club Identity & Branding (4 cols) -->
            <div class="lg:col-span-4 bg-[#0d1c33] border border-slate-800 rounded-3xl p-6 shadow-xl relative overflow-hidden">
                <div class="flex items-center justify-between mb-5 pb-4 border-b border-slate-800">
                    <div class="flex items-center gap-2.5">
                        <div class="w-8 h-8 rounded-lg bg-blue-500/20 text-blue-400 flex items-center justify-center font-bold text-sm">
                            🏛️
                        </div>
                        <h3 class="font-extrabold text-white text-base">هوية وثيم النادي</h3>
                    </div>
                    <span class="text-[11px] text-slate-400 font-mono">Profile Config</span>
                </div>

                <form action="/clubs/{{ $club->id }}/update" method="POST" enctype="multipart/form-data" class="space-y-4">
                    @csrf

                    <!-- Logo Upload with Preview -->
                    <div>
                        <label class="block text-xs font-bold text-slate-300 mb-2">شعار النادي الرسمي</label>
                        <div class="flex items-center gap-4 bg-[#081220] p-3 rounded-2xl border border-slate-700/60">
                            <div class="w-16 h-16 rounded-xl bg-slate-800 border border-slate-700 overflow-hidden flex items-center justify-center flex-shrink-0" id="logo_preview_container">
                                @if($club->logo_url)
                                    <img src="{{ $club->logo_url }}" id="logo_preview" alt="شعار النادي" class="w-full h-full object-cover">
                                @else
                                    <span id="logo_placeholder" class="text-2xl font-black text-slate-500">🛡️</span>
                                    <img id="logo_preview" alt="شعار النادي" class="w-full h-full object-cover hidden">
                                @endif
                            </div>
                            <div class="flex-1 min-w-0">
                                <label for="logo_input" class="cursor-pointer inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-slate-700 hover:bg-slate-600 text-white transition">
                                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                    </svg>
                                    <span>اختر صورة</span>
                                </label>
                                <input type="file" name="logo" id="logo_input" accept="image/*" class="sr-only" onchange="previewClubLogo(event)">
                                <p class="text-[10px] text-slate-400 mt-1 truncate">PNG, JPG, SVG (حد أقصى 2MB)</p>
                            </div>
                        </div>
                    </div>

                    <!-- Club Name & Code -->
                    <div class="grid grid-cols-3 gap-2">
                        <div class="col-span-2">
                            <label for="club_name" class="block text-xs font-bold text-slate-300 mb-1">اسم النادي <span class="text-rose-400">*</span></label>
                            <input type="text" name="club_name" id="club_name" value="{{ old('club_name', $club->club_name) }}" required
                                   class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs font-semibold focus:outline-none focus:border-blue-500 transition">
                        </div>
                        <div>
                            <label for="club_code" class="block text-xs font-bold text-slate-300 mb-1">الرمز الكودي</label>
                            <input type="text" name="club_code" id="club_code" value="{{ old('club_code', $club->club_code ?? 'TDMN') }}" maxlength="10"
                                   class="w-full bg-[#081220] border border-slate-700 rounded-xl px-2 py-2 text-amber-400 text-xs font-mono font-bold uppercase text-center focus:outline-none">
                        </div>
                    </div>

                    <!-- Season -->
                    <div>
                        <label for="season" class="block text-xs font-bold text-slate-300 mb-1">الموسم الرياضي <span class="text-rose-400">*</span></label>
                        <input type="text" name="season" id="season" value="{{ old('season', $club->season ?? '2026/2027') }}" required
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2 text-white text-xs font-semibold focus:outline-none focus:border-blue-500 transition">
                    </div>

                    <!-- Primary Brand Color & Presets -->
                    <div>
                        <label class="block text-xs font-bold text-slate-300 mb-1">لون هوية النادي (Brand Theme)</label>
                        <div class="flex items-center gap-2 mb-2">
                            <input type="color" name="primary_color_hex" id="primary_color_picker" value="{{ old('primary_color_hex', $club->primary_color_hex ?? '#0F48A2') }}"
                                   onchange="updateColorText(this.value)"
                                   class="w-9 h-9 rounded-lg border border-slate-700 bg-transparent cursor-pointer p-0.5">
                            <input type="text" id="primary_color_text" value="{{ old('primary_color_hex', $club->primary_color_hex ?? '#0F48A2') }}"
                                   onkeyup="updateColorPicker(this.value)"
                                   class="flex-1 bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs font-mono font-bold focus:outline-none">
                        </div>
                        <!-- Preset Swatches -->
                        <div class="flex items-center gap-2 pt-1">
                            <button type="button" onclick="setColor('#0F48A2')" class="w-6 h-6 rounded-full bg-[#0F48A2] border border-white/20 hover:scale-110 transition shadow-sm" title="أزرق ملكي"></button>
                            <button type="button" onclick="setColor('#059669')" class="w-6 h-6 rounded-full bg-[#059669] border border-white/20 hover:scale-110 transition shadow-sm" title="أخضر زمردي"></button>
                            <button type="button" onclick="setColor('#DC2626')" class="w-6 h-6 rounded-full bg-[#DC2626] border border-white/20 hover:scale-110 transition shadow-sm" title="أحمر رياضي"></button>
                            <button type="button" onclick="setColor('#D97706')" class="w-6 h-6 rounded-full bg-[#D97706] border border-white/20 hover:scale-110 transition shadow-sm" title="أصفر ذهبي"></button>
                            <button type="button" onclick="setColor('#7C3AED')" class="w-6 h-6 rounded-full bg-[#7C3AED] border border-white/20 hover:scale-110 transition shadow-sm" title="بنفسجي ملكي"></button>
                            <button type="button" onclick="setColor('#0F172A')" class="w-6 h-6 rounded-full bg-[#0F172A] border border-white/20 hover:scale-110 transition shadow-sm" title="كحلي داكن"></button>
                        </div>
                    </div>

                    <!-- Staff Details -->
                    <div class="grid grid-cols-2 gap-3 pt-2">
                        <div>
                            <label for="admin_name" class="block text-[11px] font-bold text-slate-300 mb-1">المشرف الإداري</label>
                            <input type="text" name="admin_name" id="admin_name" value="{{ old('admin_name', $club->admin_name) }}" placeholder="اسم الإداري"
                                   class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                        </div>
                        <div>
                            <label for="manager_name" class="block text-[11px] font-bold text-slate-300 mb-1">المدير الفني</label>
                            <input type="text" name="manager_name" id="manager_name" value="{{ old('manager_name', $club->manager_name) }}" placeholder="اسم المدرب"
                                   class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit"
                            class="w-full bg-slate-800 hover:bg-slate-700 text-white font-bold py-2.5 px-4 rounded-xl transition duration-150 border border-slate-600 text-xs flex items-center justify-center gap-2 mt-2">
                        <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                        </svg>
                        <span>حفظ واعتماد هوية النادي</span>
                    </button>
                </form>
            </div>

            <!-- Section 2: Device Registration & Licensing (8 cols) -->
            <div class="lg:col-span-8 bg-[#0d1c33] border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl">
                <div class="flex items-center justify-between mb-6 pb-4 border-b border-slate-800">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-blue-600/20 text-blue-400 flex items-center justify-center font-bold text-lg">
                            🔑
                        </div>
                        <div>
                            <h3 class="font-extrabold text-white text-lg">تسجيل وتوليد ترخيص جهاز لنادي ({{ $club->club_name }})</h3>
                            <p class="text-xs text-slate-400">إصدار رمز تفعيل موقّع رقمياً بالمفتاح الخاص بموجب بصمة الجهاز العتادية</p>
                        </div>
                    </div>
                    <span class="text-xs px-2.5 py-1 rounded-full font-bold bg-indigo-500/10 text-indigo-300 border border-indigo-500/20 font-mono">
                        {{ $club->club_code ?? 'TDMN' }} Scope
                    </span>
                </div>

                <form action="/clubs/{{ $club->id }}/generate" method="POST" class="space-y-6">
                    @csrf

                    <!-- Mode Selection -->
                    <div>
                        <label class="block text-xs font-bold text-slate-300 mb-2">نوع التسجيل والربط:</label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <label class="cursor-pointer relative flex flex-col p-4 rounded-2xl border border-slate-700 bg-[#081220] hover:border-blue-500 transition-colors">
                                <input type="radio" name="mode" value="single" class="sr-only peer" checked onchange="toggleMode('single')">
                                <div class="flex items-center justify-between mb-1.5">
                                    <span class="text-white font-black text-sm">جهاز فردي مستقل</span>
                                    <span class="w-4 h-4 rounded-full border-2 border-slate-500 peer-checked:border-blue-500 peer-checked:bg-blue-500 flex items-center justify-center"></span>
                                </div>
                                <span class="text-xs text-slate-400">توليد كود لجهاز واحد محدد بصلاحية إدارية أو ميدانية.</span>
                            </label>

                            <label class="cursor-pointer relative flex flex-col p-4 rounded-2xl border border-slate-700 bg-[#081220] hover:border-blue-500 transition-colors">
                                <input type="radio" name="mode" value="dual" class="sr-only peer" onchange="toggleMode('dual')">
                                <div class="flex items-center justify-between mb-1.5">
                                    <span class="text-white font-black text-sm">زوج أجهزة متكامل (إدارة + ميدان)</span>
                                    <span class="w-4 h-4 rounded-full border-2 border-slate-500 peer-checked:border-blue-500 peer-checked:bg-blue-500 flex items-center justify-center"></span>
                                </div>
                                <span class="text-xs text-slate-400">توليد كودين متزامنين مقترنين بمفتاح محلي مشترك للنادي.</span>
                            </label>
                        </div>
                    </div>

                    <!-- Single Mode Inputs -->
                    <div id="single-section" class="space-y-4">
                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                            <!-- Device Name -->
                            <div>
                                <label for="device_name" class="block text-xs font-bold text-slate-300 mb-1">
                                    الاسم التعريفي للجهاز <span class="text-slate-500 font-normal">(اختياري)</span>
                                </label>
                                <input type="text" name="device_name" id="device_name" placeholder="مثال: هاتف الإداري العام"
                                       class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-xs font-semibold"
                                       value="{{ old('device_name') }}">
                            </div>

                            <!-- Hardware Fingerprint -->
                            <div>
                                <label for="single_device_id" class="block text-xs font-bold text-slate-300 mb-1">
                                    بصمة الجهاز (Hardware Fingerprint) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="single_device_id" id="single_device_id" placeholder="{{ $club->club_code ?? 'TDMN' }}-XXXX-XXXX"
                                       class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-xs font-mono tracking-wider font-bold text-center"
                                       value="{{ old('single_device_id') }}">
                            </div>

                            <!-- Role Picker -->
                            <div>
                                <label for="role" class="block text-xs font-bold text-slate-300 mb-1">
                                    صفة وصلاحية الجهاز <span class="text-rose-400">*</span>
                                </label>
                                <select name="role" id="role" class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-blue-500 text-xs font-semibold">
                                    <option value="MASTER_ADMIN">جهاز الإدارة الرئيسي (Master Admin) - صلاحيات كاملة وتقارير</option>
                                    <option value="FIELD_ATTENDANCE">جهاز الميدان (Field Scout) - تحضير وترحيل فوري فقط</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Dual Mode Inputs -->
                    <div id="dual-section" class="space-y-4 hidden">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label for="master_device_id" class="block text-xs font-bold text-slate-300 mb-1">
                                    بصمة جهاز الإدارة الرئيسي (Master) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="master_device_id" id="master_device_id" placeholder="{{ $club->club_code ?? 'TDMN' }}-1111-2222"
                                       class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-xs font-mono tracking-wider font-bold text-center">
                            </div>

                            <div>
                                <label for="field_device_id" class="block text-xs font-bold text-slate-300 mb-1">
                                    بصمة جهاز المحضر الميداني (Field) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="field_device_id" id="field_device_id" placeholder="{{ $club->club_code ?? 'TDMN' }}-3333-4444"
                                       class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-xs font-mono tracking-wider font-bold text-center">
                            </div>
                        </div>
                    </div>

                    <!-- Team and Validity Days -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-4 border-t border-slate-800">
                        <div>
                            <label for="team_name" class="block text-xs font-bold text-slate-300 mb-1">الفريق المسند للجهاز</label>
                            <select name="team_name" id="team_name" class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-blue-500 text-xs font-semibold">
                                <option value="الفريق الأول" selected>الفريق الأول (Senior Team)</option>
                                <option value="فئة الشباب">فئة الشباب (U-20)</option>
                                <option value="فئة الناشئين">فئة الناشئين (U-17)</option>
                                <option value="فئة البراعم">فئة البراعم (U-14)</option>
                                <option value="كافة الفرق الرياضية">كافة الفرق الرياضية (شامل)</option>
                            </select>
                        </div>

                        <div>
                            <label for="validity_days" class="block text-xs font-bold text-slate-300 mb-1">مدة صلاحية الترخيص (أيام)</label>
                            <input type="number" name="validity_days" id="validity_days" value="365" min="30" max="1095"
                                   class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-blue-500 text-xs font-semibold">
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit"
                            class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold py-3.5 px-6 rounded-2xl transition duration-200 shadow-xl shadow-blue-600/30 flex items-center justify-center gap-2 text-sm">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                        <span>توليد وتوقيع كود التفعيل الرقمي فوراً</span>
                    </button>
                </form>
            </div>
        </div>

        <!-- Section 3: Generated Output & Dynamic QR Code Section -->
        @if(isset($results) && count($results) > 0)
            <div id="results-section" class="bg-[#0e1f38] border-2 border-blue-500/60 rounded-3xl p-6 sm:p-8 shadow-2xl space-y-6">
                <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-4 border-b border-slate-800 gap-3">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold text-xl">
                            ✅
                        </div>
                        <div>
                            <h3 class="text-lg font-black text-white">تم إصدار وتوقيع كود التفعيل الرقمي بنجاح</h3>
                            <p class="text-xs text-slate-400">مرتبط بنادي: <strong class="text-white">{{ $club->club_name }}</strong> (كود: {{ $club->club_code ?? 'TDMN' }})</p>
                        </div>
                    </div>
                    <span class="text-xs px-3 py-1 rounded-full font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                        موقع برمجياً ومعتمد 100%
                    </span>
                </div>

                @if(isset($results['single']))
                    <div class="grid grid-cols-1 md:grid-cols-12 gap-6 items-center bg-[#081220] p-6 rounded-2xl border border-slate-800">
                        <!-- Code & Details (8 cols) -->
                        <div class="md:col-span-8 space-y-4">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <span class="font-bold text-white text-sm">البصمة:</span>
                                    <span class="font-mono text-amber-400 font-bold text-sm bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">{{ $results['single']['payload']['device_id'] }}</span>
                                    <span class="text-xs text-slate-400 mr-2">({{ $results['single']['payload']['role'] === 'MASTER_ADMIN' ? 'جهاز إدارة رئيسي' : 'جهاز محضر ميداني' }})</span>
                                </div>
                                <button type="button" onclick="copyCode('single_code_text')"
                                        class="bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center gap-1.5 transition shadow-md shadow-blue-600/30">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"/>
                                    </svg>
                                    <span>نسخ الكود الرقمي</span>
                                </button>
                            </div>
                            <textarea id="single_code_text" readonly
                                      class="w-full bg-[#050b14] text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-28 p-3 rounded-xl border border-slate-700/60 select-all"
                            >{{ $results['single']['code'] }}</textarea>
                            <div class="flex flex-wrap items-center gap-4 text-xs text-slate-400">
                                <span>الفريق: <strong class="text-white">{{ $results['single']['payload']['team_name'] }}</strong></span>
                                <span>صالح حتى: <strong class="text-emerald-400 font-mono">{{ substr($results['single']['payload']['expires_at'], 0, 10) }}</strong></span>
                            </div>
                        </div>

                        <!-- Dynamic QR Code Container (4 cols) -->
                        <div class="md:col-span-4 flex flex-col items-center justify-center p-4 bg-white rounded-2xl shadow-inner">
                            <div id="qrcode_single" class="p-2"></div>
                            <p class="text-[11px] font-bold text-slate-800 mt-2 text-center">امسح الكود عبر شاشة الهاتف</p>
                        </div>
                    </div>
                @endif

                @if(isset($results['master']))
                    <div class="grid grid-cols-1 md:grid-cols-12 gap-6 items-center bg-[#081220] p-6 rounded-2xl border border-blue-500/30">
                        <div class="md:col-span-8 space-y-4">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <span class="w-3 h-3 rounded-full bg-blue-500"></span>
                                    <span class="font-bold text-white text-sm">جهاز الإدارة (Master Admin):</span>
                                    <span class="font-mono text-blue-400 font-bold text-sm bg-blue-500/10 px-2 py-0.5 rounded border border-blue-500/20">{{ $results['master']['payload']['device_id'] }}</span>
                                </div>
                                <button type="button" onclick="copyCode('master_code_text')"
                                        class="bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center gap-1.5 transition">
                                    <span>نسخ كود الإدارة</span>
                                </button>
                            </div>
                            <textarea id="master_code_text" readonly
                                      class="w-full bg-[#050b14] text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-24 p-3 rounded-xl border border-slate-700/60 select-all"
                            >{{ $results['master']['code'] }}</textarea>
                        </div>
                        <div class="md:col-span-4 flex flex-col items-center justify-center p-4 bg-white rounded-2xl shadow-inner">
                            <div id="qrcode_master" class="p-2"></div>
                            <p class="text-[11px] font-bold text-slate-800 mt-2 text-center">QR جهاز الإدارة</p>
                        </div>
                    </div>
                @endif

                @if(isset($results['field']))
                    <div class="grid grid-cols-1 md:grid-cols-12 gap-6 items-center bg-[#081220] p-6 rounded-2xl border border-emerald-500/30">
                        <div class="md:col-span-8 space-y-4">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <span class="w-3 h-3 rounded-full bg-emerald-500"></span>
                                    <span class="font-bold text-white text-sm">جهاز الميدان (Field Attendance):</span>
                                    <span class="font-mono text-emerald-400 font-bold text-sm bg-emerald-500/10 px-2 py-0.5 rounded border border-emerald-500/20">{{ $results['field']['payload']['device_id'] }}</span>
                                </div>
                                <button type="button" onclick="copyCode('field_code_text')"
                                        class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center gap-1.5 transition">
                                    <span>نسخ كود الميدان</span>
                                </button>
                            </div>
                            <textarea id="field_code_text" readonly
                                      class="w-full bg-[#050b14] text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-24 p-3 rounded-xl border border-slate-700/60 select-all"
                            >{{ $results['field']['code'] }}</textarea>
                        </div>
                        <div class="md:col-span-4 flex flex-col items-center justify-center p-4 bg-white rounded-2xl shadow-inner">
                            <div id="qrcode_field" class="p-2"></div>
                            <p class="text-[11px] font-bold text-slate-800 mt-2 text-center">QR جهاز الميدان</p>
                        </div>
                    </div>
                @endif
            </div>
        @endif

        <!-- Section 4: Registered Devices Registry Table -->
        <div class="bg-[#0d1c33] border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl">
            <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-5 border-b border-slate-800 gap-3">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-slate-800 text-white flex items-center justify-center font-bold text-lg">
                        📱
                    </div>
                    <div>
                        <h3 class="font-extrabold text-white text-lg">سجل أجهزة النادي المعتمدة ({{ $club->club_name }})</h3>
                        <p class="text-xs text-slate-400">قائمة الأجهزة الإدارية والميدانية المرخصة حصراً لنادي {{ $club->club_name }} ({{ $club->club_code ?? 'TDMN' }})</p>
                    </div>
                </div>
                <div class="text-xs text-slate-400">
                    إجمالي أجهزة النادي: <strong class="text-white font-mono">{{ count($devices) }}</strong>
                </div>
            </div>

            @if(count($devices) === 0)
                <div class="text-center py-12 text-slate-400">
                    <div class="text-4xl mb-3">📋</div>
                    <p class="text-sm font-semibold">لا توجد أجهزة مسجلة في سجل هذا النادي حتى الآن.</p>
                    <p class="text-xs text-slate-500 mt-1">قم بتوليد ترخيص جديد من النموذج أعلاه لإدراج الجهاز في السجل وتفعيل المزامنة المعزولة.</p>
                </div>
            @else
                <div class="overflow-x-auto mt-6">
                    <table class="w-full text-right text-xs">
                        <thead>
                            <tr class="text-slate-400 border-b border-slate-800 bg-[#081220]/60">
                                <th class="py-3 px-4 font-bold">اسم الجهاز</th>
                                <th class="py-3 px-4 font-bold">بصمة الجهاز (Fingerprint)</th>
                                <th class="py-3 px-4 font-bold">الصفة والصلاحية</th>
                                <th class="py-3 px-4 font-bold">الفريق المعتمد</th>
                                <th class="py-3 px-4 font-bold">تاريخ الانتهاء</th>
                                <th class="py-3 px-4 font-bold text-center">كود الترخيص / QR</th>
                                <th class="py-3 px-4 font-bold text-center">إجراءات</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-800/60">
                            @foreach($devices as $dev)
                                <tr class="hover:bg-[#11233e]/50 transition">
                                    <td class="py-3.5 px-4 font-bold text-white">
                                        {{ $dev->device_name ?? 'جهاز بدون اسم' }}
                                    </td>
                                    <td class="py-3.5 px-4 font-mono font-bold text-amber-400">
                                        {{ $dev->device_id }}
                                    </td>
                                    <td class="py-3.5 px-4">
                                        @if($dev->role === 'master_admin')
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full font-bold bg-blue-500/10 text-blue-400 border border-blue-500/20">
                                                <span class="w-1.5 h-1.5 rounded-full bg-blue-400"></span>
                                                إدارة رئيسية (Master)
                                            </span>
                                        @else
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                                                محضر ميداني (Field)
                                            </span>
                                        @endif
                                    </td>
                                    <td class="py-3.5 px-4 text-slate-300">
                                        {{ $dev->team_name ?? 'الفريق الأول' }}
                                    </td>
                                    <td class="py-3.5 px-4 font-mono text-slate-400">
                                        {{ $dev->expires_at ? (is_string($dev->expires_at) ? substr($dev->expires_at, 0, 10) : $dev->expires_at->format('Y-m-d')) : 'دائم' }}
                                    </td>
                                    <td class="py-3.5 px-4 text-center">
                                        @if($dev->license_code)
                                            <button type="button"
                                                    onclick="showQrModal('{{ $dev->device_name }}', '{{ $dev->device_id }}', '{{ $dev->license_code }}')"
                                                    class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 font-bold transition">
                                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
                                                </svg>
                                                <span>عرض QR</span>
                                            </button>
                                        @else
                                            <span class="text-slate-500">-</span>
                                        @endif
                                    </td>
                                    <td class="py-3.5 px-4 text-center">
                                        <form action="/clubs/{{ $club->id }}/devices/{{ $dev->id }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذا الجهاز من سجل النادي؟');" class="inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="text-rose-400 hover:text-rose-300 p-1.5 rounded-lg hover:bg-rose-500/10 transition" title="حذف الجهاز">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                                </svg>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif
        </div>

        <!-- Section 5: Per-Club Backup & Cloud Sync Center -->
        <div class="bg-gradient-to-r from-[#0d1a30] to-[#0e2240] border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div class="space-y-2">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                    <span>💾 مركز النسخ الاحتياطي المستقل لنادي {{ $club->club_name }}</span>
                </div>
                <h3 class="text-lg font-black text-white">تصدير وحفظ النسخة الاحتياطية الرسمية للنادي</h3>
                <p class="text-xs text-slate-300 max-w-2xl leading-relaxed">
                    يتضمن ملف النسخة الاحتياطية هوية النادي، كافة الأجهزة المرخصة، كشوفات التمارين الميدانية المعتمدة، ولقطات المزامنة الخاصة بنادي <strong>{{ $club->club_name }}</strong> بمعزل تام عن باقي الأندية.
                </p>
            </div>
            <a href="{{ route('clubs.backup.export', $club->id) }}"
               class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl font-black text-xs text-white bg-emerald-600 hover:bg-emerald-500 shadow-xl shadow-emerald-600/30 transition flex-shrink-0 border border-emerald-400/30">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                </svg>
                <span>تحميل النسخة الاحتياطية الكاملة (JSON Backup)</span>
            </a>
        </div>

        <!-- Section 6: Step-by-Step Activation Guide -->
        <div class="bg-[#091526] rounded-3xl p-6 sm:p-8 border border-slate-800 text-xs text-slate-300 leading-relaxed shadow-xl">
            <h4 class="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <span>📖</span>
                <span>دليل التفعيل الميداني للأجهزة الرياضية:</span>
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div class="bg-[#0d1c33] p-4 rounded-2xl border border-slate-800">
                    <div class="w-7 h-7 rounded-full bg-blue-600/30 text-blue-400 flex items-center justify-center font-black mb-2 text-xs">1</div>
                    <h5 class="font-bold text-white mb-1">فتح شاشة التفعيل</h5>
                    <p class="text-[11px] text-slate-400">افتح التطبيق على هاتف المحضر أو الإداري، وانسخ «بصمة الجهاز العتادية» المعروضة (TD-XXXX-XXXX).</p>
                </div>
                <div class="bg-[#0d1c33] p-4 rounded-2xl border border-slate-800">
                    <div class="w-7 h-7 rounded-full bg-blue-600/30 text-blue-400 flex items-center justify-center font-black mb-2 text-xs">2</div>
                    <h5 class="font-bold text-white mb-1">تسجيل وتحديد الصلاحية</h5>
                    <p class="text-[11px] text-slate-400">أدخل البصمة في البوابة، واختر صفة الجهاز (إدارة رئيسية بصلاحيات كاملة، أو محضر ميداني معزول للتمارين فقط).</p>
                </div>
                <div class="bg-[#0d1c33] p-4 rounded-2xl border border-slate-800">
                    <div class="w-7 h-7 rounded-full bg-blue-600/30 text-blue-400 flex items-center justify-center font-black mb-2 text-xs">3</div>
                    <h5 class="font-bold text-white mb-1">المسح أو اللصق الفوري</h5>
                    <p class="text-[11px] text-slate-400">امسح رمز الـ QR مباشرة من كاميرا الهاتف أو انسخ الكود والصقه في خانة كود التفعيل بالهاتف واضغط «تفعيل».</p>
                </div>
                <div class="bg-[#0d1c33] p-4 rounded-2xl border border-slate-800">
                    <div class="w-7 h-7 rounded-full bg-blue-600/30 text-blue-400 flex items-center justify-center font-black mb-2 text-xs">4</div>
                    <h5 class="font-bold text-white mb-1">عمل مستقل 100%</h5>
                    <p class="text-[11px] text-slate-400">يتحقق الهاتف رياضياً عبر المفتاح العام المدمج محلياً، ويعمل دون أي حاجة للإنترنت نهائياً في الملعب.</p>
                </div>
            </div>
        </div>

    </main>

    <!-- Modal for Showing Saved Device QR Code -->
    <div id="qr_modal" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-[#0d1c33] border border-slate-700 rounded-3xl max-w-md w-full p-6 shadow-2xl relative">
            <button onclick="closeQrModal()" class="absolute top-4 left-4 text-slate-400 hover:text-white p-1 rounded-lg">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>
            <div class="text-center mb-4">
                <h4 id="modal_device_name" class="font-black text-white text-base">اسم الجهاز</h4>
                <p id="modal_device_id" class="text-xs font-mono text-amber-400 font-bold mt-1">TD-XXXX-XXXX</p>
            </div>
            <div class="flex flex-col items-center justify-center bg-white p-4 rounded-2xl mb-4">
                <div id="modal_qrcode"></div>
                <p class="text-[11px] text-slate-800 font-bold mt-2">امسح الرمز عبر التطبيق</p>
            </div>
            <div class="space-y-2">
                <label class="block text-xs font-bold text-slate-300">كود التفعيل المشفر (Base64):</label>
                <textarea id="modal_code_text" readonly
                          class="w-full bg-[#081220] text-slate-300 font-mono text-[11px] focus:outline-none resize-none leading-relaxed h-20 p-2.5 rounded-xl border border-slate-700 select-all"></textarea>
                <button type="button" onclick="copyCode('modal_code_text')"
                        class="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-4 rounded-xl text-xs transition flex items-center justify-center gap-1.5">
                    <span>نسخ الكود المشفر</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="border-t border-slate-800/80 bg-[#060c18] py-6 text-center text-xs text-slate-500">
        <p>نظام التحضير الميداني غير المتصل والمزامنة الهجينة (MONAZ) • نادي {{ $club->club_name }} • حضرموت، اليمن</p>
    </footer>

    <!-- Interactive Scripts & QR Generation -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const apkBtn = document.getElementById('downloadApkDropdownBtn');
            const apkMenu = document.getElementById('downloadApkMenu');
            if (apkBtn && apkMenu) {
                apkBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    apkMenu.classList.toggle('hidden');
                });
                document.addEventListener('click', () => {
                    apkMenu.classList.add('hidden');
                });
            }
        });

        function toggleMode(mode) {
            const single = document.getElementById('single-section');
            const dual = document.getElementById('dual-section');
            if (mode === 'dual') {
                single.classList.add('hidden');
                dual.classList.remove('hidden');
            } else {
                single.classList.remove('hidden');
                dual.classList.add('hidden');
            }
        }

        function copyCode(elementId) {
            const el = document.getElementById(elementId);
            el.select();
            navigator.clipboard.writeText(el.value).then(() => {
                alert('تم نسخ كود التفعيل الرقمي بنجاح إلى الحافظة!');
            }).catch(() => {
                document.execCommand('copy');
                alert('تم نسخ كود التفعيل الرقمي!');
            });
        }

        function setColor(hex) {
            document.getElementById('primary_color_picker').value = hex;
            document.getElementById('primary_color_text').value = hex;
        }

        function updateColorText(val) {
            document.getElementById('primary_color_text').value = val.toUpperCase();
        }

        function updateColorPicker(val) {
            if (/^#[0-9A-Fa-f]{6}$/.test(val)) {
                document.getElementById('primary_color_picker').value = val;
            }
        }

        function previewClubLogo(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const img = document.getElementById('logo_preview');
                    const placeholder = document.getElementById('logo_placeholder');
                    img.src = e.target.result;
                    img.classList.remove('hidden');
                    if (placeholder) placeholder.classList.add('hidden');
                }
                reader.readAsDataURL(file);
            }
        }

        // Modal for Device QR
        let modalQrInstance = null;
        function showQrModal(name, id, code) {
            document.getElementById('modal_device_name').innerText = name || 'جهاز بدون اسم';
            document.getElementById('modal_device_id').innerText = id;
            document.getElementById('modal_code_text').value = code;

            const qrContainer = document.getElementById('modal_qrcode');
            qrContainer.innerHTML = '';
            modalQrInstance = new QRCode(qrContainer, {
                text: code,
                width: 200,
                height: 200,
                colorDark: "#000000",
                colorLight: "#ffffff",
                correctLevel: QRCode.CorrectLevel.M
            });

            document.getElementById('qr_modal').classList.remove('hidden');
        }

        function closeQrModal() {
            document.getElementById('qr_modal').classList.add('hidden');
        }

        // Render QR Codes for newly generated results on page load
        document.addEventListener('DOMContentLoaded', function() {
            @if(isset($results['single']))
                const singleContainer = document.getElementById('qrcode_single');
                if (singleContainer) {
                    new QRCode(singleContainer, {
                        text: {!! json_encode($results['single']['code']) !!},
                        width: 180,
                        height: 180,
                        colorDark: "#000000",
                        colorLight: "#ffffff",
                        correctLevel: QRCode.CorrectLevel.M
                    });
                }
            @endif

            @if(isset($results['master']))
                const masterContainer = document.getElementById('qrcode_master');
                if (masterContainer) {
                    new QRCode(masterContainer, {
                        text: {!! json_encode($results['master']['code']) !!},
                        width: 160,
                        height: 160,
                        colorDark: "#000000",
                        colorLight: "#ffffff",
                        correctLevel: QRCode.CorrectLevel.M
                    });
                }
            @endif

            @if(isset($results['field']))
                const fieldContainer = document.getElementById('qrcode_field');
                if (fieldContainer) {
                    new QRCode(fieldContainer, {
                        text: {!! json_encode($results['field']['code']) !!},
                        width: 160,
                        height: 160,
                        colorDark: "#000000",
                        colorLight: "#ffffff",
                        correctLevel: QRCode.CorrectLevel.M
                    });
                }
            @endif
        });
    </script>
</body>
</html>
