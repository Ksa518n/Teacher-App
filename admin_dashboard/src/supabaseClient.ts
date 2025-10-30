import { createClient } from '@supabase/supabase-js';

// يجب استبدال هذه المتغيرات بمتغيرات البيئة في الإنتاج
// لاستخدام هذا التطبيق، يجب عليك استبدال هذه القيم بقيم مشروعك الفعلي في Supabase
const supabaseUrl = 'https://fjutnlhglyilrwlzodhq.supabase.co'; 
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqdXRubGhnbHlpbHJ3bHpvZGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NTc2NDMsImV4cCI6MjA3NzMzMzY0M30.FdWoTSYGLRxPbu2onKMCsne_mJ9RYvciaXOpgLbyqO8';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
