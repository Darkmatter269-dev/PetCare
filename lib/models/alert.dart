import 'package:hive/hive.dart';

// Manual Hive TypeAdapter to avoid requiring code generation.
class Alert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool read;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
  });
}

class AlertAdapter extends TypeAdapter<Alert> {
  @override
  final int typeId = 1;

  @override
  Alert read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final message = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final readFlag = reader.readBool();
    return Alert(id: id, title: title, message: message, timestamp: timestamp, read: readFlag);
  }

  @override
  void write(BinaryWriter writer, Alert obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.message);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.read);
  }
}
