<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>بوابة التراخيص الرسمية وإدارة الأندية الرياضية | MONAZ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Cairo', system-ui, -apple-system, sans-serif;
            background-color: #080f1e;
            color: #f1f5f9;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between selection:bg-blue-600 selection:text-white">

    <!-- Top Navigation Bar -->
    <header class="border-b border-slate-800/80 bg-[#060c18]/90 backdrop-blur sticky top-0 z-50 shadow-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex items-center justify-between">
            <div class="flex items-center space-x-3.5 space-x-reverse">
                <div class="w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg border border-white/10 bg-gradient-to-br from-blue-600 to-indigo-800 text-white font-black text-xl">
                    🏆
                </div>
                <div>
                    <div class="flex items-center gap-2">
                        <h1 class="text-base sm:text-lg font-black text-white tracking-wide">
                            بوابة التراخيص الرسمية وإدارة الأندية
                        </h1>
                        <span class="text-[11px] px-2 py-0.5 rounded-full font-bold bg-blue-500/10 text-blue-400 border border-blue-500/20">
                            Multi-Tenant Hub
                        </span>
                    </div>
                    <p class="text-xs text-slate-400 flex items-center gap-1.5 mt-0.5">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                        نظام التحضير الميداني والمزامنة السحابية المعزولة (MONAZ)
                    </p>
                </div>
            </div>

            <div class="flex items-center gap-2 sm:gap-3">
                <button type="button" onclick="openNewClubModal()"
                        class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold text-white transition shadow-lg shadow-blue-600/30 bg-blue-600 hover:bg-blue-500 border border-blue-400/30">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                    </svg>
                    <span>تسجيل نادٍ جديد</span>
                </button>

                <div class="relative inline-block text-right">
                    <button id="downloadApkDropdownBtn" type="button"
                       title="تحميل تطبيق الأندرويد الميداني المعتمد (APK)"
                       class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold text-slate-300 hover:text-white bg-[#0e1c33] hover:bg-[#132747] transition border border-slate-700 shadow-md">
                        <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                        </svg>
                        <span>تحميل التطبيق (APK)</span>
                        <svg class="w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8 flex-1 w-full space-y-8">

        <!-- Flash Notifications & Errors -->
        @if ($errors->any())
            <div class="p-4 rounded-2xl bg-rose-500/15 border border-rose-500/40 text-rose-200 text-xs shadow-xl space-y-2">
                <div class="font-bold flex items-center gap-2 text-rose-300 text-sm">
                    <svg class="w-5 h-5 flex-shrink-0 text-rose-400" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                    </svg>
                    <span>تنبيه: تعذر إتمام العملية بسبب الملاحظات التالية:</span>
                </div>
                <ul class="list-disc list-inside pr-6 space-y-1 text-rose-200 font-medium">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if(session('error'))
            <div class="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-3 shadow-lg">
                <svg class="w-5 h-5 flex-shrink-0 text-rose-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <span class="font-semibold">{{ session('error') }}</span>
            </div>
        @endif

        @if(session('success'))
            <div class="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-3 shadow-lg">
                <svg class="w-5 h-5 flex-shrink-0 text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 01-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                <span class="font-semibold">{{ session('success') }}</span>
            </div>
        @endif

        <!-- Hero Overview Banner -->
        <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#0d1a30] via-[#112444] to-[#0a1527] border border-slate-800 p-6 sm:p-8 shadow-2xl">
            <div class="absolute -left-12 -bottom-12 w-56 h-56 rounded-full bg-blue-600/20 blur-3xl"></div>
            <div class="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div>
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20 mb-3">
                        <span>⚡ منصة إدارة الأندية المتعددة والعزل الصارم</span>
                    </div>
                    <h2 class="text-2xl sm:text-3xl font-black text-white leading-tight">
                        دليل الأندية الرياضية المعتمدة
                    </h2>
                    <p class="text-slate-300 text-sm mt-2 max-w-2xl leading-relaxed">
                        اختر أي نادٍ لإدارة أجهزته، هويته، وتوليد تراخيصه المشفرة بـ Ed25519 مع رمز QR مباشر، ومزامنة بياناته وحفظ نسخه الاحتياطية بمعزل تام عن باقي الأندية.
                    </p>
                </div>
                <div class="flex items-center gap-3">
                    <div class="bg-[#081220]/80 border border-slate-700/60 rounded-2xl px-5 py-3 text-center min-w-[120px]">
                        <div class="text-2xl font-black text-white">{{ count($clubs) }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">إجمالي الأندية</div>
                    </div>
                    <div class="bg-[#081220]/80 border border-slate-700/60 rounded-2xl px-5 py-3 text-center min-w-[120px]">
                        <div class="text-2xl font-black text-emerald-400">{{ $clubs->sum('devices_count') }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">الأجهزة المرخصة</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Registered Clubs Grid -->
        <div>
            <div class="flex items-center justify-between mb-6 pb-2 border-b border-slate-800">
                <h3 class="text-lg font-black text-white flex items-center gap-2">
                    <span>🛡️</span>
                    <span>الأندية الرياضية المسجلة في المنصة</span>
                </h3>
                <span class="text-xs text-slate-400">
                    انقر على أي نادٍ لفتح مساحة عمله المعزولة
                </span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach($clubs as $club)
                    <div class="bg-[#0d1c33] border border-slate-800 hover:border-slate-700 rounded-3xl p-6 shadow-xl transition duration-200 flex flex-col justify-between relative overflow-hidden group">
                        <!-- Club Color Ambient Accent -->
                        <div class="absolute top-0 right-0 left-0 h-1.5" style="background-color: {{ $club->primary_color_hex ?? '#0F48A2' }};"></div>

                        <div>
                            <!-- Header: Logo, Name, Code -->
                            <div class="flex items-start justify-between gap-4 mb-4">
                                <div class="w-14 h-14 rounded-2xl overflow-hidden flex items-center justify-center shadow-lg border border-white/10 flex-shrink-0"
                                     style="background: linear-gradient(135deg, {{ $club->primary_color_hex ?? '#0F48A2' }}, #081220);">
                                    @if($club->logo_url)
                                        <img src="{{ $club->logo_url }}" alt="{{ $club->club_name }}" class="w-full h-full object-cover">
                                    @else
                                        <span class="text-white font-black text-xl">{{ mb_substr($club->club_name, 5, 1) ?: 'ت' }}</span>
                                    @endif
                                </div>
                                <div class="flex flex-col items-end">
                                    <span class="text-xs font-mono font-bold px-2.5 py-0.5 rounded-full bg-slate-800 text-amber-400 border border-slate-700">
                                        {{ $club->club_code ?? 'TDMN' }}
                                    </span>
                                    <span class="text-[11px] text-slate-400 mt-1">موسم {{ $club->season ?? '2026/2027' }}</span>
                                </div>
                            </div>

                            <h4 class="text-lg font-black text-white mb-2 group-hover:text-blue-400 transition">
                                {{ $club->club_name }}
                            </h4>

                            <!-- Staff & Stats -->
                            <div class="space-y-1.5 text-xs text-slate-400 mb-6 bg-[#081220]/70 p-3 rounded-xl border border-slate-800">
                                <div class="flex items-center justify-between">
                                    <span>المشرف الإداري:</span>
                                    <strong class="text-slate-200">{{ $club->admin_name ?? 'معتمد' }}</strong>
                                </div>
                                <div class="flex items-center justify-between">
                                    <span>المدير الفني:</span>
                                    <strong class="text-slate-200">{{ $club->manager_name ?? 'معتمد' }}</strong>
                                </div>
                                <div class="flex items-center justify-between pt-1 border-t border-slate-800/80">
                                    <span>الأجهزة المرخصة:</span>
                                    <span class="font-bold font-mono px-2 py-0.5 rounded bg-blue-500/10 text-blue-400 border border-blue-500/20">
                                        {{ $club->devices_count ?? 0 }} أجهزة
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Card Action Buttons -->
                        <div class="space-y-2 pt-2 border-t border-slate-800/80">
                            <a href="{{ route('clubs.show', $club->id) }}"
                               class="w-full inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl font-bold text-xs text-white transition shadow-md border border-white/10"
                               style="background: linear-gradient(135deg, {{ $club->primary_color_hex ?? '#0F48A2' }}, #1e3a8a);">
                                <span>إدارة النادي والأجهزة</span>
                                <svg class="w-4 h-4 rtl:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"/>
                                </svg>
                            </a>

                            <a href="{{ route('clubs.backup.export', $club->id) }}"
                               class="w-full inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-xl font-bold text-[11px] text-slate-300 hover:text-white bg-[#081220] hover:bg-[#11233e] transition border border-slate-700/60"
                               title="تنزيل نسخة احتياطية كاملة للنادي (JSON)">
                                <svg class="w-3.5 h-3.5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                                </svg>
                                <span>تحميل النسخة الاحتياطية للنادي</span>
                            </a>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>

    </main>

    <!-- Modal for Creating New Club -->
    <div id="new_club_modal" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-[#0d1c33] border border-slate-700 rounded-3xl max-w-lg w-full p-6 sm:p-8 shadow-2xl relative">
            <button onclick="closeNewClubModal()" class="absolute top-5 left-5 text-slate-400 hover:text-white p-1 rounded-lg">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>

            <div class="flex items-center gap-3 mb-6 pb-4 border-b border-slate-800">
                <div class="w-10 h-10 rounded-xl bg-blue-600/20 text-blue-400 flex items-center justify-center font-bold text-lg">
                    ✨
                </div>
                <div>
                    <h3 class="font-extrabold text-white text-lg">تسجيل نادٍ رياضي جديد</h3>
                    <p class="text-xs text-slate-400">إنشاء مساحة عمل معزولة بالكامل للنادي الرياضي</p>
                </div>
            </div>

            <form action="{{ route('clubs.store') }}" method="POST" enctype="multipart/form-data" class="space-y-4">
                @csrf

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div class="sm:col-span-2">
                        <label for="new_club_name" class="block text-xs font-bold text-slate-300 mb-1">اسم النادي الرياضي <span class="text-rose-400">*</span></label>
                        <input type="text" name="club_name" id="new_club_name" value="{{ old('club_name') }}" placeholder="مثال: نادي شعب حضرموت الرياضي" required
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-white text-xs font-semibold focus:outline-none focus:border-blue-500">
                    </div>
                    <div>
                        <label for="new_club_code" class="block text-xs font-bold text-slate-300 mb-1">رمز كودي <span class="text-rose-400">*</span></label>
                        <input type="text" name="club_code" id="new_club_code" value="{{ old('club_code') }}" placeholder="SHAB" maxlength="15" required
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2.5 text-amber-400 text-xs font-mono font-bold uppercase text-center focus:outline-none focus:border-blue-500">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                        <label for="new_season" class="block text-xs font-bold text-slate-300 mb-1">الموسم الرياضي <span class="text-rose-400">*</span></label>
                        <input type="text" name="season" id="new_season" value="{{ old('season', '2026/2027') }}" required
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3.5 py-2 text-white text-xs font-semibold focus:outline-none">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-300 mb-1">لون هوية النادي</label>
                        <div class="flex items-center gap-2">
                            <input type="color" name="primary_color_hex" id="new_color_picker" value="{{ old('primary_color_hex', '#DC2626') }}"
                                   onchange="document.getElementById('new_color_text').value = this.value.toUpperCase()"
                                   class="w-8 h-8 rounded-lg border border-slate-700 bg-transparent cursor-pointer p-0.5">
                            <input type="text" id="new_color_text" value="{{ old('primary_color_hex', '#DC2626') }}"
                                   onkeyup="if(/^#[0-9A-Fa-f]{6}$/.test(this.value)) document.getElementById('new_color_picker').value = this.value;"
                                   class="flex-1 bg-[#081220] border border-slate-700 rounded-xl px-3 py-1.5 text-white text-xs font-mono font-bold">
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label for="new_admin" class="block text-[11px] font-bold text-slate-300 mb-1">المشرف الإداري</label>
                        <input type="text" name="admin_name" id="new_admin" value="{{ old('admin_name') }}" placeholder="اسم الإداري"
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                    </div>
                    <div>
                        <label for="new_manager" class="block text-[11px] font-bold text-slate-300 mb-1">المدير الفني</label>
                        <input type="text" name="manager_name" id="new_manager" value="{{ old('manager_name') }}" placeholder="اسم المدرب"
                               class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">شعار النادي (اختياري)</label>
                    <input type="file" name="logo" accept="image/*"
                           class="w-full bg-[#081220] border border-slate-700 rounded-xl px-3 py-2 text-slate-400 text-xs file:mr-2 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-bold file:bg-blue-600 file:text-white">
                </div>

                <div class="pt-3">
                    <button type="submit"
                            class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold py-3 px-4 rounded-xl transition shadow-lg shadow-blue-600/30 text-xs flex items-center justify-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                        </svg>
                        <span>تسجيل النادي وفتح لوحته المخصصة</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Footer -->
    <footer class="border-t border-slate-800/80 bg-[#060c18] py-6 text-center text-xs text-slate-500">
        <p>منصة إدارة الأندية الرياضية والمزامنة السحابية المعزولة (MONAZ Multi-Tenant) • حضرموت، اليمن</p>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const apkBtn = document.getElementById('downloadApkDropdownBtn');
            const apkMenu = document.getElementById('downloadApkMenu');
            if (apkBtn && apkMenu) {
                apkBtn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    apkMenu.classList.toggle('hidden');
                });
                document.addEventListener('click', function() {
                    apkMenu.classList.add('hidden');
                });
            }

            @if ($errors->any())
                openNewClubModal();
            @endif
        });

        function openNewClubModal() {
            document.getElementById('new_club_modal').classList.remove('hidden');
        }
        function closeNewClubModal() {
            document.getElementById('new_club_modal').classList.add('hidden');
        }
    </script>
</body>
</html>
