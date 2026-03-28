package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Appointment;
import com.tjetc.entity.User;
import com.tjetc.mapper.AppointmentMapper;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.AppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class AppointmentServiceImpl implements AppointmentService {
    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private UserMapper userMapper;

    private static final int MAX_APPOINTMENTS_PER_SLOT = 5; // 每个时间段最多预约5人

    @Override
    public JsonResult create(Appointment appointment) {
        User patient = userMapper.selectByIdCardAndUsername(appointment.getPatientIdCard(), appointment.getPatientName());
        if (patient == null) {
            return JsonResult.fail("患者信息不正确或不存在，请核对姓名和身份证号");
        }
        appointment.setPatientId(patient.getId());

        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("appointment_date", appointment.getAppointmentDate())
                .eq("start_time", appointment.getStartTime());
        long count = appointmentMapper.selectCount(queryWrapper);
        if (count >= MAX_APPOINTMENTS_PER_SLOT) {
            return JsonResult.fail("该时间段预约已满");
        }

        appointment.setSubmissionTime(LocalDateTime.now());
        appointment.setStatus("PENDING");
        appointmentMapper.insert(appointment);
        messagingTemplate.convertAndSend("/topic/checkin-list", "update");
        return JsonResult.success("预约成功", appointment);
    }

    @Override
    public JsonResult getAvailableSlots(LocalDate date, String type) {
        LocalTime start = LocalTime.of(9, 0);
        LocalTime end = LocalTime.of(17, 0);

        List<LocalTime> allSlots = Stream.iterate(start, t -> t.plusMinutes(30))
                .limit((end.toSecondOfDay() - start.toSecondOfDay()) / 1800)
                .collect(Collectors.toList());

        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("appointment_date", date);
        List<Appointment> existingAppointments = appointmentMapper.selectList(queryWrapper);

        List<LocalTime> availableSlots = allSlots.stream().filter(slot ->
                existingAppointments.stream().filter(a -> a.getStartTime().equals(slot)).count() < MAX_APPOINTMENTS_PER_SLOT
        ).collect(Collectors.toList());

        return JsonResult.success(availableSlots);
    }

    @Override
    public JsonResult checkIn(Long appointmentId) {
        Appointment appointment = appointmentMapper.selectById(appointmentId);
        if (appointment == null) {
            return JsonResult.fail("预约不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime appointmentTime = LocalDateTime.of(appointment.getAppointmentDate(), appointment.getStartTime());

        if (now.isBefore(appointmentTime.minusMinutes(10)) || now.isAfter(appointmentTime.plusMinutes(30))) {
            return JsonResult.fail("不在报道时间范围内");
        }

        appointment.setStatus("CHECKED_IN");
        appointment.setCheckInTime(now);
        appointmentMapper.updateById(appointment);

        if (!now.isBefore(appointmentTime)) {
            appointment.setStatus("IN_PROGRESS");
            appointmentMapper.updateById(appointment);
        }
        messagingTemplate.convertAndSend("/topic/checkin-list", "update");
        messagingTemplate.convertAndSend("/topic/waiting-list", "update");

        return JsonResult.success("报道成功");
    }

    @Override
    public JsonResult getCheckInList() {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "PENDING").or().eq("status", "CHECKED_IN");
        List<Appointment> list = appointmentMapper.selectList(queryWrapper);
        return JsonResult.success(list);
    }

    @Override
    public JsonResult getWaitingList() {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "IN_PROGRESS").orderByAsc("check_in_time");
        List<Appointment> list = appointmentMapper.selectList(queryWrapper);
        return JsonResult.success(list);
    }

    @Override
    public JsonResult cancel(Long id) {
        Appointment appointment = appointmentMapper.selectById(id);
        if(appointment != null){
            appointment.setStatus("CANCELED");
            appointmentMapper.updateById(appointment);
            messagingTemplate.convertAndSend("/topic/checkin-list", "update");
            return JsonResult.success("预约已取消");
        }
        return JsonResult.fail("预约不存在");
    }

    @Override
    public JsonResult complete(Long id) {
        Appointment appointment = appointmentMapper.selectById(id);
        if(appointment != null){
            appointment.setStatus("COMPLETED");
            appointmentMapper.updateById(appointment);
            messagingTemplate.convertAndSend("/topic/waiting-list", "update");
            messagingTemplate.convertAndSend("/topic/appointments", "update");
            return JsonResult.success("检查完成");
        }
        return JsonResult.fail("预约不存在");
    }

    @Override
    public JsonResult listByPatient(Long patientId) {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("patient_id", patientId)
                .orderByAsc("appointment_date", "start_time");
        List<Appointment> appointments = appointmentMapper.selectList(queryWrapper);
        return JsonResult.success(appointments);
    }

    @Override
    public JsonResult listAll() {
        QueryWrapper<Appointment> queryWrapper = new QueryWrapper<>();
        queryWrapper.orderByAsc("appointment_date", "start_time");
        List<Appointment> appointments = appointmentMapper.selectList(queryWrapper);
        return JsonResult.success(appointments);
    }
}