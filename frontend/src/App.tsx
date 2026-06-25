import { Link, Outlet } from 'react-router-dom';

const MENU = [
  ['/', '대시보드'], ['/schedule', '사업관리'], ['/requirements', '요구사항'],
  ['/kanban', '진척'], ['/test', '테스트'], ['/quality', '품질'], ['/reports', '보고']
];

export default function App() {
  return (
    <div style={{ display: 'flex', minHeight: '100vh', fontFamily: 'system-ui' }}>
      <nav style={{ width: 180, borderRight: '1px solid #e5e7eb', padding: 16 }}>
        <h3>uplusitPMS</h3>
        <ul style={{ listStyle: 'none', padding: 0, lineHeight: 2 }}>
          {MENU.map(([to, label]) => (
            <li key={to}><Link to={to}>{label}</Link></li>
          ))}
        </ul>
      </nav>
      <main style={{ flex: 1, padding: 24 }}><Outlet /></main>
    </div>
  );
}
