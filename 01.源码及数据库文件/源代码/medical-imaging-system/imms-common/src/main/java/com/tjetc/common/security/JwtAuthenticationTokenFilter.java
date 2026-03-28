package com.tjetc.common.security;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

@Slf4j
@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String token = request.getHeader("token");
        if (StringUtils.hasText(token)) {
            try {
                Claims claims = JwtTokenUtil.parseJwt(token);
                if (claims != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    String username = claims.get("username", String.class);
                    String role = claims.get("role", String.class); // 从 claims 中获取 role

                    if (username != null && role != null) {
                        // 创建一个包含用户权限的 Authentication 对象
                        UsernamePasswordAuthenticationToken authentication =
                                new UsernamePasswordAuthenticationToken(
                                        username,
                                        null,
                                        Collections.singletonList(new SimpleGrantedAuthority(role)) // 将 role 作为权限
                                );

                        // 将 Authentication 对象设置到 SecurityContext 中
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                        log.debug("Authenticated user '{}' with role '{}', setting security context", username, role);
                    }
                }
            } catch (Exception e) {
                log.error("Could not set user authentication in security context", e);
            }
        }
        // 继续执行过滤器链中的下一个过滤器
        filterChain.doFilter(request, response);
    }
}