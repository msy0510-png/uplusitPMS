export default function Placeholder({ title }: { title: string }) {
  return (
    <section>
      <h2>{title}</h2>
      <p style={{ color: '#6b7280' }}>화면 골격(스텁). 설계서 §D 기준으로 Claude Code에서 구현.</p>
    </section>
  );
}
