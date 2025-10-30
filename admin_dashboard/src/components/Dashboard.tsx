import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState({
    totalTeachers: 0,
    activeTeachers: 0,
    totalClasses: 0,
    totalStudents: 0,
    dailyOperations: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    setLoading(true);
    try {
      // 1. إجمالي المعلمين (المستخدمين)
      // ملاحظة: في Supabase، يتم الوصول إلى بيانات المستخدمين عبر auth.users
      // لكن للحصول على العدد الإجمالي، سنعتمد على جدول public.teachers الذي أنشأناه
      const { count: teachersCount, error: teachersError } = await supabase
        .from('teachers')
        .select('*', { count: 'exact', head: true });

      if (teachersError) throw teachersError;

      // 2. إجمالي الفصول
      const { count: classesCount, error: classesError } = await supabase
        .from('classes')
        .select('*', { count: 'exact', head: true });

      if (classesError) throw classesError;

      // 3. إجمالي الطلاب
      const { count: studentsCount, error: studentsError } = await supabase
        .from('students')
        .select('*', { count: 'exact', head: true });

      if (studentsError) throw studentsError;

      // 4. العمليات اليومية (مثال: عدد سجلات الأداء اليوم)
      const today = new Date().toISOString().split('T')[0];
      const { count: operationsCount, error: operationsError } = await supabase
        .from('performance_log')
        .select('*', { count: 'exact', head: true })
        .eq('log_date', today);

      if (operationsError) throw operationsError;

      setStats({
        totalTeachers: teachersCount || 0,
        activeTeachers: 0, // تتطلب منطقاً أكثر تعقيداً (آخر تسجيل دخول)
        totalClasses: classesCount || 0,
        totalStudents: studentsCount || 0,
        dailyOperations: operationsCount || 0,
      });

    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const StatCard: React.FC<{ title: string, value: number | string, icon: string }> = ({ title, value, icon }) => (
    <div className="bg-white p-6 rounded-xl shadow-lg flex items-center space-x-4">
      <div className="text-4xl text-indigo-500">{icon}</div>
      <div>
        <p className="text-sm font-medium text-gray-500">{title}</p>
        <p className="text-3xl font-bold text-gray-900">{value}</p>
      </div>
    </div>
  );

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold text-gray-800">نظرة عامة على المنصة</h1>

      {loading ? (
        <div className="text-center text-indigo-500">جاري تحميل الإحصائيات...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard title="إجمالي المعلمين" value={stats.totalTeachers} icon="🧑‍🏫" />
          <StatCard title="إجمالي الفصول" value={stats.totalClasses} icon="📚" />
          <StatCard title="إجمالي الطلاب" value={stats.totalStudents} icon="🧑‍🎓" />
          <StatCard title="عمليات اليوم" value={stats.dailyOperations} icon="⚡" />
        </div>
      )}

      {/* قسم الرسوم البيانية (سيتم تطويره لاحقاً) */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-lg">
          <h2 className="text-xl font-semibold mb-4">نمو المستخدمين (آخر 6 أشهر)</h2>
          <div className="h-64 flex items-center justify-center text-gray-400">
            (مخطط بياني سيتم إضافته هنا)
          </div>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-lg">
          <h2 className="text-xl font-semibold mb-4">أعلى 5 فصول نشاطاً</h2>
          <div className="h-64 flex items-center justify-center text-gray-400">
            (مخطط شريطي سيتم إضافته هنا)
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
