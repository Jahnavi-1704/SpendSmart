import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'overview.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List notifications = List.empty(growable: true);
  List pastNotifications = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
                Text('Notifications', style: TextStyle(fontSize: 25)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 520,
            color: Colors.white,
            child: pastNotifications.isEmpty ?
            Center(child: Text('You have no pending notifications to read'))
            :
            ListView.builder(
              itemCount: pastNotifications.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: Card(
                    elevation: 15,
                    color: Colors.grey.shade200,
                    child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text('${pastNotifications[index]['title']}', style: TextStyle(fontSize: 20)),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text('${pastNotifications[index]['body']}', style: TextStyle(fontSize: 16)),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            // TODO: on close button, delete this notification from fireStore

                            FirebaseAuth auth = FirebaseAuth.instance;
                            String uid = auth.currentUser!.uid.toString();
                            final doc = FirebaseFirestore.instance.collection('user_data').doc(uid);

                            var tempList = pastNotifications;
                            tempList.removeAt(index);

                            doc.update({
                              'notifications': tempList,
                            });
                          },
                          icon: Icon(Icons.close, size: 25),
                        ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  Future fetchDB() async {
    // fetch user profile parameters by passing user's auth_id
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      notifications = snapshot.data()!['notifications'];
    });

    // filter out this array to show only past notifications
    List tempList = snapshot.data()!['notifications'];
    List newList = List.empty(growable: true);
    for(var notification in tempList) {
      if((notification['date']).toDate().isBefore(DateTime.now()))
      {
        newList.add(notification);
      }
    }

    setState(() {
      pastNotifications = newList;
    });

  }


}
