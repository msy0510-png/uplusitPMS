import { useQuery } from '@tanstack/react-query';
import { api, ApiResponse } from '../api/client';

// S-01 대시보드 (UC-DSH-01) — 스텁: 위젯 자리만 구성
export default function Dashboard() {
  const pid = 1;
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard', pid],
    queryFn: async () => {
      const res = await api.get<ApiResponse<Record<string, unknown>>>(`/projects/${pid}/dashboard`);
      return res.data.data;
    }
  });
  if (isLoading) return <p>로딩 중…</p>;
  return (
    <section>
      <h2>대시보드</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 12 }}>
        {['WBS 달성률', '품질 달성도', '이슈/결함 처리율', '오늘의 작업'].map((t) => (
          <div key={t} style={{ border: '1px solid #e5e7eb', borderRadius: 8, padding: 16 }}>
            <strong>{t}</strong>
            <p style={{ color: '#6b7280' }}>위젯 자리 (API 연동 예정)</p>
          </div>
        ))}
      </div>
      <pre style={{ color: '#9ca3af' }}>{JSON.stringify(data, null, 2)}</pre>
    </section>
  );
}
