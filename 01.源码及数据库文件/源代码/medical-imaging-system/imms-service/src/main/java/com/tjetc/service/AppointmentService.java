package com.tjetc.service;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Appointment;

import java.time.LocalDate;

public interface AppointmentService {
    JsonResult create(Appointment appointment);
    JsonResult getAvailableSlots(LocalDate date, String type);
    JsonResult checkIn(Long appointmentId);
    JsonResult getCheckInList();
    JsonResult getWaitingList();
    JsonResult cancel(Long id);
    JsonResult complete(Long id);
    JsonResult listByPatient(Long patientId);
    JsonResult listAll();
}