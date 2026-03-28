export class AppointmentModel {
  id: number;
  patientId: number;
  patientIdCard: string;
  patientName: string;
  appointmentType: string;
  appointmentContent: string;
  appointmentDate: string;
  startTime: string;
  submissionTime: string;
  checkInTime: string;
  status: string;

  constructor(
    id: number = 0,
    patientId: number = 0,
    patientIdCard: string = '',
    patientName: string = '',
    appointmentType: string = '',
    appointmentContent: string = '',
    appointmentDate: string = '',
    startTime: string = '',
    submissionTime: string = '',
    checkInTime: string = '',
    status: string = ''
  ) {
    this.id = id;
    this.patientId = patientId;
    this.patientIdCard = patientIdCard;
    this.patientName = patientName;
    this.appointmentType = appointmentType;
    this.appointmentContent = appointmentContent;
    this.appointmentDate = appointmentDate;
    this.startTime = startTime;
    this.submissionTime = submissionTime;
    this.checkInTime = checkInTime;
    this.status = status;
  }
}