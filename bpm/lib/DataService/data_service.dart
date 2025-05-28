
import 'package:firebase_database/firebase_database.dart';

class Dataservice {
  
  Future<int> bpm() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("BPM");

    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snap = event.snapshot;

      if (snap.value != null) {
        return snap.value as int;
      } else {
        return 0; // O cualquier valor predeterminado
      }
    } catch (e) {
      return 0; // O maneja el error según sea necesario
    }
  }
}

