import React, { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import UserManagement from './components/UserManagement';
import SubscriptionBuilder from './components/SubscriptionBuilder';

// قائمة الأقسام الرئيسية في لوحة التحكم
enum View {
  DASHBOARD,
  USERS,
  SUBSCRIPTIONS,
  NOTIFICATIONS,
  SETTINGS,
}

const App: React.FC = () => {
  const [session, setSession] = useState<any | null>(null);
  const [currentView, setCurrentView] = useState<View>(View.DASHBOARD);
  const [isAdmin, setIsAdmin] = useState<boolean>(false);

  useEffect(() => {
    // التحقق من الجلسة عند تحميل التطبيق
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) {
        // التحقق من صلاحية المالك (Super Admin)
        checkAdminStatus(session.user.id);
      }
    });

    // الاستماع لتغييرات حالة المصادقة
    const { data: authListener } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session);
        if (session) {
          checkAdminStatus(session.user.id);
        } else {
          setIsAdmin(false);
        }
      }
    );

    return () => {
      authListener?.unsubscribe();
    };
  }, []);

  const checkAdminStatus = async (userId: string) => {
    // يجب أن تكون هذه الوظيفة أكثر تعقيداً في بيئة الإنتاج
    // للتحقق من جدول 'admins' أو 'owner'
    // حالياً، سنفترض أن مالك التطبيق هو المستخدم ذو الـ ID الثابت
    // (هذا يجب تغييره في الإنتاج ليكون أكثر أماناً)
    const ownerId = process.env.REACT_APP_OWNER_ID; 

    if (userId === ownerId) {
        setIsAdmin(true);
    } else {
        // في حالة عدم تطابق، يتم تسجيل الخروج تلقائياً لضمان الأمان
        await supabase.auth.signOut();
        setIsAdmin(false);
    }
  };

  if (!session) {
    return <Login />;
  }

  if (!isAdmin) {
    return (
      <div className="flex items-center justify-center h-screen bg-gray-100">
        <p className="text-red-600 font-bold">غير مصرح لك بالوصول إلى لوحة التحكم هذه.</p>
      </div>
    );
  }

  // لوحة تحكم المالك (Super Admin Dashboard)
  const renderContent = () => {
    switch (currentView) {
      case View.DASHBOARD:
        return <Dashboard />;
      case View.USERS:
        return <UserManagement />;
      case View.SUBSCRIPTIONS:
        return <SubscriptionBuilder />;
      case View.NOTIFICATIONS:
        // سيتم إضافة مكون الإشعارات لاحقاً
        return <div>إدارة الإشعارات العامة</div>;
      case View.SETTINGS:
        // سيتم إضافة مكون الإعدادات لاحقاً
        return <div>الإعدادات العامة للمنصة</div>;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* شريط التنقل الجانبي */}
      <nav className="w-64 bg-white shadow-xl p-4 flex flex-col justify-between">
        <div>
          <h1 className="text-2xl font-bold text-indigo-600 mb-8">لوحة تحكم المالك</h1>
          <ul className="space-y-2">
            <li onClick={() => setCurrentView(View.DASHBOARD)} className={\`cursor-pointer p-2 rounded-lg \${currentView === View.DASHBOARD ? 'bg-indigo-100 text-indigo-700 font-semibold' : 'hover:bg-gray-100'}\`}>الرئيسية</li>
            <li onClick={() => setCurrentView(View.USERS)} className={\`cursor-pointer p-2 rounded-lg \${currentView === View.USERS ? 'bg-indigo-100 text-indigo-700 font-semibold' : 'hover:bg-gray-100'}\`}>إدارة المعلمين</li>
            <li onClick={() => setCurrentView(View.SUBSCRIPTIONS)} className={\`cursor-pointer p-2 rounded-lg \${currentView === View.SUBSCRIPTIONS ? 'bg-indigo-100 text-indigo-700 font-semibold' : 'hover:bg-gray-100'}\`}>نظام الاشتراكات</li>
            <li onClick={() => setCurrentView(View.NOTIFICATIONS)} className={\`cursor-pointer p-2 rounded-lg \${currentView === View.NOTIFICATIONS ? 'bg-indigo-100 text-indigo-700 font-semibold' : 'hover:bg-gray-100'}\`}>الإشعارات العامة</li>
            <li onClick={() => setCurrentView(View.SETTINGS)} className={\`cursor-pointer p-2 rounded-lg \${currentView === View.SETTINGS ? 'bg-indigo-100 text-indigo-700 font-semibold' : 'hover:bg-gray-100'}\`}>الإعدادات</li>
          </ul>
        </div>
        <button onClick={() => supabase.auth.signOut()} className="w-full bg-red-500 text-white p-2 rounded-lg hover:bg-red-600 transition duration-150">تسجيل الخروج</button>
      </nav>

      {/* محتوى الصفحة */}
      <main className="flex-1 p-8 overflow-y-auto">
        {renderContent()}
      </main>
    </div>
  );
};

export default App;
