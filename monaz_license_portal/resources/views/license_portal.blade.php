<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>بوابة تراخيص نادي تضامن حضرموت | MONAZ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Cairo', system-ui, -apple-system, sans-serif;
            background-color: #0c192c;
            color: #f1f5f9;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between selection:bg-blue-600 selection:text-white">
    <!-- Header -->
    <header class="border-b border-slate-800 bg-[#081220]/80 backdrop-blur sticky top-0 z-50">
        <div class="max-w-6xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
            <div class="flex items-center space-x-3 space-x-reverse">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-800 flex items-center justify-center shadow-lg shadow-blue-500/20 border border-blue-400/30 text-white font-black text-xl">
                    ت
                </div>
                <div>
                    <h1 class="text-lg font-bold text-white flex items-center gap-2">
                        بوابة التراخيص الرسمية
                        <span class="text-xs bg-amber-500/20 text-amber-400 border border-amber-500/30 px-2 py-0.5 rounded-full font-medium">نادي تضامن حضرموت</span>
                    </h1>
                    <p class="text-xs text-slate-400">نظام إدارة التحضير الرياضي الميداني غير المتصل (MONAZ)</p>
                </div>
            </div>
            <div class="text-left hidden sm:block">
                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                    <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                    تشفير Ed25519 نشط
                </span>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-5xl mx-auto px-4 sm:px-6 py-8 flex-1 w-full">
        <!-- Hero section -->
        <div class="text-center mb-8">
            <h2 class="text-2xl sm:text-3xl font-extrabold text-white mb-2">
                توليد كود التفعيل المشفّر للأجهزة
            </h2>
            <p class="text-slate-400 text-sm max-w-2xl mx-auto">
                قم بإدخال بصمة الجهاز (Hardware Fingerprint) الظاهرة على شاشة الهاتف، لاصدار كود تفعيل معتمد وموقّع رقمياً بالمفتاح الخاص للنادي للعمل 100% دون إنترنت.
            </p>
        </div>

        @if(session('error') || isset($error))
            <div class="mb-6 p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-3">
                <svg class="w-5 h-5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <span>{{ session('error') ?? $error }}</span>
            </div>
        @endif

        @if(isset($success))
            <div class="mb-6 p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-3">
                <svg class="w-5 h-5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 01-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                <span>{{ $success }}</span>
            </div>
        @endif

        <!-- Form Card -->
        <div class="bg-[#112239] border border-slate-800 rounded-2xl shadow-xl overflow-hidden mb-8">
            <div class="p-6 sm:p-8">
                <form action="{{ route('license.generate') }}" method="POST">
                    @csrf

                    <!-- Mode Selection -->
                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-slate-300 mb-2">نوع الترخيص المراد توليده:</label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <label class="cursor-pointer relative flex flex-col p-4 rounded-xl border border-slate-700 bg-[#0d1a2d] hover:border-blue-500 transition-colors">
                                <input type="radio" name="mode" value="single" class="sr-only peer" checked onchange="toggleMode('single')">
                                <div class="flex items-center justify-between mb-1">
                                    <span class="text-white font-bold text-sm">جهاز فردي واحد</span>
                                    <span class="w-4 h-4 rounded-full border-2 border-slate-500 peer-checked:border-blue-500 peer-checked:bg-blue-500 flex items-center justify-center"></span>
                                </div>
                                <span class="text-xs text-slate-400">توليد كود لجهاز واحد فقط (إدارة أو ميدان)</span>
                            </label>

                            <label class="cursor-pointer relative flex flex-col p-4 rounded-xl border border-slate-700 bg-[#0d1a2d] hover:border-blue-500 transition-colors">
                                <input type="radio" name="mode" value="dual" class="sr-only peer" onchange="toggleMode('dual')">
                                <div class="flex items-center justify-between mb-1">
                                    <span class="text-white font-bold text-sm">زوج أجهزة متكامل (إدارة + ميدان)</span>
                                    <span class="w-4 h-4 rounded-full border-2 border-slate-500 peer-checked:border-blue-500 peer-checked:bg-blue-500 flex items-center justify-center"></span>
                                </div>
                                <span class="text-xs text-slate-400">جهاز الإدارة وجهاز الميدان مقترنين بمفتاح سرّي</span>
                            </label>
                        </div>
                    </div>

                    <!-- Single Mode Inputs -->
                    <div id="single-section" class="space-y-4 mb-6">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label for="single_device_id" class="block text-xs font-semibold text-slate-300 mb-1">
                                    بصمة الجهاز (TD-XXXX-XXXX) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="single_device_id" id="single_device_id" placeholder="مثال: TD-A1B2-C3D4"
                                       class="w-full bg-[#091424] border border-slate-700 rounded-xl px-4 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-sm font-mono tracking-wider text-center sm:text-right"
                                       value="{{ old('single_device_id') }}">
                                <p class="text-[11px] text-slate-400 mt-1">تجد البصمة مكتوبة في شاشة التفعيل داخل التطبيق على الهاتف.</p>
                            </div>

                            <div>
                                <label for="role" class="block text-xs font-semibold text-slate-300 mb-1">
                                    صفة الجهاز في النادي <span class="text-rose-400">*</span>
                                </label>
                                <select name="role" id="role" class="w-full bg-[#091424] border border-slate-700 rounded-xl px-4 py-2.5 text-white focus:outline-none focus:border-blue-500 text-sm">
                                    <option value="MASTER_ADMIN">جهاز الإدارة الرئيسي (Master Admin) - إدارة كاملة وتقارير</option>
                                    <option value="FIELD_ATTENDANCE">جهاز الميدان (Field Attendance) - تحضير وترحيل فوري فقط</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Dual Mode Inputs -->
                    <div id="dual-section" class="space-y-4 mb-6 hidden">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label for="master_device_id" class="block text-xs font-semibold text-slate-300 mb-1">
                                    بصمة جهاز الإدارة (Master) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="master_device_id" id="master_device_id" placeholder="TD-1111-2222"
                                       class="w-full bg-[#091424] border border-slate-700 rounded-xl px-4 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-sm font-mono tracking-wider text-center sm:text-right">
                            </div>

                            <div>
                                <label for="field_device_id" class="block text-xs font-semibold text-slate-300 mb-1">
                                    بصمة جهاز الميدان (Field) <span class="text-rose-400">*</span>
                                </label>
                                <input type="text" name="field_device_id" id="field_device_id" placeholder="TD-3333-4444"
                                       class="w-full bg-[#091424] border border-slate-700 rounded-xl px-4 py-2.5 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 text-sm font-mono tracking-wider text-center sm:text-right">
                            </div>
                        </div>
                    </div>

                    <!-- Club and Season Config -->
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6 pt-4 border-t border-slate-800">
                        <div>
                            <label for="club_name" class="block text-xs font-semibold text-slate-300 mb-1">اسم النادي</label>
                            <input type="text" name="club_name" id="club_name" value="نادي تضامن حضرموت الرياضي"
                                   class="w-full bg-[#091424] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                        </div>

                        <div>
                            <label for="team_name" class="block text-xs font-semibold text-slate-300 mb-1">الفريق المعتمد</label>
                            <input type="text" name="team_name" id="team_name" value="الفريق الأول"
                                   class="w-full bg-[#091424] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                        </div>

                        <div>
                            <label for="validity_days" class="block text-xs font-semibold text-slate-300 mb-1">مدة الصلاحية (أيام)</label>
                            <input type="number" name="validity_days" id="validity_days" value="365"
                                   class="w-full bg-[#091424] border border-slate-700 rounded-xl px-3 py-2 text-white text-xs">
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit"
                            class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold py-3.5 px-6 rounded-xl transition duration-200 shadow-lg shadow-blue-600/30 flex items-center justify-center gap-2 text-base">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                        <span>توليد وتوقيع كود التفعيل الرقمي فوراً</span>
                    </button>
                </form>
            </div>
        </div>

        <!-- Generated Output Section -->
        @if(isset($results) && count($results) > 0)
            <div class="space-y-6">
                @if(isset($results['single']))
                    <div class="bg-[#112239] border border-blue-500/40 rounded-2xl p-6 shadow-xl relative overflow-hidden">
                        <div class="flex items-center justify-between mb-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center font-bold">
                                    🔑
                                </div>
                                <div>
                                    <h3 class="text-base font-bold text-white">كود تفعيل الجهاز المعتمد</h3>
                                    <p class="text-xs text-slate-400 font-mono">البصمة: {{ $results['single']['payload']['device_id'] }} • الصفة: {{ $results['single']['payload']['role'] }}</p>
                                </div>
                            </div>
                            <button onclick="copyCode('single_code_text')"
                                    class="bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold px-4 py-2 rounded-lg flex items-center gap-1.5 transition">
                                <span>نسخ الكود</span>
                            </button>
                        </div>

                        <div class="bg-[#081220] rounded-xl p-4 border border-slate-800">
                            <textarea id="single_code_text" readonly
                                      class="w-full bg-transparent text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-28 select-all"
                            >{{ $results['single']['code'] }}</textarea>
                        </div>
                    </div>
                @endif

                @if(isset($results['master']))
                    <div class="bg-[#112239] border border-blue-500/40 rounded-2xl p-6 shadow-xl">
                        <div class="flex items-center justify-between mb-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center font-bold">
                                    👑
                                </div>
                                <div>
                                    <h3 class="text-base font-bold text-white">كود جهاز الإدارة (Master Admin)</h3>
                                    <p class="text-xs text-slate-400 font-mono">البصمة: {{ $results['master']['payload']['device_id'] }}</p>
                                </div>
                            </div>
                            <button onclick="copyCode('master_code_text')"
                                    class="bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold px-4 py-2 rounded-lg flex items-center gap-1.5 transition">
                                <span>نسخ كود الإدارة</span>
                            </button>
                        </div>

                        <div class="bg-[#081220] rounded-xl p-4 border border-slate-800">
                            <textarea id="master_code_text" readonly
                                      class="w-full bg-transparent text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-24 select-all"
                            >{{ $results['master']['code'] }}</textarea>
                        </div>
                    </div>
                @endif

                @if(isset($results['field']))
                    <div class="bg-[#112239] border border-emerald-500/40 rounded-2xl p-6 shadow-xl">
                        <div class="flex items-center justify-between mb-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold">
                                    ⚽
                                </div>
                                <div>
                                    <h3 class="text-base font-bold text-white">كود جهاز الميدان (Field Attendance)</h3>
                                    <p class="text-xs text-slate-400 font-mono">البصمة: {{ $results['field']['payload']['device_id'] }}</p>
                                </div>
                            </div>
                            <button onclick="copyCode('field_code_text')"
                                    class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold px-4 py-2 rounded-lg flex items-center gap-1.5 transition">
                                <span>نسخ كود الميدان</span>
                            </button>
                        </div>

                        <div class="bg-[#081220] rounded-xl p-4 border border-slate-800">
                            <textarea id="field_code_text" readonly
                                      class="w-full bg-transparent text-slate-300 font-mono text-xs focus:outline-none resize-none leading-relaxed h-24 select-all"
                            >{{ $results['field']['code'] }}</textarea>
                        </div>
                    </div>
                @endif
            </div>
        @endif

        <!-- Quick Help Guide -->
        <div class="mt-12 bg-[#091526] rounded-2xl p-6 border border-slate-800 text-xs text-slate-400 leading-relaxed">
            <h4 class="text-sm font-bold text-white mb-2">تعليمات تفعيل التطبيق:</h4>
            <ol class="list-decimal list-inside space-y-1">
                <li>افتح تطبيق تحضير تضامن حضرموت على الهاتف المحمول.</li>
                <li>ستظهر شاشة التفعيل وتحتوي على «بصمة الجهاز العتادية» مثل: <code class="text-amber-400 font-mono font-bold">TD-XXXX-XXXX</code>.</li>
                <li>انسخ البصمة أو اكتبها في الحقل المخصص أعلاه، ثم اضغط على «توليد وتوقيع كود التفعيل».</li>
                <li>انسخ الكود الناتج والصقه في مربع كود التفعيل في التطبيق واضغط على زر «تفعيل الجهاز».</li>
                <li>يتم التحقق فورياً ومحلياً 100% دون الحاجة لأي إنترنت على الهاتف عبر المفتاح العام المدمج.</li>
            </ol>
        </div>
    </main>

    <!-- Footer -->
    <footer class="border-t border-slate-800 bg-[#081220] py-6 text-center text-xs text-slate-500">
        <p>نظام التحضير الميداني غير المتصل (MONAZ) • نادي تضامن حضرموت الرياضي • حضرموت، اليمن</p>
    </footer>

    <script>
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
                alert('تم نسخ كود التفعيل المشفر بنجاح إلى الحافظة!');
            });
        }
    </script>
</body>
</html>
