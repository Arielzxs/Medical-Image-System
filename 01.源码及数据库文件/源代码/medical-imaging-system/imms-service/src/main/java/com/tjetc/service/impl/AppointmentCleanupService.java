package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.entity.Appointment;
import com.tjetc.mapper.AppointmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AppointmentCleanupService {

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Scheduled(fixedRate = 60000) // 每分钟执行一次
    public void cleanupExpiredAppointments() {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "PENDING")
                .le("appointment_date", LocalDateTime.now().toLocalDate())
                .le("start_time", LocalDateTime.now().toLocalTime().minusMinutes(30));

        List<Appointment> expiredAppointments = appointmentMapper.selectList(queryWrapper);
        for (Appointment appointment : expiredAppointments) {
            appointment.setStatus("EXPIRED");
            appointmentMapper.updateById(appointment);
        }
        if(!expiredAppointments.isEmpty()){
            messagingTemplate.convertAndSend("/topic/checkin-list", "update");
        }
    }

    @Scheduled(fixedRate = 60000) // 每分钟执行一次
    public void updateWaitingList() {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "CHECKED_IN")
                .le("appointment_date", LocalDateTime.now().toLocalDate())
                .le("start_time", LocalDateTime.now().toLocalTime());

        List<Appointment> appointmentsToUpdate = appointmentMapper.selectList(queryWrapper);
        for (Appointment appointment : appointmentsToUpdate) {
            appointment.setStatus("IN_PROGRESS");
            appointmentMapper.updateById(appointment);
        }
        if(!appointmentsToUpdate.isEmpty()){
            messagingTemplate.convertAndSend("/topic/waiting-list", "update");
        }
    }
}