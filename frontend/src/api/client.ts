import axios from 'axios';

// 표준 응답 래퍼 (설계서 §C.1)
export interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  page?: { page: number; size: number; total: number } | null;
  error?: { code: string; message: string } | null;
}

export const api = axios.create({ baseURL: '/api/v1' });

// JWT 토큰 주입 (Claude Code 단계에서 인증 연동)
api.interceptors.request.use((cfg) => {
  const token = localStorage.getItem('accessToken'); // 골격: 위치만 표시
  if (token) cfg.headers.Authorization = `Bearer ${token}`;
  return cfg;
});
