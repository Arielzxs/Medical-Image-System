package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Appointment;
import com.tjetc.service.AppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/appointment")
public class AppointmentController {
    @Autowired
    private AppointmentService appointmentService;

    @PostMapping("/create")
    public JsonResult create(@RequestBody Appointment appointment) {
        return appointmentService.create(appointment);
    }

    @GetMapping("/available-slots")
    public JsonResult getAvailableSlots(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date, @RequestParam String type) {
        return appointmentService.getAvailableSlots(date, type);
    }

    @PostMapping("/check-in/{id}")
    public JsonResult checkIn(@PathVariable Long id) {
        return appointmentService.checkIn(id);
    }

    @GetMapping("/check-in-list")
    public JsonResult getCheckInList() {
        return appointmentService.getCheckInList();
    }

    @GetMapping("/waiting-list")
    public JsonResult getWaitingList() {
        return appointmentService.getWaitingList();
    }

    @GetMapping("/cancel/{id}")
    public JsonResult cancel(@PathVariable Long id) {
        return appointmentService.cancel(id);
    }

    @GetMapping("/complete/{id}")
    public JsonResult complete(@PathVariable Long id) {
        return appointmentService.complete(id);
    }

    @GetMapping("/list/patient/{patientId}")
    public JsonResult listByPatient(@PathVariable Long patientId) {
        return appointmentService.listByPatient(patientId);
    }

    @GetMapping("/list/all")
    public JsonResult listAll() {
        return appointmentService.listAll();
    }
}