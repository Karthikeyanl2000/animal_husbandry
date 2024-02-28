import 'package:animal_husbandry/app/bovine.dart';
import 'package:hyper_object_box/model/payment.dart';
import 'package:hyper_object_box/objectbox.g.dart';

class PaymentBox {

  final paymentBox = objectBox.store.box<Payment>();
  int create(Map<String, Object?> values) {
    Payment payment = Payment.fromJson(values);
    try {
      if (payment.id == 0) return paymentBox.put(payment);
      Payment oldId = readByName(payment.id!);
      payment.id = oldId.id;
      return paymentBox.put(payment, mode: PutMode.update);
    }
    catch (e) {
      return paymentBox.put(payment);
    }
  }

  Payment readByName(int id) {
    Query<Payment> query = paymentBox.query(Payment_.id.equals(id)).build();
    Payment? payment = query.findFirst();
    query.close();
    if (payment != null) {
      return payment;
    } else {
      throw Exception('Name $id not found');
    }
  }


  bool delete(int userId) {
    Payment payment;
    try {
      payment = readByName(userId);
      return paymentBox.remove(payment.id);
    } catch (e)
    {
      return false;
    }
  }


  int deleteAll()
  {
    return paymentBox.removeAll();
  }

  List<Payment> list() {
    return paymentBox.getAll();
  }

  int import(Map<String, Object?> values) {
    Payment payment = Payment.fromJson(values);
    try {
      Payment? oldPayment = readByImportName(payment.paymentId!);
      if (oldPayment != null) {
        payment.paymentId = oldPayment.paymentId;
        paymentBox.put(payment, mode: PutMode.update);
      } else {
        payment.id = 0;
        return paymentBox.put(payment);
      }
    } catch (e) {
      print("Exception to Import Payment ==> ${e.toString()}");
      return -1; // Return an error code or handle the error as needed.
    }
    return -1; // Or another suitable default value.
  }

  Payment? readByImportName(String paymentId) {
    Query<Payment> query =
    paymentBox.query(Payment_.paymentId.equals(paymentId)).build();
    Payment? payment = query.findFirst();
    query.close();
    return payment; // Return null if not found.
  }
}

