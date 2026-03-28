package com.tjetc.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.common.security.JwtAuthenticationTokenFilter;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.PrintWriter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationTokenFilter jwtAuthenticationTokenFilter; // 注入创建的JWT过滤器

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 关闭CSRF保护
                .csrf(AbstractHttpConfigurer::disable)

                // 设置会话管理策略为STATELESS（无状态），因为使用JWT，服务器不需要维护session
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 配置HTTP请求的授权规则
                .authorizeHttpRequests(auth -> auth
                        // 允许所有对白名单路径的请求
                        .requestMatchers("/ws/**", "/auth/**", "/captcha/**", "/error", "/image/**").permitAll()
                        // 为不同角色精细化配置预约管理权限
                        .requestMatchers("/appointment/create", "/appointment/cancel/**", "/appointment/list/patient/**", "/appointment/available-slots").hasAnyAuthority("patient", "admin", "doctor", "expert")
                        .requestMatchers("/appointment/complete/**", "/appointment/list/all", "/appointment/staff").hasAnyAuthority("doctor", "expert", "admin")
                        // 明确需要登录才能访问的通用页面
                        .requestMatchers("/home", "/user/profile", "/messages/**", "/app/**", "/ai/**").authenticated()

                        // 管理员权限
                        .requestMatchers("/admin/**", "/log/**").hasAuthority("admin")

                        // 医生和专家权限
                        .requestMatchers("/report/create", "/report/update", "/report/delete/**", "/report/query").hasAnyAuthority("doctor", "expert", "admin")

                        // 除了以上规则，其他所有未匹配的请求都必须经过认证
                        .anyRequest().authenticated()
                )

                // 将JWT过滤器添加到Spring Security的过滤器链中
                // 会在标准的用户名密码认证过滤器之前执行
                .addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
    @Bean
    public AuthenticationEntryPoint authenticationEntryPoint() {
        return (request, response, authException) -> {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter writer = response.getWriter();
            writer.write(new ObjectMapper().writeValueAsString(JsonResult.fail(-1, "登录过期，请重新登录")));
            writer.flush();
            writer.close();
        };
    }

    @Bean
    public AccessDeniedHandler accessDeniedHandler() {
        return (request, response, accessDeniedException) -> {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter writer = response.getWriter();
            writer.write(new ObjectMapper().writeValueAsString(JsonResult.fail(403, "权限不足，请联系管理员")));
            writer.flush();
            writer.close();
        };
    }
}