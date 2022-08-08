class QIBusBookingModel {
  var destination;
  var duration;
  var startTime;
  var totalTime;
  var endTime;
  var seatNo;
  var passengerName;
  var ticketNo;
  var pnrNo;
  var status;
  var totalFare;
  var img;

  QIBusBookingModel(this.destination, this.duration);

  QIBusBookingModel.booking(
      this.destination,
      this.duration,
      this.startTime,
      this.totalTime,
      this.endTime,
      this.seatNo,
      this.passengerName,
      this.ticketNo,
      this.pnrNo,
      this.status,
      this.totalFare,
      this.img);
}
