import { createBrowserRouter } from 'react-router-dom';
import App from './App';
import Dashboard from './pages/Dashboard';
import Placeholder from './pages/Placeholder';

// 메뉴 사이트맵 (설계서 §D.1) — 스텁 라우팅
export const router = createBrowserRouter([
  {
    path: '/',
    element: <App />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: 'schedule', element: <Placeholder title="WBS/일정·진척" /> },
      { path: 'requirements', element: <Placeholder title="요구사항·베이스라인" /> },
      { path: 'kanban', element: <Placeholder title="진척(칸반)" /> },
      { path: 'test', element: <Placeholder title="테스트/결함" /> },
      { path: 'quality', element: <Placeholder title="품질/산출물 결재" /> },
      { path: 'reports', element: <Placeholder title="의사소통/보고" /> }
    ]
  }
]);
