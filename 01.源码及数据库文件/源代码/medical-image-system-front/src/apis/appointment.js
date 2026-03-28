import request from "@/utils/request";

export const createAppointment = (data) => {
  return request({
    url: "/api/appointment/create",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

export const getAvailableSlots = (params) => {
  return request({
    url: "/api/appointment/available-slots",
    method: "get",
    params,
  });
};

export const checkIn = (id) => {
  return request({
    url: `/api/appointment/check-in/${id}`,
    method: "post",
  });
};

export const getCheckInList = () => {
  return request({
    url: "/api/appointment/check-in-list",
    method: "get",
  });
};

export const getWaitingList = () => {
  return request({
    url: "/api/appointment/waiting-list",
    method: "get",
  });
};

export const cancelAppointment = (id) => {
  return request({
    url: `/api/appointment/cancel/${id}`,
    method: "get",
  });
};

export const completeAppointment = (id) => {
  return request({
    url: `/api/appointment/complete/${id}`,
    method: "get",
  });
};

export const getPatientAppointments = (patientId) => {
  return request({
    url: `/api/appointment/list/patient/${patientId}`,
    method: "get",
  });
};

export const getAllAppointments = () => {
  return request({
    url: "/api/appointment/list/all",
    method: "get",
  });
};
