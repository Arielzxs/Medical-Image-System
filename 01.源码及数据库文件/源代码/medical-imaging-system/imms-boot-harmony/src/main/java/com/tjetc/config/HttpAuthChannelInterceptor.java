package com.tjetc.config;

import com.tjetc.common.security.JwtTokenUtil;
import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

//拦截器，在连接之前进行token验证
@Slf4j
@Component
public class HttpAuthChannelInterceptor implements ChannelInterceptor {
    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        // 判断是否为连接命令，如果是，则进行认证
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            // 从消息头中获取 token
            String token = accessor.getFirstNativeHeader("token");

            // 验证 token
            if (StringUtils.hasText(token)) {
                try {
                    // 使用 JwtTokenUtil 解析 token
                    Claims claims = JwtTokenUtil.parseJwt(token);
                    if (claims != null) {
                        // 如果 token 有效，可以进行后续操作，例如记录日志
                        log.info("WebSocket user connected successfully with token: {}", token);
                    } else {
                        // Token 无效
                        log.warn("WebSocket connection failed due to invalid token.");
                        return null; // 返回 null 会阻止消息继续发送，即拒绝连接
                    }
                } catch (Exception e) {
                    log.error("WebSocket token parsing error.", e);
                    return null; // 解析异常，拒绝连接
                }
            } else {
                log.warn("WebSocket connection attempt without a token.");
                return null; // 没有 token，拒绝连接
            }
        }
        // 如果不是连接命令（例如发送消息），则直接放行
        return message;
    }
}
