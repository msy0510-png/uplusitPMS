package kr.co.uplusit.pms.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

/** RBAC/JWT 기반 보안 (REQ-SEC-01). 스텁: 골격 단계에서는 개방, Claude Code에서 JWT 필터·인가 구현. */
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(reg -> reg.anyRequest().permitAll()); // TODO: 인가 규칙
        return http.build();
    }
}
