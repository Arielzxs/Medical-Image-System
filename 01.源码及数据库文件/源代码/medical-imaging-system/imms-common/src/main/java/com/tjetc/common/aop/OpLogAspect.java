package com.tjetc.common.aop;

import com.tjetc.common.security.JwtTokenUtil;
import com.tjetc.entity.OperationLog;
import com.tjetc.mapper.OperationLogMapper;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.lang.reflect.Method;
import java.time.LocalDateTime;

@Aspect
@Component
public class OpLogAspect {
    @Autowired
    private OperationLogMapper operationLogMapper;

    //定义切入点，匹配所有被@OpLog注解标记的方法
    @Pointcut("@annotation(com.tjetc.common.aop.OpLog)")
    public void opLogPt() {
    }

    //使用@Around注解声明环绕通知，在目标方法执行前后执行自定义逻辑
    @Around("opLogPt()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        // 保存日志
        OperationLog opLog = new OperationLog();
        // 获取当前请求
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        //获取请求的详细信息
        HttpServletRequest request = attributes.getRequest();
        // 获取token
        String token = request.getHeader("token");
        if (token != null) {
            Claims claims = JwtTokenUtil.parseJwt(token);
            Long userId = claims.get("id", Long.class);
            opLog.setUserId(userId);
        }
        // 获取操作信息（通过反射获取被拦截方法的注解信息，获取@OpLog注解中的信息）
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        OpLog opLogAnnotation = method.getAnnotation(OpLog.class);
        if (opLogAnnotation != null) {
            opLog.setOperation(opLogAnnotation.value());
        }
        // 获取IP地址
        opLog.setIpAddress(request.getRemoteAddr());
        opLog.setCreatedAt(LocalDateTime.now());
        operationLogMapper.insert(opLog);

        return joinPoint.proceed();
    }
}